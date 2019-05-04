package com.gerantech.towercraft.models.vo
{
public class SettingsData
{
public static const TYPE_TOGGLE:int = 0;
public static const TYPE_BUTTON:int = 1;
public static const TYPE_LABEL_BUTTONS:int = 2;
public static const TYPE_ICON_BUTTONS:int = 3;

public static const LOCALES:int = 4;
public static const LINK_DEVICE:int = 10;
public static const LEGALS:int = 11;
public static const RENAME:int = 12;
public static const BUG_REPORT:int = 21;
public static const FAQ:int = 22;
public static const TELEGRAM:int = 311;
public static const INSTAGRAM:int = 312;
public static const FACEBOOOK:int = 313;
public static const YOUTUBE:int = 314;
public static const RATING:int = 315;

public var index:int;
public var key:int;
public var type:int;
public var value:Object;
public var data:Object;

public function SettingsData(key:int, type:int, value:Object, data:Object = null)
{
	this.key = key;
	this.type = type;
	this.value = value;
	this.data = data;
}
}
}