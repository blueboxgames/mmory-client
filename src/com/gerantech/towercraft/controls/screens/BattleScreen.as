package com.gerantech.towercraft.controls.screens
{
import com.gerantech.mmory.core.battle.BattleField;
import com.gerantech.mmory.core.battle.fieldes.FieldData;
import com.gerantech.mmory.core.constants.PrefsTypes;
import com.gerantech.mmory.core.constants.ResourceType;
import com.gerantech.mmory.core.socials.Challenge;
import com.gerantech.mmory.core.utils.maps.IntIntMap;
import com.gerantech.towercraft.controls.BattleHUD;
import com.gerantech.towercraft.controls.overlays.BattleStartOverlay;
import com.gerantech.towercraft.controls.overlays.BattleWaitingOverlay;
import com.gerantech.towercraft.controls.overlays.EndBattleOverlay;
import com.gerantech.towercraft.controls.overlays.EndOperationOverlay;
import com.gerantech.towercraft.controls.overlays.EndOverlay;
import com.gerantech.towercraft.controls.popups.UnderMaintenancePopup;
import com.gerantech.towercraft.events.GameEvent;
import com.gerantech.towercraft.managers.SoundManager;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.tutorials.TutorialData;
import com.gerantech.towercraft.models.tutorials.TutorialTask;
import com.gerantech.towercraft.models.vo.BattleData;
import com.gerantech.towercraft.models.vo.UserData;
import com.gerantech.towercraft.themes.MainTheme;
import com.gerantech.towercraft.views.BattleFieldView;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSObject;

import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

import flash.utils.setTimeout;

import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;
import starling.events.Event;

public class BattleScreen extends BaseCustomScreen
{
static public var IN_BATTLE:Boolean;
static public var INDEX:int;
static public var FRIENDLY_MODE:int;
static public var SPECTATED_USER:String;
static public var WAITING:BattleWaitingOverlay;
public var hud:BattleHUD;
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
	Image(backgroundSkin).scale9Grid = MainTheme.QUAD_SCALE9_GRID;
	Image(backgroundSkin).color = 0xCCB3A3;
}

protected function battleFieldView_completeHandler(e:Event):void 
{
	appModel.battleFieldView.removeEventListener(Event.COMPLETE, battleFieldView_completeHandler);
	layout = new AnchorLayout();
	
	var params:SFSObject = new SFSObject();
	params.putInt("index", INDEX);
	params.putInt("friendlyMode", FRIENDLY_MODE);
	if( SPECTATED_USER != null && SPECTATED_USER != "" )
		params.putText("spectatedUser", SPECTATED_USER);

	SFSConnection.instance.addEventListener(SFSEvent.CONNECTION_LOST,	sfsConnection_connectionLostHandler);
	if( FRIENDLY_MODE
	 == 0 )
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
		appModel.battleFieldView.summonUnits(data.getSFSArray("units"), data.getDouble("time"));
		break;
	
	case SFSCommands.BATTLE_HIT:
		appModel.battleFieldView.hitUnits(data.getInt("b"), data.getSFSArray("t"));
		break;
	
	case SFSCommands.BATTLE_NEW_ROUND:
		if( battleField.field.mode == Challenge.MODE_1_TOUCHDOWN && Math.max(data.getInt("0"), data.getInt("1")) < 3 )
			appModel.battleFieldView.requestKillPioneers(data.getInt("winner"));
		if( hud != null )
			hud.updateScores(data.getInt("round"), data.getInt("winner"), data.getInt(battleField.side + ""), data.getInt(battleField.side == 0 ? "1" : "0"), data.getInt("unitId"));
		break;

	case SFSCommands.BATTLE_ELIXIR_UPDATE:
		if( data.containsKey(battleField.side.toString()) )
			battleField.elixirUpdater.updateAt(battleField.side, data.getInt(battleField.side.toString()));
		else
			battleField.elixirUpdater.updateAt(1 - battleField.side, data.getInt(String(1 - battleField.side)));
		break;

	case SFSCommands.BATTLE_UNIT_CHANGE:
		appModel.battleFieldView.updateUnits(data);
		break;
	}

	//trace(event.params.cmd, data.getDump());
}

private function showErrorPopup(data:SFSObject):void
{
	if( !WAITING.ready )
	{
		WAITING.addEventListener(Event.READY, waitingOverlay_readyHandler);
		function waitingOverlay_readyHandler():void {
			showErrorPopup(data);
		}
		return;
	}
	if( data.containsKey("umt") )
		appModel.navigator.addPopup(new UnderMaintenancePopup(data.getInt("umt"), false));
	else if( data.containsKey("response") )
		appModel.navigator.addLog(loc("error_" + data.getInt("response")));
	WAITING.disappear();
	dispatchEventWith(Event.COMPLETE);
}

// -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_- Start Battle _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
private function startBattle():void
{
	if( this.battleData == null )
		return;

//	if( appModel.battleFieldView.battleData == null || appModel.battleFieldView.battleData.room == null )
//		return;
	
	IN_BATTLE = true;
	tutorials.addEventListener(GameEvent.TUTORIAL_TASKS_STARTED, tutorials_tasksStartHandler);
	if( !WAITING.ready )
	{
		WAITING.addEventListener(Event.READY, waitingOverlay_readyHandler);
		function waitingOverlay_readyHandler():void
		{
			WAITING.removeEventListener(Event.READY, waitingOverlay_readyHandler);
			startBattle();
		}
		return;
	}
	
	appModel.battleFieldView.addEventListener(Event.TRIGGERED, battleFieldView_triggeredHAndler);
	appModel.battleFieldView.createPlaces(this.battleData);
}

private function battleFieldView_triggeredHAndler(event:Event):void
{
	appModel.battleFieldView.removeEventListener(Event.TRIGGERED, battleFieldView_triggeredHAndler);
	WAITING.disappear();
	WAITING.addEventListener(Event.CLOSE, waitingOverlay_closeHandler);
	function waitingOverlay_closeHandler(e:Event):void 
	{
		tutorials.removeAll();
		WAITING.removeEventListener(Event.CLOSE, waitingOverlay_closeHandler);
		Starling.juggler.tween(appModel.battleFieldView, 1, {delay:1, y:appModel.battleFieldView.y + 50, scale:1, transition:Transitions.EASE_IN_OUT, onComplete:showTutorials});
		if( !player.inTutorial() )
			hud.addChildAt(new BattleStartOverlay(battleData.battleField.field.isOperation() ? battleData.battleField.field.mode : -1, battleData ), 0);
	}
	
	// show battle HUD
	hud = new BattleHUD();
	hud.addEventListener(Event.CLOSE, backButtonHandler);
	hud.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	addChild(hud);
	
	resetAll(battleData.sfsData);
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
	if( appModel.battleFieldView.battleData.userType != 0 )
		return;

	//appModel.battleFieldView.createDrops();
	if( player.getTutorStep() < 81 )
		UserData.instance.prefs.setInt(PrefsTypes.TUTOR, appModel.battleFieldView.battleData.getBattleStep() + 1);

	if( player.get_battleswins() > appModel.maxTutorBattles - 1 )
	{
		readyBattle();
		return;
	}
	
	// create tutorial steps
	var tutorialData:TutorialData = new TutorialData(battleField.field.mode + "_start");
	tutorialData.data = "start";
	tutorialData.addTask(new TutorialTask(TutorialTask.TYPE_MESSAGE, "tutor_" + battleField.field.mode + "_" + player.get_battleswins() + "_start", null, 500, 1500));
	tutorials.addEventListener(GameEvent.TUTORIAL_TASKS_FINISH, tutorials_tasksFinishHandler);
	tutorials.show(tutorialData);
}

private function readyBattle() : void 
{
	if( player.get_battleswins() < appModel.maxTutorBattles - 1 )
		appModel.battleFieldView.mapBuilder.showtutorHint(battleField.field, player.get_battleswins());
	
	touchEnable = true;
	hud.showDeck();
}

// -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_- End Battle _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
private function endBattle(data:SFSObject, skipCelebration:Boolean = false):void
{
	IN_BATTLE = false;
	var inTutorial:Boolean = player.get_battleswins() < appModel.maxTutorBattles + 1;
	battleField.state = BattleField.STATE_4_ENDED;
	var field:FieldData = battleField.field;
	touchEnable = false;
	appModel.sounds.stopAll();
	hud.stopTimers();
	Starling.juggler.tween(appModel.battleFieldView, 5, {delay:0.7, scale:0.95, transition:Transitions.EASE_OUT});

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
	if( player.get_battleswins() < 10 && rewards.getSFSObject(0).getInt("score") > 0 )
		UserData.instance.prefs.setInt(PrefsTypes.TUTOR, appModel.battleFieldView.battleData.getBattleStep() + 7);
	
	var challengUnlockAt:int;
	for( var c:int = 1; c < 4; c++ )
	{
		if( player.getTutorStep() > 200 + c * 10 )
			continue;
		challengUnlockAt = Challenge.getUnlockAt(game, c);
		if( challengUnlockAt > player.get_point() )
			break;
	}

	player.addResources(outcomes);
	
	// check new challenge unlocked
	if( challengUnlockAt > 0 && challengUnlockAt < player.get_point() )
		UserData.instance.prefs.setInt(PrefsTypes.TUTOR, 200 + c * 10);
	
	var endOverlay:EndOverlay;
	if( field.isOperation() )
		endOverlay = new EndOperationOverlay(appModel.battleFieldView.battleData, playerIndex, rewards, inTutorial);
	else
		endOverlay = new EndBattleOverlay(appModel.battleFieldView.battleData, playerIndex, rewards, inTutorial);
	endOverlay.addEventListener(Event.CLOSE, endOverlay_closeHandler);
	setTimeout(hud.end, 2000, endOverlay);// delay for noobs
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
	
	appModel.battleFieldView.responseSender.leave();
	appModel.battleFieldView.responseSender.actived = false;
	
	if( player.get_battleswins() > 5 && endOverlay.score == 3 && player.get_arena(0) > 0 ) // !sfsConnection.mySelf.isSpectator && 
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
	if( appModel.battleFieldView.battleData.userType == 1 )
	{
		appModel.battleFieldView.responseSender.leave();
		dispatchEventWith(Event.COMPLETE);
		return;
	}
	
/*	if( player.inTutorial() )
		return;
	
	if( battleField.startAt + battleField.field.times.get(0) > timeManager.now )
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
private function get battleField() : BattleField
{
	return appModel.battleFieldView.battleData.battleField;
}


override public function dispose():void
{
	removeConnectionListeners();
	appModel.sounds.stopAll();
	setTimeout(appModel.sounds.play, 2000, "main-theme", NaN, 100, 0, SoundManager.SINGLE_BYPASS_THIS);
	removeChild(appModel.battleFieldView, true);
	super.dispose();
}

private function removeConnectionListeners():void
{
	if( tutorials != null )
		tutorials.removeEventListener(GameEvent.TUTORIAL_TASKS_STARTED, tutorials_tasksStartHandler);
	SFSConnection.instance.removeEventListener(SFSEvent.CONNECTION_LOST,	sfsConnection_connectionLostHandler);
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_extensionResponseHandler);
}
}
}