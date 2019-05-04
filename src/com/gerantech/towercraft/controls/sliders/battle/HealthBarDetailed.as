package com.gerantech.towercraft.controls.sliders.battle 
{
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.views.BattleFieldView;
import feathers.controls.text.BitmapFontTextRenderer;
import feathers.text.BitmapFontTextFormat;
/**
* ...
* @author Mansour Djawadi
*/
public class HealthBarDetailed extends HealthBarLeveled 
{
private var healthDisplay:BitmapFontTextRenderer;
public function HealthBarDetailed(filedView:BattleFieldView, side:int, level:int = 1, initValue:Number = 0, initMax:Number = 1)
{
	super(filedView, side, level, initValue, initMax);
	this.width = 90;
	this.height = 18;
}
override public function initialize() : void
{
	super.initialize();

	healthDisplay = new BitmapFontTextRenderer();
	healthDisplay.pixelSnapping = false;
	healthDisplay.textFormat = new BitmapFontTextFormat(Assets.getFont(), 28, 0xFFFFFF, "left");
	healthDisplay.visible = value < maximum || _side > 0;
	filedView.guiTextsContainer.addChild(healthDisplay);
}

override public function setPosition(x:Number, y:Number) : void
{
	super.setPosition(x, y);
	if( healthDisplay != null )
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

	healthDisplay.visible = v < maximum || _side > 0;
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