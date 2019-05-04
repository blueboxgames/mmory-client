package com.gerantech.towercraft.controls.texts
{
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.themes.MainTheme;
import feathers.controls.text.TextBlockTextRenderer;
import flash.text.engine.ElementFormat;
import flash.text.engine.FontDescription;
import flash.text.engine.FontLookup;
import flash.text.engine.LineJustification;
import flash.text.engine.SpaceJustifier;

public class RTLLabel extends TextBlockTextRenderer
{
public var align:String;
public var lastAlign:String;
public var direction:String;
public var fontFamily:String;
public var fontSize:uint;
public var fontPosture:String;
public var fontWeight:String;
public var fontDescription:FontDescription;
public var color:uint;

public function RTLLabel(text:String = null, color:uint = 1, align:String = null, direction:String = null, wordWrap:Boolean = false, lastAlign:String = null, fontSize:Number = 0, fontFamily:String = null, fontWeight:String = null, fontPosture:String = null)
{
	if( fontSize == 0 )
		this.fontSize = AppModel.instance.theme.gameFontSize;
	else if( fontSize < 4 )
		this.fontSize = fontSize * AppModel.instance.theme.gameFontSize;
	else
		this.fontSize = fontSize;
				
	this.align = align == null ? AppModel.instance.align : align;
	this.lastAlign = lastAlign == null ? AppModel.instance.align : lastAlign;
	this.direction = direction == null ? AppModel.instance.direction : direction;
	this.fontFamily = fontFamily == null ? "SourceSansPro" : fontFamily;
	this.fontWeight = fontWeight == null ? "bold" : fontWeight;
	this.fontPosture = fontPosture == null ? "normal" : fontPosture;
	this.color = color == 1 ? MainTheme.PRIMARY_TEXT_COLOR : color;
	this.bidiLevel = this.direction == "ltr" ? 0 : 1;
	if( text != null && text != "" )
		this.text = text;
	this.wordWrap = wordWrap;
	if( this.wordWrap && this.align=="justify" )
	{
		this.align = this.lastAlign;
		textJustifier = new SpaceJustifier(AppModel.instance.isLTR?"en":"fa", this.lastAlign=="justify"?LineJustification.ALL_INCLUDING_LAST : LineJustification.ALL_BUT_MANDATORY_BREAK);
	}
	this.textAlign = this.align;
	//trace(align, lastAlign, textAlign)
	fontDescription = new FontDescription(this.fontFamily, this.fontWeight, this.fontPosture, FontLookup.EMBEDDED_CFF);
	elementFormat = new ElementFormat(fontDescription, this.fontSize, this.color);
}

public function get isTruncated():Boolean
{
	if(_measurementTextLines==null)
		return false;
	
	return _measurementTextLines[0].textWidth>=width;
}

/*public function get numLines():uint
{
	if(_measurementTextLines==null)
		return 0;
	return _measurementTextLines.length;
}*/

}
}