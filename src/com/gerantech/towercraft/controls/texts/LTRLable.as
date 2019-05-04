package com.gerantech.towercraft.controls.texts
{
	import com.gerantech.towercraft.models.AppModel;
	import com.gerantech.towercraft.themes.MainTheme;
	
	import flash.text.TextFormat;
	
	import feathers.controls.text.TextFieldTextRenderer;
	
	public class LTRLable extends TextFieldTextRenderer
	{
		private var align:String;
		private var fontFamily:String;
		private var fontSize:uint;
		private var color:uint;
		
		public function LTRLable(text:String, color:uint=0, align:String=null, wordWrap:Boolean=false, fontSize:Number=0, fontFamily:String=null, bold:Boolean=false, italic:Boolean=false)
		{
			if(fontSize == 0)
				this.fontSize = AppModel.instance.theme.gameFontSize;
			else if(fontSize<4)
				this.fontSize = fontSize * AppModel.instance.theme.gameFontSize;
			else
				this.fontSize = fontSize;

			embedFonts = true;
			this.align = align==null ? "right"/*AppModel.instance.align*/ : align;
			this.fontFamily = fontFamily==null ? "SourceSans" : fontFamily;
			this.color = color==1 ? MainTheme.PRIMARY_TEXT_COLOR : color;
			this.wordWrap = wordWrap;
			textFormat = new TextFormat(this.fontFamily, this.fontSize, this.color, false, italic, null, null, null, align, null, null, null);//, -fontSize/1.2
		}
	
		public function get isTruncated():Boolean
		{
			if(textField==null)
				return false;
			
			return textField.textWidth>=width;
		}
	}
}