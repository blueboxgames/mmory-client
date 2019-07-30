package com.gerantech.towercraft.controls.groups
{
import com.gerantech.towercraft.controls.TowersLayout;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.themes.MainTheme;

import feathers.core.ITextRenderer;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

import starling.display.DisplayObject;
import starling.display.Image;

public class ColorGroup extends TowersLayout
{
private var _backgroundColor:uint = 0xFFFFFF;
public function get backgroundColor():uint
{
	return _backgroundColor;
}
public function set backgroundColor(value:uint):void
{
	if( this._backgroundColor == value )
		return;
	this._backgroundColor = value;
	this.invalidate(INVALIDATION_FLAG_STYLES);
}

private var _textColor:uint = 0xFFFFFF;
public function get textColor():uint
{
	return _textColor;
}
public function set textColor(value:uint):void
{
	if( this._textColor == value )
		return;
	this._textColor = value;
	this.invalidate(INVALIDATION_FLAG_STYLES);
}

protected var _label:String;
protected var _labelRenderFactory:Function;
protected var labelTextRenderer:ITextRenderer;
public function ColorGroup() 
{
	super(); 
	height = 100;
	this._labelRenderFactory = defaultLabelRendererFactory;
}
override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout(); 
	
	var skin:Image = new Image(appModel.theme.roundMediumInnerSkin);
	// skin.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	skin.scale9Grid = MainTheme.ROUND_MEDIUM_SCALE9_GRID;
	skin.color = this._backgroundColor;
	backgroundSkin = skin;
}


/**
 * 
 * Small text renderer <b>top or bottom of button</b> for description
 * <p>if label <b>is not null</b>, you can see text element ;) !</p>
 */
public function get label() : String
{
	return this._label;
}
public function set label(value:String) : void
{
	if( this._label == value )
		return;
	this._label = value;
	if( this._label != null )
		this.invalidate(INVALIDATION_FLAG_TEXT_RENDERER);
	this.invalidate(INVALIDATION_FLAG_DATA);
}

protected function refreshlabel() : void
{
	if( this.labelTextRenderer == null )
		return;
	
	this.labelTextRenderer.visible = this._label !== null && this._label.length > 0;
	
	if( !this.labelTextRenderer.visible )
		return;
	
	this.labelTextRenderer.isEnabled = this._isEnabled;
	this.labelTextRenderer.text = this._label;
	this.labelTextRenderer.validate();
}

public function get labelRenderFactory() : Function 
{
	return this._labelRenderFactory;
}
public function set labelRenderFactory(value:Function) : void 
{
	this._labelRenderFactory = value;
	this.invalidate(INVALIDATION_FLAG_TEXT_RENDERER);
}
protected function defaultLabelRendererFactory() : ITextRenderer
{
	var ret:ShadowLabel = new ShadowLabel(this._label, this._textColor, 0, null, null, false, null, 0.9);
	ret.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, 0);
	return ret;
}


/**
 * render() won't be called unless the LayoutGroup requires a redraw.
 * this is needed to ensure that elements position and things are properly updated when the LayoutGroup is transformed.
 */
override protected function draw() : void
{
	if( this._invalidationFlags[INVALIDATION_FLAG_TEXT_RENDERER] )
	{
		if( this.labelTextRenderer == null ) 
			this.labelTextRenderer = this.labelRenderFactory();
		if( this.labelTextRenderer != null )
			this.addChild(DisplayObject(this.labelTextRenderer));
	}
	
	if( this.isInvalid(INVALIDATION_FLAG_DATA) )
		this.refreshlabel();
	if( this.isInvalid(INVALIDATION_FLAG_SKIN) && this.backgroundSkin != null )
		Image(this.backgroundSkin).color = this._backgroundColor;
	//if( this.isInvalid(INVALIDATION_FLAG_STYLES) && this.labelTextRenderer != null )
		//this.labelTextRenderer.fontStyles.format.color = this._textColor;
	
	super.draw();
}

}
}