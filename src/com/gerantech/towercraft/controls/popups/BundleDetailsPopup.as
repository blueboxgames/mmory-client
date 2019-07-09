package com.gerantech.towercraft.controls.popups
{
import com.gerantech.mmory.core.constants.CardTypes;
import com.gerantech.mmory.core.constants.ResourceType;
import com.gerantech.mmory.core.exchanges.ExchangeItem;
import com.gerantech.mmory.core.exchanges.Exchanger;
import com.gerantech.towercraft.controls.CardView;
import com.gerantech.towercraft.controls.buttons.MMOryButton;
import com.gerantech.towercraft.controls.groups.Devider;
import com.gerantech.towercraft.controls.items.exchange.ExDefaultItemRenderer;
import com.gerantech.towercraft.controls.overlays.TransitionData;
import com.gerantech.towercraft.controls.texts.CountdownLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.MainTheme;
import com.gerantech.towercraft.utils.StrUtils;

import feathers.controls.ImageLoader;
import feathers.controls.LayoutGroup;
import feathers.core.FeathersControl;
import feathers.core.ITextRenderer;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.RelativePosition;
import feathers.layout.VerticalAlign;

import flash.geom.Rectangle;

import starling.core.Starling;
import starling.display.Image;
import starling.events.Event;

public class BundleDetailsPopup extends SimplePopup
{
public var exchange:ExchangeItem;
private var closeButton:MMOryButton;
private var actionButton:MMOryButton;
private var countdownDisplay:CountdownLabel;
public function BundleDetailsPopup(exchange:ExchangeItem)
{
  super();
	this.exchange = exchange;
}

override protected function initialize():void
{
	var _p:int = 34;
	var _h:int = 1000;
	this.transitionIn = new TransitionData();
	this.transitionOut = new TransitionData();
	this.transitionOut.destinationAlpha = 0;
	this.transitionIn.sourceBound = this.transitionOut.destinationBound = new Rectangle(_p,	stageHeight * 0.5 - _h * 0.4,	stageWidth - _p * 2,	_h * 0.8);
	this.transitionOut.sourceBound = this.transitionIn.destinationBound = new Rectangle(_p,	stageHeight * 0.5 - _h * 0.5,	stageWidth - _p * 2,	_h * 1.0);
	
	super.initialize();

	this.overlay.alpha = 0.5;
	this.skin.source = appModel.theme.roundMediumInnerSkin;
	this.skin.scale9Grid = MainTheme.ROUND_MEDIUM_SCALE9_GRID;
	this.skin.color = 0x5984FF;

	var insideLayout:AnchorLayoutData = new AnchorLayoutData(110, 14, 14, 14);
	var insideSkin:ImageLoader = new ImageLoader();
	insideSkin.scale9Grid = new Rectangle(1, 1, 6, 5);
	insideSkin.source = Assets.getTexture("shop/gradient-gold-bg", "gui");
  insideSkin.layoutData = insideLayout;
  this.addChild(insideSkin);

	var headerSkin:ImageLoader = new ImageLoader();
  headerSkin.layoutData = new AnchorLayoutData(insideLayout.top, insideLayout.right, NaN, insideLayout.left);
	headerSkin.scale9Grid = MainTheme.QUAD_SCALE9_GRID;
	headerSkin.source = appModel.theme.quadSkin;
	headerSkin.height = 100;
	headerSkin.alpha = 0.5;
	headerSkin.color = 0;
	this.addChild(headerSkin);

	var titleDisplay:ShadowLabel = new ShadowLabel(loc("exchange_title_30"));
	titleDisplay.layoutData = new AnchorLayoutData(15, NaN, NaN, NaN, 50);
	this.addChild(titleDisplay);
	
	var outKeys:Vector.<int> = this.exchange.outcomes.keys();
	var reqType:int = this.exchange.requirements.keys()[0];
	var newPrice:int = this.exchange.requirements.get(reqType);
	var oldPrice:int = Exchanger.toReal(this.exchange.outcomes);

	// items
	var itemsLayout:HorizontalLayout = new HorizontalLayout();
	itemsLayout.horizontalAlign = HorizontalAlign.CENTER;
	itemsLayout.verticalAlign = VerticalAlign.JUSTIFY;
	itemsLayout.hasVariableItemDimensions = true;
	itemsLayout.padding = 40;
	itemsLayout.gap = 20;
	var gapW:int = 72;
	var colW:int = Math.min(280, (this.transitionOut.sourceBound.width - itemsLayout.gap * (outKeys.length + 1) - itemsLayout.padding * 2 - gapW * (outKeys.length - 1)) / outKeys.length);
	var items:LayoutGroup = new LayoutGroup();
	items.layoutData = new AnchorLayoutData(260, 0, 340, 0);
	items.layout = itemsLayout;
	this.addChild(items);
	for ( var i:int = 0; i < outKeys.length; i++ )
	{
		var item:LayoutGroup = createOutcome(outKeys[i], this.exchange.outcomes.get(outKeys[i]), colW);
		items.addChild(item);

		if( i == outKeys.length - 1 )
			continue;
		var plusImage:ImageLoader = new ImageLoader();
		plusImage.width = plusImage.height = gapW;
		plusImage.source = Assets.getTexture("shop/plus", "gui")
		items.addChild(plusImage);
	}

	this.closeButton = new MMOryButton();
	this.closeButton.styleName = MainTheme.STYLE_BUTTON_SMALL_NEUTRAL;
	this.closeButton.iconTexture = Assets.getTexture("theme/icon-cross", "gui");
	this.closeButton.width = 80;
	this.closeButton.height = 80;
	this.closeButton.layoutData = new AnchorLayoutData(15, 15);
	this.closeButton.addEventListener(Event.TRIGGERED, this.closeButton_triggeredHandler);
	this.addChild(this.closeButton);

	this.actionButton = new MMOryButton();
	this.actionButton.labelFactory = function () : ITextRenderer { return new ShadowLabel(null, 1, 0, "center", null, false, null, 1.2);	}
	this.actionButton.height = 200;
	this.actionButton.paddingTop = 10;
	this.actionButton.paddingBottom = 26;
	this.actionButton.messagePosition = RelativePosition.TOP;
	this.actionButton.iconSize = MMOryButton.DEFAULT_ICON_SIZE;
	this.actionButton.layoutData = new AnchorLayoutData(NaN, 28, 24, 28);
	this.actionButton.message = MMOryButton.getLabel(reqType, oldPrice);
	this.actionButton.label = MMOryButton.getLabel(reqType, newPrice);
	this.actionButton.addEventListener(Event.TRIGGERED, this.actionButton_triggeredHandler);
	this.addChild(this.actionButton);

	var line:Devider = new Devider(0xBB0000);
	line.layoutData = new AnchorLayoutData(NaN, 420, 184, 420);
	this.addChild(line);

	this.countdownDisplay = new CountdownLabel();
	this.countdownDisplay.width = 340;
	this.countdownDisplay.height = 110;
	this.countdownDisplay.time = this.exchange.expiredAt - timeManager.now;
	this.countdownDisplay.layoutData = new AnchorLayoutData(110, NaN, NaN, NaN, 10);
	this.timeManager.addEventListener(Event.CHANGE, this.timeManager_changeHandler);
	this.addChild(this.countdownDisplay);

	var discountBadge:LayoutGroup = createBadge(Math.round((1 - (newPrice / oldPrice)) * 100));
  discountBadge.layoutData = new AnchorLayoutData(-42, NaN, NaN, -_p);
	this.addChild(discountBadge);
}

static public function createBadge(discount:int):LayoutGroup 
{
	var discountBadge:LayoutGroup = new LayoutGroup();
	discountBadge.layout = new AnchorLayout();
  discountBadge.backgroundSkin = new Image(Assets.getTexture("shop/discount-badge", "gui"));

	var badgeTitle:ShadowLabel = new ShadowLabel(StrUtils.getNumber(discount + " %"), 1, 0x440000, null, "ltr", false, null, 1.5);
	badgeTitle.layoutData = new AnchorLayoutData(50, NaN, NaN, NaN, 0);
	discountBadge.addChild(badgeTitle);

	var badgeMessage:ShadowLabel = new ShadowLabel(StrUtils.loc("off_label"), 1, 0x440000, null, null, false, null, 0.8);
	badgeMessage.layoutData = new AnchorLayoutData(NaN, NaN, 50, NaN, 0);
	discountBadge.addChild(badgeMessage);
	return discountBadge;
}

static public function createOutcome(type:int, count:int, colW:int, hasShine:Boolean = true):LayoutGroup 
{
	var item:LayoutGroup = new LayoutGroup();
	item.layout = new AnchorLayout();
	item.width = colW;

	if( hasShine )
		var shineImage:ImageLoader = new ImageLoader();

	var itemIcon:FeathersControl;
	if( ResourceType.isCard(type) )
	{
		itemIcon = new CardView();
		CardView(itemIcon).type = type;
		CardView(itemIcon).availablity = CardTypes.AVAILABLITY_EXISTS;
		itemIcon.height = (item.width - 48) * CardView.VERICAL_SCALE;
		itemIcon.layoutData = new AnchorLayoutData(NaN, 24, NaN, 24, NaN, 0);

		if( hasShine )
			shineImage.width = shineImage.height = colW * 2.0;
	}
	else
	{
		itemIcon = new ImageLoader();
		ImageLoader(itemIcon).source = Assets.getTexture(getTexturURL(type), "gui");
		itemIcon.layoutData = new AnchorLayoutData(0, 0, 0, 0);

		if( hasShine )
			shineImage.width = shineImage.height = colW * 1.2;
	}
	item.addChild(itemIcon);
	
	if( hasShine )
	{
		shineImage.source = Assets.getTexture("shop/shine-under-item", "gui");
		shineImage.pivotX = shineImage.pivotY = shineImage.width * 0.5;
		Starling.juggler.tween(shineImage, 14, {rotation:Math.PI * 2, repeatCount:40});
		shineImage.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, 0);
		item.addChildAt(shineImage, 0);
	}

	if( !ResourceType.isBook(type) )
	{
		var itemCount:ShadowLabel = new ShadowLabel(ExDefaultItemRenderer.titleFormatter(type, count), 1, 0, null, null, false, null, 1);
		itemCount.layoutData = new AnchorLayoutData(NaN, NaN, -80, NaN, 0);
		item.addChild(itemCount);
	}

	return item;
}

static public function getTexturURL(type:int) : String
{
	if( ResourceType.isEvent(type) )
		return "events/banner-" + (type%10);
	if( ResourceType.isBook(type) )
		return "books/" + type;
	if( ResourceType.isCard(type) )
		return "cards/" + type;
	switch( type )
	{
		case ResourceType.R6_TICKET: return "shop/currency-72";
		case ResourceType.R4_CURRENCY_HARD: return "shop/currency-2";
		default: return "shop/currency-11";
	}
}

protected function timeManager_changeHandler(event:Event):void
{
	this.countdownDisplay.time = this.exchange.expiredAt - timeManager.now;
}

protected function actionButton_triggeredHandler(event:Event):void
{
	exchangeManager.process(exchange);
	this.close();
}

protected function closeButton_triggeredHandler(event:Event):void
{
	this.close();
}
override public function dispose():void
{
	this.timeManager.removeEventListener(Event.CHANGE, this.timeManager_changeHandler);
  this.closeButton.removeEventListener(Event.TRIGGERED, this.closeButton_triggeredHandler);
	this.actionButton.removeEventListener(Event.TRIGGERED, this.actionButton_triggeredHandler);
	super.dispose();
}
}
}