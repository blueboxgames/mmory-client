package com.gerantech.towercraft.controls.indicators 
{
import com.gerantech.towercraft.controls.TowersLayout;
import com.gerantech.towercraft.models.Assets;
import feathers.controls.ImageLoader;
import feathers.controls.text.BitmapFontTextRenderer;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.text.BitmapFontTextFormat;
import flash.geom.Rectangle;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;
/**
* ...
* @author Mansour Djawadi
*/
public class BattleKeyIndicator extends TowersLayout
{
private var alise:Boolean;
private var _value:int = -1;
private var labelDisplay:BitmapFontTextRenderer;
private var iconDisplay:ImageLoader;

public function BattleKeyIndicator(alise:Boolean) 
{
	this.alise = alise;
}

public function set value(val:int):void 
{
	if ( _value == val )
		return;
	_value = val;
	labelDisplay.text = val.toString();
	iconDisplay.scale = 2;
	Starling.juggler.tween(iconDisplay, 0.5, {scale:1, transition:Transitions.EASE_OUT_BACK});
}
override protected function initialize():void
{
	super.initialize();
	
	layout = new AnchorLayout();
	var size:int = 32;
	width = size * 3;
	height = size * 3.4;
	var color:uint = alise ? 0x007aff : 0xf20c1a;

	var bgImage:ImageLoader = new ImageLoader();
	bgImage.source = Assets.getTexture("theme/indicator-background");
	bgImage.alpha = 0.7;
	bgImage.scale9Grid = new Rectangle(8, 12, 4, 4);
	bgImage.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	addChild(bgImage);

	labelDisplay = new BitmapFontTextRenderer();//imageDisplay.width, imageDisplay.width/2, "");
	labelDisplay.textFormat = new BitmapFontTextFormat(Assets.getFont(), size*4, color, "center");
	labelDisplay.pixelSnapping = false;
	labelDisplay.layoutData = new AnchorLayoutData(NaN, 0, NaN, 0, NaN, 0);
	labelDisplay.text = "0";
	addChild(labelDisplay);
	
	iconDisplay = new ImageLoader();
	iconDisplay.pivotX = iconDisplay.width * 0.5;
	iconDisplay.pivotY = iconDisplay.height * 0.5;
	iconDisplay.width = iconDisplay.height = size * 2.4;
	iconDisplay.source = Assets.getTexture("res-1004");
	labelDisplay.pixelSnapping = false;
	iconDisplay.layoutData = new AnchorLayoutData(-size, NaN, NaN, NaN, 0);
	
	addChild(iconDisplay);
}
}
}