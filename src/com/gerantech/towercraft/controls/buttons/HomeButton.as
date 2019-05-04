package com.gerantech.towercraft.controls.buttons
{
import feathers.controls.ButtonState;
import starling.display.DisplayObject;
public class HomeButton extends SimpleButton
{
public function HomeButton(icon:DisplayObject, iconScale:Number=1)
{
	icon.alignPivot();
	icon.scale = 2 * iconScale;
	addChild(icon);
}

override public function set currentState(value:String):void
{
	super.currentState = value;
	scale = value == ButtonState.DOWN ? 0.9 : 1;
}
}
}