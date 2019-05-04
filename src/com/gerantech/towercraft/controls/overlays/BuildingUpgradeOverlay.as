package com.gerantech.towercraft.controls.overlays
{
import com.gerantech.towercraft.controls.BuildingCard;
import com.gerantech.towercraft.controls.buttons.SimpleLayoutButton;
import com.gerantech.towercraft.controls.items.CardFeatureItemRenderer;
import com.gerantech.towercraft.controls.screens.DashboardScreen;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.events.GameEvent;
import com.gerantech.towercraft.models.tutorials.TutorialData;
import com.gerantech.towercraft.models.vo.UserData;
import com.gerantech.towercraft.views.effects.UIParticleSystem;
import com.gt.towers.battle.units.Card;
import com.gt.towers.constants.CardFeatureType;
import com.gt.towers.constants.CardTypes;
import com.gt.towers.constants.PrefsTypes;
import dragonBones.starling.StarlingArmatureDisplay;
import feathers.controls.List;
import feathers.controls.ScrollPolicy;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.TiledRowsLayout;
import flash.utils.setTimeout;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.events.Event;

public class BuildingUpgradeOverlay extends BaseOverlay
{
public var card:Card;
private var initializeStarted:Boolean;
private var shineArmature:StarlingArmatureDisplay;
public function BuildingUpgradeOverlay(){ super(); }
override protected function initialize():void
{
	if( stage != null )
		addChild(defaultOverlayFactory());

	super.initialize();
	appModel.navigator.activeScreen.visible = false;
	initializeStarted = true;

	layout = new AnchorLayout();
	closeOnStage = false;

	width = stageWidth;
	height = stageHeight;
	overlay.alpha = 1;
	
	var cardView:BuildingCard = new BuildingCard(true, false, false, false);
	cardView.pivotX= cardView.width * 0.5;
	cardView.pivotY = cardView.height * 0.5;
	cardView.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, NaN);
	cardView.width = 240;
	cardView.height = cardView.width * BuildingCard.VERICAL_SCALE;
	cardView.y = (stageHeight - cardView.height) * 0.5;
	addChild(cardView);
	cardView.setData(card.type, card.level - 1);
	//card.scale = 1.6;
	
	appModel.sounds.setVolume("main-theme", 0.3);
	setTimeout(levelUp, 500);
	setTimeout(showFeatures, 1800);
	setTimeout(showEnd, 2500);
	function levelUp():void {
		var titleDisplay:RTLLabel = new RTLLabel(loc("card_title_" + cardView.type), 1, "center", null, false, null, 1.5);
		titleDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0);
		titleDisplay.y = (stageHeight - cardView.height) / 3;
		addChild(titleDisplay);
		
		cardView.scale = 2.4;
		cardView.setData(card.type, card.level);
		Starling.juggler.tween(cardView, 0.3, {scale:1.6, transition:Transitions.EASE_OUT});
		Starling.juggler.tween(cardView, 0.5, {delay:0.7, y:cardView.y - 150, transition:Transitions.EASE_IN_OUT});
		
		// shine animation
		shineArmature = OpenBookOverlay.factory.buildArmatureDisplay("shine");
		shineArmature.touchable = false;
		shineArmature.scale = 0.1;
		shineArmature.x = 120;
		shineArmature.y = 170;
		shineArmature.animation.gotoAndPlayByTime("rotate", 0, 10);
		cardView.addChildAt(shineArmature, 0);
		Starling.juggler.tween(shineArmature, 0.3, {scale:2.5, transition:Transitions.EASE_OUT_BACK});
		
		// explode particles
		var explode:UIParticleSystem = new UIParticleSystem("explode", 2);
		explode.startSize *= 4;
		explode.x = 120;
		explode.y = 170;
		cardView.addChildAt(explode, 0);
		
		// scraps particles
		var scraps:UIParticleSystem = new UIParticleSystem("scrap", 5);
		scraps.startSize *= 4;
		scraps.x = stageWidth * 0.5;
		scraps.y = -stageHeight * 0.1;
		addChildAt(scraps, 1);
		
		appModel.sounds.addAndPlay("upgrade");
	}
	function showFeatures():void 
	{
		CardFeatureItemRenderer.IN_DETAILS = false;
		var featureLayout:TiledRowsLayout = new TiledRowsLayout();
		featureLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		featureLayout.requestedColumnCount = 2;
		featureLayout.useSquareTiles = false;
		featureLayout.gap = 20;
		featureLayout.typicalItemWidth = (stageWidth - 400 - featureLayout.gap - 1) / featureLayout.requestedColumnCount;
		
		var featureList:List = new List();
		featureList.layout = featureLayout;
		featureList.width = stageWidth - 400;
		featureList.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, 560);
		featureList.horizontalScrollPolicy = featureList.verticalScrollPolicy = ScrollPolicy.OFF;
		featureList.itemRendererFactory = function ():IListItemRenderer { return new CardFeatureItemRenderer(); }
		featureList.dataProvider = new ListCollection(CardFeatureType.getRelatedTo(card.type)._list);
		addChild(featureList);
	}
	function showEnd():void 
	{
		if( player.inTutorial() && card.type == CardTypes.INITIAL && card.level == 2 )
		{
			UserData.instance.prefs.setInt(PrefsTypes.TUTOR, PrefsTypes.T_018_CARD_UPGRADED );
			exchangeManager.dispatchEventWith(FeathersEventType.END_INTERACTION, false, {type:-100});
		}
		
		var buttonOverlay:SimpleLayoutButton = new SimpleLayoutButton();
		buttonOverlay.addEventListener(Event.TRIGGERED, buttonOverlay_triggeredHandler);
		buttonOverlay.layoutData = new AnchorLayoutData(0, 0, 0, 0);
		addChild(buttonOverlay);
	}
}

private function tutorials_finishHandler(event:Event):void 
{
	var tutorial:TutorialData = event.data as TutorialData;
	if( tutorial.name != "deck_end" )
		return;
	tutorials.removeEventListener(GameEvent.TUTORIAL_TASKS_FINISH, tutorials_finishHandler);
	UserData.instance.prefs.setInt(PrefsTypes.TUTOR, PrefsTypes.T_019_RETURN_TO_BATTLE);
	DashboardScreen.TAB_INDEX = 2;
	appModel.navigator.runBattle(0);
	close();
}

private function buttonOverlay_triggeredHandler(event:Event):void
{
	close();
}

override public function dispose():void
{
	appModel.navigator.activeScreen.visible = true;
	shineArmature.removeFromParent();
	appModel.sounds.setVolume("main-theme", 1);
	super.dispose();
}
}
}