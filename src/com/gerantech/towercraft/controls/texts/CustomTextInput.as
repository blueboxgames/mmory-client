package com.gerantech.towercraft.controls.texts
{
import com.gerantech.towercraft.models.AppModel;
import feathers.controls.TextInput;
import feathers.controls.text.StageTextTextEditor;
import feathers.core.ITextEditor;
import feathers.core.ITextRenderer;
import starling.events.Event;

public class CustomTextInput extends TextInput
{
private var editor:StageTextTextEditor;
public function CustomTextInput(softKeyboardType:String, returnKeyLabel:String, textColor:uint=0, multiline:Boolean=false, textAlign:String="center", fontSize:Number=1)
{
	super();
	
	textEditorFactory = function():ITextEditor
	{
		editor = new StageTextTextEditor();
		editor.fontFamily = "SourceSans";
		editor.textAlign = textAlign;
		editor.fontSize = fontSize * AppModel.instance.theme.gameFontSize;
		if( AppModel.instance.platform == AppModel.PLATFORM_WINDOWS )
			editor.addEventListener(Event.CHANGE, editor_changeHandler);
		editor.color = textColor;
		editor.softKeyboardType = softKeyboardType;
		editor.multiline = multiline;
		editor.returnKeyLabel = returnKeyLabel;
		return editor;
	}
	
	promptFactory = function():ITextRenderer
	{
		var pr:RTLLabel = new RTLLabel("", textColor, "center", null, false, null, 0.8);
		pr.alpha = 0.7;
		return pr;
	}

	height = 128;
}

private function editor_changeHandler(event:Event):void
{
	editor.text = editor.text.split("ی").join("ي");
}
}
}