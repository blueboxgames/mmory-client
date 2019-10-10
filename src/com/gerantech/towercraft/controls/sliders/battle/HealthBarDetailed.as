package com.gerantech.towercraft.controls.sliders.battle 
{
import com.gerantech.towercraft.views.BattleFieldView;

import feathers.controls.text.BitmapFontTextRenderer;
import feathers.text.BitmapFontTextFormat;
import com.gerantech.towercraft.models.AppModel;
/**
* ...
* @author Mansour Djawadi
*/
public class HealthBarDetailed extends HealthBarLeveled 
{
private var healthDisplay:BitmapFontTextRenderer;
public function HealthBarDetailed(filedView:BattleFieldView, side:int, level:int = 1, maximum:Number = 1)
{
	super(filedView, side, level, maximum);
	this.width = 90;
	this.height = 18;
}
override public function initialize() : void
{
	super.initialize();

	healthDisplay = new BitmapFontTextRenderer();
	healthDisplay.pixelSnapping = false;
	healthDisplay.textFormat = new BitmapFontTextFormat(AppModel.instance.assets.getFont(), 28, 0xFFFFFF, "left");
	healthDisplay.visible = false;
	filedView.guiTextsContainer.addChild(healthDisplay);
}

override public function setPosition(x:Number, y:Number) : void
{
	super.setPosition(x, y);
	if( healthDisplay != null && healthDisplay.visible )
	{
		healthDisplay.x = x - width * 0.5 + 2;
		healthDisplay.y = y + (_side == 0 ? -4 : -32);
	}
}

override public function set value(v:Number) : void
{
	if( super.value == v )
		return;
	super.value = v;
	
	if( healthDisplay == null )
		return;

	healthDisplay.visible = v < maximum;
	if( healthDisplay.visible )
		healthDisplay.text = Math.round(v * 400).toString(); 
}

override public function dispose() : void 
{
	super.dispose();
	if( healthDisplay != null )
		healthDisplay.removeFromParent(true);
}
}
}