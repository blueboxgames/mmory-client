package com.gerantech.towercraft.controls.buttons 
{
/**
* ...
* @author Mansour Djawadi
*/
public class ExchangeDButton extends ExchangeButton 
{

public function ExchangeDButton() 
{
	super();
}

override protected function initialize():void
{
	labelLayoutData.verticalCenter = 0;
	iconPosition.x = 60;
	iconPosition.y = 20;
	fontsize = 0.85;
	super.initialize();
	
	iconDisplay.height = height * 0.65;
}
}
}