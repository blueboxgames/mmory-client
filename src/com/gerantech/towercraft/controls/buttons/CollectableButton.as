package com.gerantech.towercraft.controls.buttons 
{
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import com.gt.towers.exchanges.ExchangeItem;
import feathers.controls.ButtonState;
import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import flash.geom.Rectangle;
import starling.core.Starling;

/**
* ...
* @author Mansour Djawadi
*/
public class CollectableButton extends SimpleLayoutButton 
{
protected var state:int;
protected var iconDisplay:ImageLoader;
protected var titleDisplay:ShadowLabel;
protected var backgroundDisplay:ImageLoader;
public function CollectableButton(){ super(); }
override protected function initialize() : void
{
	super.initialize();
	layout = new AnchorLayout();
	update();
}

public function update() : void
{
	reset();
}

protected function backgroundFactory() : ImageLoader
{
	if( backgroundDisplay != null )
	{
		backgroundDisplay.source = Assets.getTexture("home/button-bg-" + state, "gui");
		return null;
	}

	var offRect:Rectangle = new Rectangle(-2, -2, -2, -2);
	var backgroundLayout:AnchorLayoutData = new AnchorLayoutData(offRect.x, offRect.y, offRect.width, offRect.height);
	backgroundDisplay = new ImageLoader();
	backgroundDisplay.pixelSnapping = false;
	backgroundDisplay.source = Assets.getTexture("home/button-bg-" + state, "gui");
	backgroundDisplay.layoutData = backgroundLayout;
	backgroundDisplay.maintainAspectRatio = false;
	backgroundDisplay.scale9Grid = new Rectangle(22, 56, 4, 4);
	addChild(backgroundDisplay);
	if( state == ExchangeItem.CHEST_STATE_READY )
	{
		function repeatPunch(isUp:Boolean):void {
			var p:Number = isUp ? 1 : 3;
			Starling.juggler.tween(backgroundLayout, 1.6, {top:offRect.x * p, right:offRect.y * p, bottom:offRect.width * p, left:offRect.height * p, onComplete:repeatPunch, onCompleteArgs:[!isUp]});
		}
		repeatPunch(true);
	}
	return backgroundDisplay;
}

protected function iconFactory(image:String) : ImageLoader 
{
	if( iconDisplay != null )
		return null;
	iconDisplay = new ImageLoader();
	iconDisplay.touchable = false;
	iconDisplay.source = Assets.getTexture(image, "gui");
	iconDisplay.layoutData = new AnchorLayoutData(8, 8, 8);
	addChild(iconDisplay);
	return iconDisplay;
}

protected function titleFactory(text:String) : ShadowLabel
{
	//if( state == ExchangeItem.CHEST_STATE_BUSY )
	//	return null;
	titleDisplay = new ShadowLabel(text, 1, 0, "center", null, false, null, state == ExchangeItem.CHEST_STATE_BUSY ? 0.7 : 0.95);
	titleDisplay.touchable = false;
	titleDisplay.shadowDistance = appModel.theme.gameFontSize * 0.05;
	titleDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, -64, state == ExchangeItem.CHEST_STATE_BUSY ? -40 : 0);
	addChild(titleDisplay);
	return titleDisplay;
}

// touch effect
override public function set currentState(value:String) : void
{
	super.currentState = value;
	if( backgroundDisplay == null || backgroundDisplay.layoutData == null || state == ExchangeItem.CHEST_STATE_READY )
		return;
	var ldata:AnchorLayoutData = backgroundDisplay.layoutData as AnchorLayoutData;
	var vP:int = value == ButtonState.DOWN ? 4 : -2;
	ldata.top = ldata.right = ldata.bottom = ldata.left = vP;
}

protected function reset() : void
{
	//tutorials.removeEventListener(GameEvent.TUTORIAL_TASKS_FINISH, tutorialManager_finishHandler);
	Starling.juggler.removeTweens(backgroundDisplay);
	removeChildren(0, -1, true);
	backgroundDisplay = null;
	iconDisplay = null;
	titleDisplay = null;
	//clearTimeout(timeoutId);
}

override public function dispose() : void
{
	reset();
	super.dispose();
}
}
}