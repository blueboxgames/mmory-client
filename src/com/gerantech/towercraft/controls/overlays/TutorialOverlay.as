package com.gerantech.towercraft.controls.overlays
{
import com.gerantech.towercraft.controls.groups.Devider;
import com.gerantech.towercraft.models.tutorials.TutorialTask;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import flash.utils.setTimeout;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.events.Event;

public class TutorialOverlay extends BaseOverlay
{
protected var task:TutorialTask;

public function TutorialOverlay(task:TutorialTask)
{
	super();
	this.task = task;
}

override protected function initialize():void
{
	width = stage.stageWidth;
	height = stage.stageHeight;
	super.initialize();
	
	if( overlay != null )
		overlay.alpha = 0.1;
		
	if( transitionIn == null )
		transitionIn = new TransitionData(0.1, task.startAfter * 0.001);
	
	if( transitionOut == null )
	{
		transitionOut = new TransitionData(0.1);
		transitionOut.sourceAlpha = 1;
		transitionOut.destinationAlpha = 0;
	}
	
	// execute overlay transition
	rejustLayoutByTransitionData();
}

protected function rejustLayoutByTransitionData():void
{
	Starling.juggler.removeTweens(this);
	
	alpha = transitionIn.sourceAlpha;
	Starling.juggler.tween(this, transitionIn.time,
	{
		delay:transitionIn.delay,
		alpha:transitionIn.destinationAlpha,
		onStart:transitionInStarted,
		onComplete:transitionInCompleted
	}
	);
}		

public override function close(dispose:Boolean=true):void
{
	super.close(dispose);
	
	Starling.juggler.tween(this, transitionOut.time,
	{
		delay:transitionOut.delay,
		alpha:transitionOut.destinationAlpha,
		onStart:transitionOutStarted,
		onComplete:transitionOutCompleted,
		onCompleteArgs:[dispose]
	}
	);
}

override protected function addedToStageHandler(event:Event):void
{
	super.addedToStageHandler(event);
	if( overlay != null )
		overlay.touchable = false;
	closeOnStage = false;
	setTimeout(function():void{closeOnStage = true}, task.skipableAfter);
}

override protected function defaultOverlayFactory(color:uint = 0, alpha:Number = 0.4):DisplayObject
{
	layout = new AnchorLayout();
	var overlay:Devider = new Devider();
	overlay.alpha = alpha;
	overlay.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	return overlay;
}

public override function get closeOnStage():Boolean
{
	return stage.touchable;
}
public override function set closeOnStage(value:Boolean):void
{
	if( stage )
		stage.touchable = value;
}
}
}