package com.gerantech.towercraft.controls.buttons
{
import com.gerantech.towercraft.controls.overlays.HandPoint;
import feathers.controls.ButtonState;
import feathers.events.FeathersEventType;
import flash.geom.Point;
import flash.utils.getTimer;
import flash.utils.setTimeout;
import starling.display.Sprite;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

[Event(name="triggered",type="starling.events.Event")]
[Event(name="longPress",type="starling.events.Event")]

public class SimpleButton extends Sprite
{

private static const HELPER_POINT:Point = new Point();
public var stateNames:Vector.<String> = new <String>[ButtonState.UP, ButtonState.DOWN, ButtonState.DISABLED];
public var isLongPressEnabled:Boolean = false;
public var longPressDuration:Number = 0.5;
public var keepDownStateOnRollOut:Boolean = false;
protected var _touchBeginTime:int;
protected var _hasLongPressed:Boolean = false;
private var _currentState:String = ButtonState.UP;
private var touchPointID:int;
private var handPoint:HandPoint;

public function SimpleButton()
{
	super();
	//this.isQuickHitAreaEnabled = true;
	this.addEventListener(TouchEvent.TOUCH, button_touchHandler);
	this.addEventListener(Event.REMOVED_FROM_STAGE, button_removedFromStageHandler);
}

public function get currentState():String
{
	return _currentState;
}
public function set currentState(value:String):void
{
	if(this._currentState == value)
	{
		return;
	}
	if(this.stateNames.indexOf(value) < 0)
	{
		throw new ArgumentError("Invalid state: " + value + ".");
	}
	_currentState = value;
}

/**
 * @private
 */
protected function resetTouchState(touch:Touch = null):void
{
	this.touchPointID = -1;
	this.removeEventListener(Event.ENTER_FRAME, longPress_enterFrameHandler);
	if(this.touchable)
		this.currentState = ButtonState.UP;
	else
		this.currentState = ButtonState.DISABLED;
}

/**
 * Triggers the button.
 */
protected function trigger():void
{
	if(hasEventListener(Event.TRIGGERED))
		this.dispatchEventWith(Event.TRIGGERED, false, this);
}


/**
 * @private
 */
protected function button_removedFromStageHandler(event:Event):void
{
	this.resetTouchState();
}

/**
 * @private
 */
protected function button_touchHandler(event:TouchEvent):void
{
	if(!this.touchable)
	{
		this.touchPointID = -1;
		return;
	}
	
	if(this.touchPointID >= 0)
	{
		var touch:Touch = event.getTouch(this, null, this.touchPointID);
		if(!touch)
		{
			//this should never happen
			return;
		}
		
		touch.getLocation(this.stage, HELPER_POINT);
		var isInBounds:Boolean = this.contains(this.stage.hitTest(HELPER_POINT));
		if(touch.phase == TouchPhase.BEGAN)
		{
			if(isInBounds || this.keepDownStateOnRollOut)
				this.currentState = ButtonState.DOWN;
		}
		else if(touch.phase == TouchPhase.MOVED)
		{
			if( this.currentState == ButtonState.DOWN && !isInBounds )
				this.currentState = ButtonState.UP;
		}
		else if(touch.phase == TouchPhase.ENDED)
		{
			this.resetTouchState(touch);
			//we we dispatched a long press, then triggered and change
			//won't be able to happen until the next touch begins
			if(!this._hasLongPressed && isInBounds)
			{
				this.trigger();
			}
			this.currentState = ButtonState.UP;
		}
		return;
	}
	else //if we get here, we don't have a saved touch ID yet
	{
		touch = event.getTouch(this, TouchPhase.BEGAN);
		if(touch)
		{
			this.currentState = ButtonState.DOWN;
			this.touchPointID = touch.id;
			if(this.isLongPressEnabled)
			{
				this._touchBeginTime = getTimer();
				this._hasLongPressed = false;
				this.addEventListener(Event.ENTER_FRAME, longPress_enterFrameHandler);
			}
			return;
		}
		/*touch = event.getTouch(this, TouchPhase.HOVER);
		if(touch)
		{
		this.currentState = ButtonState.HOVER;
		return;
		}*/
		
		//end of hover
		this.currentState = ButtonState.UP;
	}
}

/**
 * @private
 */
protected function longPress_enterFrameHandler(event:Event):void
{
	var accumulatedTime:Number = (getTimer() - this._touchBeginTime) / 1000;
	if(accumulatedTime >= this.longPressDuration)
	{
		this.removeEventListener(Event.ENTER_FRAME, longPress_enterFrameHandler);
		this._hasLongPressed = true;
		this.dispatchEventWith(FeathersEventType.LONG_PRESS);
	}
}

public function showTutorHint(offsetX:Number = 0, offsetY:Number = 0) : void 
{
	if( handPoint != null )
		handPoint.removeFromParent(true);
	
	handPoint = new HandPoint(width * 0.5 + offsetX, offsetY);
//	handPoint.layoutData = new AnchorLayoutData(isUp ? NaN : 0, NaN, isUp ? -handPoint._height : NaN, NaN, 0);
	setTimeout(addChild, 200, handPoint);
}
}
}