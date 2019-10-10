package com.gerantech.towercraft.controls.groups 
{
import com.gerantech.mmory.core.constants.ResourceType;
import com.gerantech.mmory.core.utils.maps.IntIntMap;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.utils.StrUtils;

import feathers.controls.ImageLoader;
import feathers.core.ITextRenderer;
import feathers.layout.AnchorLayoutData;
/**
* @author Mansour Djawadi ...
*/
public class RewardsPalette extends ColorGroup 
{
public function RewardsPalette() { super(); }
public function setRewards(rewards:IntIntMap) : void
{
	removeChildren(1);
	var keys:Vector.<int> = rewards.keys();
	var len:int = keys.length
	for(var i:int = 0; i < len; i++)
		addLine(keys[i], rewards.get(keys[i]), i);
}

private function addLine(key:int, value:int, index:int):void 
{
	var countDisplay:RTLLabel = new RTLLabel(StrUtils.getNumber(value), 0, null, null, false, null, 0.7);
	countDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 30, 50 * index - 20);
	addChild(countDisplay);
	
	var iconDisplay:ImageLoader = new ImageLoader();
	iconDisplay.height = iconDisplay.width = 50;
	iconDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, -50, 50 * index - 20);
	iconDisplay.source = appModel.assets.getTexture(getImageSource(key));
	addChildAt(iconDisplay, 1);
}

private function getImageSource(resourceType:int) : String
{
	var ret:String;
	if( resourceType == -1 )
		ret = "settings-22";
	else if( ResourceType.isBook(resourceType) )
		ret = "books/" + resourceType;
	else if( ResourceType.isCard(resourceType) )
		ret = "cards/" + resourceType;
	else
		ret = "res-" + resourceType;
	return ret;
}

override protected function defaultLabelRendererFactory() : ITextRenderer
{
	var ret:ShadowLabel = new ShadowLabel(this._label, this.textColor, 0, null, null, false, null, 0.75);
	ret.layoutData = new AnchorLayoutData(-40, NaN, NaN, NaN, 0);
	return ret;
}
}
}