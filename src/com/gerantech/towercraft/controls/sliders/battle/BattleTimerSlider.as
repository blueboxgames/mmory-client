package com.gerantech.towercraft.controls.sliders.battle
{
import com.gerantech.towercraft.controls.StarCheck;
import com.gerantech.towercraft.controls.indicators.CountdownIcon;
import com.gerantech.towercraft.controls.sliders.LabeledProgressBar;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import flash.utils.clearTimeout;
import starling.core.Starling;

public class BattleTimerSlider extends IBattleSlider
{
private var timeoutId:uint;
private var progressBar:LabeledProgressBar;
public var iconDisplay:CountdownIcon;
private var stars:Vector.<StarCheck>;

public function BattleTimerSlider() { super(); }
override protected function initialize():void
{
	super.initialize();
	
	layout = new AnchorLayout();
	width = 280;
	height = 72;

	progressBar = new LabeledProgressBar();
	progressBar.hasLabelTextRenderer = false;
	progressBar.value = 1;
	progressBar.isEnabled = false;
	progressBar.horizontalAlign = HorizontalAlign.RIGHT;
	progressBar.layoutData = new AnchorLayoutData (0,0,0,0);
	addChild(progressBar);

	iconDisplay = new CountdownIcon();
	iconDisplay.width = iconDisplay.height = height * 2.0;
	iconDisplay.x = width;
	iconDisplay.y = height * 0.5;
	addChild(iconDisplay);
	
	stars = new Vector.<StarCheck>();
	for ( var i:int = 0; i < 3; i++ )
	{
		var starImage:StarCheck = new StarCheck(true, i == 0 ? 60 : 50);
        starImage.x = width * 0.5 + (Math.ceil(i / 4) * ( i == 1 ? 1 : -1 )) * 70 - 20;
        starImage.y = height * 0.5 + (i == 0 ? -4 : 0);
        addChild(starImage);
		stars.push(starImage);
	}
}

override public function get value():Number
{
	return _value;
}
override public function set value(newValue:Number):void
{
	if( _value == newValue )
		return;
	if( newValue < 0 )
		newValue = 0;
	if( maximum == 0 )
		return;
	try {
	progressBar.value = _value = Math.max(0, Math.min( newValue, maximum ) );
	} catch(e:Error){trace(e.message);}
}

override public function get minimum():Number
{
	return progressBar.minimum;
}
override public function set minimum(value:Number):void
{
	progressBar.minimum = value;
}

override public function get maximum():Number
{
	return progressBar.maximum;
}
override public function set maximum(value:Number):void
{
	progressBar.maximum = value;
}

override public function enableStars(score:int):void
{
	for( var i:int=0; i<stars.length; i++ )
	{
		if( score < i )
			stars[i].deactive();
	}
}

override public function dispose():void
{
	clearTimeout(timeoutId);
	Starling.juggler.removeTweens(iconDisplay);
	super.dispose();
}
}
}