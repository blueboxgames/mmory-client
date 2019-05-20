package com.gerantech.towercraft.controls.items.exchange
{
import com.gerantech.towercraft.controls.buttons.IndicatorButton;
import com.gerantech.towercraft.controls.headers.ExchangeHeader;
import com.gerantech.towercraft.controls.items.AbstractTouchableListItemRenderer;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.controls.tooltips.BaseTooltip;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.vo.ShopLine;
import com.gerantech.towercraft.themes.MainTheme;
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

import starling.display.DisplayObject;
import starling.display.Image;
import starling.events.Event;

public class ExCategoryItemRenderer extends AbstractTouchableListItemRenderer 
{
private var line:ShopLine;
private var list:List;
private var labelDisplay:ShadowLabel;
private var listLayout:TiledRowsLayout;
private var headerDisplay:ExchangeHeader;
private var descriptionDisplay:RTLLabel;
private var categoryCollection:ListCollection = new ListCollection();
static public const HEADER_SIZE:int = 110;
static public const BACKGROUND_SCALEGRID:Rectangle = new Rectangle(16, 104, 1, 1);


static private const BGS:Object = {-1:"shop/cate-blue", 0:"shop/cate-purple", 10:"shop/cate-yellow", 70:"shop/cate-red"};
static public function GET_BG(category:int) : String
{
	return BGS.hasOwnProperty(category) ? BGS[category] : BGS[-1];
}

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

static private const HEIGHTS:Object = {-1:400, 0:420, 10:420, 20:420, 30:500};
static public function GET_HEIGHT(category:int) : int
{
	return HEIGHTS.hasOwnProperty(category) ? HEIGHTS[category] : HEIGHTS[-1];
}

public function ExCategoryItemRenderer() { super(); }
override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout();
	
	backgroundSkin = new Image(null);
	Image(backgroundSkin).scale9Grid = BACKGROUND_SCALEGRID;

	labelDisplay = new ShadowLabel(null, 1, 0, null, null, false, null, 0.8, null, "bold");
	labelDisplay.layoutData = new AnchorLayoutData(20, NaN, NaN, NaN, 0);
	addChild(labelDisplay as DisplayObject);
	
	var infoButton:IndicatorButton = new IndicatorButton();
	infoButton.label = "?";
	infoButton.width = 64;
	infoButton.height = 68;
	infoButton.fixed = false;
	infoButton.styleName = MainTheme.STYLE_BUTTON_SMALL_HILIGHT;
	infoButton.addEventListener(Event.TRIGGERED, infoButton_trigeredHandler);
	infoButton.layoutData = new AnchorLayoutData(20, appModel.isLTR?20:NaN, NaN, appModel.isLTR?NaN:20);
	addChild(infoButton);

	listLayout = new TiledRowsLayout();
	listLayout.paddingLeft = listLayout.paddingRight = 28;
	listLayout.paddingBottom = listLayout.paddingTop = 46;
	listLayout.tileVerticalAlign = listLayout.verticalAlign = VerticalAlign.TOP;
	listLayout.tileHorizontalAlign = listLayout.horizontalAlign = HorizontalAlign.LEFT;
	listLayout.useVirtualLayout = false;
	listLayout.useSquareTiles = false;
	listLayout.requestedColumnCount = 3;
	listLayout.horizontalGap = 42;
	listLayout.verticalGap = 32;
	
	list = new List();
	list.layout = listLayout;
	list.layoutData = new AnchorLayoutData(HEADER_SIZE, 0, 0, 0);
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
	var cellHeight:int = GET_HEIGHT(line.category);
	labelDisplay.text = loc("exchange_title_" + line.category);
	Image(backgroundSkin).texture = Assets.getTexture(GET_BG(line.category), "gui");

	//descriptionDisplay.visible = false;
	switch( line.category )
	{
		case ExchangeType.C20_SPECIALS:
			// headerDisplay.showCountdown(line.items[0]);
			if( list.itemRendererFactory == null )// init first item in feathers two called
				list.itemRendererFactory = function ():IListItemRenderer{ return new ExSpecialItemRenderer(line.category);}
			break;
		
		case ExchangeType.C30_BUNDLES:
			listLayout.typicalItemWidth = Math.floor((width - listLayout.gap * 2)) ;
			// headerDisplay.showCountdown(line.items[0]);
			list.itemRendererFactory = function ():IListItemRenderer{ return new ExBundleItemRenderer();}
			break;
		
		default:
			list.itemRendererFactory = function ():IListItemRenderer{ return new ExDefaultItemRenderer(line.category);}
			break;
	}
	
	var numLines:int = Math.ceil(line.items.length / listLayout.requestedColumnCount);
	listLayout.typicalItemWidth = Math.floor((width - listLayout.paddingLeft - listLayout.paddingRight - listLayout.horizontalGap * 2) / 3);
	listLayout.typicalItemHeight = cellHeight;
	height = cellHeight * numLines + listLayout.verticalGap * (numLines - 1) + listLayout.paddingTop + listLayout.paddingBottom + HEADER_SIZE;
	categoryCollection.data = line.items;
}

protected function list_changeHandler(event:Event) : void
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

protected function infoButton_trigeredHandler(event:Event):void
{
	appModel.navigator.addChild(new BaseTooltip(loc("tooltip_exchange_" + line.category), IndicatorButton(event.currentTarget).getBounds(stage)));
}
}
}