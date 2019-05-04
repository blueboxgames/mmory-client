package com.gerantech.towercraft.controls.overlays
{
import com.gerantech.towercraft.controls.BuildingCard;
import com.gerantech.towercraft.controls.buttons.LeagueButton;
import com.gerantech.towercraft.controls.groups.Devider;
import com.gerantech.towercraft.controls.items.CardItemRenderer;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import feathers.controls.Button;
import feathers.controls.List;
import feathers.controls.ScrollPolicy;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.layout.AnchorLayout;
import feathers.layout.TiledRowsLayout;
import feathers.layout.VerticalAlign;
import flash.utils.setTimeout;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.events.Event;

public class LeagueChangeOverlay extends BaseOverlay
{
private var oldArena:int;
private var newArena:int;
private var leagueIconDisplay:LeagueButton;
private var titleDisplay:ShadowLabel;
private var descriptionDisplay:RTLLabel;
private var cardsDisplay:List;
private var closeButton:Button;
private var initializeStarted:Boolean;

public function LeagueChangeOverlay(oldArena:int, newArena:int)
{
	super();
	this.oldArena = oldArena;
	this.newArena = newArena;
}
override protected function initialize():void
{
	closeOnStage = false;
	if( !initializingStarted )
		super.initialize();
	if( stage == null || appModel.assets.isLoading || initializingCompleted )
		return;

	layout = new AnchorLayout();
	var padding:int = 28;
	appModel.sounds.addAndPlay("outcome-"+(newArena>oldArena?"victory":"defeat"));
	
	titleDisplay = new ShadowLabel(loc(oldArena < newArena?"arena_up":"arena_down") + " " +loc("arena_title_" + newArena), 1, 0, "center", null, false, "center", 1.4);
	titleDisplay.shadowDistance = 8;
	titleDisplay.width = stage.stageWidth * 0.9;
	titleDisplay.x = stage.stageWidth * 0.05;
	titleDisplay.y = stage.stageHeight * 0.2;
	titleDisplay.alpha = 0;
	Starling.juggler.tween(titleDisplay, 0.7, {delay:0.2, y:stage.stageHeight * 0.15, alpha:1.2, transition:newArena > oldArena?Transitions.EASE_OUT_ELASTIC:Transitions.EASE_OUT});
	addChild(titleDisplay);
	
	descriptionDisplay = new RTLLabel(loc(newArena > oldArena?"arena_chance_to":"arena_motivation"), 0xDDDDDD, "center", null, false, null, 0.9);
	descriptionDisplay.x = stage.stageWidth * 0.05;
	descriptionDisplay.width = stage.stageWidth * 0.9;
	descriptionDisplay.alpha = 0;
	descriptionDisplay.y = stage.stageHeight * 0.48;
	Starling.juggler.tween(descriptionDisplay, 0.7, {delay:0.3, y:stage.stageHeight * 0.52, alpha:1.2, transition:newArena > oldArena?Transitions.EASE_OUT_ELASTIC:Transitions.EASE_OUT});
	addChild(descriptionDisplay);
	
	var cardsLayout:TiledRowsLayout = new TiledRowsLayout();
	cardsLayout.requestedColumnCount = 4;
	cardsLayout.gap = padding;
	cardsLayout.typicalItemWidth = padding * 6;
	cardsLayout.typicalItemHeight = cardsLayout.typicalItemWidth * BuildingCard.VERICAL_SCALE;
	cardsLayout.horizontalAlign = "center";
	cardsLayout.verticalAlign = VerticalAlign.JUSTIFY;
	
	cardsDisplay = new List();
	if( newArena > oldArena )
	{
		cardsDisplay.layout = cardsLayout;
		cardsDisplay.x = stage.stageWidth * 0.05;
		cardsDisplay.width = stageWidth
		cardsDisplay.height = cardsLayout.typicalItemHeight * 2 + cardsLayout.gap;
		cardsDisplay.horizontalScrollPolicy = cardsDisplay.verticalScrollPolicy = ScrollPolicy.OFF;
		cardsDisplay.dataProvider = new ListCollection(player.availabledCards(newArena, 0));
		cardsDisplay.itemRendererFactory = function ():IListItemRenderer { return new CardItemRenderer ( false, false ); };
		cardsDisplay.alpha = 0;
		cardsDisplay.y = stage.stageHeight * 0.55;
		Starling.juggler.tween(cardsDisplay, 0.7, {delay:0.5, y:stage.stageHeight * 0.58, alpha:1.2, transition:Transitions.EASE_OUT_BACK});
		addChild(cardsDisplay);
	}
	
	closeButton = new Button();
	closeButton.label = loc("close_button");
	closeButton.width = 220;
	closeButton.height = 110;
	closeButton.alpha = 0;
	closeButton.x = (stage.stageWidth - closeButton.width) * 0.5;
	closeButton.y = stage.stageHeight * 0.77;
	closeButton.addEventListener(Event.TRIGGERED, closeButton_triggeredHandler);
	Starling.juggler.tween(closeButton, 0.5, {delay:2, y:stage.stageHeight * 0.75, alpha:1.2, transition:Transitions.EASE_OUT});
	addChild(closeButton);
	
	leagueIconDisplay = new LeagueButton(newArena);
	leagueIconDisplay.touchable = false;
	leagueIconDisplay.alpha = 0;
	leagueIconDisplay.x = stage.stageWidth * 0.5;
	leagueIconDisplay.y = stage.stageHeight * 0.36;
	leagueIconDisplay.scale = 1;
	addChild(leagueIconDisplay);
	Starling.juggler.tween(leagueIconDisplay, 1.3, {scale:1.6, alpha:1.2, transition:newArena > oldArena?Transitions.EASE_OUT_ELASTIC:Transitions.EASE_OUT});
	
	initializingCompleted = true;
}

private function closeButton_triggeredHandler():void
{
	Starling.juggler.tween(closeButton, 0.5,		{delay:0.0, y:stage.stageHeight * 0.70, alpha:0, transition:Transitions.EASE_IN_BACK});
	Starling.juggler.tween(cardsDisplay, 0.5,		{delay:0.1, y:stage.stageHeight * 0.53, alpha:0, transition:Transitions.EASE_IN_BACK});
	Starling.juggler.tween(titleDisplay, 0.5,		{delay:0.2, y:stage.stageHeight * 0.30, alpha:0, transition:Transitions.EASE_IN_BACK});
	Starling.juggler.tween(descriptionDisplay, 0.5, {delay:0.3, y:stage.stageHeight * 0.47, alpha:0, transition:Transitions.EASE_IN_BACK});
	Starling.juggler.tween(leagueIconDisplay, 0.5,	{delay:0.3, scale:0.0, alpha:0, transition:Transitions.EASE_IN_BACK});
	setTimeout(close, 1000, true);
}


override protected function defaultOverlayFactory(color:uint = 0, alpha:Number = 0.4):DisplayObject
{
	var overlay:Devider = new Devider(newArena>oldArena?0x001144:0x441111);
	overlay.alpha = 0.85;
	overlay.width = stage.width * 3;
	overlay.height = stage.height * 3;
	overlay.x = -overlay.width * 0.5;
	overlay.y = -overlay.height * 0.5;
	return overlay;
}
}
}