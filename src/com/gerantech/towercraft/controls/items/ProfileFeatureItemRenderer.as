package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.utils.StrUtils;
import feathers.layout.AnchorLayoutData;
public class ProfileFeatureItemRenderer extends FeatureItemRenderer
{
override protected function commitData():void
{
	if( _owner == null || _data == null )
		return;
	
	super.commitData();
	height = 44;
	keyDisplay.text = loc("resource_title_" + _data.getInt("type"));
	valueDisplay.text = StrUtils.getNumber(_data.getInt("count"));
}

override protected function keyLabelFactory(scale:Number = 0.7, color:uint = 0):RTLLabel
{
	return super.keyLabelFactory(scale, color);
}

override protected function valueLabelFactory(scale:Number = 0.7, color:uint = 0):void
{
	if( valueDisplay != null )
		return;
	valueDisplay = new RTLLabel("", color, "left", null, false, null, scale);
	RTLLabel(valueDisplay).layoutData = new AnchorLayoutData(NaN, appModel.isLTR?12:NaN, NaN, appModel.isLTR?NaN:12, NaN, 0);
	addChild(valueDisplay as RTLLabel);
}
}
}