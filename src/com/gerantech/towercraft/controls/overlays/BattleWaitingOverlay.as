package com.gerantech.towercraft.controls.overlays
{
import com.gerantech.towercraft.controls.TileBackground;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.Assets;
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
public var cancelable:Boolean = true;

private var padding:int;
private var waitingIcon:Image;
private var cancelButton:Button;
private var waitingLabel:RTLLabel;

public function BattleWaitingOverlay(cancelable:Boolean)
{
	super();
	padding = 48;
	this.cancelable = cancelable;
}

override protected function initialize():void
{
	closeOnStage = closeWithKeyboard = false;
	autoSizeMode = AutoSizeMode.STAGE;
	super.initialize();

	waitingIcon = new Image(Assets.getTexture("home/pistole-tile", "gui"));
	waitingIcon.alignPivot();
	waitingIcon.x = stageWidth * 0.5;
	waitingIcon.y = stageHeight * 0.4;
	waitingIcon.scale = 0.5;
	waitingIcon.alpha = 0;
	addChild(waitingIcon);
	Starling.juggler.tween(waitingIcon, 0.5, {delay:0.2, scale:2, alpha:1, transition: Transitions.EASE_OUT_BACK});

	if( cancelable )
	{
		cancelButton = new Button();
		cancelButton.label = loc("cancel_button");
		cancelButton.width = 280;
		cancelButton.height = 140;
		cancelButton.pivotX = cancelButton.width * 0.5;
		cancelButton.pivotY = cancelButton.height * 0.5;
		cancelButton.styleName = MainTheme.STYLE_BUTTON_SMALL_DANGER;
		cancelButton.x = stageWidth * 0.5;
		cancelButton.y = stageHeight * 0.75;
		cancelButton.alpha = 0;
		cancelButton.addEventListener(Event.TRIGGERED, cancelButton_triggeredHandler);
		addChild(cancelButton);
		Starling.juggler.tween(cancelButton, 0.5, {delay: 1.5, alpha: 1});
	}
	
	var arena:int = player.get_arena(0);
	
	waitingLabel = new RTLLabel(loc(arena ? "tip_over" : "tip_over_tutor"), 1, "center", null, false, null, 1.2);
	waitingLabel.x = padding;
	waitingLabel.y = stageHeight * 0.55;
	waitingLabel.alpha = 0;
	waitingLabel.width = stageWidth - padding * 2;
	waitingLabel.touchable = false;
	addChild(waitingLabel);
	Starling.juggler.tween(waitingLabel, 0.5, {delay: 2, alpha: 1, y: stage.stageHeight * 0.6, transition: Transitions.EASE_OUT_BACK});
	
	if( arena > 0 )
	{
		var tipDisplay:RTLLabel = new RTLLabel(loc("tip_" + Math.min(arena - 1, 2) + "_" + Math.floor(Math.random() * 10)), 1, "justify", null, true, "center", 0.8);
		tipDisplay.x = padding;
		tipDisplay.y = stage.stageHeight - padding * 5;
		tipDisplay.width = stage.stageWidth - padding * 2;
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
	Starling.juggler.tween(overlay, 0.8, {delay:1, alpha:0});
	Starling.juggler.tween(waitingIcon, 0.3, {scale:0, alpha:0, transition:Transitions.EASE_IN_BACK});
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
	var overlay:TileBackground = new TileBackground("home/pistole-tile", 0.6, false, 0);
	overlay.y = overlay.x = -100
	overlay.width = stageWidth + 200;
	overlay.height = stageHeight + 200;
	return overlay;
}
}
}