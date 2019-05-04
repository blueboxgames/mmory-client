package com.gerantech.towercraft.controls.indicators
{
import com.gerantech.towercraft.controls.TowersLayout;
import com.gerantech.towercraft.models.Assets;
import flash.utils.clearInterval;
import flash.utils.clearTimeout;
import flash.utils.setInterval;
import flash.utils.setTimeout;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;
import starling.utils.deg2rad;

public class CountdownIcon extends TowersLayout
{
private var background:Image;
private var needle:Image;
private var _scale:Number;
private var intervalId:uint;
private var timeoutId:uint;

public function CountdownIcon(autoplay:Boolean = true)
{
	background =  new Image(Assets.getTexture("timer"));
	background.pivotX = background.width * 0.5;
	background.pivotY = background.height * 0.5;
	addChild(background);
	
	needle = new Image(Assets.getTexture("timer-needle"));
	needle.pivotX = needle.width * 0.5;
	needle.pivotY = needle.height * 0.5;
	needle.rotation = 0.47;
	addChild(needle);
	
	if( autoplay )
		play();
}

public function play():void
{
	rotate();
	intervalId = setInterval(rotate, 1000);
}

public function rotate():void
{
	Starling.juggler.tween(needle, 0.5, {rotation:needle.rotation + Math.PI * 0.5, transition:Transitions.EASE_OUT_ELASTIC});
}

public function rotateTo(from:Number, to:Number, duration:Number = 1):void
{
	var fr:int = 10;
	var index:int = 0;
	var diff:Number = to - from;
	needle.rotation = from;
	Starling.juggler.repeatCall(rotateAround, duration * fr / Math.abs(diff), Math.abs(diff) / fr);
	function rotateAround():void
	{
		//trace("rotateAround", index, deg2rad(index), fr)
		index = diff > 0 ? 1 : -1;
		needle.rotation += deg2rad(fr);
	}
}

public function scaleTo(value:Number, delay:Number = 0.5, duration:Number = 0.5, endCallback:Function=null):void
{
	scale *= 1.5;
	Starling.juggler.tween(this, duration, {delay:delay, scale:value, transition:Transitions.EASE_IN_BACK, onComplete:endCallback});
}		

public function stop():void
{
	clearInterval(intervalId);
	clearTimeout(timeoutId);
	Starling.juggler.removeTweens(background);
	Starling.juggler.removeTweens(this);
}
override public function dispose():void
{
	stop();
	super.dispose();
}
}
}