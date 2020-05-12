package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.themes.MainTheme;

import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.skins.ImageSkin;

import starling.core.Starling;

public class ExistGamesListItemRenderer extends AbstractTouchableListItemRenderer
{
private var labelDisplay:ShadowLabel;
public function ExistGamesListItemRenderer(height:int)
{
	super();
	this.height = height
}

override protected function commitData() : void
{
	super.commitData();
	if( _data == null || _owner == null )
		return;
	
	if( labelDisplay == null )
		createElements(_data.getUtfString("name"));
	else
		labelDisplay.text = _data.getUtfString("name");

	alpha = 0;
	Starling.juggler.tween(this, 0.05, {delay:index * 0.03, alpha:1});
}

private function createElements(label:String) : void
{
	var mySkin:ImageSkin = new ImageSkin(_data.getLong("id") == -2 ? appModel.theme.buttonSmallNeutralUpSkinTexture : appModel.theme.buttonSmallHilightUpSkinTexture);
	mySkin.scale9Grid = MainTheme.BUTTON_SMALL_SCALE9_GRID;
	backgroundSkin = mySkin;	
	
	layout = new AnchorLayout();
	
	labelDisplay = new ShadowLabel(label, 0xDDFFFF, 0, "center", null, false, "center", 0.9);
	labelDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, 0);
	addChild(labelDisplay);
}
}
}