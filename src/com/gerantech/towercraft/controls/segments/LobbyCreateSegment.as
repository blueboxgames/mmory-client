package com.gerantech.towercraft.controls.segments
{
import com.gerantech.mmory.core.constants.MessageTypes;
import com.gerantech.towercraft.controls.buttons.EmblemButton;
import com.gerantech.towercraft.controls.buttons.MMOryButton;
import com.gerantech.towercraft.controls.popups.EmblemsPopup;
import com.gerantech.towercraft.controls.switchers.Switcher;
import com.gerantech.towercraft.controls.texts.CustomTextInput;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.mmory.core.constants.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.data.SFSObject;

import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.RelativePosition;

import flash.text.ReturnKeyLabel;
import flash.text.SoftKeyboardType;

import starling.events.Event;

public class LobbyCreateSegment extends Segment
{
private var padding:int;
private var controlWidth:int;

private var nameInput:CustomTextInput;
private var bioInput:CustomTextInput;
private var maxSwitcher:Switcher;
private var minSwitcher:Switcher;
private var errorDisplay:RTLLabel;
private var emblemButton:EmblemButton;

private var privacySwitcher:Switcher;

public function LobbyCreateSegment(){}
override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout();
	
	padding = 110;
	controlWidth = 400;
	
	var tilteDisplay:RTLLabel = new RTLLabel(loc("lobby_create_message"), 1, "center", null, true, null, 0.8);
	tilteDisplay.layoutData = new AnchorLayoutData(padding, padding, NaN, padding);
	addChild(tilteDisplay);

	nameInput = addInput("name", 290, 100);
	bioInput = addInput("bio", 420, 240);
	
	// lobby emblem
	var emblemLabel:RTLLabel = new RTLLabel( loc("lobby_pic"), 1, null, null, false, null, 0.75);
	emblemLabel.layoutData = new AnchorLayoutData(860, appModel.isLTR?NaN:padding, NaN, appModel.isLTR?padding:NaN);
	addChild(emblemLabel);
	
	emblemButton = new EmblemButton(0);
	emblemButton.layoutData = new AnchorLayoutData(710, appModel.isLTR?padding:NaN, NaN, appModel.isLTR?NaN:padding);
	emblemButton.addEventListener(Event.TRIGGERED, emblemButton_triggeredHandler);
	emblemButton.width = 144;
	emblemButton.height = 150;
	addChild(emblemButton);


	maxSwitcher = addSwitcher("max", 900, 100, 10, 30, 50, 20);
	minSwitcher = addSwitcher("min", 1030, 100, 0, 200, 3000, 200);
	privacySwitcher = addSwitcher("pri", 1160, 100, 0, 0, 1, 1, "lobby_pri");
	
	
	errorDisplay = new RTLLabel(null, 0xFF0000, "center", null, false, null, 0.9);
	errorDisplay.layoutData = new AnchorLayoutData(NaN, padding, 50, padding);
	addChild(errorDisplay);

	var t:int = game.lobby.get_createRequirements().keys()[0];
	var v:int = game.lobby.get_createRequirements().get(t);
	var createButton:MMOryButton = new MMOryButton();
	createButton.width = 340;
	createButton.height = 172;
	createButton.messagePosition = RelativePosition.TOP;
	createButton.iconSize = MMOryButton.DEFAULT_ICON_SIZE;
	// createButton.isEnabled = game.lobby.creatable();
	createButton.message = loc("lobby_create_button");
	createButton.label = MMOryButton.getLabel(t, v);
	createButton.iconTexture = MMOryButton.getIcon(t, v);
	createButton.layoutData = new AnchorLayoutData(NaN, NaN, 150, NaN, 0);
	createButton.addEventListener(Event.TRIGGERED,  createButton_triggeredHandler);
	addChild(createButton);
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

private function createButton_triggeredHandler(event:Event):void
{
	if( nameInput.text.length < 4 || nameInput.text.length > 16 )
	{
		errorDisplay.text = loc("text_size_warn", [loc("lobby_name"), 4, 16]);
		return;
	}
	if( bioInput.text.length < 10 || bioInput.text.length > 128 )
	{
		errorDisplay.text = loc("text_size_warn", [loc("lobby_bio"), 10, 128]);
		return;
	}
	if( minSwitcher.value > Math.max(0, player.get_point()-200) )
	{
		errorDisplay.text = loc("lobby_create_error_message_point", [200]);
		return;
	}
	errorDisplay.text = "";
	var params:SFSObject = new SFSObject();
	params.putUtfString("name", nameInput.text);
	params.putUtfString("bio", bioInput.text);
	params.putInt("pri", privacySwitcher.value);
	params.putInt("max", maxSwitcher.value);
	params.putInt("min", minSwitcher.value);
	params.putInt("pic", 10);
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnectionroomCreateRresponseHandler);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.LOBBY_CREATE, params);
}		

private function addInput(controlName:String, positionY:int, controlHeight:int):CustomTextInput
{
	var inputControl:CustomTextInput = new CustomTextInput(SoftKeyboardType.DEFAULT, ReturnKeyLabel.DEFAULT);
	inputControl.promptProperties.fontSize = inputControl.textEditorProperties.fontSize = 0.8*appModel.theme.gameFontSize;
	//nameInput.maxChars = game.loginData.nameMaxLen ;
	inputControl.prompt = loc("lobby_"+controlName);
	inputControl.layoutData = new AnchorLayoutData(positionY, padding, NaN, padding);
	inputControl.height = controlHeight;
	addChild(inputControl);
	return inputControl;
}
private function addSwitcher(controlName:String, positionY:int, controlHeight:int, min:int, value:int, max:int, stepInterval:int, prefix:String=null):Switcher
{
	var labelDisplay:RTLLabel = new RTLLabel(loc("lobby_" + controlName), 1, null, null, false, null, 0.75);
	labelDisplay.layoutData = new AnchorLayoutData( positionY+controlHeight/4, appModel.isLTR?NaN:padding, NaN, appModel.isLTR?padding:NaN );
	addChild(labelDisplay);
	
	var switcher:Switcher = new Switcher(min, value, max, stepInterval);
	if ( prefix != null )
		switcher.labelStringFactory = function (value:int):String { return loc(prefix + "_" + value); }

	switcher.width = controlWidth;
	switcher.layoutData = new AnchorLayoutData( positionY, appModel.isLTR?padding:NaN, NaN, appModel.isLTR?NaN:padding);
	//switcher.layoutData = new AnchorLayoutData( positionY, appModel.isLTR?padding:controlWidth+padding*2, NaN, appModel.isLTR?controlWidth+padding*2:padding );
	switcher.height = controlHeight;
	addChild(switcher);
	return switcher;
}
protected function sfsConnectionroomCreateRresponseHandler(event:SFSEvent):void
{
	if( event.params.cmd != SFSCommands.LOBBY_CREATE )
		return;
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnectionroomCreateRresponseHandler);
	var data:SFSObject = event.params.params as SFSObject;
	if( data.getInt("response") == MessageTypes.RESPONSE_SUCCEED )
	{
		game.lobby.create();
		dispatchEventWith(Event.UPDATE, true);
		return;
	}
	errorDisplay.text = loc("lobby_create_" + data.getInt("response"));
}
}
}