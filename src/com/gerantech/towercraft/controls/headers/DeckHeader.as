package com.gerantech.towercraft.controls.headers
{
import com.gerantech.towercraft.controls.BuildingCard;
import com.gerantech.towercraft.controls.TowersLayout;
import com.gerantech.towercraft.controls.buttons.CardButton;
import com.gerantech.towercraft.controls.buttons.SimpleLayoutButton;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.MainTheme;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import flash.geom.Rectangle;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;
import starling.display.Quad;
import starling.events.Event;
import starling.events.Touch;

public class DeckHeader extends TowersLayout
{
public var _height:int;
private var padding:int;
public var cards:Vector.<CardButton>;
public var cardsBounds:Vector.<Rectangle>;

public function DeckHeader()
{
	super();
	_height = 960;
	padding = 32;
}

override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout();
	
	var image:Image = new Image(appModel.theme.quadSkin);
	image.scale9Grid = MainTheme.QUAD_SCALE9_GRID;
	image.alpha = 0.7;
	image.color = 0;
	backgroundSkin = image;
	height = _height;
	
	var titleDisplay:ShadowLabel = new ShadowLabel(loc("deck_label"));
	titleDisplay.layoutData = new AnchorLayoutData(padding * 3.5, NaN, NaN, NaN, 0);
	addChild(titleDisplay);
	
	cards = new Vector.<CardButton>();
	cardsBounds = new Vector.<Rectangle>();
	var numCars:int =  player.getSelectedDeck().keys().length;
	for ( var i:int = 0; i < numCars; i++ ) 
		createDeckItem(i);
}

private function createDeckItem(i:int):void
{
	var button:CardButton = new CardButton(player.getSelectedDeck().get(i));
	button.x = padding + 256 * (i % 4);
	button.y = padding * 6 + 290 * BuildingCard.VERICAL_SCALE * Math.floor(i / 4);
	button.addEventListener(Event.TRIGGERED, buttons_triggeredHandler);
	addChildAt(button, 0)
	
	cards.push(button);
	cardsBounds.push(button.getIconBounds());
}

private function buttons_triggeredHandler(event:Event):void
{
	dispatchEventWith(Event.SELECT, false, SimpleLayoutButton(event.currentTarget).getChildAt(0));
}

public function startHanging():void
{
	y = 0;
	for ( var i:int = 0; i < cards.length; i++ ) 
	{
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

public function getCardIndex(touch:Touch):int
{
	var ret:int = -1;
	for ( var i:int = 0; i < cardsBounds.length; i++ )
		if( cardsBounds[i].contains(touch.globalX, touch.globalY) )
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