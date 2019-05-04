package com.gerantech.towercraft.controls.segments
{
import com.gerantech.towercraft.controls.buttons.MMOryButton;
import com.gerantech.towercraft.controls.items.lobby.LobbyChatItemRenderer;
import com.gerantech.towercraft.controls.popups.ConfirmPopup;
import com.gerantech.towercraft.controls.popups.ProfilePopup;
import com.gerantech.towercraft.controls.popups.SimpleListPopup;
import com.gerantech.towercraft.controls.toasts.EmoteToast;
import com.gerantech.towercraft.managers.net.sfs.LobbyManager;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.vo.UserData;
import com.gerantech.towercraft.themes.MainTheme;
import com.gerantech.towercraft.utils.StrUtils;
import com.gt.towers.constants.MessageTypes;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSObject;
import feathers.controls.Button;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import starling.core.Starling;
import starling.display.Image;
import starling.events.Event;

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
	loadData();
}

protected function loadData():void
{
	if( manager == null || !initializeStarted || initializeCompleted || ChatSegment.factory == null )
		return;
	
	if( manager.isReady )
	{
		showElements();
		return;
	}
	manager.addEventListener(Event.READY, manager_readyHandler);
	manager.joinToPublic();
}

protected function manager_readyHandler(event:Event) : void
{
	manager.removeEventListener(Event.READY, manager_readyHandler);
	showElements();
}

override protected function showElements() : void
{
	super.showElements();
	
    emotesButton = new MMOryButton();
    emotesButton.width = emotesButton.height = footerSize;
	emotesButton.styleName = MainTheme.STYLE_BUTTON_SMALL_NEUTRAL;
    emotesButton.iconTexture = Assets.getTexture("socials/icon-emote", "gui");
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
	if( msgPack.getShort("m") == MessageTypes.M30_FRIENDLY_BATTLE  )
	{
		var myBattleId:int = manager.getMyRequestBattleId();
		if( myBattleId > -1 && msgPack.getInt("bid") != myBattleId )
			return;
		
		if( msgPack.getShort("st") > 1 )
			return;
		
		var params:SFSObject = new SFSObject();
		params.putShort("m", MessageTypes.M30_FRIENDLY_BATTLE);
		params.putInt("bid", msgPack.getInt("bid"));
		params.putShort("st", msgPack.getShort("st"));
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
	if( msgPack.getInt("i") != player.id && msgPack.getShort("m") == MessageTypes.M0_TEXT )
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
	emote.putShort("m", MessageTypes.M51_EMOTE);
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
}
}