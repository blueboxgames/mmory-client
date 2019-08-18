package com.gerantech.towercraft.controls.popups
{
import com.gerantech.mmory.core.constants.ExchangeType;
import com.gerantech.mmory.core.exchanges.ExchangeItem;
import com.gerantech.towercraft.controls.buttons.MMOryButton;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.MainTheme;

import feathers.controls.ImageLoader;
import feathers.controls.LayoutGroup;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import feathers.skins.ImageSkin;

import flash.geom.Rectangle;

import starling.events.Event;

public class AdConfirmPopup extends SimplePopup
{
private var item:ExchangeItem;
private var rewardCount:int;

protected var container:LayoutGroup;
protected var titleDisplay:ShadowLabel;
protected var descriptionDisplay:RTLLabel;
protected var outcomeGroupDisplay:LayoutGroup;
protected var acceptButton:MMOryButton;
protected var acceptButtonSkin:ImageSkin;
protected var acceptButtonStyle:String = MainTheme.STYLE_BUTTON_SMALL_NORMAL;
protected var closeButton:MMOryButton;
protected var closeButtonStyle:String = MainTheme.STYLE_BUTTON_SMALL_DANGER;

public function AdConfirmPopup()
{
	this.item = exchanger.items.get(ExchangeType.C71_TICKET);
	this.rewardCount = item.outcomes.get(item.outcome);
	super();
}

override protected function initialize():void
{
	super.initialize();
	var containerLayout:VerticalLayout = new VerticalLayout();
	containerLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
	containerLayout.verticalAlign = VerticalAlign.BOTTOM;
	containerLayout.gap = 24;
	containerLayout.padding = 48;

	container = new LayoutGroup();
	container.width = stage.stageWidth*0.8;
	container.layout = containerLayout;
	addChild(container);

	this.titleDisplay = new ShadowLabel(loc("popup_ad_title"), 1, 0, "center", null, true, "center", 1.2);
	container.addChild(titleDisplay);

	this.descriptionDisplay = new RTLLabel(loc("popup_ad_message", [rewardCount]),0,"center",null,true,"center", 0.8);
	container.addChild(descriptionDisplay);

	// -=-=-=-=-=-=-=-=-=-=-=-=-=-[Outcome Display]-=-=-=-=-=-=-=-=-=-=-=-=-=-
	var outcomeGroupDisplayLayout:HorizontalLayout = new HorizontalLayout();
	outcomeGroupDisplayLayout.horizontalAlign = HorizontalAlign.CENTER;
	outcomeGroupDisplayLayout.verticalAlign = VerticalAlign.MIDDLE;
	outcomeGroupDisplayLayout.padding = 40;
	outcomeGroupDisplayLayout.gap = 20;

	var outcomeGroupDisplay:LayoutGroup = new LayoutGroup();
	var innerSkin:ImageSkin = new ImageSkin( Assets.getTexture("theme/round-medium-skin", "gui") );
	innerSkin.scale9Grid = MainTheme.ROUND_MEDIUM_SCALE9_GRID;
	outcomeGroupDisplay.backgroundSkin = innerSkin;
	outcomeGroupDisplay.layout = outcomeGroupDisplayLayout;
  this.container.addChild(outcomeGroupDisplay);

	var videoImage:ImageLoader = new ImageLoader();
	videoImage.source = Assets.getTexture("shop/video", "gui");
	outcomeGroupDisplay.addChild(videoImage);

	var playbackImage:ImageLoader = new ImageLoader();
	playbackImage.paddingLeft = 36;
	playbackImage.source = Assets.getTexture("shop/playback", "gui");
	outcomeGroupDisplay.addChild(playbackImage);

	var currencyImage:ImageLoader = new ImageLoader();
	currencyImage.source = Assets.getTexture("shop/currency-71", "gui");
	outcomeGroupDisplay.addChild(currencyImage);

	// -=-=-=-=-=-=-=-=-=-=-=-=-=-[Accept Button]-=-=-=-=-=-=-=-=-=-=-=-=-=-
	acceptButton = new MMOryButton();
	acceptButton.styleName = acceptButtonStyle;
	acceptButton.label = loc("popup_ad_accept");
	acceptButton.addEventListener(Event.TRIGGERED, acceptButton_triggeredHandler);
	acceptButton.padding = 24;
	container.addChild(acceptButton);
	
	// -=-=-=-=-=-=-=-=-=-=-=-=-=-[Close Button]-=-=-=-=-=-=-=-=-=-=-=-=-=-
	this.closeButton = new MMOryButton();
	this.closeButton.styleName = closeButtonStyle;
	this.closeButton.iconTexture = Assets.getTexture("theme/icon-cross", "gui");
	this.closeButton.width = 70;
	this.closeButton.height = 70;
	this.closeButton.layoutData = new AnchorLayoutData(15, 15);
	this.closeButton.addEventListener(Event.TRIGGERED, this.closeButton_triggeredHandler);
	this.addChild(this.closeButton);
	
	container.validate();
	transitionIn.sourceBound = transitionOut.destinationBound = new Rectangle(stage.stageWidth*0.1, stage.stageHeight*0.35, stage.stageWidth*0.75, stage.stageHeight*0.3);
	transitionOut.sourceBound = transitionIn.destinationBound = new Rectangle(stage.stageWidth*0.1, stage.stageHeight*0.30,  container.bounds.width, container.bounds.height);
	rejustLayoutByTransitionData();
}
protected function acceptButton_triggeredHandler(event:Event):void
{
	dispatchEventWith(Event.SELECT);
	close();
}

protected function closeButton_triggeredHandler(event:Event):void
{
	dispatchEventWith(Event.CLOSE);
	close();
}
override public function dispose():void
{
  this.closeButton.removeEventListener(Event.TRIGGERED, this.closeButton_triggeredHandler);
	this.acceptButton.removeEventListener(Event.TRIGGERED, this.acceptButton_triggeredHandler);
	super.dispose();
}
}
}