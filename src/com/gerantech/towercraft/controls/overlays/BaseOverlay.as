package com.gerantech.towercraft.controls.overlays
{
import com.gerantech.towercraft.controls.ClosableLayout;
import com.gerantech.towercraft.controls.groups.Devider;
import flash.ui.Keyboard;
import starling.display.DisplayObject;
import starling.events.Event;
import starling.events.KeyboardEvent;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

public class BaseOverlay extends ClosableLayout
{
public var hasOverlay:Boolean = true;
public var overlayFactory:Function;
public var closeOnOverlay:Boolean = false;

protected var overlay:DisplayObject;
//protected static const HELPER_POINT:Point = new Point();

public function BaseOverlay()
{
	addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
}

override protected function initialize():void
{
	super.initialize();
	if( hasOverlay )
	{
		if( overlayFactory == null )
			overlayFactory = defaultOverlayFactory;
		
		if( overlay == null )
			overlay = overlayFactory();
		addChildAt(overlay, 0);
	}
}

protected function defaultOverlayFactory(color:uint = 0, alpha:Number = 0.5):DisplayObject
{
	var overlay:Devider = new Devider(color);
	overlay.alpha = alpha;
	overlay.width = stage.stageWidth * 3;
	overlay.height = stage.stageHeight * 3;
	overlay.x = -stage.stageWidth * 2;
	overlay.y = -stage.stageHeight * 2;
	return overlay;
}

override protected function stage_keyUpHandler(event:KeyboardEvent):void
{
	if( event.keyCode == Keyboard.BACK )
	{
		event.preventDefault();
		if( closeWithKeyboard && _isEnabled )
			close();
	}
}
override protected function stage_touchHandler(event:TouchEvent):void
{
	if( !_isEnabled )
		return;
	
	var touch:Touch;
	if( closeOnOverlay )
	{
		touch = event.getTouch(overlay, TouchPhase.ENDED);
		if( touch != null )
		{
			close();
			return;
		}
	}
	
	if( !closeOnStage )
		return;

	// we aren't tracking another touch, so let's look for a new one.
	touch = event.getTouch(stage, TouchPhase.BEGAN);
	if( touch == null )
		return;

	/*touch.getLocation( overlay, HELPER_POINT );
	if(!this.contains( stage.hitTest( HELPER_POINT ) ))*/
	close();
}
}
}