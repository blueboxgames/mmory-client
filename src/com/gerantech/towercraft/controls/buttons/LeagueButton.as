package com.gerantech.towercraft.controls.buttons 
{
import feathers.layout.AnchorLayoutData;

/**
* @author Mansour Djawadi
*/
public class LeagueButton extends IconButton 
{

public function LeagueButton(leagueIndex:int) 
{
	super(appModel.assets.getTexture("leagues/" + Math.floor(leagueIndex * 0.5)), 0.7, appModel.assets.getTexture("leagues/circle-" + (leagueIndex % 2) + "-0"));
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