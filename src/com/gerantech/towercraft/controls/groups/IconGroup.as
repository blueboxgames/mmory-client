package com.gerantech.towercraft.controls.groups
{
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.utils.StrUtils;
import feathers.controls.ImageLoader;
import feathers.core.ITextRenderer;
import feathers.layout.AnchorLayoutData;
import starling.textures.Texture;

public class IconGroup extends ColorGroup
{
protected var icon:Texture;
public function IconGroup(icon:Texture, label:String)
{
	super();
	this.icon = icon;
	this.label = StrUtils.getNumber(label);
}

override protected function initialize():void
{
	super.initialize();
	
	var iconDisplay:ImageLoader = new ImageLoader();
	iconDisplay.source = icon;
	iconDisplay.layoutData = new AnchorLayoutData(-32, NaN, -32, -32);
	addChild(iconDisplay);
}

override protected function defaultLabelRendererFactory() : ITextRenderer
{
	var ret:ShadowLabel = new ShadowLabel(this._label, this.textColor, 0, null, null, false, null, 0.9);
	ret.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 60, 0);
	return ret;
}
}
}