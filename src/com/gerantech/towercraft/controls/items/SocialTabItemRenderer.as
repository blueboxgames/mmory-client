package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.vo.TabItemData;
import com.gerantech.towercraft.themes.MainTheme;

import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.skins.ImageSkin;

public class SocialTabItemRenderer extends AbstractTouchableListItemRenderer
{
private var titleDisplay:ShadowLabel;
private var badgeDisplay:ImageLoader;

private var padding:int;
private var dashboardData:TabItemData;
public function SocialTabItemRenderer(width:Number)
{
	super();
	this.width = width;
}

override protected function commitData():void
{
	super.commitData();
	if( _data == null || _owner == null )
		return;
	
	layout = new AnchorLayout();
	
	this.height = _owner.height;
	padding = 16;
	dashboardData = _data as TabItemData;
	
	skin = new ImageSkin(appModel.theme.tabUpSkinTexture);
	skin.setTextureForState(STATE_NORMAL, appModel.theme.tabUpSkinTexture);
	skin.setTextureForState(STATE_SELECTED, appModel.theme.tabSelectedSkinTexture);
	skin.setTextureForState(STATE_DOWN, appModel.theme.tabDownSkinTexture);
	skin.scale9Grid = MainTheme.TAB_SCALE9_GRID;
	backgroundSkin = skin;
	
	titleDisplay = new ShadowLabel(loc("tab-"+dashboardData.index), 1, 0, "center", null, false, null, 0.8);
	titleDisplay.layoutData = new AnchorLayoutData(NaN, padding, NaN, padding, NaN, 0);
	addChild(titleDisplay);
	
	badgeDisplay = new ImageLoader();
	badgeDisplay.width = badgeDisplay.height = padding*1.6;
	badgeDisplay.layoutData = new AnchorLayoutData(padding/2, padding/2);
	
	updateBadge();
}

private function updateBadge():void
{
	if( dashboardData.badgeNumber+dashboardData.newBadgeNumber <= 0 )
	{
		if(badgeDisplay.parent == this)
			removeChild(badgeDisplay);
	}
	else
	{
		badgeDisplay.source = Assets.getTexture(dashboardData.newBadgeNumber>0 ? "theme/badge-notification-new" : "theme/badge-notification")
		addChild(badgeDisplay);
	}
}

override public function set isSelected(value:Boolean):void
{
	if( value == super.isSelected )
		return;
	super.isSelected = value;
	if(dashboardData != null)
		updateBadge();
}
}
}