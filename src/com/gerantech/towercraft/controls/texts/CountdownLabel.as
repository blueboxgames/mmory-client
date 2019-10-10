package com.gerantech.towercraft.controls.texts 
{
import com.gerantech.towercraft.controls.TowersLayout;
import com.gerantech.towercraft.utils.StrUtils;

import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.RelativePosition;

import flash.utils.setInterval;

import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;

/**
* ...
* @author Mansour Djawadi
*/
public class CountdownLabel extends TowersLayout 
{
public var localString:String = null;
public var iconPosition:String = "left";
private var iconDisplay:ImageLoader;
private var needleDisplay:Image;
private var labelDisplay:RTLLabel;
private var _scale:Number;
private var intervalId:uint;
private var timeoutId:uint;
private var _time:uint;
private var padding:Number;

public function CountdownLabel() { super(); height = 84;}
override protected function initialize() : void
{
	padding = height * 0.15;
	layout = new AnchorLayout();
		
	iconDisplay = new ImageLoader();
	iconDisplay.source = appModel.assets.getTexture("timer");
	iconDisplay.layoutData = new AnchorLayoutData(0, iconPosition == RelativePosition.LEFT ? NaN : 0, 0, iconPosition == RelativePosition.LEFT ? 0 : NaN);
	iconDisplay.height = iconDisplay.width = height;
	addChild(iconDisplay);
	
	needleDisplay = new Image(appModel.assets.getTexture("timer-needle"));
	needleDisplay.pivotX = needleDisplay.width * 0.5;
	needleDisplay.pivotY = needleDisplay.height * 0.5;
	needleDisplay.height = height * 0.6;
	needleDisplay.scaleX = needleDisplay.scaleY;
	needleDisplay.x = iconPosition == RelativePosition.LEFT ? height * 0.5 : width - height * 0.5;
	needleDisplay.y = height * 0.5;
	needleDisplay.rotation = 0.55;
	addChild(needleDisplay);
	
	labelDisplay = new RTLLabel(defaultFormatLabelFactory(_time, localString), 1, "center", localString == null ? "ltr" : null, false, null, height / 140);
	labelDisplay.layoutData = new AnchorLayoutData(NaN, iconPosition == RelativePosition.LEFT ? 3 : height * 0.8, NaN, iconPosition == RelativePosition.LEFT ? height * 0.8 : 3, NaN, 0);
	addChild(labelDisplay);
	
	play();
}

public function play():void
{
	rotate();
	intervalId = setInterval(rotate, 2000);
}

public function rotate():void
{
	Starling.juggler.tween(needleDisplay, 0.5, {rotation:needleDisplay.rotation + Math.PI * 0.5, transition:Transitions.EASE_OUT_ELASTIC});
}


protected function defaultFormatLabelFactory(value:int, localString:String = null) : String
{
	return StrUtils.getNumber( localString == null ? StrUtils.uintToTime(value) : loc(localString, [StrUtils.uintToTime(value)]) );
}

public function get time():uint 
{
	return _time;
}
public function set time(value:uint):void 
{
	if( _time == value )
		return;
	
	_time = value;
	if( labelDisplay != null )
		labelDisplay.text = defaultFormatLabelFactory(_time, localString);
}
}
}