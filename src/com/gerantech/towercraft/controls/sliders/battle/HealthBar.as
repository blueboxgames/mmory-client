package com.gerantech.towercraft.controls.sliders.battle
{
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.views.BattleFieldView;
import flash.geom.Rectangle;
import starling.display.Image;

public class HealthBar
{
static protected var SCALE_RECT:Rectangle = new Rectangle(3, 3, 9, 9);
public var width:Number = 48;
public var height:Number = 15;
protected var _value:Number = 0;
protected var _side:int = -2;
protected var maximum:Number;
protected var sliderFillDisplay:Image;
protected var sliderBackDisplay:Image;
protected var filedView:BattleFieldView;
public function HealthBar(filedView:BattleFieldView, side:int, initValue:Number = 0, initMax:Number = 1)
{
	super();
	this.value = initValue;
	this.maximum = initMax;
	this.side = side;
	this.filedView = filedView;
}

public function initialize() : void
{
	sliderBackDisplay = new Image(AppModel.instance.assets.getTexture("sliders/" + side + "/back"));
	sliderBackDisplay.scale9Grid = SCALE_RECT;
	sliderBackDisplay.touchable = false;
	sliderBackDisplay.width = width;
	sliderBackDisplay.height = height;
	sliderBackDisplay.visible = value < maximum;
	filedView.guiImagesContainer.addChild(sliderBackDisplay);
	
	sliderFillDisplay = new Image(AppModel.instance.assets.getTexture("sliders/" + side + "/fill"));
	sliderFillDisplay.scale9Grid = SCALE_RECT;
	sliderFillDisplay.touchable = false;
	sliderFillDisplay.height = height;
	sliderFillDisplay.visible = value < maximum;
	filedView.guiImagesContainer.addChild(sliderFillDisplay);
}

public function setPosition(x:Number, y:Number) : void
{
	if( sliderBackDisplay != null )
	{
		sliderBackDisplay.x = x - width * 0.5;
		sliderBackDisplay.y = y;
	}
	if( sliderFillDisplay != null )
	{
		sliderFillDisplay.x = x - width * 0.5;
		sliderFillDisplay.y = y;
	}
}



public function get value() : Number
{
	return _value;
}
public function set value(v:Number) : void
{
	if( _value == v )
		return;
	if( v > maximum )
		v = maximum;
	if( v < 0 )
		v = 0;
	_value = v;

	if( sliderFillDisplay != null )
	{
		sliderFillDisplay.visible = _value < maximum;
		sliderFillDisplay.width =  width * (_value / maximum);
	}
	
	if( sliderFillDisplay != null )
		sliderFillDisplay.visible = _value < maximum;
}

public function get side():int
{
	return _side;
}
public function set side(value:int):void
{
	if( _side == value )
		return;
	_side = value;
	
	if( sliderBackDisplay!= null )
		sliderBackDisplay.texture = AppModel.instance.assets.getTexture("sliders/" + _side + "/back");
	if( sliderFillDisplay != null )
		sliderFillDisplay.texture = AppModel.instance.assets.getTexture("sliders/" + _side + "/fill");

}

public function dispose() : void 
{
	if( sliderBackDisplay!= null )
		sliderBackDisplay.removeFromParent(true);
	if( sliderFillDisplay != null )
		sliderFillDisplay.removeFromParent(true);
}
}
}