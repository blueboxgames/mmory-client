package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.MainTheme;
import com.gerantech.towercraft.utils.StrUtils;

import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.TiledRowsLayout;
import feathers.skins.ImageSkin;

public class EmblemItemRenderer extends AbstractTouchableListItemRenderer
{

private var iconDisplay:ImageLoader;
public function EmblemItemRenderer()
{
	super();
}

override protected function initialize():void
{
	super.initialize();
	var padding:int = 16;
	layout = new AnchorLayout();
	
	skin = new ImageSkin(appModel.theme.itemRendererUpSkinTexture);
	skin.setTextureForState(STATE_NORMAL, appModel.theme.itemRendererUpSkinTexture);
	skin.setTextureForState(STATE_DOWN, appModel.theme.itemRendererSelectedSkinTexture);
	skin.setTextureForState(STATE_SELECTED, appModel.theme.itemRendererSelectedSkinTexture);
	skin.scale9Grid = MainTheme.ITEM_RENDERER_SCALE9_GRID;
	backgroundSkin = skin;
	
	iconDisplay = new ImageLoader();
	iconDisplay.pixelSnapping = false;
	iconDisplay.layoutData = new AnchorLayoutData(padding, padding, padding*1.3, padding);
	addChild(iconDisplay);
	
}
override protected function commitData():void
{
	super.commitData();
	if( index < 0 || _data == null )
		return;
	width = TiledRowsLayout(_owner.layout).typicalItemWidth;
	height = TiledRowsLayout(_owner.layout).typicalItemHeight;
	iconDisplay.source = Assets.getTexture("emblems/emblem-"+StrUtils.getZeroNum(_data+""), "gui");
}
}
}