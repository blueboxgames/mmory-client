package com.gerantech.towercraft.controls.sliders.battle 
{
import com.gerantech.towercraft.controls.TowersLayout;
/**
 * ...
 * @author Mansour Djawadi
 */
public class IBattleSlider extends TowersLayout
{
protected var _value:Number = 0;

public function IBattleSlider(){}
public function get minimum():Number 
{
	return 0;
}
public function set minimum(value:Number):void 
{
}
public function get maximum():Number 
{
	return 0;
}
public function set maximum(value:Number):void 
{
}
public function enableStars(score:int):void 
{
}

public function get value():Number 
{
	return _value;
}
public function set value(val:Number):void 
{
	_value = val;
}
}
}