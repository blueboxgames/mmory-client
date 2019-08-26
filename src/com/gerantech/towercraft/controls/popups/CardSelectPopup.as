package com.gerantech.towercraft.controls.popups
{
import com.gerantech.mmory.core.battle.units.Card;
import com.gerantech.mmory.core.constants.CardTypes;
import com.gerantech.towercraft.controls.CardView;
import com.gerantech.towercraft.controls.ClosableLayout;
import com.gerantech.towercraft.controls.buttons.MMOryButton;
import com.gerantech.towercraft.themes.MainTheme;

import feathers.controls.Button;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

import flash.geom.Rectangle;

import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

public class CardSelectPopup extends AbstractPopup
{
public var cardType:int;
private var card:Card;
private var _bounds:Rectangle;
private var detailsButton:MMOryButton;

public function CardSelectPopup(){}
override protected function initialize():void
{
	hasOverlay = false;
	layout = new AnchorLayout();
	super.initialize();

	var skin:Image = new Image(appModel.theme.roundMediumInnerSkin);
	skin.scale9Grid = MainTheme.ROUND_MEDIUM_SCALE9_GRID;
	skin.color = 0;
	skin.alpha = 0.3;
	backgroundSkin = skin;
	
	card = player.cards.get(cardType);
	
	var iconDisplay:CardView = new CardView();
	// iconDisplay.showSlider = true;
	iconDisplay.showElixir = true;
	iconDisplay.type = card.type;
	iconDisplay.level = card.level;
	iconDisplay.layoutData = new AnchorLayoutData(10, 10, data?145:270, 10);
	addChild(iconDisplay as DisplayObject);

	var upgradable:Boolean = Card.get_upgradeCards(card.level, card.rarity) <= player.getResource(card.type);
	detailsButton = new MMOryButton();
	detailsButton.height = 132;
	detailsButton.label = loc(upgradable ? "upgrade_label" : "info_label");
	detailsButton.styleName = upgradable ? MainTheme.STYLE_BUTTON_NORMAL : MainTheme.STYLE_BUTTON_NEUTRAL;
	detailsButton.layoutData = new AnchorLayoutData(NaN, 10, data?6:136, 10);
	detailsButton.addEventListener(Event.TRIGGERED, detailsButton_triggeredHandler);
	addChild(detailsButton);
}

override protected function stage_touchHandler(event:TouchEvent):void
{
	var touch:Touch = event.getTouch(stage, TouchPhase.BEGAN);
	if( touch == null || _bounds == null )
		return;
	if( !_bounds.contains(touch.globalX, touch.globalY) )
	{
		dispatchEventWith(ClosableLayout.ONLY_CLOSE);
		close();
	}
}

override protected function transitionInCompleted():void
{
	super.transitionInCompleted();
	
	backgroundSkin .alpha = 0.7;
	_bounds = getBounds(stage);

	detailsButton.alpha = 0;
	Starling.juggler.tween(detailsButton, 0.1, {alpha:1});
	
	showTutorHint();
	
	if( data )
		return;
	
	var usingButton:Button = new Button();
	usingButton.styleName = MainTheme.STYLE_BUTTON_HILIGHT;
	usingButton.label = loc("usage_label");
	//usingButton.width = 240;
	usingButton.height = 132;
	usingButton.layoutData = new AnchorLayoutData(NaN, 10, 6, 10);
	usingButton.addEventListener(Event.TRIGGERED, usingButton_triggeredHandler);
	addChild(usingButton);		
	usingButton.alpha = 0;
	Starling.juggler.tween(usingButton, 0.1, {delay:0.05, alpha:1});
	
}
private function showTutorHint () : void
{
	if( player.inDeckTutorial() && card.type == CardTypes.INITIAL )
		detailsButton.showTutorHint();
}

protected function usingButton_triggeredHandler(event:Event):void
{
	dispatchEventWith(Event.SELECT, false, card);
	close();
}		
protected function detailsButton_triggeredHandler(event:Event):void
{
	dispatchEventWith(Event.OPEN, false, card);
	close();
}
override protected function transitionOutStarted():void
{
	removeChildren(2);
	super.transitionOutStarted();
}
}
}