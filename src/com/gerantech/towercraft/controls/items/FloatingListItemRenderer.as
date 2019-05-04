package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.themes.MainTheme;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.skins.ImageSkin;
import starling.core.Starling;

public class FloatingListItemRenderer extends AbstractTouchableListItemRenderer
{
private var nameShadowDisplay:ShadowLabel;
private var labelDisplay:ShadowLabel;
public function FloatingListItemRenderer(height:int)
{
	super();
	this.height = height
}

override protected function commitData() : void
{
	super.commitData();
	if( _data == null || _owner == null )
		return;
	
	var label:String = loc(_data + "");
	if( labelDisplay == null )
		createElements( label );
	else
		labelDisplay.text = label;

	alpha = 0;
	Starling.juggler.tween(this, 0.05, {delay:index * 0.03, alpha:1});
}

private function createElements(label:String) : void
{
	var mySkin:ImageSkin = new ImageSkin(String(_data).indexOf("$") >-1?appModel.theme.itemRendererSelectedSkinTexture:appModel.theme.itemRendererUpSkinTexture);
	mySkin.scale9Grid = MainTheme.ITEM_RENDERER_SCALE9_GRID;
	backgroundSkin = mySkin;	
	
	layout = new AnchorLayout();
	//var padding:int = 36;
	
	labelDisplay = new ShadowLabel(label, 0xDDFFFF, 0, "center", null, false, "center", 0.9);
	labelDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, 0);
	addChild(labelDisplay);
}
}
}