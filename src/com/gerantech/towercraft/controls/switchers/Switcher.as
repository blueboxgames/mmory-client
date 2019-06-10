package com.gerantech.towercraft.controls.switchers
{
import com.gerantech.towercraft.controls.TowersLayout;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.themes.MainTheme;
import com.gerantech.towercraft.utils.StrUtils;

import feathers.controls.Button;
import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

import starling.animation.Transitions;
import starling.core.Starling;
import starling.events.Event;

public class Switcher extends TowersLayout
{
public var min:int;
public var max:int;
public var stepInterval:int;
public var labelStringFactory:Function;
private var _value:int;

private var labelDisplay:RTLLabel;

public function Switcher(min:int = 0, value:int = 5, max:int = 10, stepInterval:int = 1)
{
	this.min = min;
	this.value = value;
	this.max = max;
	this.stepInterval = stepInterval;
}

override protected function initialize():void
{
	super.initialize();
	
	if( labelStringFactory == null )
		labelStringFactory = defaulLabelStringFactory;
	
	layout = new AnchorLayout();
	var controlSize:int = 96;
	minHeight = controlSize;
	minWidth = 120;
	
	var skin:ImageLoader = new ImageLoader();
	skin.source = appModel.theme.backgroundSliderSkin;
	skin.scale9Grid = MainTheme.SLIDER_SCALE9_GRID;
	skin.layoutData = new AnchorLayoutData(5, 5, 5, 5);
	addChild(skin);
	
	var leftButton:Button = new Button();
	leftButton.label = ">";
	leftButton.width = controlSize;
	leftButton.styleName = MainTheme.STYLE_BUTTON_NEUTRAL;
	leftButton.layoutData = new AnchorLayoutData(0, NaN, 0, 0);
	leftButton.addEventListener(Event.TRIGGERED, leftButton_triggerdHandler);
	addChild(leftButton);
	
	var rightButton:Button = new Button();
	rightButton.label = "<";
	rightButton.width = controlSize;
	rightButton.styleName = MainTheme.STYLE_BUTTON_NEUTRAL;
	rightButton.layoutData = new AnchorLayoutData(0, 0, 0, NaN);
	rightButton.addEventListener(Event.TRIGGERED, rightButton_triggerdHandler);
	addChild(rightButton);
	
	labelDisplay = new RTLLabel(labelStringFactory(value), 1, "center", null, false, null, 0.8);
	labelDisplay.pixelSnapping = false;
	labelDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, 0);
	addChild(labelDisplay);
}

protected function defaulLabelStringFactory(value:int):String
{
	return StrUtils.getNumber(value);
}

private function leftButton_triggerdHandler(event:Event):void
{
	value = Math.max(Math.min(max, value-stepInterval), min);
}

private function rightButton_triggerdHandler(event:Event):void
{
	value = Math.max(Math.min(max, value+stepInterval), min);
}


public function get value():int
{
	return _value;
}
public function set value(val:int):void
{
	if( _value == val )
		return;
	
	_value = val;
	if( labelDisplay )
	{
		Starling.juggler.removeTweens(labelDisplay);
		labelDisplay.text = labelStringFactory(value);
		labelDisplay.scale = 0;
		Starling.juggler.tween(labelDisplay, 0.2, {scale:1, transition:Transitions.EASE_OUT_BACK});
	}
}
}
}