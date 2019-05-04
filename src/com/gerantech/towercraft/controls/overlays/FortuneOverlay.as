package com.gerantech.towercraft.controls.overlays
{
import com.gerantech.towercraft.controls.Spinner;
import com.gerantech.towercraft.controls.buttons.SimpleLayoutButton;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.views.effects.UIParticleSystem;
import com.gt.towers.utils.maps.IntIntMap;
import dragonBones.starling.StarlingArmatureDisplay;
import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import flash.geom.Rectangle;
import flash.utils.setTimeout;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.events.Event;

public class FortuneOverlay extends EarnOverlay
{
public var delta:Number = 0.005;
public var fortuneHeight:Number;
private var spinners:Vector.<Spinner>;
private var shadow:ImageLoader;
private var openOverlay:OpenBookOverlay;

public function FortuneOverlay(type:int)
{
	super(type);
	fortuneHeight = 300;
	appModel.sounds.setVolume("main-theme", 0.3);
}

override protected function initialize():void
{
	super.initialize();
	appModel.navigator.activeScreen.visible = false;

	layout = new AnchorLayout();
	closeOnStage = false;
	width = stageWidth;
	height = stageHeight;
	overlay.alpha = 1;

	spinners = new Vector.<Spinner>();
	for (var i:int = 0; i < 6; i++ )
	{
		var spinner:Spinner = new Spinner();
		spinner.display = OpenBookOverlay.factory.buildArmatureDisplay("" + (51 + i));
		spinner.scaleFactor = OpenBookOverlay.getBookScale(51 + i) * 2;
		StarlingArmatureDisplay(spinner.display).animation.gotoAndStopByProgress("appear", 1);
		StarlingArmatureDisplay(spinner.display).animation.timeScale = 0;
		spinner.display.touchable = false;
		spinner.angle = i * 360 / 6 * Math.PI / 180;
		spinner.display.x = width * 0.5;
		addChild(spinner.display);
		spinners.push(spinner);
	}

	addEventListener(Event.ENTER_FRAME, enterFrameHandler);
	
	shadow = new ImageLoader();
	shadow.alpha = 0;
	shadow.touchable = false;
	shadow.scale9Grid = new Rectangle(2, 2, 12, 12);
	shadow.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	shadow.source = Assets.getTexture("radial-gradient-shadow");
	addChild(shadow);
	animateShadow(0, 1);
	
	// become to faster rotation
	var time:Number = 3.5 + Math.random() * 2;
	setTimeout(appModel.sounds.addAndPlay, time * 1000 - 2000, "book-appear");
	Starling.juggler.tween(this, time, {delta:0.25, transition:Transitions.EASE_IN, onComplete:rotationCompleted});
	Starling.juggler.tween(this, 3, {fortuneHeight:720, transition:Transitions.EASE_OUT_BACK});
	Starling.juggler.tween(this, 1, {delay:time - 1, fortuneHeight:300, transition:Transitions.EASE_IN});
}

protected function animateShadow(alphaSeed:Number, delay:Number):void
{
	Starling.juggler.tween(shadow, Math.random() + 0.1, {delay:delay, alpha:Math.random() * alphaSeed + 0.1, onComplete:animateShadow, onCompleteArgs:[alphaSeed==0?0.7:0, 0]});
}

protected function rotationCompleted() : void 
{
	removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
	for ( var i:int = 0; i < 6; i++ )
		spinners[i].dispose();

	Starling.juggler.removeTweens(shadow);
	shadow.removeFromParent();
	
	// explode particles
	var explode:UIParticleSystem = new UIParticleSystem("explode", 1);
	explode.startSize *= 4;
	explode.x = width * 0.5;
	explode.y = height * 0.5;
	addChild(explode);

	// shine animation
	var shineArmature:StarlingArmatureDisplay = OpenBookOverlay.factory.buildArmatureDisplay("shine");
	shineArmature.touchable = false;
	shineArmature.scale = 0.1;
	shineArmature.x = width * 0.5;
	shineArmature.y = height * 0.5;
	shineArmature.animation.gotoAndPlayByTime("rotate", 0, 10);
	addChild(shineArmature);
	Starling.juggler.tween(shineArmature, 0.3, {scale:4, transition:Transitions.EASE_OUT_BACK});

	// book animation
	var bookArmature:StarlingArmatureDisplay = OpenBookOverlay.factory.buildArmatureDisplay(type.toString());
	bookArmature.touchable = false;
	bookArmature.x = width * 0.5;
	bookArmature.y = height * 0.5;
	bookArmature.scale = 0.1;
	bookArmature.animation.gotoAndStopByProgress("appear", 1);
	bookArmature.animation.timeScale = 0;
	Starling.juggler.tween(bookArmature, 0.3, {scale:2.5, transition:Transitions.EASE_OUT_BACK});
	addChild(bookArmature);
	
	var buttonOverlay:SimpleLayoutButton = new SimpleLayoutButton();
	buttonOverlay.addEventListener(Event.TRIGGERED, buttonOverlay_triggeredHandler);
	buttonOverlay.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	addChild(buttonOverlay);
}

protected function buttonOverlay_triggeredHandler():void
{
	openOverlay = new OpenBookOverlay(type);
	appModel.navigator.addOverlay(openOverlay);
	if( outcomes != null )
	{
		openOverlay.outcomes = outcomes;
		setTimeout(close, 500);
	}
}

protected function enterFrameHandler(e:Event):void 
{
	var _spinners:Array = new Array();
	for ( var i:int = 0; i < 6; i++ )
	{
		var spinner:Spinner = spinners[i] as Spinner;
		spinner.angle -= delta;
		spinner.order = 0.1 + (Math.sin( spinner.angle ) + 1 ) * 0.45;
		spinner.display.visible = spinner.order > 0.3;
		if( spinner.display.visible )
		{
			spinner.display.y = height * 0.5 + fortuneHeight * Math.cos( spinner.angle );
			spinner.display.scale = spinner.order * spinner.scaleFactor;
		}
		_spinners.push(spinner);
	}
	_spinners.sortOn("order", Array.NUMERIC  );
	for ( i = 0; i < 6; i++ )
		setChildIndex(_spinners[i].display, i + 2);

}

override public function set outcomes(value:IntIntMap):void 
{
	super.outcomes = value;
	if( openOverlay != null )
	{
		openOverlay.outcomes = outcomes;
		setTimeout(close, 500);
	}
}

override public function dispose():void
{
	//shineArmature.removeFromParent();
	appModel.sounds.setVolume("main-theme", 1);
	Starling.juggler.removeTweens(shadow);
	Starling.juggler.removeTweens(this);
	removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
	appModel.navigator.activeScreen.visible = true;
	super.dispose();
}
}
}