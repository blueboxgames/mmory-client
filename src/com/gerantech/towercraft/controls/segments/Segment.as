package com.gerantech.towercraft.controls.segments
{
import com.gerantech.towercraft.controls.TowersLayout;

public class Segment extends TowersLayout implements ISegment
{
	private var _paddingH:Number;
	public function get paddingH():Number
	{
		return _paddingH;
	}
	public function set paddingH(value:Number):void
	{
		_paddingH = value;
	}

	private var _initializeStarted:Boolean;
	public function get initializeStarted():Boolean
	{
		return _initializeStarted;
	}
	public function set initializeStarted(value:Boolean):void
	{
		_initializeStarted = value;
	}

	private var _initializeCompleted:Boolean;
	public function get initializeCompleted():Boolean
	{
		return _initializeCompleted;
	}
	public function set initializeCompleted(value:Boolean):void
	{
		_initializeCompleted = value;
	}
	public function init():void
	{
		initializeStarted = true;
		focus();
	}
	public function Segment() { super(); }
	public function updateData():void {}
	public function focus():void {}
}
}