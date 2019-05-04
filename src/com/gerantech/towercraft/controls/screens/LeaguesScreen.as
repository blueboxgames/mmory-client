package com.gerantech.towercraft.controls.screens
{
import com.gerantech.towercraft.controls.items.LeagueItemRenderer;
import com.gerantech.towercraft.controls.overlays.EndBattleOverlay;
import com.gerantech.towercraft.controls.overlays.OpenBookOverlay;
import com.gerantech.towercraft.controls.toasts.BattleTurnToast;
import com.gerantech.towercraft.models.vo.BattleData;
import com.gerantech.towercraft.views.BattleFieldView;
import com.gt.towers.battle.units.Card;
import com.gt.towers.constants.CardTypes;
import com.gt.towers.constants.PrefsTypes;
import com.gt.towers.constants.ResourceType;
import com.gt.towers.utils.maps.IntIntMap;
import com.smartfoxserver.v2.entities.data.SFSArray;
import com.smartfoxserver.v2.entities.data.SFSObject;
import dragonBones.objects.DragonBonesData;
import dragonBones.starling.StarlingFactory;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
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
	
	LeagueItemRenderer.HEIGHT = 1000;
	LeagueItemRenderer.LEAGUE = player.get_arena(0);

	listLayout.gap = 0;
	listLayout.paddingTop = 500;
	listLayout.paddingBottom = 0;
	listLayout.useVirtualLayout = false;
	
	list.itemRendererFactory = function():IListItemRenderer { return new LeagueItemRenderer(); }
	list.addEventListener(FeathersEventType.CREATION_COMPLETE, list_createCompleteHandler);
	list.elasticity = 0.03;
	list.dataProvider = leaguesCollection;
	
	//testOpenBook();
	//testOffer();
	//testBattleToast();
	//testBattleOverlay();
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
//	trace(leaguesCollection.length,FactionItemRenderer.playerLeague,(leaguesCollection.length-FactionItemRenderer.playerLeague-1), FactionItemRenderer._height * (leaguesCollection.length-FactionItemRenderer.playerLeague-1))
	list.scrollToPosition(NaN, LeagueItemRenderer.HEIGHT * (leaguesCollection.length - LeagueItemRenderer.LEAGUE - 1) + 300, 0);
	Starling.juggler.delayCall(list.scrollToPosition, 0.3, NaN, LeagueItemRenderer.HEIGHT * (leaguesCollection.length - LeagueItemRenderer.LEAGUE - 2) , 1);
}
}
}