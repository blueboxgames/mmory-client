package com.gerantech.towercraft.views 
{
import com.gt.towers.utils.CoreUtils;
import com.gt.towers.utils.Point3;
import flash.utils.Dictionary;
/**
* ...
* @author Mansour Djawadi
*/
public class ArtRules 
{
static public const BULLET:String = "bullet";
static public const BULLET_FX:String = "bulletFX";
static public const FLAME:String = "flame";
static public const SMOKE:String = "smoke";
static public const HIT:String = "hit";
static public const DIE:String = "die";
static public const SUMMON_SFX:String = "summonSFX";
static public const ATTACK_SFX:String = "attackSFX";
static public const HIT_SFX:String = "hitSFX";

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
		return "";
	return rules[type][attribute];
}
public function getArray(type:int, attribute:String) : Array
{
	if( rules[type] == null )
		return null;
	return rules[type][attribute];
}

static public function getFlamePosition(type:int, rad:Number) : Point3
{
	var radStr:String = CoreUtils.getRadString(rad);
	if( radStr == "000" )
	switch( type )
	{
		case	101	:	return new Point3(18, -141, 0);
		case	102	:	return new Point3(32, -204, 0);
		case	103	:	return new Point3(14, -117, 0);
		case	104	:	return new Point3(15,-140, 0);
		case	105	:	return new Point3(28,-101, 0);
		case	106	:	return new Point3(18, -141, 0);
		case	107	:	return new Point3(18, -141, 0);
		case	108	:	return new Point3(14,-152, 0);
		case	109	:	return new Point3(0,-134, 0);
		case	110	:	return new Point3(14, -117, 0);
		case	111	:	return new Point3(15,-140, 0);
		case	112	:	return new Point3(18, -141, 0);
		case	113	:	return new Point3(18, -141, 0);
		
		case	201 :	return new Point3(-27, -166, 0);
		case	222 :	return new Point3(-24, -170, 0);
	}

	if( radStr == "045" )
	switch( type )
	{
		case	101	:	return new Point3(-52, -130, 0);
		case	102	:	return new Point3(-46,-200, 0);
		case	103	:	return new Point3(-52,-104, 0);
		case	104	:	return new Point3(-52,-129, 0);
		case	105	:	return new Point3(-10,-106, 0);
		case	106	:	return new Point3(18, -141, 0);
		case	107	:	return new Point3(18, -141, 0);
		case	108	:	return new Point3(-52,-139, 0);
		case	109	:	return new Point3(-66,-111, 0);
		case	110	:	return new Point3(-52,-104, 0);
		case	111	:	return new Point3(-52,-129, 0);
		case	112	:	return new Point3(18, -141, 0);
		case	113	:	return new Point3(18, -141, 0);
		
		case	201 :	return new Point3(-116, -130, 0);
		case	222 :	return new Point3(-96, -142, 0);
	}

	if( radStr == "090" )
	switch( type )
	{
		case	101	:	return new Point3(-96, -83, 0);
		case	102	:	return new Point3(-99,-156, 0);
		case	103	:	return new Point3(-89,-59, 0);
		case	104	:	return new Point3(-95,-82, 0);
		case	105	:	return new Point3(-40,-90, 0);
		case	106	:	return new Point3(18, -141, 0);
		case	107	:	return new Point3(18, -141, 0);
		case	108	:	return new Point3(-95,-95, 0);
		case	109	:	return new Point3(-100,-60, 0);
		case	110	:	return new Point3(-89,-59, 0);
		case	111	:	return new Point3(-95,-82, 0);
		case	112	:	return new Point3(18, -141, 0);
		case	113	:	return new Point3(18, -141, 0);
		
		case	201 :	return new Point3(-148, -55, 0);
		case	222 :	return new Point3(-130, -62, 0);
	}

	if( radStr == "135" )
	switch( type )
	{
		case	101	:	return new Point3(-90, -21, 0);
		case	102	:	return new Point3(-100,-95, 0);
		case	103	:	return new Point3(-76,-5, 0);
		case	104	:	return new Point3(-83,-25, 0);
		case	105	:	return new Point3(-52,-61, 0);
		case	106	:	return new Point3(18, -141, 0);
		case	107	:	return new Point3(18, -141, 0);
		case	108	:	return new Point3(-82,-38, 0);
		case	109	:	return new Point3(-76,-0, 0);
		case	110	:	return new Point3(-76,-5, 0);
		case	111	:	return new Point3(-83,-25, 0);
		case	112	:	return new Point3(18, -141, 0);
		case	113	:	return new Point3(18, -141, 0);
		
		case	201 :	return new Point3(-83, 33, 0);
		case	222 :	return new Point3(-80, 4, 0);
	}

	if( radStr == "180" )
	switch( type )
	{
		case	101	:	return new Point3(-21, 14, 0);
		case	102	:	return new Point3(-38,-52, 0);
		case	103	:	return new Point3(-16,26, 0);
		case	104	:	return new Point3(-18,9, 0);
		case	105	:	return new Point3(-30,35, 0);
		case	106	:	return new Point3(18, -141, 0);
		case	107	:	return new Point3(18, -141, 0);
		case	108	:	return new Point3(-17,-7, 0);
		case	109	:	return new Point3(0,22, 0);
		case	110	:	return new Point3(-16,26, 0);
		case	111	:	return new Point3(-18,9, 0);
		case	112	:	return new Point3(18, -141, 0);
		case	113	:	return new Point3(18, -141, 0);
		
		case	201 :	return new Point3(32, 44, 0);
		case	222 :	return new Point3(25, 11, 0);
	}

	if( radStr == "-45" )
	switch( type )
	{
		case	101	:	return new Point3(52, -130, 0);
		case	102	:	return new Point3(46,-200, 0);
		case	103	:	return new Point3(52,-104, 0);
		case	104	:	return new Point3(52,-129, 0);
		case	105	:	return new Point3(10,-106, 0);
		case	106	:	return new Point3(18, -141, 0);
		case	107	:	return new Point3(18, -141, 0);
		case	108	:	return new Point3(52,-139, 0);
		case	109	:	return new Point3(52,-139, 0);
		case	110	:	return new Point3(52,-104, 0);
		case	111	:	return new Point3(52,-129, 0);
		case	112	:	return new Point3(18, -141, 0);
		case	113	:	return new Point3(18, -141, 0);
		
		case	201 :	return new Point3(116, -130, 0);
		case	222 :	return new Point3(96, -142, 0);
	}

	if( radStr == "-90" )
	switch( type )
	{
		case	101	:	return new Point3(96, -83, 0);
		case	102	:	return new Point3(99,-156, 0);
		case	103	:	return new Point3(89,-59, 0);
		case	104	:	return new Point3(95,-82, 0);
		case	105	:	return new Point3(40,-90, 0);
		case	106	:	return new Point3(18, -141, 0);
		case	107	:	return new Point3(18, -141, 0);
		case	108	:	return new Point3(95,-95, 0);
		case	109	:	return new Point3(95,-95, 0);
		case	110	:	return new Point3(89,-59, 0);
		case	111	:	return new Point3(95,-82, 0);
		case	112	:	return new Point3(18, -141, 0);
		case	113	:	return new Point3(18, -141, 0);
		
		case	201 :	return new Point3(148, -55, 0);
		case	222 :	return new Point3(130, -62, 0);
	}

	if( radStr == "-35" )
	switch( type )
	{
		case	101	:	return new Point3(90, -21, 0);
		case	102	:	return new Point3(100,-95, 0);
		case	103	:	return new Point3(76,-5, 0);
		case	104	:	return new Point3(83,-25, 0);
		case	105	:	return new Point3(52,-61, 0);
		case	106	:	return new Point3(18, -141, 0);
		case	107	:	return new Point3(18, -141, 0);
		case	108	:	return new Point3(82,-38, 0);
		case	109	:	return new Point3(82,-38, 0);
		case	110	:	return new Point3(76,-5, 0);
		case	111	:	return new Point3(83,-25, 0);
		case	112	:	return new Point3(18, -141, 0);
		case	113	:	return new Point3(18, -141, 0);
	
		case	201 :	return new Point3(83, 33, 0);
		case	222 :	return new Point3(80, 4, 0);
	}
	return new Point3(0, 0, 0);
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
		case	102	:	return 1.0;
		case	104	:	return 0.7;
		case	111	:	return 0.7;
		
		case	201 :	return 1.0;
		case	222 :	return 1.0;
	}
	return 10;
}

static public function getSmokeSize(type:int): Number
{
	switch( type )
	{
		case	101	:	return 0.6;
		case	102	:	return 1.2;
		case	104	:	return 1.0;
		case	111	:	return 1.0;
		
		case	201 :	return 0.7;
		case	222 :	return 0.5;
	}
	return 10;
}
}
}