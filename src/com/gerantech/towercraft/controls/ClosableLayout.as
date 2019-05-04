package com.gerantech.towercraft.controls
{
import com.gerantech.towercraft.controls.overlays.TransitionData;
import feathers.events.FeathersEventType;
import flash.geom.Point;
import flash.ui.Keyboard;
import starling.core.Starling;
import starling.events.Event;
import starling.events.KeyboardEvent;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

public class ClosableLayout extends TowersLayout
{
public var transitionIn:TransitionData;
public var transitionOut:TransitionData;
public var data:Object;
public var isOpen:Boolean;

public var closeWithKeyboard:Boolean = true;
protected var _closeOnStage:Boolean = true;
protected var transitionState:int;

protected static const HELPER_POINT:Point = new Point();
protected var initializingStarted:Boolean;
protected var initializingCompleted:Boolean;

public function ClosableLayout()
{
	addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
}

override protected function initialize():void
{
	super.initialize();
	initializingStarted = true;
}
protected function transitionInStarted():void
{
	transitionState = TransitionData.STATE_IN_STARTED;
	isOpen = true;
	if(hasEventListener(FeathersEventType.TRANSITION_IN_START))
		dispatchEventWith(FeathersEventType.TRANSITION_IN_START);
}
protected function transitionInCompleted():void
{
	transitionState = TransitionData.STATE_IN_COMPLETED;
	if(hasEventListener(FeathersEventType.TRANSITION_IN_COMPLETE))
		dispatchEventWith(FeathersEventType.TRANSITION_IN_COMPLETE);
}

protected function addedToStageHandler(event:Event):void
{
	removeEventListener( Event.ADDED_TO_STAGE, addedToStageHandler);
	addEventListener( Event.REMOVED_FROM_STAGE, removeFromStageHandler);
	stage.addEventListener( KeyboardEvent.KEY_DOWN, stage_keyUpHandler);
	stage.addEventListener( TouchEvent.TOUCH, stage_touchHandler);
}

protected function removeFromStageHandler(event:Event):void
{
	removeEventListener( Event.REMOVED_FROM_STAGE, removeFromStageHandler);
	stage.removeEventListener( KeyboardEvent.KEY_DOWN, stage_keyUpHandler);
	stage.removeEventListener( TouchEvent.TOUCH, stage_touchHandler);
}

protected function stage_keyUpHandler(event:KeyboardEvent):void
{

	if( event.keyCode == Keyboard.BACK )
	{
		event.preventDefault();
		if( closeWithKeyboard && _isEnabled && transitionState >= TransitionData.STATE_IN_COMPLETED && transitionState < TransitionData.STATE_OUT_STARTED )
			close();
	}
}
protected function stage_touchHandler(event:TouchEvent):void
{
	if( !_isEnabled || !closeOnStage || transitionState < TransitionData.STATE_IN_COMPLETED || transitionState >= TransitionData.STATE_OUT_STARTED )
		return;

	// we aren't tracking another touch, so let's look for a new one.
	var touch:Touch = event.getTouch(stage, TouchPhase.BEGAN);
	if( touch == null )
		return;

	close();
}

public function close(dispose:Boolean=true):void
{
	if( !dispose )
		addEventListener( Event.ADDED_TO_STAGE, addedToStageHandler);
	
	if( hasEventListener(Event.CLOSE) )
		dispatchEventWith(Event.CLOSE);
	
	Starling.juggler.removeTweens(this);
	
	if( transitionOut == null )
		transitionOutCompleted(dispose);
	isOpen = false;
}
protected function transitionOutStarted():void
{
	transitionState = TransitionData.STATE_OUT_STARTED;
	if( hasEventListener(FeathersEventType.TRANSITION_OUT_START) )
		dispatchEventWith(FeathersEventType.TRANSITION_OUT_START);
}
protected function transitionOutCompleted(dispose:Boolean=true):void
{
	transitionState = TransitionData.STATE_OUT_COMPLETED;
	if( hasEventListener(FeathersEventType.TRANSITION_OUT_COMPLETE) )
		dispatchEventWith(FeathersEventType.TRANSITION_OUT_COMPLETE);
	removeFromParent(dispose);
}


public function get closeOnStage():Boolean
{
	return _closeOnStage;
}
public function set closeOnStage(value:Boolean):void
{
	_closeOnStage = value;
}
}
}