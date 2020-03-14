package com.gerantech.towercraft.views.hb
{
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.views.BattleFieldView;
/**
* ...
* @author Mansour Djawadi
*/
public class HealthBarDetailed extends HealthBarLeveled 
{
private var healthDisplay:ShadowLabel;
public function HealthBarDetailed(filedView:BattleFieldView, side:int, level:int = 1, maximum:Number = 1)
{
	super(filedView, side, level, maximum);
	this.width = 90;
	this.height = 18;

	healthDisplay = new ShadowLabel(null, 1, 0, "left", "ltr", false, null, 0.45);//28
	healthDisplay.pixelSnapping = false;
	healthDisplay.visible = false;
	filedView.guiTextsContainer.addChild(healthDisplay);
}

override public function setPosition(x:Number, y:Number) : void
{
	super.setPosition(x, y);
	if( healthDisplay != null && healthDisplay.visible )
	{
		healthDisplay.x = x - width * 0.5 + 6;
		healthDisplay.y = y + (_side == 0 ? 8 : -24);
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

override public function set alpha(value:Number):void
{
	if( super.alpha == value )
		return;
	super.alpha = value;
	if( healthDisplay != null )
		healthDisplay.alpha = value;
}

override public function dispose() : void 
{
	super.dispose();
	if( healthDisplay != null )
		healthDisplay.removeFromParent(true);
}
}
}