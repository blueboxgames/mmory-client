package com.gerantech.towercraft.controls.items
{
import flash.geom.Point;
import starling.display.DisplayObjectContainer;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

public class AbstractTouchableListItemRenderer extends AbstractListItemRenderer
{
public static const STATE_NORMAL:String = "normal";
public static const STATE_DOWN:String = "down";
public static const STATE_SELECTED:String = "selected";
public static const STATE_DISABLED:String = "disabled";
public var stateNames:Vector.<String> = new <String> [ STATE_NORMAL, STATE_DOWN, STATE_SELECTED, STATE_DISABLED ];
private var _currentState:String = STATE_NORMAL;

protected var touch:Touch;
protected var touchTarget:DisplayObjectContainer;
private var touchID:int = -1;
private static const HELPER_POINT:Point = new Point();

public function AbstractTouchableListItemRenderer(){}
override protected function initialize():void
{
	super.initialize();
	touchTarget = this;
	addEventListener( TouchEvent.TOUCH, touchHandler);
}

protected function touchHandler( event:TouchEvent ):void
{
	if( !_isEnabled || _currentState == STATE_DISABLED )
	{
		touchID = -1;
		return;
	}
	//trace("touchHandler", index, touchID)
	if( touchID >= 0 )
	{
		touch = event.getTouch( touchTarget, null, touchID );
		if( !touch )
			return;
		
		if( touch.phase == TouchPhase.ENDED )
		{
			touch.getLocation( touchTarget.stage, HELPER_POINT );
			var isInBounds:Boolean = touchTarget.contains( touchTarget.stage.hitTest( HELPER_POINT ) );
			if( isInBounds )
			{
				dispatchEventWith(Event.TRIGGERED);
				if( _owner.allowMultipleSelection )
					setSelection(!isSelected);
				else
					setSelection(true);
			}
			// the touch has ended, so now we can start watching for a new one.
			touchID = -1;
		}
		else if( touch.phase == TouchPhase.MOVED )
		{
			if( Math.abs(touch.globalX - touch.previousGlobalX) > 10 || Math.abs(touch.globalY - touch.previousGlobalY) > 10 )
			{
				currentState = STATE_NORMAL;
				touchID = -1;
			}
		}
		return;
	}
	else
	{
		// we aren't tracking another touch, so let's look for a new one.
		touch = event.getTouch( touchTarget, TouchPhase.BEGAN );
		if( touch != null )
		{
			currentState = STATE_DOWN;
		}
		else
		{
			// we only care about the began phase. ignore all other phases.
			return;
		}
		// save the touch ID so that we can track this touch's phases.
		touchID = touch.id;
	}
}

override protected function removedFromStageHandler( event:Event ):void
{
	super.removedFromStageHandler(event);
	touchID = -1;
}

protected function setSelection(value:Boolean):void
{
	isSelected = value;
}
override public function set isSelected(value:Boolean):void
{
	if(currentState == STATE_DISABLED)
		return;	
	super.isSelected = value;

	currentState = value ? STATE_SELECTED : STATE_NORMAL;
}

public function get currentState():String
{
	return _currentState;
}
public function set currentState(value:String):void
{
	//trace(index, _currentState, value)
	if( _currentState == value )
		return;
	
	if( stateNames.indexOf(value) < 0 )
	{
		throw new ArgumentError("Invalid state: " + value + ".");
		return;
	}
	
	_currentState = value;
	
	if( _currentState == STATE_DISABLED && isEnabled )
		isEnabled = false;
	else if( _currentState != STATE_DISABLED && !isEnabled )
		isEnabled = true;
	
	if( skin )
		skin.defaultTexture = skin.getTextureForState(_currentState);
}
}
}