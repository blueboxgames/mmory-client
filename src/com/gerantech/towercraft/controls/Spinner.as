package com.gerantech.towercraft.controls 
{
import starling.display.DisplayObject;

/**
* ...
* @author Mansour Djawadi
*/
public class Spinner
{
public var display:DisplayObject;
public var angle:Number;
public var scaleFactor:Number = 1;
public var order:Number;
public function Spinner() {	super(); }
public function dispose():void 
{
	display.removeFromParent();
}
}
}