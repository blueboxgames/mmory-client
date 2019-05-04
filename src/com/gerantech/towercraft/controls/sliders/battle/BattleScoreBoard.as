package com.gerantech.towercraft.controls.sliders.battle 
{
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.MainTheme;
import com.gerantech.towercraft.utils.StrUtils;
import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
/**
 * @author Mansour Djawadi
 */
public class BattleScoreBoard extends IBattleBoard
{
private var alliseValue:int;
private var axisValue:int;
private var allisScoreDisplay:ShadowLabel;
private var axisScoreDisplay:ShadowLabel;
public function BattleScoreBoard() 
{
	super();
	width = 120;
	height = 500;
}
override protected function initialize():void
{
	super.initialize();
	
	layout = new AnchorLayout();
	
	var allisBG:ImageLoader = new ImageLoader();
	allisBG.color = 0x000044;
	allisBG.source = appModel.theme.roundMediumInnerSkin;
	allisBG.scale9Grid = MainTheme.ROUND_MEDIUM_SCALE9_GRID;
	allisBG.height = 140;
	allisBG.alpha = 0.8;
	allisBG.layoutData = new AnchorLayoutData(NaN, 0, 0, 0);
	addChild(allisBG);

	var axisBG:ImageLoader = new ImageLoader();
	axisBG.color = 0x440000;
	axisBG.source = appModel.theme.roundMediumInnerSkin;
	axisBG.scale9Grid = MainTheme.ROUND_MEDIUM_SCALE9_GRID;
	axisBG.height = 140;
	axisBG.alpha = 0.8;
	axisBG.layoutData = new AnchorLayoutData(0, 0, NaN, 0);
	addChild(axisBG);	
	
	var allisIcon:ImageLoader = new ImageLoader();
	allisIcon.source = Assets.getTexture("res-17");
	allisIcon.layoutData = new AnchorLayoutData(NaN, NaN, 100, NaN, -10);
	allisIcon.height = 70;
	addChild(allisIcon);

	var axisIcon:ImageLoader = new ImageLoader();
	axisIcon.source = Assets.getTexture("res-17");
	axisIcon.layoutData = new AnchorLayoutData(100, NaN, NaN, NaN, -10);
	axisIcon.height = 70;
	addChild(axisIcon);
	
	allisScoreDisplay = new ShadowLabel(StrUtils.getNumber(0), 0x3333FF, 0, null, null, false, null, 1.2);
	allisScoreDisplay .layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, -8, 190 + 5);
	allisScoreDisplay.pixelSnapping = false;
	addChild(allisScoreDisplay);
	
	axisScoreDisplay = new ShadowLabel(StrUtils.getNumber(0), 0xFF3333, 0, null, null, false, null, 1.2);
	axisScoreDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, -8, -190 + 5);
	axisScoreDisplay.pixelSnapping = false;
	addChild(axisScoreDisplay);
}

override public function update(allise:int, axis:int):void
{
	if( alliseValue != allise )
	{
		alliseValue = allise;
		allisScoreDisplay.text = StrUtils.getNumber(allise);
	}
	if( axisValue != axis )
	{
		axisValue = axis;
		axisScoreDisplay.text = StrUtils.getNumber(axis);
	}
	/*//var sum:int = allise + axis;
	Starling.juggler.tween(allisFill,	0.5, {height : height * ( allise	/ sum ), transition:Transitions.EASE_OUT_BACK});
	Starling.juggler.tween(axisFill,	0.5, {height : height * ( axis		/ sum ), transition:Transitions.EASE_OUT_BACK});*/
}
}
}