package com.gerantech.towercraft.controls.items.exchange
{
import com.gerantech.towercraft.controls.items.AbstractTouchableListItemRenderer;
import com.gerantech.mmory.core.exchanges.ExchangeItem;

import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.TiledRowsLayout;
import feathers.skins.ImageSkin;

import flash.geom.Rectangle;

import starling.events.Event;

public class ExBaseItemRenderer extends AbstractTouchableListItemRenderer
{
protected var firstCommit:Boolean = true;
protected var exchange:ExchangeItem;

public function ExBaseItemRenderer(){super();}
override protected function initialize():void
{
	super.initialize();
	
	layout = new AnchorLayout();
	skin = new ImageSkin();
	backgroundSkin = skin;
}

override protected function commitData():void
{
	if( firstCommit )
	{
		width = TiledRowsLayout(_owner.layout).typicalItemWidth;
		height = TiledRowsLayout(_owner.layout).typicalItemHeight;
		exchangeManager.addEventListener(FeathersEventType.END_INTERACTION, exchangeManager_endInteractionHandler);
		firstCommit = false;
	}
	exchange = exchanger.items.get(_data as int);
	super.commitData();
}

protected function exchangeManager_endInteractionHandler(event:Event):void 
{
	if( event.data == null )
		return;
	resetData(event.data as ExchangeItem);
}

protected function resetData(item:ExchangeItem):void 
{
	commitData();
	if( item.type == exchange.type )
		showAchieveAnimation(item);
}

protected function showAchieveAnimation(item:ExchangeItem):void 
{
	if( item == null )
		return;
	var outs:Vector.<int> = item.outcomes.keys();
	var rect:Rectangle = getBounds(stage);
	for( var i:int = 0; i < outs.length; i++ )
		appModel.navigator.dispatchEventWith("achieveResource", false, [rect.x + rect.width * 0.5, rect.y + rect.height * 0.5, outs[i], item.outcomes.get(outs[i]), i * 0.3 + 0.1]);
}

override public function dispose() : void
{
	if( exchangeManager != null )
		exchangeManager.removeEventListener(FeathersEventType.END_INTERACTION, exchangeManager_endInteractionHandler);
	super.dispose();
}
}
}