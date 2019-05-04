package com.gerantech.towercraft.controls.overlays
{
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.tutorials.TutorialTask;
import feathers.controls.text.BitmapFontTextRenderer;
import feathers.text.BitmapFontTextFormat;
import starling.animation.Transitions;
import starling.animation.Tween;
import starling.core.Starling;
import starling.display.Image;
import starling.display.Sprite;

public class TutorialSwipeOverlay extends TutorialOverlay
{
private var tweenStep:int ;
private var doubleSwipe:Boolean;
private var doubleCount:int = 0;

private var finger:Sprite;
private var cardFrame:Image;
private var swipeNumText:BitmapFontTextRenderer;

public function TutorialSwipeOverlay(task:TutorialTask)
{
//	task.points.sortOn("tutorIndex", Array.NUMERIC | Array.DESCENDING);
	
	/*this.places = new Vector.<Point>();
	while( array.length > 0 ) 
		this.places.push(array.pop());
	*/
	super(task);
	touchable = false;
}

override protected function initialize():void
{
	super.initialize();
	finger = new Sprite();
	finger.touchable = false;
	var f:Image = new Image(Assets.getTexture("hand"));
	f.pivotX = 0;
	f.pivotY = f.height * 0.8;
	finger.addChild(f)
}

protected override function transitionInCompleted():void
{
	super.transitionInCompleted();
	//doubleSwipe = this.task.points[0).tutorIndex >= 10;
	addChild(finger);
	
	swipeNumText = new BitmapFontTextRenderer();
	swipeNumText.textFormat = new BitmapFontTextFormat(Assets.getFont(), appModel.theme.gameFontSize * 1.4, 0xFFFFFF, "center")
	swipeNumText.pixelSnapping = false;
	swipeNumText.y = -200;
	swipeNumText.touchable = false;
	swipeNumText.text = "  ";
	swipeNumText.visible = false;
	finger.addChild(swipeNumText);
	swipeNumText.pivotX = swipeNumText.width * 0.5;
	swipeNumText.pivotY = swipeNumText.height * 0.5;
	
	cardFrame = new Image(Assets.getTexture("cards/tutor-frame"));
	cardFrame.pivotX = cardFrame.width * 0.5;
	cardFrame.pivotY = cardFrame.height * 0.5;
	cardFrame.rotation = 0.3;
	cardFrame.alpha = 0;
	cardFrame.scale = 0;
	finger.addChildAt(cardFrame, 0);
	
	tweenCompleteCallback("stepLast")
}

private function swipe(from:int, to:int, fromAlpha:Number=1, toAlpha:Number=1, fromScale:Number=1, toScale:Number=1, fromRotation:Number=0, toRotation:Number=0, time:Number=1.5, doubleA:Boolean=true, swipeIndex:int=-1):void
{
	animate( "stepMid",
		task.points[from].x, 
		task.points[from].y, 
		task.points[to].x, 
		task.points[to].y,
		fromAlpha, toAlpha, fromScale, toScale, fromRotation, toRotation, time, 0, swipeIndex
	);
}


private function tweenCompleteCallback(swipeName:String):void
{
	if( !isOpen )
		return;
	switch(swipeName)
	{
		case "stepFirst":
		case "stepMid":
			if( swipeName == "stepMid" )
				tweenStep ++;
			
			if( tweenStep == task.points.length - 1 )
			{
				if ( doubleSwipe && doubleCount == 0 )
				{
					doubleCount ++;
					animate( "doubleOut",
						task.points[tweenStep].x, 
						task.points[tweenStep].y, 
						task.points[tweenStep].x, 
						task.points[tweenStep].y,
						1, 0, 1, 1, 0, -0.2, 0.2);
				}
				else
				{
					animate( "stepLast",
						task.points[tweenStep].x, 
						task.points[tweenStep].y, 
						task.points[tweenStep].x, 
						task.points[tweenStep].y - 200,
						1, 0, 1, 1.3, -0.3, 0, 0.7);
				}
			}
			else
			{
				swipe(tweenStep, tweenStep + 1, 1, 1, 1, 1, -0.3, -0.3, 1, true, task.points.length > 2 ? tweenStep : -1);
			}
			break;
		case "stepLast":
			tweenStep = 0;
			doubleCount = 0;
			animate( "stepFirst",
				task.points[0].x, 
				task.points[0].y - 200, 
				task.points[0].x, 
				task.points[0].y,
				0, 1, 1.3, 1, 0, -0.3, 0.5, 0);	
			break;
		case "doubleOut":
			tweenStep = 0;
			finger.alpha = 1;
			tweenCompleteCallback("stepFirst");
			break;
	}
	//trace("tweenStep:", tweenStep, task.points[tweenStep).tutorIndex);
}

private function animate(name:String, startX:Number, startY:Number, endX:Number, endY:Number, startAlpha:Number=1, endAlpha:Number=1, startScale:Number=1, endScale:Number=1, startRotation:Number=0, endRotation:Number=0, time:Number=1.5, delayTime:Number=0, swipeIndex:int=-1):void
{
	finger.x = startX;
	finger.y = startY;
	finger.alpha = startAlpha;
	finger.scale = startScale;
	finger.rotation = startRotation;
	
	var __ts:Number = 1.6;
	var tween:Tween = new Tween(finger, time * __ts, Transitions.EASE_IN_OUT);
	tween.moveTo(endX, endY);
	tween.delay = delayTime;
	tween.scaleTo(endScale);
	tween.rotateTo(endRotation);
	tween.fadeTo(endAlpha);
	tween.onComplete = tweenCompleteCallback;
	tween.onCompleteArgs = [name];
	Starling.juggler.add(tween);
	
	if( swipeIndex > -1 )
	{
		swipeNumText.text = String(swipeIndex + 1);
		swipeNumText.scale = 1.3;
		Starling.juggler.tween(swipeNumText, 0.3, {scale:1, transition:Transitions.EASE_OUT});
	}
	else
	{
		swipeNumText.text = "";
	}
	swipeNumText.visible = swipeIndex > -1;
	
	if( startRotation == 0 && endRotation != 0 )
		Starling.juggler.tween(cardFrame, 0.4, {delay:0.8, alpha:1, scale:1, transition:Transitions.EASE_OUT});
	if( startRotation != 0 && endRotation == 0 )
		Starling.juggler.tween(cardFrame, 0.3, {delay:0.0, alpha:0, scale:0, transition:Transitions.EASE_IN});
}
override public function close(dispose:Boolean = true):void 
{
	Starling.juggler.removeTweens(finger);
	finger.removeFromParent(dispose);
	super.close(dispose);
}
}
}