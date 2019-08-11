package com.gerantech.towercraft.controls.popups
{
import com.gerantech.mmory.core.constants.ExchangeType;

import flash.geom.Rectangle;

public class AdConfirmPopup extends ConfirmPopup
{
private var rewardCount:int;

public function AdConfirmPopup()
{
	rewardCount = ExchangeType.getNumSlots(exchanger.items.get(ExchangeType.C71_TICKET).outcome);
	declineStyle = "danger";
	super(loc("popup_ad_title", [rewardCount]), loc("popup_ad_accept"), loc("popup_decline_label"));
}

override protected function initialize():void
{
	super.initialize();
	transitionIn.sourceBound = transitionOut.destinationBound = new Rectangle(stage.stageWidth*0.15, stage.stageHeight*0.35, stage.stageWidth*0.7, stage.stageHeight*0.3);
	transitionOut.sourceBound = transitionIn.destinationBound = new Rectangle(stage.stageWidth*0.15, stage.stageHeight*0.30, stage.stageWidth*0.7, stage.stageHeight*0.4);
	rejustLayoutByTransitionData();
	
	// TODO: Design the popup
	// var cardsDisplay:ImageLoader = new ImageLoader();
	// cardsDisplay.height = padding * 8;
	// cardsDisplay.source = Assets.getTexture("cards");
	// cardsDisplay.layoutData = new AnchorLayoutData(NaN, NaN, padding*7, NaN, 0);
	// addChild(cardsDisplay)
}
}
}