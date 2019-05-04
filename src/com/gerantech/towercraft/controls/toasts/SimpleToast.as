package com.gerantech.towercraft.controls.toasts
{
import com.gerantech.towercraft.controls.buttons.SimpleLayoutButton;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.themes.MainTheme;

import flash.utils.setTimeout;

import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

import starling.display.Quad;
import starling.events.Event;

public class SimpleToast extends BaseToast
{
private var message:String;

public function SimpleToast(message:String)
{
	this.message = message;
	super();
}
override protected function initialize():void
{
	toastHeight = 112;
	closeAfter = 4000;
	var padding:int = 16;
	layout = new AnchorLayout();
	super.initialize();
	
	var background:SimpleLayoutButton = new SimpleLayoutButton();
	background.addEventListener(Event.TRIGGERED, background_triggeredHandler);
	background.backgroundSkin = new Quad(1, 1, 0);
	background.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	background.alpha = 0.8;
	addChild(background);
	
	var messageDisplay:RTLLabel = new RTLLabel(message, 1, "center", null, true, null, 0.8);
	messageDisplay.touchable = false;
	messageDisplay.layoutData = new AnchorLayoutData(NaN, padding, NaN, padding, NaN, 0);
	addChild(messageDisplay);
}

private function background_triggeredHandler(event:Event):void
{
	dispatchEventWith(Event.SELECT);
}
}
}