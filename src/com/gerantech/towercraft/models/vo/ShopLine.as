package com.gerantech.towercraft.models.vo
{
public class ShopLine
{
public var category:int;
public var items:Array;

public function ShopLine(category:int)
{
	this.category = category;
	items = new Array();
}

public function add(type:int):void
{
	items.push(type);
}

}
}