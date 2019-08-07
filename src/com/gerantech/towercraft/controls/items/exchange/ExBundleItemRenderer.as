package com.gerantech.towercraft.controls.items.exchange
{
import com.gerantech.mmory.core.exchanges.ExchangeItem;
import com.gerantech.mmory.core.exchanges.Exchanger;
import com.gerantech.towercraft.controls.buttons.MMOryButton;
import com.gerantech.towercraft.controls.groups.Devider;
import com.gerantech.towercraft.controls.popups.BundleDetailsPopup;
import com.gerantech.towercraft.models.Assets;

import feathers.controls.ImageLoader;
import feathers.controls.LayoutGroup;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.RelativePosition;
import feathers.layout.VerticalAlign;

import flash.geom.Rectangle;

import starling.events.Event;
import starling.core.Starling;

public class ExBundleItemRenderer extends ExDefaultItemRenderer
{
public function ExBundleItemRenderer(category:int) { super(category); }
override protected function initialize() : void
{
	super.initialize();
	
	var insideLayout:AnchorLayoutData = new AnchorLayoutData(20, 20, 196, 20);
	var insideSkin:ImageLoader = new ImageLoader();
	insideSkin.scale9Grid = new Rectangle(1, 1, 6, 5);
	insideSkin.source = Assets.getTexture("shop/gradient-gold-bg", "gui");
  insideSkin.layoutData = insideLayout;
  this.addChildAt(insideSkin, 0);
}

override protected function commitData() : void
{
	super.commitData();

	if( this.exchange.numExchanges > 0 )
	{
		// this.buttonDisplay.label = loc("achieved_label");
		// this.buttonDisplay.iconTexture = null;
		return;
	}

	var outKeys:Vector.<int> = this.exchange.outcomes.keys();
	var oldPrice:int = Exchanger.toReal(this.exchange.outcomes);
	
	// items
	var itemsLayout:HorizontalLayout = new HorizontalLayout();
	itemsLayout.horizontalAlign = HorizontalAlign.CENTER;
	itemsLayout.verticalAlign = VerticalAlign.JUSTIFY;
	itemsLayout.hasVariableItemDimensions = true;
	itemsLayout.padding = 60;
	itemsLayout.gap = 0;
	var gapW:int = 48;
	var colW:int = Math.min(280, (this._owner.width - itemsLayout.gap * (outKeys.length + 1) - itemsLayout.padding * 2 - gapW * (outKeys.length - 1)) / outKeys.length);
	var items:LayoutGroup = new LayoutGroup();
	items.layoutData = new AnchorLayoutData(40, 0, 280, 0);
	items.layout = itemsLayout;
	this.addChild(items);
	for ( var i:int = 0; i < outKeys.length; i++ )
	{
		items.addChild(BundleDetailsPopup.createOutcome(outKeys[i], this.exchange.outcomes.get(outKeys[i]), colW));

		if( i == outKeys.length - 1 )
			continue;
		var plusImage:ImageLoader = new ImageLoader();
		plusImage.width = plusImage.height = gapW;
		plusImage.source = Assets.getTexture("shop/plus", "gui")
		items.addChild(plusImage);
	}

	this.buttonDisplay.message = MMOryButton.getLabel(reqType, oldPrice);

	var discountBadge:LayoutGroup = BundleDetailsPopup.createBadge(Math.round((1 - (reqCount / oldPrice)) * 100));
  discountBadge.layoutData = new AnchorLayoutData(NaN, NaN, -32, -20);
	this.addChild(discountBadge);
}

override protected function iconFactory() : void {}
override protected function titleFactory() : void {}
override protected function buttonFactory():void
{
	super.buttonFactory();
	this.buttonDisplay.height = 142;
	this.buttonDisplay.paddingLeft = 200;
	this.buttonDisplay.messagePosition = RelativePosition.RIGHT;

	var line:Devider = new Devider(0xBB0000);
	line.layoutData = new AnchorLayoutData(NaN, 280, 148, 460);
	this.addChild(line);
}
override protected function exchangeManager_endInteractionHandler(event:Event):void 
{
	var item:ExchangeItem = event.data as ExchangeItem;
	if( item.type == exchange.type )
		showAchieveAnimation(item);
}

override protected function showAchieveAnimation(item:ExchangeItem):void 
{
	if( item.containBook() > -1 )
		return;
	super.showAchieveAnimation(item);
}
}
}