package com.gerantech.towercraft.managers
{
import com.gerantech.mmory.core.battle.BattleField;

import flash.utils.clearInterval;
import flash.utils.getTimer;
import flash.utils.setInterval;

import starling.events.Event;
import starling.events.EventDispatcher;

public class TimeManager extends EventDispatcher
{
private var _now:uint;
private var sampler:Number;
private var _millis:Number;
private var intervalId:uint;
private static var _instance:TimeManager;
public function TimeManager(now:uint)
{
	_instance = this;
	_now = now;
	_millis = now * 1000;
	sampler = getTimer();
	intervalId = setInterval(timeCounterCallback, BattleField.DELTA_TIME);
}

public function get now():uint
{
	return _now;
}
public function setNow(value:uint):void
{
	_now = value;
}

public function get millis():Number
{
	return _millis;
}

public function setMillis(value:Number):void
{
	_millis = value;
}

private function timeCounterCallback():void
{
	dispatchEventWith(Event.UPDATE, false, forceUpdate());
}

public function forceUpdate():int
{
	var s:int = getTimer();
	var diff:int = s - sampler;
	_millis += diff;
	
	sampler = s;

	if( _millis > _now * 1000 + 991 )
	{
		_now ++;
		dispatchEventWith(Event.CHANGE, false, _now)		
	}
	return diff;
}

public static function get instance():TimeManager
{
	return _instance;
}

public function dispose():void
{
	clearInterval(intervalId);
	_instance = null;
	
}
}
}