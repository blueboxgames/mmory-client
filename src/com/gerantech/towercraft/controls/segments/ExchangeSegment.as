package com.gerantech.towercraft.controls.segments
{
import com.gerantech.mmory.core.constants.ExchangeType;
import com.gerantech.mmory.core.constants.ResourceType;
import com.gerantech.mmory.core.exchanges.ExchangeItem;
import com.gerantech.towercraft.controls.items.EmoteItemRenderer;
import com.gerantech.towercraft.controls.items.exchange.ExCategoryItemRenderer;
import com.gerantech.towercraft.controls.items.exchange.ExCategoryPlaceHolder;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.vo.ShopLine;

import feathers.controls.List;
import feathers.controls.ScrollBarDisplayMode;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalLayout;

import starling.events.Event;
import com.gerantech.mmory.core.socials.Challenge;

public class ExchangeSegment extends Segment
{
public static var SELECTED_CATEGORY:int = 0
private var itemslistData:ListCollection;
private var itemslist:List;
private var scrollPaddingTop:int;

public function ExchangeSegment(){ super(); }
override public function init():void
{
	super.init();
/* 	EmoteItemRenderer.loadEmotes(animation_loadCallback);
}

protected function animation_loadCallback():void 
{ */

	layout = new AnchorLayout();

	if( player.get_battleswins() < 4 )
	{
		var labelDisplay:ShadowLabel = new ShadowLabel(loc("button_availabled_after_tutorial", [loc("tab-0")]), 1, 0, "center");
		labelDisplay.width = width;
		labelDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, NaN, 0);
		addChild(labelDisplay);
		return;
	}

	var listLayout:VerticalLayout = new VerticalLayout();
	listLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
	listLayout.hasVariableItemDimensions = true;
	listLayout.useVirtualLayout = true;
	listLayout.padding = 50;
	listLayout.paddingTop = 180;
	listLayout.gap = 80;
	
	updateData();
	itemslist = new List();
	itemslist.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
	itemslist.layout = listLayout;
	itemslist.layoutData = new AnchorLayoutData(0, paddingH, 0, paddingH);
	itemslist.itemRendererFactory = function():IListItemRenderer { return new ExCategoryItemRenderer(); }
	itemslist.dataProvider = itemslistData;
	itemslist.addEventListener(Event.SELECT, list_categorySelectHandler);
	addChild(itemslist);
	initializeCompleted = true;
	focus();
}

override public function focus():void
{
	//if( !initializeCompleted )
		// return;
	///////////////////////showTutorial();
	//var time:Number = Math.abs(focusedCategory * 520 - itemslist.verticalScrollPosition) * 0.003;
	if( SELECTED_CATEGORY == 0 )
		itemslist.scrollToPosition(0, 0, 0.5);
	else
		itemslist.scrollToPosition(0, SELECTED_CATEGORY * ExCategoryPlaceHolder.GET_HEIGHT(0) + scrollPaddingTop, 0.5);
	SELECTED_CATEGORY = 0;
}

override public function updateData():void
{
	if( itemslistData != null )
		return;
	
	var itemKeys:Vector.<int> = exchanger.items.keys();
	var bundles:ShopLine = new ShopLine(ExchangeType.C30_BUNDLES);
	var specials:ShopLine = new ShopLine(ExchangeType.C20_SPECIALS);
	var emotes:ShopLine = new ShopLine(ExchangeType.C80_EMOTES);
	var magics:ShopLine = new ShopLine(ExchangeType.C120_MAGICS);
	var tickets:ShopLine = new ShopLine(ExchangeType.C70_TICKETS);
	var hards:ShopLine = new ShopLine(ExchangeType.C0_HARD);
	var softs:ShopLine = new ShopLine(ExchangeType.C10_SOFT);
	for( var i:int=0; i<itemKeys.length; i++ )
	{
		if( ExchangeType.getCategory( itemKeys[i] ) == ExchangeType.C30_BUNDLES && exchanger.items.get(itemKeys[i]).expiredAt > timeManager.now )
			bundles.add(itemKeys[i]);
		if( ExchangeType.getCategory( itemKeys[i] ) == ExchangeType.C20_SPECIALS && itemKeys[i] != ExchangeType.C29_DAILY_BATTLES )
			specials.add(itemKeys[i]);
		else if( ExchangeType.getCategory( itemKeys[i] ) == ExchangeType.C80_EMOTES && player.unlocked_social() )
			emotes.add(itemKeys[i]);
		else if( ExchangeType.getCategory( itemKeys[i] ) == ExchangeType.C120_MAGICS && player.get_arena(0) > 1 )
			magics.add(itemKeys[i]);
		else if( ExchangeType.getCategory( itemKeys[i] ) == ExchangeType.C70_TICKETS && Challenge.getUnlockAt(game, 1) <= player.getResource(ResourceType.R7_MAX_POINT) && player.getResource(ResourceType.R6_TICKET) < 20 )
			tickets.add(itemKeys[i]);
		else if( ExchangeType.getCategory( itemKeys[i] ) == ExchangeType.C0_HARD && itemKeys[i] != ExchangeType.C0_HARD )
			hards.add(itemKeys[i]);
		else if( ExchangeType.getCategory( itemKeys[i] ) == ExchangeType.C10_SOFT )
			softs.add(itemKeys[i]);
	}
	
	scrollPaddingTop = ExCategoryPlaceHolder.GET_HEIGHT(120) + 100;
	var categoreis:Array = new Array();
	if( bundles.items.length > 0 )
	{
		categoreis.push(bundles);
		scrollPaddingTop += ExCategoryPlaceHolder.GET_HEIGHT(30);
	}
	if( specials.items.length > 0 )
	{
		categoreis.push(specials);
		scrollPaddingTop += ExCategoryPlaceHolder.GET_HEIGHT(20);
	}
	if( magics.items.length > 0 )
		categoreis.push(magics);
	if( emotes.items.length > 0 )
		categoreis.push(emotes);
	if( tickets.items.length > 0 )
		categoreis.push(tickets);
	if( hards.items.length > 0 )
		categoreis.push(hards);
	if( softs.items.length > 0 )
		categoreis.push(softs);

	for (i=0; i<categoreis.length; i++)
		categoreis[i].items.sort();
	
	itemslistData = new ListCollection(categoreis);
	scrollPaddingTop = ExCategoryPlaceHolder.GET_HEIGHT(120);
}

private function list_categorySelectHandler(event:Event) : void
{
	exchangeManager.process(event.data as ExchangeItem);
}

/*private function confirms_closeHandler(event:Event):void
{
	var item:ExchangeItem = RequirementConfirmPopup(event.currentTarget).data as ExchangeItem;
	item.enabled = true;
}
private function confirms_errorHandler(event:Event):void
{
	appModel.navigator.addLog(loc("log_not_enough", [loc("resource_title_" + ResourceType.R4_CURRENCY_HARD)]));
}
private function confirms_selectHandler(event:Event):void
{
	var item:ExchangeItem = RequirementConfirmPopup(event.currentTarget).data as ExchangeItem;
	var params:SFSObject = new SFSObject();
	params.putInt("type", item.type );
	params.putInt("hards", RequirementConfirmPopup(event.currentTarget).numHards );
	sendData(params);
}*/
}
}