package com.gerantech.towercraft.controls.sliders.battle
{
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.themes.MainTheme;
import com.gerantech.towercraft.utils.StrUtils;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;

/**
* @author Mansour Djawadi
*/
public class BattleCountdown extends IBattleSlider
{
public var timeLabel:ShadowLabel;
public function BattleCountdown() { super(); }
override protected function initialize() : void
{
	super.initialize();
	
	var bgImage:Image = new Image(appModel.theme.roundSmallSkin);
	bgImage.scale9Grid = MainTheme.ROUND_SMALL_SCALE9_GRID;
	bgImage.alpha = 0.6;
	bgImage.color = 0;
	backgroundSkin = bgImage;
	
	layout = new AnchorLayout();
	
	var messageLabel:RTLLabel =  new RTLLabel(loc("battle_remain"), 1, "center", null, false, null, 0.75);
	messageLabel.layoutData = new AnchorLayoutData(5, 16, NaN, 16);
	addChild(messageLabel);
	
	timeLabel = new ShadowLabel(null, 1, 0, null, "ltr", false, null, 1.2);
	timeLabel.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, 32);
	timeLabel.height = 84;
	addChild(timeLabel);
}
override public function set value(val:Number):void 
{
	if( val < 0 )
		return;
	timeLabel.text = StrUtils.getNumber(StrUtils.uintToTime(val));
}
override public function enableStars(score:int):void 
{
	if( score < 3 )
		return;

	Image(backgroundSkin).color = score;
	backgroundSkin.alpha = 0.8;
	timeLabel.scale = 0.4;
	Starling.juggler.tween(timeLabel, 0.5, {scale : 1, transition:Transitions.EASE_OUT_BACK});
}
}
}