package com.gerantech.towercraft.controls.items.exchange
{
import com.gerantech.towercraft.controls.items.AbstractTouchableListItemRenderer;
import com.gerantech.towercraft.models.vo.ShopLine;

import feathers.layout.AnchorLayout;

import starling.display.DisplayObject;

public class ExCategoryItemRenderer extends AbstractTouchableListItemRenderer 
{
static public var placeholders:Object;

static private const TEXT_COLORS:Object = {-1:0x88ccff, 0:0xf666ff, 10:0xffcc66, 70:0xff3859};
static public function GET_TEXT_COLORS(category:int) : uint
{
	return TEXT_COLORS.hasOwnProperty(category) ? TEXT_COLORS[category] : TEXT_COLORS[-1];
}

static private const COLORS:Object = {-1:0x4296fd, 0:0x1cd612, 10:0x1cd612};
static public function GET_COLOR(category:int) : uint
{
	return COLORS.hasOwnProperty(category) ? COLORS[category] : COLORS[-1];
}

public function ExCategoryItemRenderer() { super(); }
override protected function initialize():void
{
	layout = new AnchorLayout();
}
override protected function commitData():void
{
	super.commitData();
	if ( _data == null )
		return;
	
	if( placeholders == null )
		placeholders = new Object();
	
	var line:ShopLine = _data as ShopLine;
	if( placeholders[line.category] == null )
	{
		placeholders[line.category] = new ExCategoryPlaceHolder(line, _owner);
		placeholders[line.category].width = this.width;
	}
	
	this.removeChildren();
	this.addChild(placeholders[line.category] as DisplayObject)
}
}
}