package com.gerantech.towercraft.controls.headers
{
import com.gerantech.towercraft.controls.BuildingCard;
import com.gerantech.towercraft.controls.TowersLayout;
import com.gerantech.towercraft.controls.buttons.CardButton;
import com.gerantech.towercraft.controls.buttons.SimpleLayoutButton;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.themes.MainTheme;

import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

import flash.geom.Rectangle;

import starling.animation.Transitions;
import starling.core.Starling;
import starling.events.Event;

public class DeckHeader extends TowersLayout
{
static public var HEIGHT:int;
private var padding:int;
public var cards:Vector.<CardButton>;
public var cardsBounds:Vector.<Rectangle>;

public function DeckHeader()
{
	super();
	HEIGHT = 980;
}

override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout();
	
	var backgroundDisplay:ImageLoader = new ImageLoader();
	backgroundDisplay.source = appModel.theme.popupInsideBackgroundSkinTexture;
	backgroundDisplay.scale9Grid = MainTheme.POPUP_INSIDE_SCALE9_GRID;
	backgroundDisplay.layoutData = new AnchorLayoutData(0, -150, 0, -150);
	backgroundDisplay.alpha = 0.8;
	addChild(backgroundDisplay);
	height = HEIGHT;
	
	var titleDisplay:ShadowLabel = new ShadowLabel(loc("deck_label"), 1, 0, null, null, false, null, 0.9);
	titleDisplay.layoutData = new AnchorLayoutData(120, NaN, NaN, NaN, 0);
	addChild(titleDisplay);
	
	cards = new Vector.<CardButton>();

	var numCars:int =  player.getSelectedDeck().keys().length;
	for ( var i:int = 0; i < numCars; i++ ) 
		createDeckItem(i);
}

private function createDeckItem(i:int):void
{
	var button:CardButton = new CardButton(player.getSelectedDeck().get(i));
	button.x = 32 + 256 * (i % 4);
	button.y = 220 + 290 * BuildingCard.VERICAL_SCALE * Math.floor(i / 4);
	button.addEventListener(Event.TRIGGERED, buttons_triggeredHandler);
	addChildAt(button, 1)
	cards.push(button);
}

private function buttons_triggeredHandler(event:Event):void
{
	dispatchEventWith(Event.SELECT, false, SimpleLayoutButton(event.currentTarget).getChildAt(0));
}

public function startHanging():void
{
	y = 0;
	cardsBounds = new Vector.<Rectangle>();
	for ( var i:int = 0; i < cards.length; i++ ) 
	{
		cardsBounds.push(cards[i].getIconBounds());
		cards[i].iconDisplay.rotation = -0.02;
		Starling.juggler.tween(cards[i].iconDisplay, 0.15, {delay:i * 0.05, rotation:0.015, reverse:true, repeatCount:1000, transition:Transitions.EASE_IN_OUT});
		
	}
}

public function fix():void
{
	for ( var i:int = 0; i < cards.length; i++ )
	{
		Starling.juggler.removeTweens(cards[i].iconDisplay);
		cards[i].scale = 1;
		cards[i].iconDisplay.rotation = 0;
	}
}

public function getCardIndex(touchX:Number, touchY:Number):int
{
	var ret:int = -1;
	for ( var i:int = 0; i < cardsBounds.length; i++ )
		if( cardsBounds[i].contains(touchX, touchY) )
			ret = i;
	for ( i = 0; i < cards.length; i++ )
		cards[i].scale = i==ret ? 1.1 : 1;
	return ret;
}

public function update():void
{
	for( var i:int = 0; i < cards.length; i++ ) 
		cards[i].update();	
}
}
}