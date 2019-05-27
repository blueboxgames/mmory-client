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

import starling.events.Event;

public class ExSpecialItemRenderer extends ExDefaultItemRenderer
{
public function ExSpecialItemRenderer(category:int) { super(category); }
override protected function initialize() : void
{
	this.exchangeManager.addEventListener(FeathersEventType.BEGIN_INTERACTION, exchangeManager_beginInteractionHandler);
	super.initialize();
}

override protected function commitData() : void
{
	this.removeChildren();
	super.commitData();
	if( this.exchange.numExchanges > 0 )
	{
		this.buttonDisplay.label = loc("achieved_label");
		this.buttonDisplay.iconTexture = null;
		return;
	}

	var outValue:int = exchange.requirements.keys()[0] == ResourceType.R4_CURRENCY_HARD ? Exchanger.toHard(exchange.outcomes) : Exchanger.toSoft(exchange.outcomes);
	var discount:int = Math.round((1 - (exchange.requirements.values()[0] / outValue)) * 100);
	var ribbonDisplay:ImageLoader = new ImageLoader();
	ribbonDisplay.source = Assets.getTexture("cards/empty-badge", "gui");
	ribbonDisplay.layoutData = new AnchorLayoutData(0, NaN, NaN, 0);
	ribbonDisplay.height = ribbonDisplay.width = width * 0.6;
	addChild(ribbonDisplay);
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
override protected function iconFactory() : void
{
	this.iconDisplay = new ImageLoader();
	this.iconDisplay.width = 150;
	this.iconDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, -40);
	this.iconDisplay.height = this.iconDisplay.width * CardView.VERICAL_SCALE;

	var iconBGDisplay:ImageLoader = new ImageLoader();
	iconBGDisplay.width = this.iconDisplay.width + 6;
	iconBGDisplay.source = appModel.theme.roundSmallSkin;
	iconBGDisplay.layoutData = this.iconDisplay.layoutData;
	iconBGDisplay.scale9Grid = MainTheme.ROUND_SMALL_SCALE9_GRID;
	iconBGDisplay.height = this.iconDisplay.width * CardView.VERICAL_SCALE + 6;

	this.addChild(iconBGDisplay);
	this.addChild(this.iconDisplay);
}

override protected function titleFactory() : void
{
	this.titleDisplay = new ShadowLabel(null, 1, 0, null, null, false, null, 0.9);
	this.titleDisplay.layoutData = new AnchorLayoutData(NaN, 72, 130);
	this.addChild(this.titleDisplay);
}

override protected function buttonLabelFactory() : ITextRenderer
{
	if( this.exchange.numExchanges == 0)
		return new ShadowLabel(null, 0x2ee723, 0, "center", null, false, null, 0.85);
	return new RTLLabel(null, 0x000088, "center", null, false, null, 0.85);
}

override protected function exchangeManager_endInteractionHandler(event:Event):void {}
protected function exchangeManager_beginInteractionHandler(event:Event):void 
{
	this.resetData(event.data as ExchangeItem);
}
}
}