package com.gerantech.towercraft.controls.items.lobby
{
import com.gerantech.towercraft.controls.items.FeatureItemRenderer;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.utils.StrUtils;
import feathers.layout.AnchorLayoutData;

public class LobbyFeatureItemRenderer extends FeatureItemRenderer
{
override protected function commitData():void
{
	if( _owner == null || _data == null )
		return;
	
	super.commitData();
	height = 44;
	keyDisplay.text = loc("lobby_" + _data.key);
	valueDisplay.text = _data.key == "pri" ? loc("lobby_pri_" + _data.value) : StrUtils.getNumber(_data.value);
}

override protected function keyLabelFactory(scale:Number = 0.65, color:uint = 0):RTLLabel
{
	if( keyDisplay != null )
		return null;
	keyDisplay = new RTLLabel("", color, null, null,	false, null, scale);
	keyDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?NaN:12, NaN, appModel.isLTR?12:NaN, NaN, 0);
	addChild(keyDisplay);
	return keyDisplay;
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