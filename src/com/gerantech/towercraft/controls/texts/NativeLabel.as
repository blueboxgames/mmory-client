package com.gerantech.towercraft.controls.texts
{
  import com.gerantech.towercraft.models.AppModel;
  import com.gerantech.towercraft.themes.MainTheme;

  import flash.display.Sprite;
  import flash.text.engine.ElementFormat;
  import flash.text.engine.FontDescription;
  import flash.text.engine.FontLookup;
  import flash.text.engine.TextBlock;
  import flash.text.engine.TextElement;
  import flash.text.engine.TextLine;
  import flash.text.engine.TextJustifier;
  import flash.text.engine.SpaceJustifier;
  import flash.text.engine.LineJustification;

  public class NativeLabel extends Sprite
  {
    public var text:String;
    public var align:String;
    public var lastAlign:String;
    public var bidiLevel:int;
    public var direction:String;
    public var fontFamily:String;
    public var fontSize:uint;
    public var fontPosture:String;
    public var fontWeight:String;
    public var fontDescription:FontDescription;
    public var textJustifier:SpaceJustifier;
    public var color:uint;
    public var wordWrap:Boolean;

    public function NativeLabel(text:String = null, width:int = 500, color:uint = 1, align:String = null, direction:String = null, wordWrap:Boolean = false, lastAlign:String = null, fontSize:Number = 0, fontFamily:String = null, fontWeight:String = null, fontPosture:String = null)
    {
      if( fontSize == 0 )
        this.fontSize = AppModel.instance.theme.smallFontSize * 0.6;
      else if( fontSize < 4 )
        this.fontSize = fontSize * AppModel.instance.theme.smallFontSize * 0.6;
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
        this.textJustifier = new SpaceJustifier(AppModel.instance.isLTR?"en":"fa", this.lastAlign=="justify"?LineJustification.ALL_INCLUDING_LAST : LineJustification.ALL_BUT_MANDATORY_BREAK);
      }
      //trace(align, lastAlign, textAlign)
      fontDescription = new FontDescription(this.fontFamily, this.fontWeight, this.fontPosture, FontLookup.EMBEDDED_CFF);
      var elementFormat:ElementFormat = new ElementFormat(fontDescription, this.fontSize, this.color);

      var textBlock:TextBlock = new TextBlock(); 
      textBlock.textJustifier = this.textJustifier;
    	textBlock.bidiLevel = bidiLevel;
      textBlock.content = new TextElement(this.text, elementFormat); 

      var textLine:TextLine = textBlock.createTextLine(null, width);
      var prevLine:TextLine;
      while(textLine != null)
      {
        // For some reason the text line is created so that it's base line is in y=0 and we want
        // the top of the text to be at y=0 so we add the line's ascent.
        textLine.y = int(prevLine!=null ? prevLine.y + prevLine.height + 10 : 0);
        addChild(textLine);
        
        // Save the current line.
        prevLine = textLine;	

        // Create the next line of text.
        textLine = textBlock.createTextLine(prevLine, width);
      }

      if( this.lastAlign == "right" )
        prevLine.x = width - prevLine.textWidth;
      else if( this.lastAlign == "center" )
        prevLine.x = (width - prevLine.textWidth) * 0.5;
    }
  }
}