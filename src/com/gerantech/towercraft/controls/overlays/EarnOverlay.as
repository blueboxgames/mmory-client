package com.gerantech.towercraft.controls.overlays 
{
import com.gt.towers.utils.maps.IntIntMap;
/**
 * @author Mansour Djawadi
 */
public class EarnOverlay extends BaseOverlay 
{ 
	public var type:int;
	protected var _outcomes:IntIntMap;
	public function EarnOverlay(type:int)
	{
		this.type = type;
		super(); 
	}
	override protected function initialize() : void 
	{
		super.initialize(); 
	}
	public function get outcomes():IntIntMap 
	{
		return _outcomes;
	}
	public function set outcomes(value:IntIntMap):void 
	{
		_outcomes = value;
	}
}
}