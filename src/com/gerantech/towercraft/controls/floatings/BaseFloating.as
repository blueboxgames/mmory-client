package com.gerantech.towercraft.controls.floatings
{
	import com.gerantech.towercraft.controls.overlays.BaseOverlay;
	import com.gerantech.towercraft.controls.overlays.TransitionData;
	
	import flash.geom.Point;
	
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	public class BaseFloating extends BaseOverlay
	{

		public function BaseFloating()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
				
			if(transitionIn == null)
			{
				transitionIn = new TransitionData();
				transitionIn.destinationPosition = transitionIn.sourcePosition = new Point(stage.stageWidth/2, stage.stageHeight/2);
			}
			if(transitionOut== null)
			{
				transitionOut = new TransitionData();
				transitionOut.transition = Transitions.EASE_IN;
				transitionOut.destinationPosition = transitionOut.sourcePosition = new Point(stage.stageWidth/2, stage.stageHeight/2);
			}
			
			// execute popup transition
			x = transitionIn.sourcePosition.x;
			y = transitionIn.sourcePosition.y;

			
			Starling.juggler.tween(this, transitionIn.time,
				{
					delay:transitionIn.delay,
					alpha:transitionIn.destinationAlpha,
					x:transitionIn.destinationPosition.x, 
					y:transitionIn.destinationPosition.y, 
					transition:transitionIn.transition,
					onStart:transitionInStarted,
					onComplete:transitionInCompleted
				}
			);
			appModel.sounds.addAndPlay("whoosh");
		}
		
		protected override function stage_touchHandler(event:TouchEvent):void
		{
			if( !closeOnStage || !_isEnabled )
				return;
			
			// we aren't tracking another touch, so let's look for a new one.
			var touch:Touch = event.getTouch( stage, TouchPhase.BEGAN);
			if( !touch )
				return;
			
			touch.getLocation( stage, HELPER_POINT );
			if(!this.contains( stage.hitTest( HELPER_POINT ) ))
				close();
		}
		
		public override function close(dispose:Boolean=true):void
		{
			super.close(dispose);
			Starling.juggler.tween(this, transitionOut.time,
				{
					delay:transitionOut.delay,
					alpha:transitionOut.destinationAlpha,
					x:transitionOut.destinationPosition.x, 
					y:transitionOut.destinationPosition.y, 
					transition:transitionOut.transition,
					onStart:transitionOutStarted,
					onComplete:transitionOutCompleted,
					onCompleteArgs:[dispose]
				}
			);
		}
	}
}