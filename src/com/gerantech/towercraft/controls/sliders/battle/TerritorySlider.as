package com.gerantech.towercraft.controls.sliders.battle 
{
import com.gerantech.towercraft.controls.TowersLayout;
import com.gerantech.towercraft.models.Assets;
import feathers.controls.ImageLoader;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import flash.geom.Rectangle;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;
import starling.events.Event;

/**
* ...
* @author Mansour Djawadi
*/
public class TerritorySlider extends IBattleBoard 
{
private var axisFill:ImageLoader;
private var allisFill:ImageLoader;
private var keys_1:ImageLoader;
private var keys_2:ImageLoader;

public function TerritorySlider() {super();}
override protected function initialize():void
{
	super.initialize();
	
	var bgImage:Image = new Image(Assets.getTexture("healthbar-bg--1"));
	bgImage.alpha = 0.6;
	bgImage.scale9Grid = new Rectangle(4, 8, 4, 6);
	backgroundSkin = bgImage;
	
	layout = new AnchorLayout();
	
	allisFill = new ImageLoader();
	allisFill.source = Assets.getTexture("healthbar-fill-0");
	allisFill.layoutData = new AnchorLayoutData(NaN, 0, 0, 0);
	allisFill.scale9Grid = bgImage.scale9Grid;
	addChild(allisFill);
	
	axisFill = new ImageLoader();
	axisFill.source = Assets.getTexture("healthbar-fill-1");
	axisFill.layoutData = new AnchorLayoutData(0, 0, NaN, 0);
	axisFill.scale9Grid = bgImage.scale9Grid;
	addChild(axisFill);
	
	addEventListener(FeathersEventType.CREATION_COMPLETE, createCompleteHandler);
}

private function createCompleteHandler(e:Event):void 
{
	removeEventListener(FeathersEventType.CREATION_COMPLETE, createCompleteHandler);

	var keys_1:ImageLoader = new ImageLoader();
	keys_1.height = 54;
	keys_1.layoutData = new AnchorLayoutData(NaN, 0, height * 0.33);
	keys_1.source = Assets.getTexture("keys-1");
	addChild(keys_1);
	
	var keys_2:ImageLoader = new ImageLoader();
	keys_2.height = 54;
	keys_2.layoutData = new AnchorLayoutData(height * 0.33, 0);
	keys_2.source = Assets.getTexture("keys-2");
	addChild(keys_2);
	
	var keys_3:ImageLoader = new ImageLoader();
	keys_3.height = 54;
	keys_3.layoutData = new AnchorLayoutData(5, 0);
	keys_3.source = Assets.getTexture("keys-3");
	addChild(keys_3);
}

override public function update(allise:int, axis:int):void
{	
	var sum:int = allise + axis;
	Starling.juggler.tween(allisFill,	0.5, {height : height * ( allise	/ sum ), transition:Transitions.EASE_OUT_BACK});
	Starling.juggler.tween(axisFill,	0.5, {height : height * ( axis		/ sum ), transition:Transitions.EASE_OUT_BACK});
}
}
}