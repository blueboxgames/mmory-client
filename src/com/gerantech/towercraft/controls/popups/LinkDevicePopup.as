package com.gerantech.towercraft.controls.popups
{
import com.gerantech.extensions.NativeAbilities;
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.overlays.TransitionData;
import com.gerantech.towercraft.controls.texts.CustomTextInput;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.events.LoadingEvent;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.vo.UserData;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.data.SFSObject;
import flash.desktop.Clipboard;
import flash.desktop.ClipboardFormats;
import flash.geom.Rectangle;
import flash.text.ReturnKeyLabel;
import flash.text.SoftKeyboardType;
import feathers.layout.AnchorLayoutData;
import starling.animation.Transitions;
import starling.events.Event;

public class LinkDevicePopup extends SimplePopup
{
private var errorDisplay:RTLLabel;
private var restoreCodeInput:CustomTextInput;

public function LinkDevicePopup(){}
override protected function initialize():void
{
	transitionIn = new TransitionData();
	transitionIn.transition = Transitions.EASE_OUT_BACK;
	transitionIn.sourceBound = new Rectangle(stage.stageWidth*0.10, stage.stageHeight*0.3, stage.stageWidth*0.8, stage.stageHeight*0.4);
	transitionIn.destinationBound = new Rectangle(stage.stageWidth*0.15, stage.stageHeight*0.25, stage.stageWidth*0.7, stage.stageHeight*0.5);
	
	transitionOut = new TransitionData();
	transitionOut.sourceAlpha = 1;
	transitionOut.destinationAlpha = 0;
	transitionOut.transition = Transitions.EASE_IN;
	transitionOut.sourceBound = transitionIn.destinationBound
	transitionOut.destinationBound = transitionIn.sourceBound
	super.initialize();
	
	var padding:int = 36;
	var oldDeviceLabel:ShadowLabel = new ShadowLabel(loc("popup_link_old_label"), 1, 0, "center");
	oldDeviceLabel.layoutData = new AnchorLayoutData(padding, NaN, NaN, NaN, 0);
	addChild(oldDeviceLabel);
	
	var getCodeButton:CustomButton = new CustomButton();
	getCodeButton.label = loc("popup_link_old_button");
	getCodeButton.width = width * 0.7;
	getCodeButton.addEventListener(Event.TRIGGERED, getCodeButtton_triggeredHandler);
	getCodeButton.layoutData = new AnchorLayoutData(padding*3.5, NaN, NaN, NaN, 0);
	addChild(getCodeButton);
	
	var getRestoreCode:RTLLabel = new RTLLabel (loc("popup_link_old_message"), 1, "center", null, false, null, 0.8);
	getRestoreCode.alpha = 0.7;
	getRestoreCode.layoutData = new AnchorLayoutData(padding*8, NaN, NaN, NaN, 0);
	addChild(getRestoreCode);
	
	// new 
	var newDeviceLabel:ShadowLabel = new ShadowLabel(loc("popup_link_new_label"), 1, 0, "center");
	newDeviceLabel.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, 0);
	addChild(newDeviceLabel);
	
	restoreCodeInput = new CustomTextInput(SoftKeyboardType.DEFAULT, ReturnKeyLabel.DEFAULT);
	restoreCodeInput.layoutData = new AnchorLayoutData(NaN, NaN, padding*8, NaN, 0);
	restoreCodeInput.prompt = loc("popup_link_new_promp");
	addChild(restoreCodeInput);
	
	var sendCodeButton:CustomButton = new CustomButton();
	sendCodeButton.label = loc("popup_link_new_button");
	sendCodeButton.width = width * 0.4;
	sendCodeButton.layoutData = new AnchorLayoutData(NaN, NaN, padding*3, NaN, 0);
	sendCodeButton.addEventListener(Event.TRIGGERED, sendCodeButton_triggeredHandler);
	addChild(sendCodeButton);
	
	errorDisplay = new RTLLabel("", 0xFF0000, null, null, true, null, 0.8);
	errorDisplay.layoutData = new AnchorLayoutData(NaN, NaN, padding, NaN, 0);
}

private function getCodeButtton_triggeredHandler():void
{
	var params:SFSObject = new SFSObject();
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_getCodeHandler);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.RESTORE, params);
}

protected function sfs_getCodeHandler(event:SFSEvent):void
{
	if( event.params.cmd != SFSCommands.RESTORE )
		return;
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_getCodeHandler);
	//trace(event.params.params.getDump())
	Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, event.params.params.getText("restoreCode"));
	
	var resultPopup:ConfirmPopup = new ConfirmPopup(loc("popup_link_old_select"), loc("popup_link_old_copy_label"), loc("popup_link_old_share_label"));
	resultPopup.addEventListener(Event.SELECT, function():void{Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, event.params.params.getText("restoreCode")); appModel.navigator.addLog(loc("popup_link_old_copy")); });
	resultPopup.addEventListener(Event.CANCEL, function():void{NativeAbilities.instance.shareText( loc("popup_link_old_share_title"), loc("popup_link_old_share_message", [event.params.params.getText("restoreCode")])); });
	appModel.navigator.addPopup(resultPopup);
	//close();
}


private function sendCodeButton_triggeredHandler():void
{
	if ( restoreCodeInput.text.length == 0 )
	{
		addChild(errorDisplay);
		errorDisplay.text = loc("popup_link_new_invalid");
		return;
	}
	var params:SFSObject = new SFSObject();
	params.putText("code", restoreCodeInput.text);
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_sendCodeHandler);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.RESTORE, params);
}
protected function sfs_sendCodeHandler(event:SFSEvent):void
{
	if( event.params.cmd != SFSCommands.RESTORE )
		return;
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_sendCodeHandler);
	
	var params:SFSObject = event.params.params as SFSObject;//trace(params.getDump())
	if ( params.getInt("id") == -1 || params.getInt("id") == player.id || !params.containsKey("password") )
	{
		addChild(errorDisplay);
		errorDisplay.text = loc("popup_link_new_invalid");
		return;
	}
	
	UserData.instance.id = event.params.params.getInt("id");
	UserData.instance.password = event.params.params.getText("password");
	UserData.instance.save();
	appModel.loadingManager.dispatchEvent(new LoadingEvent(LoadingEvent.FORCE_RELOAD));
	close();
}
}
}