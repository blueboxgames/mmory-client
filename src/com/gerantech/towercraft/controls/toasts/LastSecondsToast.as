package com.gerantech.towercraft.controls.toasts
{
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.utils.StrUtils;

import flash.text.engine.ElementFormat;
import flash.utils.clearInterval;
import flash.utils.setInterval;

import starling.animation.Transitions;
import starling.core.Starling;
/**
* ...
* @author Mansour Djawadi
*/
public class LastSecondsToast extends ShadowLabel
{
private static const _COLORS:Array = [0xFFFFFF, 0xFFDDDDD, 0xFFCCCC, 0xFFBBBB, 0xFFAAAA, 0xFF8888, 0xFF6666, 0xFF4444, 0xFF2222, 0xFF0000];
private var intervalId:uint;
private var second:uint = 11;
public function LastSecondsToast() 
{
	super(StrUtils.getNumber(10), 1, 0, "center", "ltr", false, null, 3.8);

	width = 220;
	height = 220;
	touchable = false;
	pixelSnapping = false;
	pivotX = width * 0.5;
	pivotY = height;

	AppModel.instance.sounds.addAndPlay("battle-cd");
}

override protected function initialize() : void
{
	super.initialize();
	
	intervalId = setInterval(showScondsTexts, 1000);
	showScondsTexts();
}

private function showScondsTexts() : void 
{
	second --;
	if( second <= 0 )
	{
		removeFromParent(true);
		return;
	}
	elementFormat = new ElementFormat(this.fontDescription, this.fontSize, _COLORS[10 - second]);
	text = StrUtils.getNumber(second);
	scaleY = 0;
	Starling.juggler.tween(this, 0.5, {scaleY:1, transition:Transitions.EASE_OUT_BACK});
}

override public function dispose() : void
{
	Starling.juggler.removeTweens(this);
	clearInterval(intervalId);
	super.dispose();
}
}
}