package com.gerantech.towercraft.controls.segments
{
import com.gerantech.towercraft.controls.buttons.MMOryButton;
import com.gerantech.towercraft.controls.headers.LobbyHeader;
import com.gerantech.towercraft.controls.items.lobby.LobbyChatItemRenderer;
import com.gerantech.towercraft.controls.popups.FriendlyBattleModePopup;
import com.gerantech.towercraft.controls.popups.SimpleListPopup;
import com.gerantech.towercraft.managers.net.sfs.LobbyManager;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.vo.UserData;
import com.gerantech.towercraft.themes.MainTheme;
import com.gt.towers.battle.fieldes.FieldData;
import com.gt.towers.constants.MessageTypes;
import com.smartfoxserver.v2.entities.data.SFSObject;
import feathers.controls.Button;
import feathers.layout.AnchorLayoutData;
import flash.utils.setTimeout;
import starling.display.Image;
import starling.events.Event;

public class LobbyChatSegment extends LobbyBaseChatSegment
{
private var header:LobbyHeader;
private var battleButton:MMOryButton;
private var startScrollBarIndicator:Number = 0;

public function LobbyChatSegment(){ super(); }
override public function get manager():LobbyManager
{
	return SFSConnection.instance.lobbyManager;
}

override protected function loadData():void
{
	if( !initializeStarted || ChatSegment.factory == null )
		return;
	
	if( manager.isReady )
		showElements();
	else
		manager.addEventListener(Event.READY, manager_readyHandler);
}

override protected function showElements():void
{
	super.showElements();
	
	header = new LobbyHeader();
	header.layoutData = new AnchorLayoutData(NaN, 0, NaN, 0);
	addChild(header);
	
	battleButton = new MMOryButton();
	battleButton.styleName = MainTheme.STYLE_BUTTON_SMALL_HILIGHT;
	battleButton.width = battleButton.height = footerSize;
	battleButton.iconTexture = Assets.getTexture("socials/icon-battle", "gui");
    battleButton.layoutData = new AnchorLayoutData(NaN, NaN, padding, padding);
	battleButton.addEventListener(Event.TRIGGERED, battleButton_triggeredHandler);
	addChild(battleButton);
	
	chatLayout.paddingTop = LobbyHeader.HEIGHT;
	chatList.addEventListener(Event.ROOT_CREATED, chatList_triggeredHandler);
	manager.addEventListener(Event.TRIGGERED, manager_triggerHandler);	

	UserData.instance.lastLobbeyMessageTime = timeManager.now;
	UserData.instance.save();
}

protected function chatList_triggeredHandler(event:Event):void
{
	var selectedItem:LobbyChatItemRenderer = event.data[0] as LobbyChatItemRenderer;
	var params:SFSObject = event.data[1] as SFSObject;
	// show info
	if( params.getShort("pr") == MessageTypes.M10_COMMENT_JOINT )
	{
		var sfs:SFSObject = new SFSObject();
		sfs.putInt("i", params.getInt("o"));
		sfs.putUtfString("s", params.getUtfString("on"));
		showSimpleListPopup(sfs, selectedItem, buttonsPopup_selectHandler, buttonsPopup_selectHandler, "lobby_profile");
		return;
	}
	// accept or reject
	if( MessageTypes.isConfirm(params.getShort("m")) )
		SFSConnection.instance.sendExtensionRequest(SFSCommands.LOBBY_PUBLIC_MESSAGE, params, manager.lobby );
}

override protected function scrollChatList(changes:Number) : void
{
    super.scrollChatList(changes);
    header.y = Math.max(-LobbyHeader.HEIGHT, Math.min(0, header.y+changes));
}

protected function battleButton_triggeredHandler(event:Event):void
{
	var battleModePopup:FriendlyBattleModePopup = new FriendlyBattleModePopup();
	battleModePopup.addEventListener(Event.SELECT, battleModePopup_selectHandler);
	appModel.navigator.addPopup(battleModePopup);
	//showSimpleListPopup(null, battleButton, battlebutton_selectHandler, battlebutton_selectHandler, "button_battle_left", "button_battle_right");
    scrollToEnd();
}

protected function battleModePopup_selectHandler(event:Event):void 
{
	var battleModePopup:FriendlyBattleModePopup = event.currentTarget as FriendlyBattleModePopup;
	battleModePopup.removeEventListener(Event.SELECT, battleModePopup_selectHandler);
	
	setTimeout(function():void{ buttonsEnabled = false}, 1);
	var params:SFSObject = new SFSObject();
	params.putShort("m", MessageTypes.M30_FRIENDLY_BATTLE);
	params.putShort("st", 0);
	if( event.data == 1 )
		params.putBool("bt", true);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.LOBBY_PUBLIC_MESSAGE, params, manager.lobby);
}

protected function manager_triggerHandler(event:Event):void
{
	buttonsEnabled = true;
	appModel.navigator.runBattle(SFSObject(event.data).getInt("m"), false, null, 1);
}

override public function enabledChatting(value:Boolean):void
{
    super.enabledChatting(value);
    battleButton.visible = !value;
}

override public function set buttonsEnabled(value:Boolean):void
{
	super.buttonsEnabled = value;
	header.touchable = _buttonsEnabled;
	battleButton.isEnabled = _buttonsEnabled;
}

override public function dispose():void
{
	if( manager != null ) 
		manager.removeEventListener(Event.TRIGGERED, manager_triggerHandler);
	super.dispose();
}
}
}