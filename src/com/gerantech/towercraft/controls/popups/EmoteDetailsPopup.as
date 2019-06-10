package com.gerantech.towercraft.controls.popups
{
import com.gerantech.mmory.core.exchanges.ExchangeItem;
import com.gerantech.towercraft.controls.buttons.MMOryButton;
import com.gerantech.towercraft.controls.items.EmoteItemRenderer;
import com.gerantech.towercraft.controls.overlays.TransitionData;
import com.gerantech.towercraft.controls.texts.CountdownLabel;

import dragonBones.events.EventObject;
import dragonBones.starling.StarlingArmatureDisplay;
import dragonBones.starling.StarlingEvent;

import feathers.layout.AnchorLayoutData;
import feathers.layout.RelativePosition;

import flash.geom.Rectangle;

import starling.events.Event;

public class EmoteDetailsPopup extends SimpleHeaderPopup
{
private var exchange:ExchangeItem;
 private var showButton:Boolean;
// private var messageDisplay:RTLLabel;
private var actionButton:MMOryButton;
// private var footerDisplay:ImageLoader;
private var countdownDisplay:CountdownLabel;
private var armatureDisplay:StarlingArmatureDisplay;
public function EmoteDetailsPopup(exchange:ExchangeItem, showButton:Boolean = true)
{
	super();
	this.exchange = exchange;
	this.hasCloseButton = false;
	this.showButton = showButton;
	this.title = loc("emote_title_" + exchange.outcome);
}

override protected function initialize():void
{
	var _p:int = 40;
	var _h:int = this.showButton ? 580 : 380;
	this.transitionIn = new TransitionData();
	this.transitionOut = new TransitionData();
	this.transitionOut.destinationAlpha = 0;
	this.transitionIn.sourceBound = this.transitionOut.destinationBound = new Rectangle(_p,	stageHeight * 0.5 - _h * 0.4,	stageWidth - _p * 2,	_h * 0.8);
	this.transitionOut.sourceBound = this.transitionIn.destinationBound = new Rectangle(_p,	stageHeight * 0.5 - _h * 0.5,	stageWidth - _p * 2,	_h * 1.0);
	
	super.initialize();
	this.titleDisplay.layoutData = new AnchorLayoutData(15, appModel.isLTR ? NaN : 48, NaN, appModel.isLTR ? 48 : NaN);

	/* var insideBG:Devider = new Devider(0x1E66C2);
	insideBG.height = 120;
	insideBG.layoutData = new AnchorLayoutData(80, 0, NaN, 0);
	addChild(insideBG); */
	
	timeManager.addEventListener(Event.CHANGE, timeManager_changeHandler);

	if( !showButton )
		return;

	var r:int = exchange.requirements.keys()[0];
	actionButton = new MMOryButton();
	actionButton.width = 300;
	actionButton.height = 150;
	actionButton.iconSize = MMOryButton.DEFAULT_ICON_SIZE;
	actionButton.paddingBottom = 30;
	actionButton.label = MMOryButton.getLabel(r, exchange.requirements.get(r));
	actionButton.iconTexture = MMOryButton.getIcon(r, exchange.requirements.get(r));
	actionButton.paddingTop = 10;
	actionButton.layoutData = new AnchorLayoutData(NaN, NaN, 20, NaN, 0);
	actionButton.addEventListener(Event.TRIGGERED, batton_triggeredHandler);
	addChild(actionButton);
}

override protected function transitionInCompleted():void
{
	super.transitionInCompleted();

	armatureDisplay = EmoteItemRenderer.factory.buildArmatureDisplay("emote");
	armatureDisplay.addEventListener(EventObject.SOUND_EVENT, bookArmature_soundEventHandler);
	armatureDisplay.animation.gotoAndPlayByTime("st-" + exchange.outcome, 0);	
	armatureDisplay.x = transitionIn.destinationBound.width * 0.5;
	armatureDisplay.y = transitionIn.destinationBound.height - 210;
	armatureDisplay.scale = 1.4;
	addChild(armatureDisplay);
	function bookArmature_soundEventHandler(event:StarlingEvent):void
	{
		// appModel.sounds.addAndPlay(event.eventObject.name);
	}
}

protected function timeManager_changeHandler(event:Event):void
{
	if( countdownDisplay == null )
	{
		countdownDisplay = new CountdownLabel();
		countdownDisplay.layoutData = new AnchorLayoutData(10, appModel.isLTR ? 10: NaN, NaN, appModel.isLTR ? NaN : 10);
		countdownDisplay.iconPosition = appModel.isLTR ? RelativePosition.RIGHT : RelativePosition.LEFT;
		countdownDisplay.height = 92;
		countdownDisplay.width = 400;
		addChild(countdownDisplay);
	}
	countdownDisplay.time = uint(exchange.expiredAt - timeManager.now);
}

protected function batton_triggeredHandler(event:Event) : void
{
	dispatchEventWith(Event.SELECT, false, exchange);
	close();
}


override public function dispose():void
{
	if( actionButton != null )
		actionButton.removeEventListener(Event.TRIGGERED, batton_triggeredHandler);
	timeManager.removeEventListener(Event.CHANGE, timeManager_changeHandler);
	super.dispose();
}
}
}