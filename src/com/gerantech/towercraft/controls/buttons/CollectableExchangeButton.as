package com.gerantech.towercraft.controls.buttons 
{
import com.gerantech.towercraft.controls.texts.CountdownLabel;
import com.gt.towers.exchanges.ExchangeItem;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import starling.events.Event;

/**
* @author Mansour Djawadi
*/
public class CollectableExchangeButton extends CollectableButton 
{
protected var exchange:ExchangeItem;
protected var countdownDisplay:CountdownLabel;
public function CollectableExchangeButton(){ super(); }
override public function update() : void
{
	super.update();

	state = exchange.getState(timeManager.now);
	if( state == ExchangeItem.CHEST_STATE_BUSY )
	{
		timeManager.addEventListener(Event.CHANGE, timeManager_changeHandler);
		timeManager_changeHandler(null);
	}
	exchangeManager.addEventListener(FeathersEventType.END_INTERACTION, exchangeManager_endInteractionHandler);
	countdownFactory();
}

protected function countdownFactory() : CountdownLabel
{
	if( state != ExchangeItem.CHEST_STATE_BUSY )
		return null;
	
	countdownDisplay = new CountdownLabel();
	countdownDisplay.touchable = false;
	countdownDisplay.height = 90;
	countdownDisplay.layoutData = new AnchorLayoutData(NaN, 170, NaN, 20, NaN, 20);
	addChild(countdownDisplay);
	return countdownDisplay;
}

protected function exchangeManager_endInteractionHandler(event:Event) : void 
{
	var item:ExchangeItem = event.data as ExchangeItem;
	if( item.type != exchange.type )
		return;
	update();
}
protected function timeManager_changeHandler(event:Event) : void
{
	if(	exchange.getState(timeManager.now) != ExchangeItem.CHEST_STATE_BUSY )
	{
		update();
		return;
	}
	
	var t:uint = uint(exchange.expiredAt - timeManager.now);//trace(index, t)
	//if( buttonDisplay != null )
	//	buttonDisplay.count = Exchanger.timeToHard(t);
	
	if( countdownDisplay != null )
		countdownDisplay.time = t;
}

override protected function reset() : void
{
	super.reset();
	countdownDisplay = null;
	exchangeManager.removeEventListener(FeathersEventType.END_INTERACTION, exchangeManager_endInteractionHandler);
	timeManager.removeEventListener(Event.CHANGE, timeManager_changeHandler);
}
}
}