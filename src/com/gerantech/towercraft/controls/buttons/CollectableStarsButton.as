package com.gerantech.towercraft.controls.buttons 
{
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.vo.RewardData;
import com.gerantech.towercraft.utils.StrUtils;
import com.gt.towers.constants.ExchangeType;
import com.gt.towers.constants.ResourceType;
import com.gt.towers.exchanges.ExchangeItem;
import feathers.controls.ImageLoader;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayoutData;
import starling.events.Event;

/**
* @author Mansour Djawadi
*/
public class CollectableStarsButton extends CollectableExchangeButton
{
public function CollectableStarsButton(){ super(); }

override public function update() : void
{
	exchange = exchanger.items.get(ExchangeType.C104_STARS);
	if( exchange == null )
		return;
	super.update();

	backgroundFactory();
	sliderFactory();
	iconFactory("home/gift");
	if( countdownDisplay != null )
		addChild(countdownDisplay)
	titleFactory(loc(state == ExchangeItem.CHEST_STATE_BUSY ? "nextin_label" : (state == ExchangeItem.CHEST_STATE_WAIT ? "" : "open_label")));
}

override protected function titleFactory(text:String) : ShadowLabel
{
	titleDisplay = new ShadowLabel(text, 1, 0, "center", null, false, null, state == ExchangeItem.CHEST_STATE_READY ? 0.9 : 0.6);
	titleDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, -54, state == ExchangeItem.CHEST_STATE_READY ? 0 : -30);
	titleDisplay.touchable = false;
	addChild(titleDisplay);
	return titleDisplay;
}

protected function sliderFactory() : Indicator 
{
	if( state != ExchangeItem.CHEST_STATE_WAIT )
	{
		appModel.navigator.addEventListener("achieveResource", navigator_achieveResourceHandler);
		return null;
	}
	
	var ind_17:Indicator = new Indicator("ltr", ResourceType.R17_STARS, true, false);
	ind_17.height = 54;
	ind_17.layoutData = new AnchorLayoutData(NaN, 90, NaN, 90, NaN, 0);
	ind_17.formatValueFactory = function(value:Number, minimum:Number, maximum:Number) : String
	{
		return StrUtils.getNumber( Math.round(value) + "/" + maximum );
	}
	ind_17.addEventListener(FeathersEventType.CREATION_COMPLETE, function() : void
	{
		var icon:ImageLoader = ind_17.iconDisplay;
		icon.width = icon.height = 80;
		AnchorLayoutData(icon.layoutData).verticalCenter = -8;
		AnchorLayoutData(icon.layoutData).left = -55;
	});
	ind_17.maximum = 10;
	addChild(ind_17);
	return ind_17;
}

// remove key achieve item when indicator is not exists
protected function navigator_achieveResourceHandler(event:Event) : void 
{
	if( appModel.battleFieldView == null || appModel.battleFieldView.battleData == null || appModel.battleFieldView.battleData.outcomes == null )
		return;
	for( var i:int = 0; i < appModel.battleFieldView.battleData.outcomes.length; i++ )
	{
		var rd:RewardData = appModel.battleFieldView.battleData.outcomes[i];
		if( rd.key == ResourceType.R17_STARS )
		{
			appModel.battleFieldView.battleData.outcomes.removeAt(i);
			return;
		}
	}
}

override protected function reset() : void
{
	super.reset();
	appModel.navigator.removeEventListener("achieveResource", navigator_achieveResourceHandler);
}
}
}