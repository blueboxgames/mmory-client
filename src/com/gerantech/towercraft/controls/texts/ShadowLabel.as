package com.gerantech.towercraft.controls.texts
{
import feathers.layout.AnchorLayoutData;
import flash.filters.DropShadowFilter;
import flash.filters.GlowFilter;

public class ShadowLabel extends RTLLabel
{
public var shadowDistance:Number = 0;
public var mainLayout:AnchorLayoutData;
public function ShadowLabel(text:String = null, color:uint = 1, shadowColor:uint = 0, align:String = null, direction:String = null, wordWrap:Boolean = false, lastAlign:String = null, fontSize:Number = 0, fontFamily:String = null, fontWeight:String = null, fontPosture:String = null)
{		
	super(text, color, align, direction, wordWrap, lastAlign, fontSize, fontFamily, fontWeight, fontPosture);
	nativeFilters = [new GlowFilter(shadowColor, 1, elementFormat.fontSize * 0.03, elementFormat.fontSize * 0.03, elementFormat.fontSize * 0.1), new DropShadowFilter(elementFormat.fontSize * 0.03, 90, 0, 1, 0, 0) ];
}
}
}