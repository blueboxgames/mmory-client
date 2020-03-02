package com.gerantech.towercraft.views 
{
import com.gerantech.mmory.core.utils.CoreUtils;

import flash.geom.Point;
import flash.utils.Dictionary;
/**
* ...
* @author Mansour Djawadi
*/
public class ArtRules 
{
static public const POSITIONS:String = "p";
static public const Y:String = "y";
static public const SIDE:String = "sd";
static public const TEXTURE:String = "texture";
static public const BASE:String = "base";
static public const OVERLAY:String = "overlay";
static public const BULLET:String = "bullet";
static public const BULLET_FX:String = "bulletFX";
static public const FLAME:String = "flame";
static public const SMOKE:String = "smoke";
static public const SUMMON:String = "summon";
static public const HIT:String = "hit";
static public const DIE:String = "die";

static public const SUMMON_SFX:String = "summonSFX";
static public const ATTACK_SFX:String = "attackSFX";
static public const HIT_SFX:String = "hitSFX";
static public const DIE_SFX:String = "dieSFX";

static public const DIE_SHAKE:String = "dieShake";
static public const HIT_SHAKE:String = "hitShake";

private var rules:Dictionary;
public function ArtRules(data:Object)
{
	rules = new Dictionary();
	for ( var i:int = 0; i < data.units.length; i++ )
		rules[data.units[i].id] = data.units[i];
}

public function get(type:int, attribute:String) : String
{
	if( rules[type] == null )
		return attribute == TEXTURE ? type.toString() : "";
	return rules[type][attribute];
}
public function getInt(type:int, attribute:String) : int
{
	if( rules[type] == null )
		return 0;
	return int(rules[type][attribute]);
}
public function getBool(type:int, attribute:String) : Boolean
{
	if( rules[type] == null )
		return false;
	return Boolean(rules[type][attribute]);
}
public function getNumber(type:int, attribute:String) : Number
{
	if( rules[type] == null )
		return 0;
	return Number(rules[type][attribute]);
}
public function getArray(type:int, attribute:String) : Array
{
	if( rules[type] == null )
		return null;
	return rules[type][attribute];
}

public function getFlamePosition(type:int, rad:Number) : Point
{
	var radStr:String = CoreUtils.getRadString(rad);
	var ret:Point = new Point();

	if( radStr == "000" )
		ret = new Point(getArray(type, POSITIONS)[0], getArray(type, POSITIONS)[1]);
	if( radStr == "045" || radStr == "-45" )
		ret = new Point(getArray(type, POSITIONS)[2], getArray(type, POSITIONS)[3]);
	if( radStr == "090" || radStr == "-90"  )
		ret = new Point(getArray(type, POSITIONS)[4], getArray(type, POSITIONS)[5]);
	if( radStr == "135" || radStr == "-35"  )
		ret = new Point(getArray(type, POSITIONS)[6], getArray(type, POSITIONS)[7]);
	if( radStr == "180" )
		ret = new Point(getArray(type, POSITIONS)[8], getArray(type, POSITIONS)[9]);

	ret.x -= 256;
	ret.y -= (333 - getInt(type, Y));

	if( radStr == "-45" || radStr == "-90"  || radStr == "-35" )
		ret.x *= -1;
	
	return ret;
}

static public function getShadowSize(type:int): Number
{
	switch( type )
	{
		case	101	:	return 80;
		case	102	:	return 100;
		case	103	:	return 50;
		case	104	:	return 85;
		case	105	:	return 90;
		case	106	:	return 90;
		case	107	:	return 70;
		case	108	:	return 80;
		case	109	:	return 80;
		case	110	:	return 50;
		case	111	:	return 80;
		case	112	:	return 85;
		case	113	:	return 85;
		case	119	:	return 85;		
		
		case	201 :	return 80;
		case	222 :	return 95;
	}
	return 100;
}

static public function getFlameSize(type:int): Number
{
	switch( type )
	{
		case	101	:	return 0.8;
		case	104	:	return 0.7;
		case	111	:	return 0.7;
	}
	return 1.0;
}

static public function getSmokeSize(type:int): Number
{
	switch( type )
	{
		case	101	:	return 0.6;
		case	102	:	return 1.2;
		
		case	201 :	return 0.7;
		case	222 :	return 0.5;
	}
	return 1.0;
}
}
}