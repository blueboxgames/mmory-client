package com.gerantech.towercraft.controls.items.exchange
{
import com.gerantech.towercraft.controls.CardView;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.MainTheme;
import com.gt.towers.constants.ResourceType;
import com.gt.towers.exchanges.ExchangeItem;
import com.gt.towers.exchanges.Exchanger;

import feathers.controls.ImageLoader;
import feathers.core.ITextRenderer;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayoutData;

import flash.geom.Point;

import starling.events.Event;

public class ExBundleItemRenderer extends ExDefaultItemRenderer
{
public function ExBundleItemRenderer(category:int) { super(category); }
override protected function initialize() : void
{
	this.exchangeManager.addEventListener(FeathersEventType.BEGIN_INTERACTION, exchangeManager_beginInteractionHandler);
	super.initialize();
}

override protected function commitData() : void
{
	super.commitData();
	if( this.exchange.numExchanges > 0 )
	{
		this.buttonDisplay.label = loc("achieved_label");
		this.buttonDisplay.iconTexture = null;
		return;
	}

/* 	var availabledLabel:RTLLabel = new RTLLabel(exchange.numExchanges + "/3", 0, null, "right", false, null, 0.7);
	availabledLabel.layoutData = new AnchorLayoutData(12, 24);
	addChild(availabledLabel);*/
 	
	var outKeys:Vector.<int> = exchange.outcomes.keys();
	var p:int = 140;
	var rowH:int = (width + p * 2) / (outKeys.length + 1);
	for ( var i:int = 0; i < outKeys.length; i++ )
		this.createOutcome(outKeys, i, rowH, p);

	var outValue:int = Exchanger.toReal(exchange.outcomes);
	var discount:int = Math.round((1 - (exchange.requirements.values()[0] / outValue)) * 100)
	var ribbonDisplay:ImageLoader = new ImageLoader();
	ribbonDisplay.source = Assets.getTexture("cards/empty-badge", "gui");
	ribbonDisplay.layoutData = new AnchorLayoutData(0, NaN, NaN, 0);
	ribbonDisplay.height = ribbonDisplay.width = 180;
	this.addChild(ribbonDisplay);
	ribbonDisplay.addEventListener(FeathersEventType.CREATION_COMPLETE, function():void
	{
		var discoutDisplay:ShadowLabel = new ShadowLabel( discount + "% OFF", 1, 0, "center", "ltr", false, null, 0.6);
		discoutDisplay.width = 200;
		discoutDisplay.alignPivot();
		discoutDisplay.rotation = -0.8;
		discoutDisplay.x = ribbonDisplay.width * 0.3;
		discoutDisplay.y = ribbonDisplay.height * 0.3;
		ribbonDisplay.addChild(discoutDisplay);
	});
}

private function createOutcome(outKeys:Vector.<int>, i:int, rowH:int, _padding:int):void 
{
	var book:Boolean = ResourceType.isBook(outKeys[i]);
	var _width:int = book ? 220 : 180;
	var point:Point = new Point((i+1) * rowH - _width * 0.5 - _padding, 70);

	var itemIcon:ImageLoader = new ImageLoader();
	itemIcon.width = _width;
	itemIcon.height = itemIcon.width * CardView.VERICAL_SCALE;trace(outKeys[i])
	itemIcon.source = Assets.getTexture((book ? "books/" : "cards/") + outKeys[i], "gui");
	itemIcon.x = point.x;
	itemIcon.y = point.y;

	if( !book )
	{
		var p:int = 3;
		var bgDisplay:ImageLoader = new ImageLoader();
		bgDisplay.width = itemIcon.width + p * 2;
		bgDisplay.height = itemIcon.width * CardView.VERICAL_SCALE + p * 2;
		bgDisplay.scale9Grid = MainTheme.ROUND_SMALL_SCALE9_GRID;
		bgDisplay.source = appModel.theme.roundSmallSkin;
		bgDisplay.x = point.x - p;
		bgDisplay.y = point.y - p;
		this.addChild(bgDisplay);
	}
	this.addChild(itemIcon);

	var itemCount:ShadowLabel = new ShadowLabel(null, 1, 0, null, null, false, null, 0.9);
	itemCount.x = point.x;
	itemCount.y = point.y - 10;
	this.addChild(itemCount);
}

override protected function buttonLabelFactory() : ITextRenderer
{
	if( this.exchange.numExchanges == 0)
		return new ShadowLabel(null, 0x2ee723, 0, "center", null, false, null, 0.85);
	return new RTLLabel(null, 0x000088, "center", null, false, null, 0.85);
}

override protected function iconFactory() : void {}
override protected function titleFactory() : void {}
override protected function exchangeManager_endInteractionHandler(event:Event):void {}
protected function exchangeManager_beginInteractionHandler(event:Event):void 
{
	this.resetData(event.data as ExchangeItem);
}

override protected function showAchieveAnimation(item:ExchangeItem):void 
{
	if( item.containBook() > -1 )
		return;
	super.showAchieveAnimation(item);
}
}
}