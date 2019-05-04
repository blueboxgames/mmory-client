package com.gerantech.towercraft.controls.items.exchange
{
import com.gerantech.towercraft.controls.buttons.ExchangeButton;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import com.gt.towers.constants.ResourceType;
import com.gt.towers.exchanges.ExchangeItem;
import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayoutData;
import flash.geom.Rectangle;
import starling.events.Event;

public class ExCurrencyItemRenderer extends ExBaseItemRenderer
{
private var iconDisplay:ImageLoader;
private var titleDisplay:ShadowLabel;
private var countDisplay:ShadowLabel;
private var buttonDisplay:ExchangeButton;
public function ExCurrencyItemRenderer(){}
override protected function commitData():void
{
	super.commitData();
	
	iconDisplay = new ImageLoader();
	iconDisplay.source = Assets.getTexture("shop/currency-" + exchange.type, "gui");
	iconDisplay.layoutData = new AnchorLayoutData(0, NaN, NaN, NaN, 0);
    iconDisplay.width = 380;
	addChild(iconDisplay);
	
	titleDisplay = new ShadowLabel(loc("exchange_title_" + exchange.type), 1, 0, null, null, false, null, 0.85);
	titleDisplay.layoutData = new AnchorLayoutData(padding * 2, NaN, NaN, NaN, 0);
	addChild(titleDisplay);
	
	countDisplay = new ShadowLabel("x " + exchange.outcomes.values()[0]);
	countDisplay.layoutData = new AnchorLayoutData(NaN, NaN, padding * 11, NaN, 0);
	addChild(countDisplay);	
	
	buttonDisplay = new ExchangeButton();
	buttonDisplay.layoutData = new AnchorLayoutData(NaN, padding, padding, padding);
	buttonDisplay.height = 96;
	if( exchange.requirements.keys()[0] == ResourceType.R5_CURRENCY_REAL )
		buttonDisplay.currency = "ت";
	buttonDisplay.count = exchange.requirements.values()[0];
	buttonDisplay.type = exchange.requirements.keys()[0];
	addChild(buttonDisplay);
}
}
}