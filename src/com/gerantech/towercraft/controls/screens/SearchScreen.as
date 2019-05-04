package com.gerantech.towercraft.controls.screens
{
import com.gerantech.towercraft.controls.texts.CustomTextInput;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.data.SFSArray;
import com.smartfoxserver.v2.entities.data.SFSObject;
import feathers.data.ListCollection;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayoutData;
import flash.text.ReturnKeyLabel;
import flash.text.SoftKeyboardType;
import starling.events.Event;

public class SearchScreen extends ListScreen
{
protected var patternLimit:int = 3;
protected var result:ListCollection = new ListCollection();
protected var textInput:CustomTextInput;

public function SearchScreen(){}
override protected function initialize():void
{
	super.initialize();
	
	textInput = new CustomTextInput(SoftKeyboardType.DEFAULT, ReturnKeyLabel.SEARCH);
	textInput.promptProperties
	textInput.promptProperties.fontSize = textInput.textEditorProperties.fontSize = 0.8*appModel.theme.gameFontSize;
	textInput.maxChars = 16;
	textInput.addEventListener(FeathersEventType.ENTER, searchButton_triggeredHandler);
	textInput.layoutData = new AnchorLayoutData(0, 0, NaN, 0);
	textInput.height = 168;
	addChild(textInput);
	
	listLayout.gap = 5;	
	listLayout.padding = 12;
	listLayout.paddingTop = 180;
	list.dataProvider = result;
}

protected function searchButton_triggeredHandler(e:Event) : Boolean
{
	if( textInput.text.length < patternLimit )
	{
		appModel.navigator.addLog("Wrong Pattern!");
		return false;
	}
	return true;
}
}
}