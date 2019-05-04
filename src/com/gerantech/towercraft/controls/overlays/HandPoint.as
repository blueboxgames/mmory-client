package com.gerantech.towercraft.controls.overlays 
{
import com.gerantech.towercraft.models.Assets;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;
import starling.events.Event;

/**
 * ...
 * @author Mansour Djawadi
 */
public class HandPoint extends Image 
{
public function HandPoint(x:Number, y:Number) 
{
	super(Assets.getTexture("hand", "gui"));
	this.x = x + 320;
	this.y = y;
	this.scale = 1.2;
	this.pivotX = width;
	this.pivotY = height;
	this.touchable = false;
	addEventListener(Event.ADDED_TO_STAGE, addedToSatgeHandler);
}

protected function addedToSatgeHandler(e:Event):void 
{
	removeEventListener(Event.ADDED_TO_STAGE, addedToSatgeHandler);
	show();
}

private function show(delay:Number = 0):void
{
	rotation = 0.1;
	Starling.juggler.tween(this, 0.2, {delay:delay,			rotation:-.5, scaleX:1.0});
	Starling.juggler.tween(this, 0.4, {delay:delay + 0.5,	rotation:0.1, scaleX:1.2, onComplete:show, onCompleteArgs:[0.9], transition:Transitions.EASE_OUT_BACK});
}

override public function dispose() : void
{
	Starling.juggler.removeTweens(this);
	super.dispose();
}
}
}