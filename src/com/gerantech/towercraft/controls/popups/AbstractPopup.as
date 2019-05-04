package com.gerantech.towercraft.controls.popups
{
import com.gerantech.towercraft.controls.overlays.BaseOverlay;
import com.gerantech.towercraft.controls.overlays.TransitionData;
import flash.geom.Rectangle;
import starling.animation.Transitions;
import starling.core.Starling;

public class AbstractPopup extends BaseOverlay
{
public function AbstractPopup()
{
	closeOnStage = false;
	closeOnOverlay = true;
}

override protected function initialize():void
{
	super.initialize();
	
	// create transition in data
	if( transitionIn == null )
	{
		var _h:int = 400;
		var _p:int = 120;
		transitionIn = new TransitionData();
		transitionIn.transition = Transitions.EASE_OUT_BACK;
		transitionIn.sourceBound = new Rectangle(_p,	stageHeight* 0.5 - _h * 0.4,	stageWidth - _p * 2,	_h * 0.8);
		transitionIn.destinationBound = new Rectangle(_p,	stageHeight* 0.5 - _h * 0.5,	stageWidth - _p * 2,	_h * 1.0);
	}
	if( transitionOut == null )
	{
		transitionOut = new TransitionData();
		transitionOut.sourceAlpha = 1;
		transitionOut.destinationAlpha = 0;
		transitionOut.transition = Transitions.EASE_IN;
		transitionOut.sourceBound = transitionIn.destinationBound
		transitionOut.destinationBound = transitionIn.sourceBound
	}
	
	// execute popup transition
	rejustLayoutByTransitionData();
}

protected function rejustLayoutByTransitionData():void
{
	Starling.juggler.removeTweens(this);
	
	alpha = transitionIn.sourceAlpha;
	x = transitionIn.sourceBound.x;
	y = transitionIn.sourceBound.y;
	width = transitionIn.sourceBound.width;
	height = transitionIn.sourceBound.height;
	Starling.juggler.tween(this, transitionIn.time,
		{
			delay:transitionIn.delay,
			alpha:transitionIn.destinationAlpha,
			x:transitionIn.destinationBound.x, 
			y:transitionIn.destinationBound.y, 
			width:transitionIn.destinationBound.width, 
			height:transitionIn.destinationBound.height, 
			transition:transitionIn.transition,
			onStart:transitionInStarted,
			onComplete:transitionInCompleted
		}
	);
	appModel.sounds.addAndPlay("whoosh");

}		

public override function close(dispose:Boolean=true):void
{
	super.close(dispose);

	Starling.juggler.tween(this, transitionOut.time,
		{
			delay:transitionOut.delay,
			alpha:transitionOut.destinationAlpha,
			x:transitionOut.destinationBound.x, 
			y:transitionOut.destinationBound.y, 
			width:transitionOut.destinationBound.width, 
			height:transitionOut.destinationBound.height, 
			transition:transitionOut.transition,
			onStart:transitionOutStarted,
			onComplete:transitionOutCompleted,
			onCompleteArgs:[dispose]
		}
	);
}
}
}