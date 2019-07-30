package com.gerantech.towercraft.controls.items 
{
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.MainTheme;

import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.skins.ImageSkin;
/**
* ...
* @author Mansour Djawadi
*/
public class TabsHeaderItemRenderer extends AbstractTouchableListItemRenderer 
{
private var labelDisplay:ShadowLabel;
private var iconDisplay:ImageLoader;
public var labelLayoutData:AnchorLayoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, 0);
public var iconLayoutData:AnchorLayoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, 0);

public function TabsHeaderItemRenderer() { super(); }
override protected function initialize() : void
{
	super.initialize();
	layout = new AnchorLayout();
	width = 390;
	backgroundFactory();
}

override protected function commitData():void
{
	if( _owner == null || _data == null )
		return;

	if( _data.hasOwnProperty("width") )
		width = _data.width;
	labelDisplayFactory();
	iconDisplayFactory();
}
protected function backgroundFactory():ImageSkin
{
	if( skin != null )
		return null;
	skin = new ImageSkin(appModel.theme.tabUpSkinTexture);
	skin.setTextureForState(STATE_NORMAL, appModel.theme.tabUpSkinTexture);
	skin.setTextureForState(STATE_DOWN, appModel.theme.tabUpSkinTexture);
	skin.setTextureForState(STATE_SELECTED, appModel.theme.tabSelectedSkinTexture);
	skin.setTextureForState(STATE_DISABLED, appModel.theme.tabDisabledSkinTexture);
	skin.scale9Grid = MainTheme.TAB_SCALE9_GRID;
	backgroundSkin = skin;
	return skin;
}

protected function labelDisplayFactory() : ShadowLabel
{
	if( !_data.hasOwnProperty("label") )
		return null;
	if( labelDisplay == null )
	{
		labelDisplay = new ShadowLabel("", _data.hasOwnProperty("labelColor") ? _data.labelColor : 1, 0, null, null, false, null, _data.hasOwnProperty("labelSize") ? _data.labelSize : 0.8);
		labelDisplay.touchable = false;
		labelDisplay.layoutData = labelLayoutData;
		addChild(labelDisplay);
	}
	labelDisplay.text = _data.label;
	return labelDisplay;
}

protected function iconDisplayFactory() : ImageLoader
{
	if( !_data.hasOwnProperty("icon") )
		return null;
	if( iconDisplay == null )
	{
		iconDisplay = new ImageLoader();
		iconDisplay.layoutData = iconLayoutData;
		if( _data.hasOwnProperty("iconWidth") )
			iconDisplay.width = _data.iconWidth;
		if( _data.hasOwnProperty("iconHeigth") )
			iconDisplay.height = _data.iconHeigth;
		addChild(iconDisplay);
	}
	iconDisplay.source = Assets.getTexture(_data.icon, "gui");
	return iconDisplay;
}
}
}