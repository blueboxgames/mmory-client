package com.gerantech.towercraft.controls.segments
{
import com.gerantech.extensions.NativeAbilities;
import com.gerantech.extensions.events.AndroidEvent;
import com.gerantech.mmory.core.constants.MessageTypes;
import com.gerantech.towercraft.controls.buttons.MMOryButton;
import com.gerantech.towercraft.controls.items.EmoteItemRenderer;
import com.gerantech.towercraft.controls.items.lobby.LobbyChatItemRenderer;
import com.gerantech.towercraft.controls.popups.ConfirmPopup;
import com.gerantech.towercraft.controls.popups.ProfilePopup;
import com.gerantech.towercraft.controls.popups.SimpleListPopup;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.controls.toasts.EmoteToast;
import com.gerantech.towercraft.managers.net.sfs.LobbyManager;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.models.vo.UserData;
import com.gerantech.towercraft.themes.MainTheme;
import com.gerantech.towercraft.utils.StrUtils;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSObject;

import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

import starling.core.Starling;
import starling.events.Event;
import com.gerantech.mmory.core.constants.ResourceType;

public class LobbyBaseChatSegment extends ChatSegment
{
private var preText:String = "";
protected var emotesButton:MMOryButton;
public function LobbyBaseChatSegment(){ super(); }
public function get manager():LobbyManager
{
	if( SFSConnection.instance.publicLobbyManager == null )
		SFSConnection.instance.publicLobbyManager = new LobbyManager(true);
	return SFSConnection.instance.publicLobbyManager;
}

override protected function animation_loadCallback():void
{
	super.animation_loadCallback();
	loadData();
}

override public function init():void
{
	if( initializeStarted )
		return;
	
	super.init();
	layout = new AnchorLayout();

	if( player.getResource(ResourceType.R7_MAX_POINT) < 300 )
	{
		var descDisplay:ShadowLabel = new ShadowLabel(loc("availableuntil_messeage", [loc("resource_title_2") + " " + 300, " "]), 1, 0, "center");
		descDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, 0);
		descDisplay.width = stageWidth - 200;
		addChild(descDisplay);
		return;
	}
	

	loadData();
}

protected function loadData():void
{
	var imei:String = appModel.platform == AppModel.PLATFORM_ANDROID ? NativeAbilities.instance.deviceInfo.imei : "";
	if( appModel.platform == AppModel.PLATFORM_ANDROID && imei == "" )
	{
		var confirm:ConfirmPopup = new ConfirmPopup(loc("lobby_imei_confirm"));
		confirm.addEventListener(Event.SELECT, confirm_selectHandler);
		confirm.addEventListener(Event.CANCEL, confirm_canceltHandler);
		appModel.navigator.addPopup(confirm);
		function confirm_selectHandler(event:Event):void{
			NativeAbilities.instance.addEventListener(AndroidEvent.PERMISSION_REQUEST, nativeAbilities_requestPermissionHandler);
			NativeAbilities.instance.requestPermission("android.permission.READ_PHONE_STATE", 1312);
		}
		function confirm_canceltHandler(event:Event):void{
			dispatchEventWith(Event.UPDATE, true, null);
		}
		return;
	}

	if( isBan() )
		return;
	
	if( manager == null || !initializeStarted || initializeCompleted || EmoteItemRenderer.factory == null )
		return;
	
	if( manager.isReady )
	{
		showElements();
		return;
	}
	
	manager.addEventListener(Event.READY, manager_readyHandler);
	manager.joinToPublic(imei);
}

private function nativeAbilities_requestPermissionHandler(event:AndroidEvent):void
{
	NativeAbilities.instance.removeEventListener(AndroidEvent.PERMISSION_REQUEST , nativeAbilities_requestPermissionHandler);
	if( String(event.data).search("READ_PHONE_STATE") == -1 )
		return;
	loadData();
}

protected function manager_readyHandler(event:Event) : void
{
	manager.removeEventListener(Event.READY, manager_readyHandler);
	if( isBan() )
		return;
	showElements();
}

override protected function showElements() : void
{
	super.showElements();

	emotesButton = new MMOryButton();
	emotesButton.width = emotesButton.height = footerSize;
	emotesButton.styleName = MainTheme.STYLE_BUTTON_SMALL_NEUTRAL;
	emotesButton.iconTexture = appModel.assets.getTexture("socials/icon-emote");
	emotesButton.addEventListener(Event.TRIGGERED, emotesButton_triggeredHandler);
	emotesButton.layoutData = new AnchorLayoutData(NaN, padding * 2 + footerSize, padding, NaN);
	addChild(emotesButton);
	
	chatList.dataProvider = manager.messages;
	manager.addEventListener(Event.UPDATE, manager_updateHandler);
}

override protected function chatList_changeHandler(event:Event) : void
{
	if( chatList.selectedItem == null )
		return;
	var msgPack:ISFSObject = chatList.selectedItem as SFSObject;
	if( msgPack.getInt("m") == MessageTypes.M30_FRIENDLY_BATTLE  )
	{
		var myBattleId:int = manager.getMyRequestBattleId();
		if( myBattleId > -1 && msgPack.getInt("bid") != myBattleId )
			return;
		
		if( msgPack.getInt("st") > 1 )
			return;
		
		var params:SFSObject = new SFSObject();
		params.putInt("m", MessageTypes.M30_FRIENDLY_BATTLE);
		params.putInt("bid", msgPack.getInt("bid"));
		params.putInt("st", msgPack.getInt("st"));
		SFSConnection.instance.sendExtensionRequest(SFSCommands.LOBBY_PUBLIC_MESSAGE, params, manager.lobby );
	}
}

override protected function scrollToEnd():void
{
    chatList.scrollToDisplayIndex(Math.max(0, manager.messages.length - 1));
    autoScroll = true;
}

override protected function chatList_focusInHandler(event:Event):void
{
    if( !_buttonsEnabled )
        return;
	var selectedItem:LobbyChatItemRenderer = event.data as LobbyChatItemRenderer;
	if( selectedItem == null )
		return;
	
	var msgPack:ISFSObject = selectedItem.data as ISFSObject;
	// prevent hints for my messages
	if( msgPack.getInt("i") != player.id && msgPack.getInt("m") == MessageTypes.M0_TEXT )
		showSimpleListPopup(msgPack, selectedItem, buttonsPopup_selectHandler, buttonsPopup_selectHandler, "lobby_report", "lobby_profile", "lobby_reply");
}

override protected function buttonsPopup_selectHandler(event:Event):void
{
	var buttonsPopup:SimpleListPopup = event.currentTarget as SimpleListPopup;
	buttonsPopup.removeEventListener(Event.SELECT, buttonsPopup_selectHandler);
	buttonsPopup.removeEventListener(Event.CLOSE, buttonsPopup_selectHandler);
	
	if( event.type == Event.CLOSE )
		return;
	
	var msgPack:ISFSObject = buttonsPopup.data as ISFSObject;
	switch( event.data )
	{
		case "lobby_profile":
            var user:Object = {name:msgPack.getUtfString("s"), id:int(msgPack.getInt("i"))};
            if( !manager.isPublic )
            {
                user.ln = manager.lobby.name;
                user.lp = manager.emblem;
            }
            appModel.navigator.addPopup( new ProfilePopup(user) );
			break;
		
		case "lobby_report":
			var confirm:ConfirmPopup = new ConfirmPopup(loc("popup_sure_label"), loc("popup_yes_label"));
			confirm.acceptStyle = MainTheme.STYLE_BUTTON_SMALL_DANGER;
			confirm.declineStyle = MainTheme.STYLE_BUTTON_SMALL_NEUTRAL;
			confirm.addEventListener(Event.SELECT, confirm_selectHandler);
			appModel.navigator.addPopup(confirm);
			break;
		
		case "lobby_reply":
			chatButton_triggeredHandler(null);
			var msg:String = msgPack.getUtfString("t");
			preText = "@" + msgPack.getUtfString("s") + ": " + msg.substr(msg.lastIndexOf("\n") + 1, 20) + "... :\n";
			break;
	}
	function confirm_selectHandler(evet:Event):void
	{
		var sfsReport:ISFSObject = new SFSObject();
		sfsReport.putUtfString("t", msgPack.getUtfString("t"));
		sfsReport.putInt("i", msgPack.getInt("i"));
		sfsReport.putInt("u", msgPack.getInt("u"));
		SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_reportResponseHandler);
		SFSConnection.instance.sendExtensionRequest(SFSCommands.LOBBY_REPORT, sfsReport, manager.lobby);
	}
	function sfs_reportResponseHandler(e:SFSEvent):void
	{
		if( e.params.cmd != SFSCommands.LOBBY_REPORT )
			return;
		SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_reportResponseHandler);
		appModel.navigator.addLog(loc("lobby_report_response_" + e.params.params.getInt("response")) );
	}
}

protected function manager_updateHandler(event:Event):void
{
	if( Starling.current.nativeStage.frameRate < 1 )
		return;
	UserData.instance.lastLobbeyMessageTime = timeManager.now;
	buttonsEnabled = manager.getMyRequestBattleIndex() == -1;
	chatList.validate();
    if( autoScroll )
        scrollToEnd();
}

override protected function chatButton_triggeredHandler(event:Event):void
{
    super.chatButton_triggeredHandler(event);
	preText = "";
}

protected function emotesButton_triggeredHandler(event:Event) : void 
{
	if( isInvalidMessage("emote") )
		return;
	
	var emoteToast:EmoteToast = new EmoteToast();
	emoteToast.addEventListener(Event.CHANGE, emoteToast_changeHandler);
	appModel.navigator.addToast(emoteToast);
}
protected function emoteToast_changeHandler(event:Event) : void 
{
	event.currentTarget.removeEventListener(Event.CHANGE, emoteToast_changeHandler);
	var emote:SFSObject = new SFSObject();
	emote.putInt("m", MessageTypes.M51_EMOTE);
	emote.putInt("e", event.data as int);
	emote.putInt("i", player.id);
	emote.putUtfString("s", player.nickName);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.LOBBY_PUBLIC_MESSAGE, emote, manager.lobby);
}

override protected function sendButton_triggeredHandler(event:Event):void
{
	if( isInvalidMessage(chatTextInput.text) )
		return;

	var params:SFSObject = new SFSObject();
	params.putUtfString("t", preText + StrUtils.getSimpleString(chatTextInput.text));
	SFSConnection.instance.sendExtensionRequest(SFSCommands.LOBBY_PUBLIC_MESSAGE, params, manager.lobby );
	chatTextInput.text = preText = "";
}

override protected function isInvalidMessage(message:String) : Boolean 
{
	if( super.isInvalidMessage(message) )
		return true;
	var last:ISFSObject = manager.messages.getItemAt(manager.messages.length - 1) as SFSObject;
	if( last != null && last.getInt("i") == player.id && last.containsKey("t") && last.getText("t").split("\n").length > 4 )
	{
		appModel.navigator.addLog(loc("lobby_message_limit"));
		return true;
	}
	return false;
}

override public function dispose():void
{
	if( manager != null )
		manager.removeEventListener(Event.UPDATE, manager_updateHandler);
	super.dispose();
}

private function isBan():Boolean
{
	var ban:ISFSObject = appModel.loadingManager.serverData.containsKey("ban") ? appModel.loadingManager.serverData.getSFSObject("ban") : null;
	if( ban != null && ban.getInt("mode") > 1 )// banned user
	{
		// backgroundSkin = new Image(appModel.theme.backgroundDisabledSkinTexture);
		// Image(backgroundSkin).scale9Grid = MainTheme.DEFAULT_BACKGROUND_SCALE9_GRID;
		// backgroundSkin.alpha = 0.6;
		
		var labelDisplay:ShadowLabel = new ShadowLabel(loc("lobby_banned", [StrUtils.toTimeFormat(ban.getLong("until"))]), 1, 0, "center", null, true, null, 0.9);
		labelDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, 0);
		labelDisplay.width = stageWidth - 200;
		addChild(labelDisplay);
		
		var descDisplay:RTLLabel = new RTLLabel(ban.getUtfString("message"), 0xAABBCC, null, null, true, null, 0.65);
		descDisplay.layoutData = labelDisplay.layoutData;
		descDisplay.width = stageWidth - 200;
		addChild(descDisplay);
		return true;
	}
	return false;
}
}
}