package com.gerantech.towercraft.controls.overlays 
{
import com.gerantech.mmory.core.constants.ResourceType;
import com.gerantech.mmory.core.utils.maps.IntIntMap;
import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.ISFSObject;
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

	static public function getOutcomse(sfsArray:ISFSArray) : IntIntMap
	{
		var ret:IntIntMap = new IntIntMap();
		//trace(data.getSFSArray("rewards").getDump());
		var item:ISFSObject;
		for( var i:int=0; i<sfsArray.size(); i++ )
		{
			item = sfsArray.getSFSObject(i);
			if( ResourceType.isCard(item.getInt("t")) || ResourceType.isBook(item.getInt("t")) || item.getInt("t") == ResourceType.R3_CURRENCY_SOFT || item.getInt("t") == ResourceType.R4_CURRENCY_HARD || item.getInt("t") == ResourceType.R6_TICKET )
				ret.set(item.getInt("t"), item.getInt("c"));
		}
		return ret;
	}
}
}