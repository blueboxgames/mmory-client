package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.models.Assets;
import feathers.layout.AnchorLayout;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;

public class RatingItemRenderer extends AbstractTouchableListItemRenderer
{
private var iconDisplay:Image;

public function RatingItemRenderer(){}
override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout();
	height = width = 130;
}

override protected function commitData():void
{
	super.commitData();
	if( iconDisplay == null )
	{
		iconDisplay = new Image(Assets.getTexture("gold-key" + (_data.s ? "" : "-off"), "gui"));
		iconDisplay.x = iconDisplay.y = width * 0.5;
		iconDisplay.pivotX = iconDisplay.pivotY = iconDisplay.width * 0.5
		iconDisplay.width = iconDisplay.height = width * 0.8;
		iconDisplay.pixelSnapping = false;
		addChild(iconDisplay);
	}
	else
	{
		iconDisplay.texture = Assets.getTexture("gold-key" + (_data.s ? "" : "-off"), "gui");
	}
	
	if( !_data.s )
		return;
	iconDisplay.width = iconDisplay.height = width;
	Starling.juggler.removeTweens(iconDisplay);
	Starling.juggler.tween(iconDisplay, 0.5, {width:width * 0.8, height:width * 0.8, transition:Transitions.EASE_OUT_BACK});
}
}
}