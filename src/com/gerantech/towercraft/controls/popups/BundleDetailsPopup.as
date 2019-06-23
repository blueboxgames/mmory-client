package com.gerantech.towercraft.controls.popups
{
import com.gerantech.mmory.core.constants.ResourceType;
import com.gerantech.mmory.core.exchanges.ExchangeItem;
import com.gerantech.mmory.core.exchanges.Exchanger;
import com.gerantech.towercraft.controls.buttons.MMOryButton;
import com.gerantech.towercraft.controls.overlays.TransitionData;
import com.gerantech.towercraft.controls.texts.CountdownLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.MainTheme;
import com.gerantech.towercraft.utils.StrUtils;

import feathers.controls.ImageLoader;
import feathers.controls.LayoutGroup;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.RelativePosition;

import flash.geom.Rectangle;

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
	insideSkin.scale9Grid = new Rectangle(1, 1, 14, 13);
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
	
  this.closeButton = new MMOryButton();
	this.closeButton.styleName = MainTheme.STYLE_BUTTON_SMALL_NEUTRAL;
	this.closeButton.iconTexture = Assets.getTexture("theme/icon-cross", "gui");
	this.closeButton.width = 80;
	this.closeButton.height = 80;
	this.closeButton.layoutData = new AnchorLayoutData(15, 15);
	this.closeButton.addEventListener(Event.TRIGGERED, this.closeButton_triggeredHandler);
	this.addChild(this.closeButton);

	var oldPrice:int = Exchanger.toReal(this.exchange.outcomes);
	var newPrice:int = this.exchange.requirements.values()[0];

	this.actionButton = new MMOryButton();
	this.actionButton.height = 200;
	this.actionButton.paddingTop = 10;
	this.actionButton.paddingBottom = 30;
	this.actionButton.messagePosition = RelativePosition.TOP;
	this.actionButton.iconSize = MMOryButton.DEFAULT_ICON_SIZE;
	this.actionButton.layoutData = new AnchorLayoutData(NaN, 28, 24, 28);
	this.actionButton.message = MMOryButton.getLabel(ResourceType.R5_CURRENCY_REAL, oldPrice);
	this.actionButton.label = MMOryButton.getLabel(ResourceType.R5_CURRENCY_REAL, newPrice);
	this.actionButton.addEventListener(Event.TRIGGERED, this.actionButton_triggeredHandler);
	this.addChild(this.actionButton);

	this.countdownDisplay = new CountdownLabel();
	this.countdownDisplay.width = 400;
	this.countdownDisplay.time = this.exchange.expiredAt - timeManager.now;
	this.countdownDisplay.layoutData = new AnchorLayoutData(120, NaN, NaN, NaN, 10);
	this.timeManager.addEventListener(Event.CHANGE, this.timeManager_changeHandler);
	this.addChild(this.countdownDisplay);

	var discountBadge:LayoutGroup = new LayoutGroup();
	discountBadge.layout = new AnchorLayout();
  discountBadge.backgroundSkin = new Image(Assets.getTexture("shop/discount-badge", "gui"));
  discountBadge.layoutData = new AnchorLayoutData(-42, NaN, NaN, -_p);
	this.addChild(discountBadge);

	var badgeTitle:ShadowLabel = new ShadowLabel(StrUtils.getNumber(Math.round((1 - (newPrice / oldPrice)) * 100) + " %"), 1, 0x440000, null, "ltr", false, null, 1.5);
	badgeTitle.layoutData = new AnchorLayoutData(50, NaN, NaN, NaN, 0);
	discountBadge.addChild(badgeTitle);

	var badgeMessage:ShadowLabel = new ShadowLabel(loc("off_label"), 1, 0x440000, null, null, false, null, 0.8);
	badgeMessage.layoutData = new AnchorLayoutData(NaN, NaN, 50, NaN, 0);
	discountBadge.addChild(badgeMessage);
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