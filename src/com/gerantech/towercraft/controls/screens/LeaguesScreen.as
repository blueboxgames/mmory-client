package com.gerantech.towercraft.controls.screens
{
import com.gerantech.mmory.core.battle.units.Card;
import com.gerantech.mmory.core.constants.CardTypes;
import com.gerantech.mmory.core.constants.PrefsTypes;
import com.gerantech.mmory.core.constants.ResourceType;
import com.gerantech.mmory.core.exchanges.ExchangeItem;
import com.gerantech.mmory.core.utils.maps.IntIntMap;
import com.gerantech.towercraft.controls.items.LeagueItemRenderer;
import com.gerantech.towercraft.controls.overlays.EndBattleOverlay;
import com.gerantech.towercraft.controls.overlays.OpenBookOverlay;
import com.gerantech.towercraft.controls.popups.BundleDetailsPopup;
import com.gerantech.towercraft.controls.toasts.BattleTurnToast;
import com.gerantech.towercraft.models.tutorials.TutorialData;
import com.gerantech.towercraft.models.tutorials.TutorialTask;
import com.gerantech.towercraft.models.vo.BattleData;
import com.gerantech.towercraft.models.vo.UserData;
import com.gerantech.towercraft.views.BattleFieldView;
import com.smartfoxserver.v2.entities.data.SFSArray;
import com.smartfoxserver.v2.entities.data.SFSObject;

import dragonBones.objects.DragonBonesData;
import dragonBones.starling.StarlingFactory;

import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

import ir.metrix.sdk.Metrix;
import ir.metrix.sdk.MetrixEvent;

import starling.core.Starling;
import starling.events.Event;

public class LeaguesScreen extends ListScreen
{
public static var factory:StarlingFactory;
public static var dragonBonesData:DragonBonesData;
private static var factoryCreateCallback:Function;
private static var leaguesCollection:ListCollection;

public function LeaguesScreen()
{
	if( leaguesCollection == null )
	{
		leaguesCollection = new ListCollection();
		var keys:Vector.<int> = game.arenas.keys();
		var numLeagues:int = keys.length - 1;
		while( numLeagues >= 0 )
		{
			leaguesCollection.addItem(game.arenas.get(keys[numLeagues]));
			numLeagues --;
		}
	}
	title = "";
}

override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout();
	
	LeagueItemRenderer.START = 0;
	LeagueItemRenderer.HEIGHT = 1800;
	LeagueItemRenderer.POINT = player.get_point();
	LeagueItemRenderer.LEAGUE = player.get_arena(0);
	LeagueItemRenderer.STEP = player.getResource(ResourceType.R25_REWARD_STEP);

	listLayout.gap = 0;
	listLayout.paddingTop = 500;
	listLayout.paddingBottom = 200;
	listLayout.useVirtualLayout = false;
	listLayout.hasVariableItemDimensions = true;
	
	AnchorLayoutData(list.layoutData).bottom = -listLayout.paddingBottom;
	list.itemRendererFactory = function():IListItemRenderer { return new LeagueItemRenderer(); }
	list.addEventListener(FeathersEventType.CREATION_COMPLETE, list_createCompleteHandler);
	list.elasticity = 0.03;
	list.dataProvider = leaguesCollection;
	
	// testStarterPack();
	// testOpenBook();
	// testOffer();
	// testBattleToast();
	// testBattleOverlay();

	if( player.getTutorStep() == PrefsTypes.T_72_NAME_SELECTED )
	{
		UserData.instance.prefs.setInt(PrefsTypes.TUTOR, PrefsTypes.T_75_TROPHY_ROAD);

		var tutorialData:TutorialData = new TutorialData("tutor_end");
		tutorialData.addTask(new TutorialTask(TutorialTask.TYPE_MESSAGE, "tutor_end", null, 500, 1500, 0));
		tutorials.show(tutorialData);
	}
}

private function testOpenBook():void 
{
	OpenBookOverlay.createFactory();
	var openOverlay:OpenBookOverlay = new OpenBookOverlay(59);
	appModel.navigator.addOverlay(openOverlay);
	var outcomes:IntIntMap = new IntIntMap();
	outcomes.set(ResourceType.R3_CURRENCY_SOFT, 50);
	outcomes.set(ResourceType.R4_CURRENCY_HARD, 5);
	outcomes.set(CardTypes.C105, 1);
	outcomes.set(CardTypes.C110, 1);
	outcomes.set(CardTypes.C103, 12);
	outcomes.set(CardTypes.C107, 2);
	outcomes.set(CardTypes.C104, 2);
	player.resources.set(CardTypes.C110, 2);
	player.cards.set(CardTypes.C110, new Card(game, 110, -1))
	openOverlay.outcomes = outcomes;
}

private function testOffer():void 
{
	var wins:int = player.getResource(ResourceType.R13_BATTLES_WINS);
	// Send metrix player event after 10 battle win.
	if( wins == 10 )
	{
		if( Metrix.instance.isSupported )
		{
			var first_session_event:MetrixEvent = Metrix.instance.newEvent("ifrcs");
			Metrix.instance.sendEvent(first_session_event);
		}
	}
	player.resources.set(ResourceType.R13_BATTLES_WINS, player.prefs.getAsInt(PrefsTypes.OFFER_30_RATING) + 1);
	appModel.navigator.showOffer();
	player.resources.set(ResourceType.R13_BATTLES_WINS, wins);
}

private function testBattleToast():void 
{
	appModel.navigator.addPopup(new BattleTurnToast(1, 3));
}

private function testBattleOverlay() : void
{
	var rewards:SFSArray = new SFSArray();
	var sfs2:SFSObject = new SFSObject();
	for (var i:int = 0; i < 2; i++) 
	{
		var sfs:SFSObject = new SFSObject();
		sfs.putInt("score", i == 0?2:0);
		sfs.putInt("id", i == 0?10004:214);
		sfs.putText("name", i == 0?"ManJav":"Enemy");
		sfs.putInt("3", 22);
		sfs.putInt("2", -12);
		sfs.putInt("52", 112);
		rewards.addSFSObject(sfs);
		
		var p:SFSObject = new SFSObject();
		p.putText("name", i == 0?"ManJav":"Enemy");
		p.putInt("xp", 0);
		p.putInt("point", 0);
		p.putText("deck", "101,102");
		p.putInt("score", 0);
		sfs2.putSFSObject("p" + i, p);
	}
	sfs2.putInt("mode", 0);
	sfs2.putText("map", "{}");
	sfs2.putBool("hasExtraTime", false);
	sfs2.putInt("side", 0);
	sfs2.putInt("startAt", 1243554);
	sfs2.putInt("friendlyMode", 0);
	
	appModel.battleFieldView = new BattleFieldView();
	appModel.battleFieldView.battleData = new BattleData(sfs2);
	var endOverlay:EndBattleOverlay = new EndBattleOverlay(appModel.battleFieldView.battleData, 0, rewards, false);
	endOverlay.addEventListener(Event.CLOSE, function():void{dispatchEventWith(Event.COMPLETE); });
	appModel.navigator.addOverlay(endOverlay);
}

private function list_createCompleteHandler():void
{
	var leagueY:int = LeagueItemRenderer.HEIGHT * (leaguesCollection.length - LeagueItemRenderer.LEAGUE);
	list.scrollToPosition(NaN, leagueY + 200, 0);
	Starling.juggler.delayCall(list.scrollToPosition, 0.1, NaN, leagueY - 400, 1);
}

private function testStarterPack():void
{
	var item:ExchangeItem = new  ExchangeItem(31, 0, timeManager.now + 5000,  ResourceType.R5_CURRENCY_REAL + ":1990", "116:40," + ResourceType.R4_CURRENCY_HARD + ":300");
	appModel.navigator.addPopup(new BundleDetailsPopup(item));
}
}
}