package com.gerantech.towercraft.controls.toasts 
{
import com.gerantech.towercraft.controls.StarCheck;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import flash.utils.setTimeout;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Quad;
/**
 * ...
 * @author Mansour Djawadi
 */
public class BattleTurnToast extends BaseToast
{
private var side:int;
private var score:int;
private var titleDisplay:ShadowLabel;
public function BattleTurnToast(side:int, score:int) 
{
	this.side = side;
	this.score = score;
	closeAfter = 2000;
	toastHeight = 240;
	layout = new AnchorLayout();
}

override protected function initialize():void
{
	super.initialize();

	touchable = false;
	backgroundSkin = new Quad (1, 1, side == 0 ? 0x000088 : 0x880000);
	backgroundSkin.alpha = 0.7;
	
	transitionIn.time = 0.7;
	transitionOut.destinationBound.y = transitionIn.sourceBound.y = side == 0 ? 1000 : 350;
	transitionIn.destinationBound.y = transitionOut.sourceBound.y = side == 0 ? 1050 : 400;
	rejustLayoutByTransitionData();
	
	titleDisplay = new ShadowLabel(loc(side == 0 ? "guest_label" : "enemy_label"), 1, 0, null, null, false, null, 1.4);
	titleDisplay.layoutData = new AnchorLayoutData(NaN, NaN, 50, NaN, 0);
	addChild(titleDisplay);
	
	// sound
	appModel.sounds.addAndPlay("scoreboard-change-" + side);

	var _h:int = transitionIn.destinationBound.height;
	for ( var i:int = 0; i < 3; i++ )
	{
		var starImage:StarCheck = new StarCheck(i + 1 < score, i == 0 ? 220 : 180);
		starImage.x = stageWidth * 0.5 + (Math.ceil(i / 4) * ( i == 1 ? 1 : -1 )) * 256;
		starImage.y = i == 0 ? -50 : 0;
		addChild(starImage);
		if( i + 1 == score )
			setTimeout(starImage.active, 800);
	}
}
}
}