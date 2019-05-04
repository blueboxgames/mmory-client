package com.gerantech.towercraft.controls.items.exchange
{
import com.gerantech.towercraft.controls.buttons.ExchangeButton;
import com.gerantech.towercraft.controls.overlays.OpenBookOverlay;
import com.gt.towers.constants.CardTypes;
import com.gt.towers.constants.ExchangeType;
import com.gt.towers.constants.ResourceType;
import com.gt.towers.exchanges.ExchangeItem;
import dragonBones.starling.StarlingArmatureDisplay;
import feathers.layout.AnchorLayoutData;
public class ExBookBaseItemRenderer extends ExBaseItemRenderer
{
protected var buttonDisplay:ExchangeButton;
protected var bookArmature:StarlingArmatureDisplay;

public function ExBookBaseItemRenderer(){}
override protected function commitData():void
{
	if( index < 0 || _data == null )
		return;
	super.commitData();
	bookFactory();
	buttonFactory();
}
protected function bookFactory() : StarlingArmatureDisplay 
{
	if( bookArmature == null )
	{
		bookArmature = OpenBookOverlay.factory.buildArmatureDisplay(exchange.outcome.toString());
		bookArmature.scale = OpenBookOverlay.getBookScale(exchange.outcome);
		bookArmature.x = width * 0.5;
		bookArmature.y = height * 0.4;
	}
	addChild(bookArmature);
	return bookArmature;
}
protected function buttonFactory() : ExchangeButton
{
	if( buttonDisplay == null )
	{
		buttonDisplay = new ExchangeButton();
		buttonDisplay.layoutData = new AnchorLayoutData(NaN, NaN, padding * 2, NaN, 0);
		buttonDisplay.height = 96;
		buttonDisplay.count = exchange.requirements.get(ResourceType.R4_CURRENCY_HARD);	
		buttonDisplay.type = ResourceType.R4_CURRENCY_HARD;		
	}
	addChild(buttonDisplay);
	return buttonDisplay;
}
override protected function showAchieveAnimation(item:ExchangeItem):void {}
}
}