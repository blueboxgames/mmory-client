package com.gerantech.towercraft.controls.headers
{
import com.gerantech.towercraft.controls.buttons.IconButton;
import com.gerantech.towercraft.controls.buttons.SimpleLayoutButton;
import com.gerantech.towercraft.controls.popups.LobbyDetailsPopup;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.managers.net.sfs.LobbyManager;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.MainTheme;
import com.gerantech.towercraft.utils.StrUtils;
import com.smartfoxserver.v2.core.SFSEvent;
import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import starling.events.Event;

public class LobbyHeader extends SimpleLayoutButton
{
static public const HEIGHT:int = 220;
static public const PADDING:int = 20;
private var usersDisplay:RTLLabel;
private var scoreDisplay:RTLLabel;
private var infoButton:IconButton;
private var manager:LobbyManager;
public function LobbyHeader()
{
	super();
	height = HEIGHT;
	touchGroup = true;
	manager = SFSConnection.instance.lobbyManager;
	updateRoomVariables();
	SFSConnection.instance.addEventListener(SFSEvent.ROOM_VARIABLES_UPDATE, sfsConnection_roomVariablesUpdateHandler);
	SFSConnection.instance.addEventListener(SFSEvent.USER_ENTER_ROOM, room_userChangeHandler);
	SFSConnection.instance.addEventListener(SFSEvent.USER_EXIT_ROOM, room_userChangeHandler);
}

override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout();
	
	var skin:ImageLoader = new ImageLoader();
	skin.layoutData = new AnchorLayoutData(PADDING, PADDING, PADDING, PADDING);
	skin.scale9Grid = MainTheme.ROUND_SMALL_SCALE9_GRID;
	skin.source = appModel.theme.roundSmallSkin;
	skin.color = 0x0A1821;
	addChild(skin);
	
	var nameDisplay:RTLLabel = new RTLLabel(manager.lobby.name, 1, null, null, false, null, 0.7);
	nameDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?NaN:80, NaN, appModel.isLTR?80:NaN, NaN, -26);
	addChild(nameDisplay);
	
	scoreDisplay = new RTLLabel(loc("lobby_sum") + ": " + StrUtils.getNumber(manager.point), 1, null, null, false, null, 0.6);
	scoreDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?NaN:80, NaN, appModel.isLTR?80:NaN, NaN, 28);
	addChild(scoreDisplay);
	
	usersDisplay = new RTLLabel(loc("lobby_onlines", [manager.lobby.userCount, manager.members.size()]) , 0x0077B4, null, null, false, null, 0.65);
	usersDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?HEIGHT * 0.76:NaN, NaN, appModel.isLTR?NaN:HEIGHT * 0.76, NaN, 0);
	addChild(usersDisplay);
	
	infoButton = new IconButton(Assets.getTexture("events/info"), 0.6, Assets.getTexture("events/badge"));
	infoButton.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?HEIGHT * 0.28:NaN, NaN, appModel.isLTR?NaN:HEIGHT * 0.28, NaN, -3);
	infoButton.height = 86;
	infoButton.width = 80;
	addChild(infoButton); 
}

protected function sfsConnection_roomVariablesUpdateHandler(event:SFSEvent):void
{
	updateRoomVariables();
}

private function updateRoomVariables():void
{
	if( usersDisplay != null && manager.lobby != null )
		usersDisplay.text = loc("lobby_onlines", [manager.lobby.userCount, manager.members.size()]);
}

protected function room_userChangeHandler(event:SFSEvent):void
{
	updateRoomVariables();
}

override protected function trigger() : void
{
	super.trigger();
	var detailsPopup:LobbyDetailsPopup = new LobbyDetailsPopup({id:manager.id, name:manager.lobby.name, pic:manager.emblem, num:manager.members.size(), sum:manager.point, all:manager.members, max:manager.lobby.maxUsers});
	detailsPopup.addEventListener(Event.UPDATE, detailsPopup_updateHandler);
	appModel.navigator.addPopup(detailsPopup);
	function detailsPopup_updateHandler(ev:Event):void 
	{
		detailsPopup.removeEventListener(Event.UPDATE, detailsPopup_updateHandler);
		dispatchEventWith(Event.UPDATE, true, ev.data);
	}
}

/*override public function set isEnabled(value:Boolean):void
{
	super.isEnabled = value;
	touchable = value;
}*/

override public function dispose():void
{
	SFSConnection.instance.removeEventListener(SFSEvent.ROOM_VARIABLES_UPDATE, sfsConnection_roomVariablesUpdateHandler);
	SFSConnection.instance.removeEventListener(SFSEvent.USER_EXIT_ROOM, room_userChangeHandler);
	SFSConnection.instance.removeEventListener(SFSEvent.USER_ENTER_ROOM, room_userChangeHandler);
	super.dispose();
}
}
}