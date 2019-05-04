package com.gerantech.towercraft.controls.buttons 
{
import com.gerantech.towercraft.models.Assets;
import feathers.layout.AnchorLayoutData;
import flash.geom.Rectangle;
import starling.textures.Texture;

/**
* @author Mansour Djawadi
*/
public class LeagueButton extends IconButton 
{

public function LeagueButton(leagueIndex:int) 
{
	super(Assets.getTexture("leagues/" + Math.floor(leagueIndex * 0.5), "gui"), 0.7, Assets.getTexture("leagues/circle-" + (leagueIndex % 2) + "-0", "gui"));
	width = 140;
	height = 154;
}
override protected function initialize():void
{
	super.initialize();
	AnchorLayoutData(iconDisplay.layoutData).verticalCenter = -15;
}
}
}