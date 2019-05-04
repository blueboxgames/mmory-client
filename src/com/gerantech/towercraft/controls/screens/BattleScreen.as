package com.gerantech.towercraft.controls.screens
{
import com.gerantech.towercraft.controls.BattleHUD;
import com.gerantech.towercraft.controls.overlays.BattleStartOverlay;
import com.gerantech.towercraft.controls.overlays.BattleWaitingOverlay;
import com.gerantech.towercraft.controls.overlays.EndBattleOverlay;
import com.gerantech.towercraft.controls.overlays.EndOperationOverlay;
import com.gerantech.towercraft.controls.overlays.EndOverlay;
import com.gerantech.towercraft.controls.popups.ConfirmPopup;
import com.gerantech.towercraft.controls.popups.UnderMaintenancePopup;
import com.gerantech.towercraft.events.GameEvent;
import com.gerantech.towercraft.managers.SoundManager;
import com.gerantech.towercraft.managers.VideoAdsManager;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.tutorials.TutorialData;
import com.gerantech.towercraft.models.tutorials.TutorialTask;
import com.gerantech.towercraft.models.vo.BattleData;
import com.gerantech.towercraft.models.vo.UserData;
import com.gerantech.towercraft.models.vo.VideoAd;
import com.gerantech.towercraft.themes.MainTheme;
import com.gerantech.towercraft.views.BattleFieldView;
import com.gt.towers.battle.BattleField;
import com.gt.towers.battle.fieldes.FieldData;
import com.gt.towers.constants.PrefsTypes;
import com.gt.towers.constants.ResourceType;
import com.gt.towers.socials.Challenge;
import com.gt.towers.utils.maps.IntIntMap;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSObject;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import flash.utils.setTimeout;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;
import starling.events.Event;

public class BattleScreen extends BaseCustomScreen
{
public static var IN_BATTLE:Boolean;
public var index:int;
public var friendlyMode:int;
public var spectatedUser:String;
public var hud:BattleHUD;
public var waitingOverlay:BattleWaitingOverlay;
private var touchEnable:Boolean;
private var battleData:BattleData;

public function BattleScreen()
{
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE,	sfsConnection_extensionResponseHandler);

	appModel.battleFieldView = new BattleFieldView();
	appModel.battleFieldView.addEventListener(Event.COMPLETE,	battleFieldView_completeHandler);
	appModel.battleFieldView.initialize();
	addChild(appModel.battleFieldView);
	
	backgroundSkin = new Image(appModel.theme.quadSkin);
	Image(backgroundSkin).color = 0xCCB3A3;
}

protected function battleFieldView_completeHandler(e:Event):void 
{
	appModel.battleFieldView.removeEventListener(Event.COMPLETE, battleFieldView_completeHandler);
	layout = new AnchorLayout();
	
	var params:SFSObject = new SFSObject();
	params.putInt("index", index);
	params.putInt("friendlyMode", friendlyMode);
	if( spectatedUser != null && spectatedUser != "" )
		params.putText("spectatedUser", spectatedUser);

	SFSConnection.instance.addEventListener(SFSEvent.CONNECTION_LOST,	sfsConnection_connectionLostHandler);
	if( friendlyMode == 0 )
		SFSConnection.instance.sendExtensionRequest(SFSCommands.BATTLE_START, params);
	
	startBattle();
}

protected function sfsConnection_connectionLostHandler(event:SFSEvent):void
{
	removeConnectionListeners();
}
protected function sfsConnection_extensionResponseHandler(event:SFSEvent):void
{
	var data:SFSObject = event.params.params as SFSObject;
	if( event.params.cmd == SFSCommands.BATTLE_START )
	{
		if( data.containsKey("umt") || data.containsKey("response") )
		{
			showErrorPopup(data);
			return;
		}
		
		this.battleData = new BattleData(data);
		if( appModel.battleFieldView.mapBuilder != null )
			startBattle();
		return;
	}
	
	if( appModel.battleFieldView.battleData == null )
		return;
	
	switch(event.params.cmd)
	{
	case SFSCommands.BATTLE_END:
		endBattle(data);
		break;
	
	case SFSCommands.BATTLE_SEND_STICKER:
		hud.showBubble(data.getInt("t"), false);
		break;
	
	case SFSCommands.BATTLE_SUMMON_UNIT:
		for( var i:int = 0; i < data.getSFSArray("units").size(); i++ )
		{
			var sfs:ISFSObject = data.getSFSArray("units").getSFSObject(i);
			appModel.battleFieldView.summonUnit(sfs.getInt("i"), sfs.getInt("t"), sfs.getInt("l"), sfs.getInt("s"), sfs.getDouble("x"), sfs.getDouble("y"));
		}
		break;
	
	case SFSCommands.BATTLE_HIT:
		appModel.battleFieldView.hitUnits(data.getInt("b"), data.getSFSArray("t"));
		break;
	
	case SFSCommands.BATTLE_NEW_ROUND:
		if( appModel.battleFieldView.battleData.battleField.field.mode == Challenge.MODE_1_TOUCHDOWN )
			appModel.battleFieldView.battleData.battleField.requestReset();
		if( hud != null )
			hud.updateScores(data.getInt("round"), data.getInt("winner"), data.getInt(appModel.battleFieldView.battleData.battleField.side + ""), data.getInt(appModel.battleFieldView.battleData.battleField.side == 0 ? "1" : "0"), data.getInt("unitId"));
		break;
	}
	//trace(event.params.cmd, data.getDump());
}

private function showErrorPopup(data:SFSObject):void
{
	if( !waitingOverlay.ready )
	{
		waitingOverlay.addEventListener(Event.READY, waitingOverlay_readyHandler);
		function waitingOverlay_readyHandler():void {
			showErrorPopup(data);
		}
		return;
	}
	if( data.containsKey("umt") )
		appModel.navigator.addPopup(new UnderMaintenancePopup(data.getInt("umt"), false));
	else if( data.containsKey("response") )
		appModel.navigator.addLog(loc("error_" + data.getInt("response")));
	waitingOverlay.disappear();
	dispatchEventWith(Event.COMPLETE);
}

// -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_- Start Battle _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
private function startBattle():void
{
	if( this.battleData == null)
		return;

//	if( appModel.battleFieldView.battleData == null || appModel.battleFieldView.battleData.room == null )
//		return;
	
	IN_BATTLE = true;
	tutorials.addEventListener(GameEvent.TUTORIAL_TASKS_STARTED, tutorials_tasksStartHandler);
	if( !waitingOverlay.ready )
	{
		waitingOverlay.addEventListener(Event.READY, waitingOverlay_readyHandler);
		function waitingOverlay_readyHandler():void
		{
			waitingOverlay.removeEventListener(Event.READY, waitingOverlay_readyHandler);
			startBattle();
		}
		return;
	}
	
	appModel.battleFieldView.createPlaces(this.battleData);

	waitingOverlay.disappear();
	waitingOverlay.addEventListener(Event.CLOSE, waitingOverlay_closeHandler);
	function waitingOverlay_closeHandler(e:Event):void 
	{
		tutorials.removeAll();
		waitingOverlay.removeEventListener(Event.CLOSE, waitingOverlay_closeHandler);
		Starling.juggler.tween(appModel.battleFieldView, 1, {delay:1, scale:1, transition:Transitions.EASE_IN_OUT, onComplete:showTutorials});
		if( !player.inTutorial() )
			hud.addChildAt(new BattleStartOverlay(battleData.battleField.field.isOperation() ? battleData.battleField.field.mode : -1, battleData ), 0);
	}
	
	// show battle HUD
	hud = new BattleHUD();
	hud.addEventListener(Event.CLOSE, backButtonHandler);
	hud.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	addChild(hud);
	
	resetAll(battleData.sfsData);
	appModel.battleFieldView.updateUnits();
	
	SFSConnection.instance.addEventListener(SFSEvent.ROOM_VARIABLES_UPDATE, sfsConnection_roomVariablesUpdateHandler);
	appModel.loadingManager.serverData.putBool("inBattle", false);
	
	// play battle theme -_-_-_
	appModel.sounds.stopAll();
	appModel.sounds.addAndPlay("battle-0", null, SoundManager.CATE_THEME, SoundManager.SINGLE_BYPASS_THIS, 8);
}

private function tutorials_tasksStartHandler(e:Event) : void
{
	/*clearSources(sourcePlaces);
	sourcePlaces = null;*/
}

private function showTutorials() : void 
{
	if( SFSConnection.instance.mySelf.isSpectator )
		return;

	//appModel.battleFieldView.createDrops();
	if( player.getTutorStep() > 81 )
	{
		readyBattle();
		return;
	}
	
	// create tutorial steps
	var field:FieldData = appModel.battleFieldView.battleData.battleField.field;
	var tutorialData:TutorialData = new TutorialData(field.mode + "_start");
	tutorialData.data = "start";
	tutorialData.addTask(new TutorialTask(TutorialTask.TYPE_MESSAGE, "tutor_" + field.mode + "_" + player.get_battleswins() + "_start", null, 500, 1500));
	tutorials.addEventListener(GameEvent.TUTORIAL_TASKS_FINISH, tutorials_tasksFinishHandler);
	tutorials.show(tutorialData);
	
	UserData.instance.prefs.setInt(PrefsTypes.TUTOR, appModel.battleFieldView.battleData.getBattleStep() + 1);
}

private function readyBattle() : void 
{
	if( player.get_battleswins() < 3 )
		appModel.battleFieldView.mapBuilder.showEnemyHint(appModel.battleFieldView.battleData.battleField.field, player.get_battleswins());
	
	touchEnable = true;
	hud.showDeck();
}

// -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_- End Battle _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
private function endBattle(data:SFSObject, skipCelebration:Boolean = false):void
{
	IN_BATTLE = false;
	var inTutorial:Boolean = player.get_battleswins() < 5;
	appModel.battleFieldView.battleData.battleField.state = BattleField.STATE_4_ENDED;
	var field:FieldData = appModel.battleFieldView.battleData.battleField.field;
	touchEnable = false;
	appModel.sounds.stopAll();
	hud.stopTimers();

	tutorials.removeAll();
	
	var rewards:ISFSArray = data.getSFSArray("outcomes");
	var playerIndex:int = -1
	for(var i:int = 0; i < rewards.size(); i++)
	{
		if( rewards.getSFSObject(i).getInt("id") == player.id )
		{
			playerIndex = i;
			break;
		}
	}
	
	// reduce player resources
	if( playerIndex > -1 )
	{
		var outcomes:IntIntMap = new IntIntMap();
		var item:ISFSObject = rewards.getSFSObject(playerIndex);
		var bookKey:String = null;
		var _keys:Array = item.getKeys();
		for( i = 0; i < _keys.length; i++)
		{
			var key:int = int(_keys[i]);
			if( ResourceType.isBook(key) )
				bookKey = _keys[i];
			else if ( key > 0 )
			{
				if( key == ResourceType.R17_STARS )
					exchanger.collectStars(item.getInt(_keys[i]), timeManager.now);
				outcomes.set(key, item.getInt(_keys[i]));
			}
		}
		if( bookKey != null )
			outcomes.set(int(bookKey), item.getInt(bookKey));
	}
	
	// reserved prefs data
	if( inTutorial && rewards.getSFSObject(0).getInt("score") > 0 )
		UserData.instance.prefs.setInt(PrefsTypes.TUTOR, appModel.battleFieldView.battleData.getBattleStep() + 7);
	
	player.addResources(outcomes);
	var endOverlay:EndOverlay;
	if( field.isOperation() )
		endOverlay = new EndOperationOverlay(appModel.battleFieldView.battleData, playerIndex, rewards, inTutorial);
	else
		endOverlay = new EndBattleOverlay(appModel.battleFieldView.battleData, playerIndex, rewards, inTutorial);
	endOverlay.addEventListener(Event.CLOSE, endOverlay_closeHandler);
	setTimeout(hud.end, 1500, endOverlay);// delay for noobs
}

private function endOverlay_closeHandler(event:Event):void
{
	var endOverlay:EndOverlay = event.currentTarget as EndOverlay;
	endOverlay.removeEventListener(Event.CLOSE, endOverlay_closeHandler);
	
	if( endOverlay.playerIndex == -1 )
	{
		dispatchEventWith(Event.COMPLETE);
		return;
	}
	
	var field:FieldData = appModel.battleFieldView.battleData.battleField.field;
	appModel.battleFieldView.responseSender.leave();
	appModel.battleFieldView.responseSender.actived = false;
	
	if( player.get_battleswins() > 5 && endOverlay.score == 3 && player.get_arena(0) > 0 )//!sfsConnection.mySelf.isSpectator && 
		appModel.navigator.showOffer();
	dispatchEventWith(Event.COMPLETE);
}

private function tutorials_tasksFinishHandler(event:Event):void
{
	tutorials.removeEventListener(GameEvent.TUTORIAL_TASKS_FINISH, tutorials_tasksFinishHandler);
	var tutorial:TutorialData = event.data as TutorialData;
	if( tutorial.data == "start" )
	{
		readyBattle();
		return;
	}
	
	if( tutorial.name == "tutor_battle_celebration" )
	{
		endBattle(tutorial.data as SFSObject, true);
		return;
	}
	
	if( player.get_battleswins() == 2 )
	{
		UserData.instance.prefs.setInt(PrefsTypes.TUTOR, PrefsTypes.T_011_SLOT_FOCUS);
		appModel.navigator.popToRootScreen();
		return;
	}
	dispatchEventWith(Event.COMPLETE);
}

protected function sfsConnection_roomVariablesUpdateHandler(event:SFSEvent):void
{
	if( event.params.changedVars.indexOf("units") > -1 )
	{
		appModel.battleFieldView.updateUnits();
	    //hud.updateRoomVars();
	}

	/*if( event.params.changedVars.indexOf("s") > -1 )
	{
		var room:SFSRoom = SFSRoom(event.params.room);
		var towers:ISFSArray = room.getVariable("s").getSFSArrayValue();
		var destination:int = room.getVariable("d").getIntValue();
		var troopsDivision:Number = room.getVariable("n").getDoubleValue();
		
		for( var i:int=0; i<towers.size(); i++ )
			appModel.battleFieldView.places[towers.getInt(i)].fight(appModel.battleFieldView.places[destination].place, troopsDivision);
	}*/
	//sfsConnection.removeFromCommands(SFSCommands.FIGHT);
}
private function resetAll(data:ISFSObject):void
{
	if( !data.containsKey("buildings") )
		return;
	/*var bSize:int = data.getSFSArray("buildings").size();
	for( var i:int=0; i < bSize; i++ )
	{
		var b:ISFSObject = data.getSFSArray("buildings").getSFSObject(i);
		appModel.battleFieldView.places[b.getInt("i")].replaceBuilding(b.getInt("t"), b.getInt("l"), b.getInt("tt"), b.getInt("p"));
	}*/
}

override protected function backButtonFunction():void
{
	if( SFSConnection.instance.lastJoinedRoom != null && SFSConnection.instance.mySelf.isSpectator )
	{
		appModel.battleFieldView.responseSender.leave();
		dispatchEventWith(Event.COMPLETE);
		return;
	}
	
/*	if( player.inTutorial() )
		return;
	
	if( appModel.battleFieldView.battleData.battleField.startAt + appModel.battleFieldView.battleData.battleField.field.times.get(0) > timeManager.now )
		return;
	var confirm:ConfirmPopup = new ConfirmPopup(loc("leave_battle_confirm_message"));
	confirm.acceptStyle = MainTheme.STYLE_BUTTON_SMALL_DANGER;
	confirm.addEventListener(Event.SELECT, confirm_selectsHandler);
	appModel.navigator.addPopup(confirm);
	function confirm_selectsHandler(event:Event):void 
	{
		confirm.removeEventListener(Event.SELECT, confirm_selectsHandler);
		appModel.battleFieldView.responseSender.leave();
	}*/
}

override public function dispose():void
{
	removeConnectionListeners();
	appModel.sounds.stopAll();
	setTimeout(appModel.sounds.play, 2000, "main-theme", 1, 100, 0, SoundManager.SINGLE_BYPASS_THIS);
	removeChild(appModel.battleFieldView, true);
	super.dispose();
}

private function removeConnectionListeners():void
{
	if( tutorials != null )
		tutorials.removeEventListener(GameEvent.TUTORIAL_TASKS_STARTED, tutorials_tasksStartHandler);
	SFSConnection.instance.removeEventListener(SFSEvent.CONNECTION_LOST,	sfsConnection_connectionLostHandler);
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_extensionResponseHandler);
	SFSConnection.instance.removeEventListener(SFSEvent.ROOM_VARIABLES_UPDATE, sfsConnection_roomVariablesUpdateHandler);
}
}
}