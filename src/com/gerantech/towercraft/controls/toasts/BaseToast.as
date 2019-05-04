package com.gerantech.towercraft.controls.toasts
{
import com.gerantech.towercraft.controls.overlays.TransitionData;
import com.gerantech.towercraft.controls.popups.AbstractPopup;
import feathers.controls.LayoutGroup;
import flash.geom.Rectangle;
import flash.utils.setTimeout;
import starling.animation.Transitions;
import starling.display.DisplayObject;

public class BaseToast extends AbstractPopup
{
static public const ANIMATION_MODE_TOP:int = 0;
static public const ANIMATION_MODE_BOTTOM:int = 1;
public var closeAfter:int = -1;
protected var toastHeight:int = 220;
protected var animationMode:int = 0;
public function BaseToast(){ hasOverlay = false; }
override protected function initialize():void
{
	if( transitionIn == null )
	{
		transitionIn = new TransitionData();
		transitionIn.transition = Transitions.EASE_OUT_BACK;
		transitionIn.sourceBound = new Rectangle(0, animationMode == ANIMATION_MODE_TOP ? -toastHeight : stageHeight, stageWidth, toastHeight);
		transitionIn.destinationBound = new Rectangle(0, animationMode == ANIMATION_MODE_TOP ? 0 : stageHeight - toastHeight, stageWidth, toastHeight);
	}
	if( transitionOut == null )
	{
		transitionOut = new TransitionData();
		transitionOut.sourceAlpha = 1;
		transitionOut.destinationAlpha = 0;
		transitionOut.transition = Transitions.EASE_IN;
		transitionOut.sourceBound = transitionIn.destinationBound;
		transitionOut.destinationBound = transitionIn.sourceBound;
	}
	
	super.initialize();
	
	if( closeAfter > -1 )
		setTimeout(close, closeAfter, true);
}
}
}