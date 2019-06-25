package com.gerantech.towercraft.controls.buttons
{
import com.gerantech.towercraft.controls.CardView;
import com.gerantech.mmory.core.battle.units.Card;
import com.gerantech.mmory.core.constants.CardTypes;
import com.gerantech.mmory.core.scripts.ScriptEngine;

import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;

import flash.geom.Rectangle;

import starling.events.Event;

public class CardButton extends SimpleLayoutButton
{
private var card:Card;
public var iconDisplay:CardView;

public function CardButton(type:int)
{
	super();
	card = player.cards.get(type);
}

public function getIconBounds():Rectangle 
{
	return iconDisplay.getBounds(stage);
}

override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout();
	
	iconDisplay = new CardView();
	iconDisplay.width = 240;
	iconDisplay.type = card.type;
	iconDisplay.level = card.level;
	iconDisplay.showSlider = true;
	iconDisplay.showElixir = true;
	iconDisplay.height = iconDisplay.width * CardView.VERICAL_SCALE;
	iconDisplay.x = iconDisplay.pivotX = iconDisplay.width * 0.5;
	iconDisplay.y = iconDisplay.pivotY = iconDisplay.height * 0.5;
	addChild(iconDisplay);
	
	addEventListener(FeathersEventType.CREATION_COMPLETE, createCompleteHandler);
}

protected function createCompleteHandler(e:Event):void 
{
	removeEventListener(FeathersEventType.CREATION_COMPLETE, createCompleteHandler);
	if( card.type == CardTypes.INITIAL && player.inDeckTutorial())
		showTutorHint(0, 100);
}

public function update():void 
{
	iconDisplay.level = player.cards.get(iconDisplay.type).level;
}
}
}