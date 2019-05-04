package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.models.Assets;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import flash.geom.Rectangle;
import starling.display.Image;

public class StickerItemRenderer extends AbstractTouchableListItemRenderer
{
private var labelDisplay:RTLLabel;
public function StickerItemRenderer() { super(); }
override protected function initialize():void
{
	super.initialize();
	
	var sk:Image = new Image(Assets.getTexture("sticker-item"));
	sk.scale9Grid = new Rectangle(14, 14, 2, 2);
	backgroundSkin = sk;
	layout = new AnchorLayout();
	
	labelDisplay = new RTLLabel("", 0, null, null, false, null, appModel.isLTR ? 0.7 : 0.8);
	labelDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, -5);
	addChild(labelDisplay);
}

override protected function commitData():void
{
	super.commitData();
	labelDisplay.text = loc("sticker_" + _data );
}
}
}