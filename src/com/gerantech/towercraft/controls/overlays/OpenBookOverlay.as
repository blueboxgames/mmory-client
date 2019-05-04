package com.gerantech.towercraft.controls.overlays
{
import com.gerantech.towercraft.controls.BuildingCard;
import com.gerantech.towercraft.controls.TileBackground;
import com.gerantech.towercraft.controls.buttons.IndicatorCard;
import com.gerantech.towercraft.controls.buttons.SimpleLayoutButton;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.utils.StrUtils;
import com.gerantech.towercraft.views.effects.UIParticleSystem;
import com.gt.towers.constants.CardFeatureType;
import com.gt.towers.constants.CardTypes;
import com.gt.towers.constants.ResourceType;
import com.gt.towers.scripts.ScriptEngine;
import com.gt.towers.utils.maps.IntIntMap;
import dragonBones.events.EventObject;
import dragonBones.objects.DragonBonesData;
import dragonBones.starling.StarlingArmatureDisplay;
import dragonBones.starling.StarlingEvent;
import dragonBones.starling.StarlingFactory;
import dragonBones.starling.StarlingTextureData;
import feathers.controls.AutoSizeMode;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import flash.geom.Rectangle;
import flash.text.engine.ElementFormat;
import flash.utils.getTimer;
import flash.utils.setTimeout;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.events.Event;
import starling.extensions.ColorArgb;
import starling.textures.SubTexture;
import starling.textures.Texture;

public class OpenBookOverlay extends EarnOverlay
{
public static var factory: StarlingFactory;
public static var dragonBonesData:DragonBonesData;

private var rewardKeys:Vector.<int>;
private var rewardItems:Vector.<BuildingCard>;
private var bookArmature:StarlingArmatureDisplay;
private var shineArmature:StarlingArmatureDisplay;
private var buttonOverlay:SimpleLayoutButton;
private var readyToWait:Boolean;
private var lastTappedTime:int;
private var frequentlyTapped:int;
private var rewardType:int;
private var rewardRarity:int;
private var titleDisplay:ShadowLabel;
private var descriptionDisplay:RTLLabel;
private var sliderDisplay:IndicatorCard;
private var collectedItemIndex:int = -1;

public function OpenBookOverlay(type:int)
{
	super(type);
	createFactory();
}

public static function createFactory():void
{
	if( factory != null )
		return;
	factory = new StarlingFactory();
	dragonBonesData = factory.parseDragonBonesData(AppModel.instance.assets.getObject("packs_ske"));
	factory.parseTextureAtlasData(AppModel.instance.assets.getObject("packs_tex"), AppModel.instance.assets.getTexture("packs_tex"));
}			

static public function getBookScale(type:int):Number
{
	return 0.9 + ((type % 10) / 5 ) * 0.2;
}

override protected function initialize():void
{
	super.initialize();
	appModel.navigator.activeScreen.visible = false;// hide back items for better perfomance
	autoSizeMode = AutoSizeMode.STAGE;
	
	layout = new AnchorLayout();
//	overlay.alpha = 0;
	Starling.juggler.tween(overlay, 0.3, { alpha:1, onStart:transitionInStarted, onComplete:transitionInCompleted });
}
override protected function defaultOverlayFactory(color:uint = 0, alpha:Number = 0.4):DisplayObject
{
	var overlay:TileBackground = new TileBackground("home/pistole-tile", 0.3, true, stage.color);
	overlay.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	overlay.touchable = true;
	return overlay;
}

override protected function addedToStageHandler(event:Event):void
{
	super.addedToStageHandler(event);
	closeOnStage = false;
	if( dragonBonesData == null )
		return;
	
	appModel.sounds.setVolume("main-theme", 0.3);
	
	bookArmature = factory.buildArmatureDisplay(type.toString());
	bookArmature.touchable = false;
	bookArmature.x = stage.stageWidth * 0.5;
	bookArmature.y = stage.stageHeight * 0.5;
	bookArmature.scale = 2;
	bookArmature.addEventListener(EventObject.COMPLETE, openAnimation_completeHandler);
	bookArmature.addEventListener(EventObject.SOUND_EVENT, openAnimation_soundEventHandler);
	bookArmature.animation.gotoAndPlayByTime("appear", 0, 1);
	addChild(bookArmature);
	Starling.juggler.tween(bookArmature, 0.4, {delay:0.2, y:stage.stageHeight * 0.85, transition:Transitions.EASE_IN});
	
	shineArmature = factory.buildArmatureDisplay("shine");
	shineArmature.touchable = false;
	shineArmature.visible = false;
	shineArmature.scale = 3;
	shineArmature.x = 348;
	shineArmature.y = stage.stageHeight * 0.85 - 580;
	addChild(shineArmature);
	
	sliderDisplay = new IndicatorCard("ltr", type);
	sliderDisplay.touchable = false;
	sliderDisplay.visible = false;
	sliderDisplay.width = 340;
	sliderDisplay.height = 84;
	sliderDisplay.y = shineArmature.y + 96;
	addChild(sliderDisplay);

	titleDisplay = new ShadowLabel("", 1, 0, "left", null, false, null, 1.4);
	titleDisplay.touchable = false;
	titleDisplay.visible = false;
	titleDisplay.width = 600;
	addChild(titleDisplay);
	
	descriptionDisplay = new ShadowLabel("", 1, 0, "left", null, false, null, 0.9);
	descriptionDisplay.y = shineArmature.y - 82;
	descriptionDisplay.touchable = false;
	descriptionDisplay.visible = false;
	descriptionDisplay.width = 600;
	addChild(descriptionDisplay);
}

override public function set outcomes(value:IntIntMap):void 
{
	super.outcomes = value;
	buttonOverlay = new SimpleLayoutButton();
	buttonOverlay.addEventListener(Event.TRIGGERED, buttonOverlay_triggeredHandler);
	buttonOverlay.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	addChild(buttonOverlay);
	
	rewardItems = new Vector.<BuildingCard>();
	rewardKeys = outcomes.keys();
	if( readyToWait )
		bookArmature.animation.gotoAndPlayByTime("wait", 0, -1);
}

// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= EVENT HANDLERS =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
protected function openAnimation_soundEventHandler(event:StarlingEvent):void
{
	switch( event.eventObject.name )
	{
		case "reward-shown":
			showDetails();
			break;
		
		default:
			appModel.sounds.addAndPlay(event.eventObject.name);
	}
}
protected function openAnimation_completeHandler(event:StarlingEvent):void
{
	if( event.eventObject.animationState.name == "appear" )
	{
		readyToWait = true;
		if( outcomes != null )
		{
			if( player.get_arena(0) < 2 )
				bookArmature.addEventListener(EventObject.LOOP_COMPLETE, openAnimation_loopCompleteHandler);
			bookArmature.animation.gotoAndPlayByTime("wait", 0, -1);
		}
	}
	else if( event.eventObject.animationState.name == "hide" )
	{
		close();
	}
}
protected function openAnimation_loopCompleteHandler(event:StarlingEvent) : void 
{
 	//trace(event.eventObject.animationState.name, event.eventObject.animationState.currentPlayTimes);
	if( event.eventObject.animationState.name == "wait" && event.eventObject.animationState.currentPlayTimes == 2 )
	{
		bookArmature.removeEventListener(EventObject.LOOP_COMPLETE, openAnimation_loopCompleteHandler);
		appModel.navigator.addOverlay(new TutorialTouchOverlay(null, bookArmature.x, bookArmature.y - 100, this));
	}
}
protected function buttonOverlay_triggeredHandler():void
{
	grabLastReward();
	if( collectedItemIndex < outcomes.keys().length - 1 )
	{
		pullCard();
		lastTappedTime = getTimer();
	}
	else if( collectedItemIndex == rewardKeys.length - 1 && lastTappedTime < getTimer() - 1200 )
	{
		buttonOverlay.removeEventListener(Event.TRIGGERED, buttonOverlay_triggeredHandler);
		setTimeout(bookArmature.animation.gotoAndPlayByTime, 400, "hide", 0, 1);
		hideAllRewards();
	}
}

private function pullCard() : void
{
	collectedItemIndex ++;
	rewardType = rewardKeys[collectedItemIndex];
	rewardRarity = ScriptEngine.getInt(CardFeatureType.F00_RARITY, rewardType);
	
	// play SFXs
	if( ResourceType.isCard(rewardType) )
		appModel.sounds.addAndPlay("card-r-" + rewardRarity);
	else
		appModel.sounds.addAndPlay("card-" + rewardType);
	
	resetElements();	
	bookArmature.animation.gotoAndPlayByTime("open", 0, 1);
	
	// expload in book
	var explode:UIParticleSystem = new UIParticleSystem("explode");
	explode.startSize *= 4;
	explode.scaleY = 0.8;
	explode.speedVariance = 0;
	explode.emitAngle = 0.8;
	explode.emitAngleVariance = 2;
	setTimeout(bookArmature.addChildAt, 200, explode, 3);
	
	// change card
	var texture:Texture = Assets.getTexture("cards/" + rewardType, "gui");
	var subtexture:SubTexture = new SubTexture(texture, new Rectangle(0, 0, texture.width, texture.height));
	StarlingTextureData(bookArmature.armature.getSlot("template-card").skinSlotData.getDisplay("cards/template-card").texture).texture = subtexture;
	
	// change rarity color
	texture = Assets.getTexture("cards/bevel-card-back-" + rewardRarity, "gui");
	subtexture = new SubTexture(texture, new Rectangle(0, 0, texture.width, texture.height));
	StarlingTextureData(bookArmature.armature.getSlot("bevel-card-back").skinSlotData.getDisplay("cards/bevel-card").texture).texture = subtexture;
	
	var cardDisply:BuildingCard = new BuildingCard(false, false, true, false);
	cardDisply.width = 328;
	cardDisply.height = cardDisply.width * BuildingCard.VERICAL_SCALE;
	cardDisply.x = shineArmature.x - cardDisply.width * 0.5;
	cardDisply.y = shineArmature.y - cardDisply.height * 0.5;
	cardDisply.touchable = false;
	cardDisply.visible = false;
	addChild(cardDisply);
	cardDisply.setData(rewardType, 1, outcomes.get(rewardType));

	rewardItems[collectedItemIndex] = cardDisply;
}

private function showDetails() : void 
{
	var cardDisply:BuildingCard = rewardItems[collectedItemIndex];

	shineArmature.animation.gotoAndPlayByTime("rotate", 0, 10);
	shineArmature.animation.timeScale = 0.5;
	
	titleDisplay.text = loc(( ResourceType.isCard(rewardType) ? "card_title_" : "resource_title_" ) + rewardType);
	titleDisplay.visible = true;
	titleDisplay.x = 400;
	titleDisplay.y = shineArmature.y + (rewardRarity > 0 ? -198 : (ResourceType.isCard(rewardType) ? -30 : 100));
	titleDisplay.alpha = 0;
	Starling.juggler.tween(titleDisplay, 0.3, {alpha:1, x:552, transition:Transitions.EASE_OUT_BACK});
	
	if( ResourceType.isCard(rewardType) )
	{
		if( rewardRarity > 0 )
		{
			descriptionDisplay.elementFormat = new ElementFormat(descriptionDisplay.fontDescription, descriptionDisplay.fontSize, CardTypes.getRarityColor(rewardRarity));
			descriptionDisplay.text = loc("card_rarity_" + rewardRarity);
			descriptionDisplay.visible = true;
			descriptionDisplay.x = 400;
			descriptionDisplay.alpha = 0;
			Starling.juggler.tween(descriptionDisplay, 0.3, {delay:0.2, alpha:1, x:550, transition:Transitions.EASE_OUT_BACK});
		}
		
		sliderDisplay.type = rewardType;
		sliderDisplay.setData(sliderDisplay.minimum, player.getResource(rewardType) - outcomes.get(rewardType),	sliderDisplay.maximum);
		sliderDisplay.visible = true;
		sliderDisplay.x = 400;
		sliderDisplay.alpha = 0;
		Starling.juggler.tween(sliderDisplay, 0.3, {delay:0.1, alpha:1, x:550, transition:Transitions.EASE_OUT_BACK});
		sliderDisplay.setData(sliderDisplay.minimum, player.getResource(rewardType),			sliderDisplay.maximum, 1);
	}
	
	cardDisply.visible = true;

	if( rewardRarity > 0 )
	{
		var kira:UIParticleSystem = new UIParticleSystem("kira", 1);
		kira.name = "kira";
		kira.startSize *= 4;
		kira.capacity = rewardRarity == 2 ? 200 : 80;
		kira.speed = rewardRarity == 2 ? 180 : 30;
		kira.startColor = rewardRarity == 2 ? new ColorArgb(1, 0, 0.8, 0.9) : new ColorArgb(1, 0.5, 0, 0.5);
		kira.x = cardDisply.width * 0.5;
		kira.y = cardDisply.height * 0.5;
		cardDisply.addChild(kira);
	}
}


private function grabLastReward() : void
{
	if( rewardItems.length <= 0 )
		return;
	var card:BuildingCard = rewardItems[rewardItems.length - 1]
	if( card == null )
		return;
	resetElements();
	card.visible = true;
	var kira:DisplayObject = card.getChildByName("kira");
	if( kira != null )
		kira.removeFromParent(true);

	var index:int = rewardItems.indexOf(card);
	var numCol:int = rewardKeys.length > 6 ? 4 : 3;
	var padding:int = numCol == 4 ? 40 : 80;
	var cellWidth:int = (stageWidth - ((numCol + 1) * padding) ) / numCol;// ((stageWidth - reward.width * 0.4 * scal - paddingH * 2) / (numCol - 1));
	var i:int = index % numCol;
	var j:int = Math.floor(index / numCol);
	Starling.juggler.tween(card, 0.5, {width:cellWidth, height:cellWidth * BuildingCard.VERICAL_SCALE, x:i * (cellWidth + padding) + padding, y:j * (cellWidth * BuildingCard.VERICAL_SCALE + padding * 1.2) + padding, transition:Transitions.EASE_OUT_BACK});
}

private function hideAllRewards():void
{
	for(var i:int=0; i < rewardItems.length; i++)
		Starling.juggler.tween(rewardItems[i], 0.4, {delay:0.1 * i, y:0, alpha:0, transition:Transitions.EASE_IN_BACK});
}


private function resetElements():void 
{
	bookArmature.animation.gotoAndStopByFrame("open", 0);
	
	titleDisplay.visible = false;
	sliderDisplay.visible = false;
	shineArmature.visible = false;
	descriptionDisplay.visible = false;
	Starling.juggler.removeTweens(descriptionDisplay);
	Starling.juggler.removeTweens(titleDisplay);
	shineArmature.animation.stop();
}

override public function dispose():void
{
	appModel.navigator.activeScreen.visible = true;
	appModel.sounds.setVolume("main-theme", 1);
	if( buttonOverlay != null )
		buttonOverlay.removeEventListener(Event.TRIGGERED, buttonOverlay_triggeredHandler);
	bookArmature.removeEventListener(EventObject.SOUND_EVENT, openAnimation_soundEventHandler);
	bookArmature.removeEventListener(dragonBones.events.EventObject.COMPLETE, openAnimation_completeHandler);
	super.dispose();
}
}
}