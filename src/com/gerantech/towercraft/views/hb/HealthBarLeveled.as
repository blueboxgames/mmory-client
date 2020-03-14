package com.gerantech.towercraft.views.hb
{
import com.gerantech.mmory.core.utils.CoreUtils;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.views.BattleFieldView;

import starling.display.Image;
/**
* ...
* @author Mansour Djawadi
*/
public class HealthBarLeveled extends HealthBar 
{
private var level:int;
private var levelDisplay:Image;
public function HealthBarLeveled(filedView:BattleFieldView, side:int, level:int = 1, maximum:Number = 1)
{
	super(filedView, side, maximum);
	this.level = level;
}

override public function initialize() : void
{
	super.initialize();
	
	levelDisplay = new Image(AppModel.instance.assets.getTexture("sliders/" + _side + "/level-" + CoreUtils.clamp(level, 1, 13)));
	levelDisplay.height = 28;
	levelDisplay.scaleX = levelDisplay.scaleY;
	levelDisplay.touchable = false;
	levelDisplay.visible = false;
	filedView.guiImagesContainer.addChild(levelDisplay);	
}

override public function setPosition(x:Number, y:Number) : void
{
	if( sliderBackDisplay != null )
	{
		sliderBackDisplay.x = x - width * 0.5;
		sliderBackDisplay.y = y;
	}
	if( sliderFillDisplay != null )
	{
		sliderFillDisplay.x = x - width * 0.5;
		sliderFillDisplay.y = y;
	}

	if( levelDisplay != null )
	{
		levelDisplay.x = x - (value < maximum ? (width * 0.5 + levelDisplay.width) : (levelDisplay.width * 0.5));
		levelDisplay.y = y - 7;
	}
}

override public function set value(v:Number) : void
{
	if( super.value == v )
		return;
	super.value = v;
	
	var __visible:Boolean = v < maximum || _side > 0;
	if( levelDisplay != null )
		levelDisplay.visible = __visible;
}

override public function dispose() : void 
{
	super.dispose();
	if( levelDisplay != null )
		levelDisplay.removeFromParent(true);
}

public function set alpha(value:Number):void 
{
}
}
}