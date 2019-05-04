package com.gerantech.towercraft.controls.items.exchange
{
import com.gerantech.towercraft.controls.headers.ExchangeHeader;
import com.gerantech.towercraft.controls.items.AbstractTouchableListItemRenderer;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.models.vo.ShopLine;
import com.gt.towers.constants.ExchangeType;
import com.gt.towers.exchanges.ExchangeItem;
import feathers.controls.List;
import feathers.controls.ScrollPolicy;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.TiledRowsLayout;
import feathers.layout.VerticalAlign;
import flash.geom.Rectangle;
import starling.events.Event;

public class ExCategoryItemRenderer extends AbstractTouchableListItemRenderer 
{
private static const _COLOR:Object = {c0:0xcc00ff, c10:0xffba00, c20:0x43da00, c30:0x2b85ff, c70:0xf2421f, c120:0x2b85ff};
private var line:ShopLine;
private var list:List;
private var listLayout:TiledRowsLayout;
private var headerDisplay:ExchangeHeader;
private var descriptionDisplay:RTLLabel;
private var categoryCollection:ListCollection = new ListCollection();

public static const HEIGHT_NORMAL:int = 360;
public static const HEIGHT_C20_SPECIALS:int = 492;
public static const HEIGHT_C30_BUNDLES:int = 580;
public static const HEIGHT_C120_MAGICS:int = 360;

public function ExCategoryItemRenderer() { super(); }
override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout();
	
	headerDisplay = new ExchangeHeader("shop/header", new Rectangle(44, 12, 2, 4), 52);
	headerDisplay.layoutData = new AnchorLayoutData(0, 0, NaN, 0);
	headerDisplay.height = 112;
	addChild(headerDisplay);
	
	listLayout = new TiledRowsLayout();
	listLayout.requestedColumnCount = 3;
	listLayout.tileHorizontalAlign = listLayout.horizontalAlign = HorizontalAlign.LEFT;
	listLayout.tileVerticalAlign = listLayout.verticalAlign = VerticalAlign.TOP;
	listLayout.useSquareTiles = false;
	listLayout.useVirtualLayout = false;
	listLayout.padding = listLayout.gap = 5;
	
	list = new List();
	list.layout = listLayout;
	list.layoutData = new AnchorLayoutData(headerDisplay.height, 0, 0, 0);
	list.horizontalScrollPolicy = list.verticalScrollPolicy = ScrollPolicy.OFF;
	list.addEventListener(Event.CHANGE, list_changeHandler);
	list.dataProvider = categoryCollection;
	addChild(list);
}

override protected function commitData():void
{
	super.commitData();
	if ( _data == null )
		return;
	line = _data as ShopLine;
	headerDisplay.label = loc("exchange_title_" + line.category);
	headerDisplay.data = line.category;
	headerDisplay.color = _COLOR["c" + line.category];

    var CELL_SIZE:int = 360;
	listLayout.typicalItemWidth = Math.floor((width - listLayout.gap * 4) / 3) ;
	//descriptionDisplay.visible = false;
	switch( line.category )
	{
		case ExchangeType.C20_SPECIALS:
			CELL_SIZE = HEIGHT_C20_SPECIALS;
			headerDisplay.showCountdown(line.items[0]);
			if( list.itemRendererFactory == null )// init first item in feathers two called
				list.itemRendererFactory = function ():IListItemRenderer{ return new ExSpecialItemRenderer();}
			break;
		
		case ExchangeType.C30_BUNDLES:
			CELL_SIZE = HEIGHT_C30_BUNDLES;
			listLayout.typicalItemWidth = Math.floor((width - listLayout.gap * 2)) ;
			headerDisplay.showCountdown(line.items[0]);
			list.itemRendererFactory = function ():IListItemRenderer{ return new ExBundleItemRenderer();}
			break;
		
		case ExchangeType.C120_MAGICS:
			CELL_SIZE = HEIGHT_C120_MAGICS;
			list.itemRendererFactory = function ():IListItemRenderer{ return new ExBookBaseItemRenderer();}
			break;		
		
		default:
            CELL_SIZE = (line.category == ExchangeType.C0_HARD || line.category == ExchangeType.C10_SOFT || line.category == ExchangeType.C70_TICKETS ? 520:360);
			list.itemRendererFactory = function ():IListItemRenderer{ return new ExCurrencyItemRenderer();}
			break;
	}
	
	height = CELL_SIZE * Math.ceil(line.items.length / listLayout.requestedColumnCount) + headerDisplay.height;
	listLayout.typicalItemHeight = CELL_SIZE - listLayout.gap * 1.6;
	/*setTimeout(function():void{*/categoryCollection.data = line.items/*}, index * 300);*/
	//alpha = 0;
	//Starling.juggler.tween(this, 0.3, {delay:index * 0.3, alpha:1});
}

private function list_changeHandler(event:Event):void
{
	var ei:ExchangeItem = exchanger.items.get(list.selectedItem as int);
	if( !ei.enabled )
		return;
	ei.enabled = false;
	owner.dispatchEventWith(FeathersEventType.FOCUS_IN, false, ei);
	list.removeEventListener(Event.CHANGE, list_changeHandler);
	list.selectedIndex = -1;
	list.addEventListener(Event.CHANGE, list_changeHandler);
}
}
}