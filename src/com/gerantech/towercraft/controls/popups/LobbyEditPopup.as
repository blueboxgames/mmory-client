package com.gerantech.towercraft.controls.popups
{
import com.gerantech.mmory.core.constants.SFSCommands;
import com.gerantech.towercraft.controls.buttons.EmblemButton;
import com.gerantech.towercraft.controls.overlays.TransitionData;
import com.gerantech.towercraft.controls.switchers.Switcher;
import com.gerantech.towercraft.controls.texts.CustomTextInput;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.themes.MainTheme;
import com.smartfoxserver.v2.entities.data.SFSObject;

import feathers.controls.Button;
import feathers.layout.AnchorLayoutData;

import flash.geom.Rectangle;
import flash.text.ReturnKeyLabel;
import flash.text.SoftKeyboardType;

import starling.events.Event;

public class LobbyEditPopup extends SimpleHeaderPopup
{
private var roomData:Object;
private var minSwitcher:Switcher;
private var maxSwitcher:Switcher;
private var priSwitcher:Switcher;
private var errorDisplay:RTLLabel;
private var bioInput:CustomTextInput;
private var nameInput:CustomTextInput;
private var emblemButton:EmblemButton;
public function LobbyEditPopup(roomData:Object) 
{
	this.roomData = roomData;
	var _h:int = 1500;
	var _p:int = 48;
	transitionIn = new TransitionData();
	transitionOut = new TransitionData();
	transitionOut.destinationAlpha = 0;
	transitionIn.sourceBound = transitionOut.destinationBound = new Rectangle(_p,	stageHeight* 0.5 - _h * 0.4,	stageWidth - _p * 2,	_h * 0.8);
	transitionOut.sourceBound = transitionIn.destinationBound = new Rectangle(_p,	stageHeight* 0.5 - _h * 0.5,	stageWidth - _p * 2,	_h * 1.0);
	title = loc("lobby_edit_label");
}

override protected function showElements():void
{
	if( transitionState < TransitionData.STATE_IN_COMPLETED )
		return;
	
	padding = 48;
	super.showElements();
	
	//nameInput = addInput("name", roomData.name, 180, 100);
	bioInput = addInput("bio", roomData.bio, 180, 320);
	
	// lobby emblem
	var emblemLabel:RTLLabel = new RTLLabel( loc("lobby_pic"), 0, null, null, false, null, 0.75);
	emblemLabel.layoutData = new AnchorLayoutData(640, appModel.isLTR?NaN:padding, NaN, appModel.isLTR?padding:NaN);
	addChild(emblemLabel);
	
	emblemButton = new EmblemButton(roomData.pic as int);
	emblemButton.layoutData = new AnchorLayoutData(590, appModel.isLTR?padding:NaN, NaN, appModel.isLTR?NaN:padding);
	emblemButton.addEventListener(Event.TRIGGERED, emblemButton_triggeredHandler);
	emblemButton.width = 144;
	emblemButton.height = 150;
	addChild(emblemButton);

	maxSwitcher = addSwitcher("max", 780, 10, roomData.max, 50, 20);
	minSwitcher = addSwitcher("min", 920, 0, roomData.min, 3000, 200);
	priSwitcher = addSwitcher("pri", 1060, 0, roomData.pri, 1, 1, "lobby_pri");

	errorDisplay = new RTLLabel( "", 0xFF0000, "center", null, false, null, 0.9 );
	errorDisplay.layoutData = new AnchorLayoutData( NaN, padding, 210, padding );
	addChild(errorDisplay);

	var updateButton:Button = new Button();
	updateButton.width = 340;
	updateButton.height = 160;
	updateButton.label = loc("lobby_edit");
	updateButton.styleName = MainTheme.STYLE_BUTTON_NEUTRAL;
	updateButton.layoutData = new AnchorLayoutData(NaN, NaN, padding, NaN, 0);
	updateButton.addEventListener(Event.TRIGGERED,  updateButton_triggeredHandler);
	addChild(updateButton);
}

private function addInput(controlName:String, text:String, positionY:int, controlHeight:int):CustomTextInput
{
	var inputControl:CustomTextInput = new CustomTextInput(SoftKeyboardType.DEFAULT, ReturnKeyLabel.DEFAULT);
	inputControl.promptProperties.fontSize = inputControl.textEditorProperties.fontSize = 0.8*appModel.theme.gameFontSize;
	//nameInput.maxChars = game.loginData.nameMaxLen ;
	inputControl.layoutData = new AnchorLayoutData(positionY, padding, NaN, padding);
	inputControl.prompt = loc("lobby_" + controlName);
	inputControl.height = controlHeight;
	inputControl.text = text;
	addChild(inputControl);
	return inputControl;
}
private function addSwitcher(controlName:String, positionY:int, min:int, value:int, max:int, stepInterval:int, prefix:String=null):Switcher
{
	var labelDisplay:RTLLabel = new RTLLabel(loc("lobby_" + controlName), 0, null, null, false, null, 0.75);
	labelDisplay.layoutData = new AnchorLayoutData( positionY + 25, appModel.isLTR?NaN:padding, NaN, appModel.isLTR?padding:NaN );
	addChild(labelDisplay);
	
	var switcher:Switcher = new Switcher(min, value, max, stepInterval);
	if ( prefix != null )
		switcher.labelStringFactory = function (value:int):String { return loc(prefix + "_" + value); }

	switcher.width = 360;
	switcher.height = 100;
	switcher.layoutData = new AnchorLayoutData( positionY, appModel.isLTR?padding:NaN, NaN, appModel.isLTR?NaN:padding);
	addChild(switcher);
	return switcher;
}

private function emblemButton_triggeredHandler(event:Event):void
{
	var emblemsPopup:EmblemsPopup = new EmblemsPopup();
	emblemsPopup.addEventListener(Event.SELECT, emblemsPopup_selectHandler);
	appModel.navigator.addPopup(emblemsPopup);
	function emblemsPopup_selectHandler(eve:Event):void {
		emblemsPopup.removeEventListener(Event.SELECT, emblemsPopup_selectHandler);
		emblemButton.value = eve.data as int;
	}
}

private function updateButton_triggeredHandler(event:Event):void
{
	if( bioInput.text.length < 10 || bioInput.text.length > 128 )
	{
		errorDisplay.text = loc("text_size_warn", [loc("lobby_bio"), 10, 128]);
		return;
	}
	var params:SFSObject = new SFSObject();
	if( roomData.max != maxSwitcher.value )
		params.putInt("max", maxSwitcher.value);
	if( roomData.min != minSwitcher.value )
		params.putInt("min", minSwitcher.value);
	if( roomData.pri != priSwitcher.value )
		params.putInt("pri", priSwitcher.value);
	if( roomData.pic != emblemButton.value )
		params.putInt("pic", emblemButton.value);
	if( roomData.bio != bioInput.text )
		params.putUtfString("bio", bioInput.text);
	// if( roomData.name != nameInput.text )
	// 	params.putUtfString("name", nameInput.text);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.LOBBY_EDIT, params, SFSConnection.instance.lobbyManager.lobby);
	SFSConnection.instance.lobbyManager.requestData(true, true);
	close();
}
}
}