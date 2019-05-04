package com.gerantech.towercraft.controls.popups
{
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.buttons.EmblemButton;
import com.gerantech.towercraft.controls.switchers.Switcher;
import com.gerantech.towercraft.controls.texts.CustomTextInput;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.smartfoxserver.v2.entities.data.SFSObject;
import feathers.layout.AnchorLayoutData;
import flash.geom.Rectangle;
import flash.text.ReturnKeyLabel;
import flash.text.SoftKeyboardType;
import starling.events.Event;

public class LobbyEditPopup extends SimplePopup
{
private var roomData:Object;
private var errorDisplay:RTLLabel;
private var emblemButton:EmblemButton;
private var minPointSwitcher:Switcher;
private var maxMembersSwitcher:Switcher;
private var bioInput:CustomTextInput;
private var privacySwitcher:Switcher;
public function LobbyEditPopup(roomData:Object) { this.roomData = roomData; }
protected override function initialize():void
{
	super.initialize();
	transitionOut.destinationBound = transitionIn.sourceBound = new Rectangle(stage.stageWidth*0.1, stage.stageHeight*0.10, stage.stageWidth*0.8, stage.stageHeight*0.8);
	transitionOut.sourceBound = transitionIn.destinationBound = new Rectangle(stage.stageWidth*0.1, stage.stageHeight*0.15, stage.stageWidth*0.8, stage.stageHeight*0.7);
	rejustLayoutByTransitionData();
	
	var titleDisplay:ShadowLabel = new ShadowLabel(loc("lobby_edit_label"), 1, 0);
	titleDisplay.layoutData = new AnchorLayoutData( padding, NaN, NaN, NaN, 0);
	addChild(titleDisplay);
	
	bioInput = new CustomTextInput(SoftKeyboardType.DEFAULT, ReturnKeyLabel.DEFAULT);
	bioInput.promptProperties.fontSize = bioInput.textEditorProperties.fontSize = 0.8*appModel.theme.gameFontSize;
	bioInput.prompt = loc("lobby_bio");
	bioInput.text = roomData.bio;
	bioInput.layoutData = new AnchorLayoutData( padding*3.6, padding, NaN, padding );
	bioInput.height = padding * 7.6;
	addChild(bioInput);
	
	// lobby emblem
	var emblemLabel:RTLLabel = new RTLLabel( loc("lobby_pic"), 0, null, null, false, null, 0.8 );
	emblemLabel.layoutData = new AnchorLayoutData( padding*13.5, appModel.isLTR?NaN:padding, NaN, appModel.isLTR?padding:NaN );
	addChild(emblemLabel);
	
	emblemButton = new EmblemButton(roomData.pic as int);
	emblemButton.layoutData = new AnchorLayoutData( padding*12, appModel.isLTR?padding:NaN, NaN, appModel.isLTR?NaN:padding);
	emblemButton.width = padding * 4;
	emblemButton.height = padding * 4.2;
	emblemButton.addEventListener(Event.TRIGGERED, emblemButton_triggeredHandler);
	addChild(emblemButton);
	
	// max mambers allowed
	var maxMemsLabel:RTLLabel = new RTLLabel( loc("lobby_max"), 0, null, null, false, null, 0.8 );
	maxMemsLabel.layoutData = new AnchorLayoutData( padding*17.7, appModel.isLTR?NaN:padding, NaN, appModel.isLTR?padding:NaN );
	addChild(maxMemsLabel);	
	
	maxMembersSwitcher = new Switcher(10, roomData.max, 50, 20);
	maxMembersSwitcher.width = padding * 12;
	maxMembersSwitcher.height = padding * 3;
	maxMembersSwitcher.layoutData = new AnchorLayoutData( padding*17, appModel.isLTR?padding:NaN, NaN, appModel.isLTR?NaN:padding);
	addChild(maxMembersSwitcher);
	
	// min points allowed
	var minPointLabel:RTLLabel = new RTLLabel( loc("lobby_min"), 0, null, null, false, null, 0.8 );
	minPointLabel.layoutData = new AnchorLayoutData( padding*21.7, appModel.isLTR?NaN:padding, NaN, appModel.isLTR?padding:NaN );
	addChild(minPointLabel);
	
	minPointSwitcher = new Switcher(0, roomData.min, 3000, 200);
	minPointSwitcher.width = padding * 12;
	minPointSwitcher.height = padding * 3;
	minPointSwitcher.layoutData = new AnchorLayoutData( padding*21, appModel.isLTR?padding:NaN, NaN, appModel.isLTR?NaN:padding);
	addChild(minPointSwitcher);
	
	// privacy mode
	var privacyLabel:RTLLabel = new RTLLabel( loc("lobby_pri"), 0, null, null, false, null, 0.8 );
	privacyLabel.layoutData = new AnchorLayoutData( padding*25.7, appModel.isLTR?NaN:padding, NaN, appModel.isLTR?padding:NaN );
	addChild(privacyLabel);
	
	privacySwitcher = new Switcher(0, roomData.pri, 1, 1);
	privacySwitcher.labelStringFactory = function (value:int):String { return loc("lobby_pri_" + value); }
	privacySwitcher.width = padding * 12;
	privacySwitcher.height = padding * 3;
	privacySwitcher.layoutData = new AnchorLayoutData( padding*25, appModel.isLTR?padding:NaN, NaN, appModel.isLTR?NaN:padding);
	addChild(privacySwitcher);
	
	errorDisplay = new RTLLabel( "", 0xFF0000, "center", null, false, null, 0.9 );
	errorDisplay.layoutData = new AnchorLayoutData( NaN, padding, padding*6, padding );
	addChild(errorDisplay);

	var updateButton:CustomButton = new CustomButton();
	updateButton.width = padding * 8;
	updateButton.label = loc("lobby_edit");
	updateButton.layoutData = new AnchorLayoutData(NaN, NaN, padding, NaN, 0);
	updateButton.addEventListener(Event.TRIGGERED,  updateButton_triggeredHandler);
	addChild(updateButton);
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
	if( roomData.max != maxMembersSwitcher.value )
		params.putInt("max", maxMembersSwitcher.value);
	if( roomData.min != minPointSwitcher.value )
		params.putInt("min", minPointSwitcher.value);
	if( roomData.pri != privacySwitcher.value )
		params.putInt("pri", privacySwitcher.value);
	if( roomData.pic != emblemButton.value )
		params.putInt("pic", emblemButton.value);
	if( roomData.bio != bioInput.text )
		params.putUtfString("bio", bioInput.text);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.LOBBY_EDIT, params, SFSConnection.instance.lobbyManager.lobby);
	SFSConnection.instance.lobbyManager.requestData(true, true);
	close();
}
}
}