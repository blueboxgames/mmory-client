package com.gerantech.towercraft.controls.tooltips
{
import com.gerantech.towercraft.themes.MainTheme;

import feathers.controls.Button;
import feathers.layout.AnchorLayoutData;

import flash.geom.Rectangle;

import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

public class ConfirmTooltip extends BaseTooltip
{
public var hasDecline:Boolean;
public var hasAccept:Boolean;
public function ConfirmTooltip(message:String, position:Rectangle, fontScale:Number=0.8, hSize:Number=0.5, hasDecline:Boolean=true, hasAccept:Boolean=true)
{
	super(message, position, fontScale, hSize);
	this.hasAccept = hasAccept;
	this.hasDecline = hasDecline;
}

override protected function initialize():void
{
	super.initialize();
	
	if( hasAccept )
	{
		var acceptButton:Button = new Button();
		acceptButton.styleName = MainTheme.STYLE_BUTTON_SMALL_NEUTRAL;
		acceptButton.label = loc("popup_ok_label");
		acceptButton.width = hasDecline ? 180 : 240;
		acceptButton.height = padding * 4;
		acceptButton.addEventListener(Event.TRIGGERED, acceptButton_triggeredHandler);
		acceptButton.layoutData = new AnchorLayoutData(NaN, hasDecline ? padding * 2 : NaN, padding * 2, NaN, hasDecline ? NaN : 0);
		addChild(acceptButton);
	}
	else
	{
		this.touchable = true;
		this.stage.addEventListener(TouchEvent.TOUCH, stage_touchHandler);

		this.labelDisplay.layoutData = new AnchorLayoutData(80, 80, 80, 80); 
	}
	
	if( hasDecline )
	{
		var declineButton:Button = new Button();
		declineButton.styleName = MainTheme.STYLE_BUTTON_SMALL_DANGER;
		declineButton.label = loc("popup_decline_label");
		declineButton.width = 180;
		declineButton.height = padding * 4;
		declineButton.addEventListener(Event.TRIGGERED, acceptButton_triggeredHandler);
		declineButton.layoutData = new AnchorLayoutData(NaN, NaN, padding * 2, padding * 2);
		addChild(declineButton);
	}
}
override protected function transitionInStarted():void
{
	height = labelDisplay.height + padding * 9;
	super.transitionInStarted();
}

private function acceptButton_triggeredHandler(event:Event):void
{
	dispatchEventWith(Button(event.currentTarget).styleName == MainTheme.STYLE_BUTTON_SMALL_DANGER ? Event.CANCEL : Event.SELECT );
}
override protected function stage_touchHandler(event:TouchEvent):void
{
	var touch:Touch = event.touches.pop();
	if( touch != null && touch.phase == TouchPhase.ENDED )
		dispatchEventWith(Event.SELECT);
}

}
}