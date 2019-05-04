package com.gerantech.towercraft.controls.groups 
{
import com.gerantech.towercraft.controls.TowersLayout;
import com.gerantech.towercraft.controls.items.exchange.ExBookSlotItemRenderer;
import com.gt.towers.constants.ExchangeType;
import com.gt.towers.exchanges.ExchangeItem;
import feathers.controls.List;
import feathers.controls.ScrollPolicy;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.TiledRowsLayout;
import feathers.layout.VerticalAlign;
import starling.core.Starling;
import starling.events.Event;

/**
* ...
* @author Mansour Djawadi
*/
public class HomeBooksLine extends TowersLayout 
{
static public const HEIGHT:int = Math.min(320, Starling.current.stage.stageHeight * 0.2);
private var listLayout:feathers.layout.TiledRowsLayout;
private var list:feathers.controls.List;

public function HomeBooksLine(){super();}
override protected function initialize():void 
{
    height = HEIGHT;
	super.initialize();
	
	layout = new AnchorLayout();
	
	listLayout = new TiledRowsLayout();
	listLayout.requestedColumnCount = 4;
	listLayout.tileHorizontalAlign = listLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
	listLayout.verticalAlign = VerticalAlign.BOTTOM;
	listLayout.useSquareTiles = false;
	listLayout.useVirtualLayout = false;
	listLayout.padding = listLayout.gap = 3;
	listLayout.typicalItemWidth = Math.floor(stage.stageWidth / listLayout.requestedColumnCount - 15);
	listLayout.typicalItemHeight = height - listLayout.gap;

	list = new List();
	list.layout = listLayout;
	list.clipContent = false;
	list.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	list.horizontalScrollPolicy = list.verticalScrollPolicy = ScrollPolicy.OFF;
	list.addEventListener(Event.CHANGE, list_changeHandler);
	list.itemRendererFactory = function ():IListItemRenderer{ return new ExBookSlotItemRenderer();}
	list.dataProvider = new ListCollection([111, 112, 113, 114]);
	addChild(list);
}

private function list_changeHandler(event:Event):void
{
	var ei:ExchangeItem = exchanger.items.get(list.selectedItem as int);
	if(	!ei.enabled	)
		return;
	ei.enabled = false;
	exchangeManager.process(ei);
	
	list.removeEventListener(Event.CHANGE, list_changeHandler);
	list.selectedIndex = -1;
	list.addEventListener(Event.CHANGE, list_changeHandler);
}
}
}