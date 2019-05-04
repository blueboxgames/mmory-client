package com.gerantech.towercraft.controls.buttons 
{
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gt.towers.constants.ResourceType;
/**
* @author Mansour Djawadi
*/
public class IndicatorPoint extends Indicator
{
public function IndicatorPoint(direction:String = "ltr", autoApdate:Boolean = true)
{
	super(direction, ResourceType.R2_POINT, true, false, autoApdate);
}
override public function setData(minimum:Number, value:Number, maximum:Number, changeDuration:Number = 0) : void
{
	if( value == -1 )
		value = player.get_point();
	var arena:int = player.get_arena(value);//trace(value, arena, player.resources.toString())
	super.setData(game.arenas.get(arena).min, value, game.arenas.get(arena).max, changeDuration);
}
}
}