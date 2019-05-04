package com.gerantech.towercraft.controls.items.exchange
{
import com.gerantech.towercraft.controls.BuildingCard;
import com.gerantech.towercraft.controls.buttons.DiscountButton;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import com.gt.towers.constants.ResourceType;
import com.gt.towers.exchanges.ExchangeItem;
import com.gt.towers.exchanges.Exchanger;
import feathers.controls.ImageLoader;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayoutData;
import starling.events.Event;

public class ExSpecialItemRenderer extends ExBaseItemRenderer
{

public function ExSpecialItemRenderer(){}
override protected function commitData():void
{
	if( firstCommit )
		exchangeManager.addEventListener(FeathersEventType.BEGIN_INTERACTION, exchangeManager_beginInteractionHandler);
	
	super.commitData();
	skin.alpha = 0.7;
	var cardDisplay:BuildingCard = new BuildingCard(false, false, true, false);
	cardDisplay.width = width * 0.65;
	cardDisplay.layoutData = new AnchorLayoutData(padding, NaN, NaN, NaN, 0);
	addChild(cardDisplay);
	cardDisplay.setData(exchange.outcome, 1, exchange.outcomes.values()[0]);
	
	if( exchange.numExchanges > 0 )
	{
		var fineDisplay:ImageLoader = new ImageLoader();
		fineDisplay.source = Assets.getTexture("checkbox-on");
		fineDisplay.layoutData = new AnchorLayoutData(NaN, NaN, padding * 4, NaN, padding * 2);
		fineDisplay.height = fineDisplay.width = width * 0.32;
		addChild(fineDisplay);
		return;
	}
	
	var outValue:int = exchange.requirements.keys()[0] == ResourceType.R4_CURRENCY_HARD ? Exchanger.toHard(exchange.outcomes) : Exchanger.toSoft(exchange.outcomes);
	var discount:int = Math.round((1 - (exchange.requirements.values()[0] / outValue)) * 100)
	
	var buttonDisplay:DiscountButton = new DiscountButton();
	buttonDisplay.layoutData = new AnchorLayoutData(NaN, NaN, padding * 2, NaN, 0);
	buttonDisplay.width = 320;
	if( exchange.requirements.keys()[0] == ResourceType.R5_CURRENCY_REAL )
		buttonDisplay.currency = "ت";
	buttonDisplay.originCount = outValue;
	buttonDisplay.count = exchange.requirements.values()[0];
	buttonDisplay.type = exchange.requirements.keys()[0];
	addChild(buttonDisplay);
	
	var ribbonDisplay:ImageLoader = new ImageLoader();
	ribbonDisplay.source = Assets.getTexture("cards/empty-badge");
	ribbonDisplay.layoutData = new AnchorLayoutData( -14, NaN, NaN, -14);
	ribbonDisplay.height = ribbonDisplay.width = width * 0.5;
	addChild(ribbonDisplay);
	ribbonDisplay.addEventListener(FeathersEventType.CREATION_COMPLETE, function():void
	{
		var discoutDisplay:ShadowLabel = new ShadowLabel( discount + "% OFF", 1, 0, "center", "ltr", false, null, 0.7 );
		discoutDisplay.width = 200;
		discoutDisplay.alignPivot();
		discoutDisplay.rotation = -0.8;
		discoutDisplay.x = ribbonDisplay.width * 0.33;
		discoutDisplay.y = ribbonDisplay.height * 0.33;
		ribbonDisplay.addChild(discoutDisplay);
	});
}

override protected function exchangeManager_endInteractionHandler(event:Event):void {}
protected function exchangeManager_beginInteractionHandler(event:Event):void 
{
	resetData(event.data as ExchangeItem);
}
}
}