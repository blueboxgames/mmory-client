package com.gerantech.towercraft.controls
{
import com.gerantech.towercraft.controls.buttons.Indicator;
import com.gerantech.towercraft.controls.buttons.IndicatorCard;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.MainTheme;
import com.gerantech.towercraft.utils.StrUtils;
import com.gt.towers.battle.units.Card;
import com.gt.towers.constants.CardFeatureType;
import com.gt.towers.constants.CardTypes;
import com.gt.towers.constants.ResourceType;
import com.gt.towers.scripts.ScriptEngine;
import feathers.controls.ImageLoader;
import feathers.controls.LayoutGroup;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import flash.geom.Rectangle;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.events.Event;

public class BuildingCard extends TowersLayout
{
public static var VERICAL_SCALE:Number = 1.25;

public var backgroundDisplayFactory:Function;
public var iconDisplayFactory:Function;
public var levelDisplayFactory:Function;
public var sliderDisplayFactory:Function;
public var countDisplayFactory:Function;
public var elixirDisplayFactory:Function;
public var rarityDisplayFactory:Function;
public var coverDisplayFactory:Function;

public var type:int = -1;
public var level:int = 0;
public var rarity:int = 0;
public var count:int = 0;
public var elixirSize:int = 0;
public var availablity:int = 0;

protected var showLevel:Boolean = true;
protected var showSlider:Boolean = true;
protected var showCount:Boolean = false;
protected var showElixir:Boolean = true;
protected var showRarity:Boolean = true;

protected var padding:int;
protected var backgroundDisaplay:ImageLoader;
protected var iconDisplay:ImageLoader;
protected var labelsContainer:LayoutGroup;
protected var levelDisplay:RTLLabel;
protected var levelBackground:ImageLoader;
protected var sliderDisplay:Indicator;
protected var coverDisplay:ImageLoader;
protected var rarityDisplay:ImageLoader;
protected var countDisplay:ShadowLabel;

public function BuildingCard(showLevel:Boolean, showSlider:Boolean, showCount:Boolean, showElixir:Boolean)
{
	super();
	this.showLevel = showLevel;
	this.showSlider = showSlider;
	this.showCount = showCount;
	this.showElixir = showElixir;
	labelsContainer = new LayoutGroup();
}

override protected function initialize():void
{
	super.initialize();
	
	layout= new AnchorLayout();
	padding = 16;
	
	labelsContainer.layout = new AnchorLayout();
	labelsContainer.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	
	if( backgroundDisplayFactory == null )
		backgroundDisplayFactory = defaultBackgroundDisplayFactory;
	if( iconDisplayFactory == null )
		iconDisplayFactory = defaultIconDisplayFactory;
	if( levelDisplayFactory == null )
		levelDisplayFactory = defaultLevelDisplayFactory;
	if( sliderDisplayFactory == null )
		sliderDisplayFactory = defaultSliderDisplayFactory;
	if( countDisplayFactory == null )
		countDisplayFactory = defaultCountDisplayFactory;
	if( elixirDisplayFactory == null )
		elixirDisplayFactory = defaultElixirDisplayFactory;
	if( rarityDisplayFactory == null )
		rarityDisplayFactory = defaultRarityDisplayFactory;
	if( coverDisplayFactory == null )
		coverDisplayFactory = defaultCoverDisplayFactory;

	addEventListener(FeathersEventType.CREATION_COMPLETE, createCompleteHandler);
	addEventListener(Event.ADDED, addedHandler);
//	callFactories();
}


protected function addedHandler():void
{
	if( labelsContainer )
		addChild(labelsContainer);	
}
protected function createCompleteHandler():void
{
	removeEventListener(FeathersEventType.CREATION_COMPLETE, createCompleteHandler);
	height = width * VERICAL_SCALE;
}

//       _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-  DATA  -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
public function setData(type:int, level:int = 1, count:int = 1):void
{
	if( this.type == type && this.level == level && this.count == count )
		return;
	
	if( type < 0 )
		return;
	
	this.type = type;
	this.availablity = game.getBuildingAvailablity(type);
	if( ResourceType.isCard(type) )
		this.level = this.availablity == CardTypes.AVAILABLITY_EXISTS && level == 1 ? player.cards.get(type).level : level;
	this.rarity = ScriptEngine.getInt(CardFeatureType.F00_RARITY, type, 1);
	this.count = count;// != 1 ? building.troopsCount : count;
	this.elixirSize = ScriptEngine.getInt(CardFeatureType.F02_ELIXIR_SIZE, type, 1);
	callFactories();
}

private function callFactories() : void 
{
	//if( backgroundDisplayFactory != null )
	//	backgroundDisplayFactory();
	if( iconDisplayFactory != null )
		iconDisplayFactory();
	if( levelDisplayFactory != null )
		levelDisplayFactory();
	if( rarityDisplayFactory != null )
		rarityDisplayFactory();
	if( coverDisplayFactory != null )
		coverDisplayFactory();
	if( sliderDisplayFactory != null )
		sliderDisplayFactory();
	if( countDisplayFactory != null )
		countDisplayFactory();
	if( elixirDisplayFactory != null )
		elixirDisplayFactory();
}

//       _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-  BACKGROUND  -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
protected function defaultBackgroundDisplayFactory() : ImageLoader
{
	if( availablity != CardTypes.AVAILABLITY_NOT && type < 1000 )
		return null;
	
	if( backgroundDisaplay == null )
	{
		backgroundDisaplay = new ImageLoader();
		backgroundDisaplay.color = 0xAAAA77;
		backgroundDisaplay.layoutData = new AnchorLayoutData(padding, padding, padding, padding);
		backgroundDisaplay.scale9Grid = MainTheme.SMALL_BACKGROUND_SCALE9_GRID;
		backgroundDisaplay.source = Assets.getTexture("theme/popup-inside-background-skin");
		addChildAt(backgroundDisaplay, 0);		
	}
	return backgroundDisaplay;
}

//       _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-  ICON  -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
protected function defaultIconDisplayFactory() : ImageLoader 
{
	if( iconDisplay == null )
	{
		iconDisplay = new ImageLoader();
		iconDisplay.pixelSnapping = false;
		iconDisplay.layoutData = new AnchorLayoutData(padding, padding, padding, padding);
		addChild(iconDisplay);
	}

	if( availablity != CardTypes.AVAILABLITY_EXISTS )
	{
		if( iconDisplay.filter == null )
		{
		/*	var f:ColorMatrixFilter = new ColorMatrixFilter();
			f.adjustSaturation( -1 );
			iconDisplay.filter = f;*/
		}
	}
	else
	{
		iconDisplay.filter = null;
	}
	iconDisplay.source = Assets.getTexture("cards/" + type, "gui");
	return iconDisplay;
}


//       _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-  LEVEL  -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
protected function defaultLevelDisplayFactory() : RTLLabel
{
	if( !showLevel || !ResourceType.isCard(type) || availablity != CardTypes.AVAILABLITY_EXISTS || type < 0 || level <= 0 )
		return null;
	
	if( levelDisplay == null )
	{
		levelDisplay = new RTLLabel(null, rarity == 0?1:0, null, null, false, null, 0.8);
		levelDisplay.alpha = 0.8;
		levelDisplay.height = 52;
		levelDisplay.layoutData = new AnchorLayoutData(NaN, NaN, 25, NaN, 0);
		labelsContainer.addChild(levelDisplay);
	}
	levelDisplay.text = loc("level_label", [level]);
	
	if( levelBackground == null )
	{
		levelBackground = new ImageLoader();
		levelBackground.maintainAspectRatio = false
		levelBackground.source = Assets.getTexture("cards/rarity-skin-" + rarity, "gui");
		levelBackground.alpha = 0.7;
		levelBackground.height = 54;
		levelBackground.layoutData = new AnchorLayoutData(NaN, padding, padding, padding);
		addChildAt(levelBackground, Math.min(1, numChildren));
	}
	else
	{
		levelBackground.source = Assets.getTexture("cards/rarity-skin-" + rarity, "gui");
	}
	return levelDisplay;
}


//       _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-  COVER  -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
protected function defaultCoverDisplayFactory() : ImageLoader 
{
	if( coverDisplay == null )
	{
		coverDisplay = new ImageLoader();
		coverDisplay.scale9Grid = new Rectangle(47, 47, 4, 4);
		coverDisplay.source = Assets.getTexture("cards/bevel-card");
		coverDisplay.layoutData = new AnchorLayoutData(0, 0, 0, 0);
		addChild(coverDisplay);
	}
	return coverDisplay;
}

//       _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-  SLIDER  -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
protected function defaultSliderDisplayFactory() : Indicator
{
	if( !showSlider )
		return null;
	
	if( ResourceType.isCard(type) )
	{
		if( this.availablity < CardTypes.AVAILABLITY_WAIT )
			return null;
		
		var card:Card = player.cards.get(type);
		if( card == null )
			return null;
	}
	if( sliderDisplay == null )
	{
		if( ResourceType.isCard(type) )
			sliderDisplay = new IndicatorCard("ltr", type);
		else
			sliderDisplay = new Indicator("ltr", type, false, false);
		sliderDisplay.height = 60;
		sliderDisplay.layoutData = new AnchorLayoutData(NaN, 10, -56, 10);
		addChild(sliderDisplay);
	}
	else
	{
		sliderDisplay.setData(0, -1, sliderDisplay.maximum);
	}
	return sliderDisplay;
}
public function punchSlider() : void
{
	if( sliderDisplay != null )
	{
		sliderDisplay.alpha = 0;
		Starling.juggler.tween(sliderDisplay, 1.0, {alpha:1, repeatCount:3});
	}
}

//       _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-  RARITY  -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
protected function defaultRarityDisplayFactory() : ImageLoader
{
	if( !showRarity || rarity == 0 || availablity != CardTypes.AVAILABLITY_EXISTS )
	{
		if( rarityDisplay != null )
			rarityDisplay.removeFromParent();
		return null;
	}
	if( rarityDisplay == null )
	{
		rarityDisplay = new ImageLoader();
		rarityDisplay.touchable = false;
		rarityDisplay.scale9Grid = new Rectangle(39, 39, 4, 4);
		rarityDisplay.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	}
	addChild(rarityDisplay);
	rarityDisplay.source = Assets.getTexture("cards/hilight", "gui");
	rarityDisplay.color = CardTypes.getRarityColor(rarity);
	return rarityDisplay;
}
//       _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-  COUNT  -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
protected function defaultCountDisplayFactory() : ShadowLabel
{
	if( !showCount || availablity != CardTypes.AVAILABLITY_EXISTS || type < 0 || count < 1 )
		return null;
	
	if( countDisplay == null )
	{
		countDisplay = new ShadowLabel(null, 1, 0, null, "ltr", false, null, 1.4);
		countDisplay.layoutData = new AnchorLayoutData(NaN, padding * 1.8, padding * 0.6);
		labelsContainer.addChild(countDisplay);
	}
	countDisplay.text = (ResourceType.isCard(type) ? "x" : "+") + StrUtils.getNumber(count);
	return countDisplay;
}


//       _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-  ELIXIR SIZE  -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
protected function defaultElixirDisplayFactory():void
{
	if( !showElixir || availablity == CardTypes.AVAILABLITY_NOT || level <= 0 )
		return;
	
	var elixirBackground:ImageLoader = new ImageLoader();
	elixirBackground.source = Assets.getTexture("cards/elixir-" + elixirSize, "gui");
	elixirBackground.width = elixirBackground.height = 90;
	elixirBackground.layoutData = new AnchorLayoutData( -padding * 0.5, NaN, NaN, -padding * 0.3);
	addChild(elixirBackground);
}
}
}