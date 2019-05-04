package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.controls.texts.LTRLable;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import feathers.core.ITextRenderer;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.Quad;

public class FeatureItemRenderer extends AbstractTouchableListItemRenderer
{
protected var keyDisplay:RTLLabel;
protected var valueDisplay:ITextRenderer;
protected var _firstCommit:Boolean = true;

public function FeatureItemRenderer(){}
override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout();
}

override protected function commitData():void
{
	if( _owner == null || _data == null )
		return;
	
	if( _firstCommit )
	{
		_firstCommit = false;
		height = 64;
	}
	backgroundFactory();
	keyLabelFactory();
	valueLabelFactory();
	
	alpha = 0;
	Starling.juggler.tween(this, 0.2, {delay:index / 30, alpha:1});
}
protected function backgroundFactory():DisplayObject
{
	if( backgroundSkin != null )
		return null;
	backgroundSkin = new Quad(1, 1, index % 2 == 0 ? 0xFFFFFF : 0xAAAAAA);
	backgroundSkin.alpha = 0.5;
	return backgroundSkin;
}

protected function keyLabelFactory(scale:Number = 0.8, color:uint = 0):RTLLabel
{
	if( keyDisplay != null )
		return null;
	keyDisplay = new RTLLabel("", color, null, null, false, null, scale * 0.9);
	keyDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?NaN:10, NaN, appModel.isLTR?10:NaN, NaN, 0);
	addChild(keyDisplay);
	return keyDisplay;
}

protected function valueLabelFactory(scale:Number = 0.8, color:uint = 0):void
{
	if( valueDisplay != null )
		return;
	valueDisplay = new LTRLable("", color, "left", false, scale);
	LTRLable(valueDisplay).layoutData = new AnchorLayoutData(-16, appModel.isLTR?10:NaN, -10, appModel.isLTR?NaN:10);
	addChild(valueDisplay as LTRLable);
}
}
}