package com.gerantech.towercraft.controls.overlays
{
import com.gerantech.mmory.core.constants.SFSCommands;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.themes.MainTheme;
import com.smartfoxserver.v2.core.SFSEvent;

import feathers.controls.AutoSizeMode;
import feathers.controls.Button;

import flash.utils.setTimeout;

import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.events.Event;

public class BattleWaitingOverlay extends BaseOverlay
{
public var ready:Boolean;
public var showTips:Boolean;
private var _cancelable:Boolean;

public function get cancelable():Boolean { return _cancelable; }
public function set cancelable(value:Boolean):void
{
	if( _cancelable == value )
		return;
	_cancelable = value;
	if( cancelButton!= null )
		cancelButton.isEnabled = false;
}
public var spactateMode:Boolean;

private var cancelButton:Button;
private var waitingLabel:ShadowLabel;

public function BattleWaitingOverlay(cancelable:Boolean, spactateMode:Boolean, showTips:Boolean)
{
	super();
	this.showTips = showTips;
	this.cancelable = cancelable;
	this.spactateMode = spactateMode;
}

override protected function initialize():void
{
	hasOverlay = closeOnStage = closeWithKeyboard = false;
	autoSizeMode = AutoSizeMode.STAGE;
	super.initialize();

	var topImage:Image = new Image(appModel.theme.quadSkin);
	topImage.scale9Grid = MainTheme.QUAD_SCALE9_GRID;
	topImage.color = 0xbbd0ff;
	topImage.width = stageWidth;
	topImage.height = stageHeight * 0.5;
	this.addChild(topImage);

	var bottomImage:Image = new Image(appModel.theme.quadSkin);
	bottomImage.scale9Grid = MainTheme.QUAD_SCALE9_GRID;
	bottomImage.color = 0x1d2b42;
	bottomImage.pivotY = bottomImage.height;
	bottomImage.width = stageWidth;
	bottomImage.height = stageHeight * 0.5;
	bottomImage.y = stageHeight;
	this.addChild(bottomImage);

	var centerImage:Image = new Image(appModel.assets.getTexture("poster/center"));
	centerImage.pivotY = centerImage.height *  0.5;
	centerImage.width = stageWidth;
	centerImage.scaleY = centerImage.scaleX;
	centerImage.y = stageHeight * 0.5;
	this.addChild(centerImage);

	var logoImage:Image = new Image(appModel.assets.getTexture("poster/logo"));
	logoImage.pivotX = logoImage.width *  0.5;
	logoImage.pivotY = logoImage.height *  0.5;
	logoImage.x = stageWidth * 0.5;
	logoImage.y = stageHeight * 0.13;
	logoImage.scale = 0;
	Starling.juggler.tween(logoImage, 0.5, {scale:1.2, transition:Transitions.EASE_OUT_BACK});
	this.addChild(logoImage);

	if( cancelable )
	{
		cancelButton = new Button();
		cancelButton.width = 280;
		cancelButton.height = 140;
		cancelButton.label = loc("cancel_button");
		cancelButton.pivotX = cancelButton.width * 0.5;
		cancelButton.pivotY = cancelButton.height * 0.5;
		cancelButton.styleName = MainTheme.STYLE_BUTTON_SMALL_DANGER;
		cancelButton.x = stageWidth * 0.5;
		cancelButton.y = stageHeight * 0.88;
		cancelButton.alpha = 0;
		cancelButton.addEventListener(Event.TRIGGERED, cancelButton_triggeredHandler);
		addChild(cancelButton);
		Starling.juggler.tween(cancelButton, 0.5, {delay:1, alpha:1});
	}
	
	var arena:int = player.get_arena(0);
	
	waitingLabel = new ShadowLabel(loc(arena > 0 && !spactateMode && cancelable ? "tip_over" : "tip_over_tutor"), 1, 0,"center", null, false, null, 1.2);
	waitingLabel.alpha = 0;
	waitingLabel.x = 48;
	waitingLabel.y = stageHeight * 0.85;
	waitingLabel.width = stageWidth - 90;
	waitingLabel.touchable = false;
	addChild(waitingLabel);
	Starling.juggler.tween(waitingLabel, 0.5, {delay:0.6, alpha:1, y:stageHeight * (cancelable?0.78:0.82), transition: Transitions.EASE_OUT_BACK});
	
	if( showTips )
	{
		var tipDisplay:ShadowLabel = new ShadowLabel(loc("tip_" + Math.min(arena - 1, 2) + "_" + Math.floor(Math.random() * 10)), 1, 0, "justify", null, true, "center", 0.8);
		tipDisplay.x = 48;
		tipDisplay.y = stage.stageHeight - 140;
		tipDisplay.width = stage.stageWidth - 86;
		tipDisplay.touchable = false;
		addChild(tipDisplay);
	}
	
	setTimeout(gotoReady, ready ? 0 : 1000);
}

private function gotoReady():void
{
	ready = true;
	if( !initializingStarted )
		return;
	
	dispatchEventWith(Event.READY);
}

private function cancelButton_triggeredHandler(event:Event):void
{
	cancelButton.touchable = false;
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_cancelResponseHandler);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.BATTLE_CANCEL);
}

protected function sfs_cancelResponseHandler(event:SFSEvent):void
{
	if( event.params.cmd != SFSCommands.BATTLE_CANCEL )
		return;
	
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_cancelResponseHandler);
	appModel.navigator.popToRootScreen();
	cancelButton.touchable = false;
	setTimeout(disappear, 400);
}

public function disappear():void
{
	Starling.juggler.removeTweens(waitingLabel);
	// Starling.juggler.tween(overlay, 0.8, {delay:1, alpha:0});
	// Starling.juggler.tween(waitingIcon, 0.3, {scale:0, alpha:0, transition:Transitions.EASE_IN_BACK});
	if( cancelButton != null )
	{
		cancelButton.touchable = false;
		Starling.juggler.tween(cancelButton, 0.5, {delay:0.1, scale:0, transition:Transitions.EASE_IN_BACK});
	}
	if( waitingLabel != null )
		Starling.juggler.tween(waitingLabel, 0.4, {alpha:0, y:waitingLabel.y - height * 0.1, transition:Transitions.EASE_IN_BACK});
	setTimeout(close, 800, true);
}

override protected function defaultOverlayFactory(color:uint = 0, alpha:Number = 0.4):DisplayObject
{
	return null;
}
}
}