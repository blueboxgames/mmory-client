package com.gerantech.towercraft.controls.headers
{
import com.gerantech.towercraft.controls.StarCheck;
import com.gerantech.towercraft.controls.TowersLayout;
import com.gerantech.towercraft.controls.overlays.OpenBookOverlay;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.MainTheme;
import dragonBones.Armature;
import dragonBones.starling.StarlingArmatureDisplay;
import feathers.controls.ImageLoader;
import flash.utils.setTimeout;

import flash.geom.Rectangle;

import feathers.controls.AutoSizeMode;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;

public class BattleHeader extends TowersLayout
{
public var labelDisplay:ShadowLabel;
private var label:String;
private var isAllise:Boolean;
private var created:Boolean;
private var needsShowWinner:Boolean;

private var padding:int;
private var score:int;
public function BattleHeader(label:String, isAllise:Boolean, score:int)
{
	super();
	width = 220;
	height = 140;
	this.label = label;
	this.isAllise = isAllise;
	this.score = score;
	padding = 48;
}

override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout();
	addEventListener(FeathersEventType.CREATION_COMPLETE, creationCompleteHandler);
}

private function creationCompleteHandler():void
{
	var ribbon:ImageLoader = new ImageLoader();
	ribbon.source = Assets.getTexture("ribbon-" + (isAllise?"blue":"red"), "gui");
	ribbon.pixelSnapping = false;
	ribbon.scale9Grid = MainTheme.RIBBON_SCALE9_GRID;
	ribbon.layoutData = new AnchorLayoutData(0, NaN, 0, NaN, 0);
	addChild(ribbon);

	ribbon.width = 0;
	Starling.juggler.tween(ribbon, 0.6, {width:this.width, transition:Transitions.EASE_OUT_BACK});
	
	labelDisplay = new ShadowLabel(label, isAllise?0xDDDDFF:0xFFDDDD, 0, "center", null, false, null, height * 0.01);
	//labelDisplay.autoSizeMode = AutoSizeMode.CONTENT
	labelDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, -height * 0.05); 
//	labelDisplay.shadowDistance *= -height * 0.05;
	addChild(labelDisplay);
	
	labelDisplay.alpha = 0;
	Starling.juggler.tween(labelDisplay, 0.3, {delay:0.5, alpha:1});
	
	created = true;
	if( needsShowWinner )
		showWinnerLabel(true);

	if( score == -1 )
		return;
	
	for( var i:int = 0; i < 3; i++ ) 
	{
		var starImage:StarCheck = new StarCheck(false, i == 0 ? 220 : 180);
		starImage.x = width * 0.5 + (Math.ceil(i / 4) * ( i == 1 ? 1 : -1 )) * 256;
		starImage.y = i == 0 ? -140 : -90;
		addChild(starImage);
		if( i < score )
			setTimeout(starImage.active, (i+1) * 500 + 500);
	}	
}

public function showWinnerLabel(isWinner:Boolean) : void
{
	if( !isWinner )
		return;
	if( !created )
	{
		needsShowWinner = true;
		return;
	}
	
	var winnerLabel:ShadowLabel = new ShadowLabel(loc(isWinner ? "winner_label" : "loser_label"));
	winnerLabel.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, padding * 1.4); 
	addChild(winnerLabel);	
	
	var armatureDisplay:StarlingArmatureDisplay = OpenBookOverlay.factory.buildArmatureDisplay("shine");
	armatureDisplay.animation.timeScale = 0.5;
	armatureDisplay.alpha = 0.7;
	armatureDisplay.x = width * 0.5;
	//armatureDisplay.y = height * 0.5;
	armatureDisplay.scaleX = 4;
	armatureDisplay.scaleY = 2;
	armatureDisplay.animation.gotoAndPlayByFrame("rotate", 1);
	addChildAt(armatureDisplay, 0);
}
}
}