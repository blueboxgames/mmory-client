package com.gerantech.towercraft.controls.popups
{
import com.gerantech.towercraft.controls.buttons.MMOryButton;
import com.gerantech.towercraft.controls.overlays.TransitionData;
import com.gerantech.towercraft.controls.screens.DashboardScreen;
import com.gerantech.towercraft.controls.segments.ExchangeSegment;
import com.gerantech.towercraft.controls.texts.CustomTextInput;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.utils.StrUtils;
import com.gt.towers.constants.ExchangeType;
import com.gt.towers.constants.MessageTypes;
import com.gt.towers.constants.ResourceType;
import com.gt.towers.exchanges.ExchangeItem;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.data.SFSObject;
import feathers.events.FeathersEventType;
import flash.geom.Rectangle;
import flash.text.ReturnKeyLabel;
import flash.text.SoftKeyboardType;
import flash.utils.setTimeout;
import starling.core.Starling;
import starling.events.Event;

public class SelectNamePopup extends ConfirmPopup
{
private var errorDisplay:RTLLabel;
private var textInput:CustomTextInput;
private var eItem:ExchangeItem;
public function SelectNamePopup()
{
	eItem = exchanger.items.get(ExchangeType.C42_RENAME);
	
	super(loc((player.nickName != "guest" && eItem.numExchanges == 0) ? "popup_select_name_title_warned" :  "popup_select_name_title"), 
	(player.nickName != "guest" && eItem.numExchanges > 0) ? exchanger.getRequierement(eItem, timeManager.now).get(ResourceType.R4_CURRENCY_HARD).toString() : loc("popup_register_label"),
	null);
}

override protected function initialize():void
{
	// create transition in data
	var _h:int = 540;
	var _p:int = 84;
	transitionIn = new TransitionData();
	transitionOut = new TransitionData();
	transitionOut.destinationAlpha = 0;
	transitionIn.sourceBound = transitionOut.destinationBound = new Rectangle(_p,	stageHeight* 0.5 - _h * 0.4,	stageWidth - _p * 2,	_h * 0.8);
	transitionOut.sourceBound = transitionIn.destinationBound = new Rectangle(_p,	stageHeight* 0.5 - _h * 0.5,	stageWidth - _p * 2,	_h * 1.0);

	super.initialize();
	closeWithKeyboard = closeOnOverlay = player.nickName != "guest";

	textInput = new CustomTextInput(SoftKeyboardType.DEFAULT, ReturnKeyLabel.GO);
	textInput.maxChars = game.loginData.nameMaxLen ;
	if( player.nickName == "guest" )
		textInput.prompt = loc( "popup_select_name_prompt" );
	else
		textInput.text = player.nickName;
	textInput.addEventListener(Event.CHANGE, textInput_changeHandler);
	textInput.addEventListener(FeathersEventType.ENTER, acceptButton_triggeredHandler);
	container.addChild(textInput);
	
	errorDisplay = new RTLLabel("", 0xFF0000, "center");
	errorDisplay.alpha = 0;
	container.addChild(errorDisplay);
	
	acceptButton.isEnabled = false;
	acceptButton.iconSize = MMOryButton.DEFAULT_ICON_SIZE;
	acceptButton.width = 360;
	if( closeOnOverlay && eItem.numExchanges > 0 )
		acceptButton.iconTexture = Assets.getTexture("res-" + ResourceType.R4_CURRENCY_HARD, "gui");
	declineButton.removeFromParent();
	rejustLayoutByTransitionData();
}

protected function textInput_changeHandler(event:Event):void
{
	acceptButton.isEnabled = textInput.text.length >= game.loginData.nameMinLen;
}

protected override function acceptButton_triggeredHandler(event:Event):void
{
	var selectedName:String = textInput.text;
	var nameLen:int = selectedName.length;
	if ( nameLen < game.loginData.nameMinLen || nameLen > game.loginData.nameMaxLen )
	{
		showError(loc("popup_select_name_-5", [game.loginData.nameMinLen, game.loginData.nameMaxLen]));
		return;
	}
	
	if( isBad(selectedName) )
	{
		showError(loc("popup_select_name_-1"));
		return;
	}
	var sfs:SFSObject = SFSObject.newInstance();
	sfs.putUtfString( "name", selectedName );
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_extensionResponseHandler);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.SELECT_NAME, sfs );
}

protected function sfsConnection_extensionResponseHandler(event:SFSEvent):void
{
	if( event.params.cmd != SFSCommands.SELECT_NAME )
		return;
	
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_extensionResponseHandler);
	var result:SFSObject = event.params.params as SFSObject;trace(result.getDump())
	var response:int = result.getInt("response");
	
	if( response != MessageTypes.RESPONSE_SUCCEED )
	{
		if( response == 2 )
		{
			DashboardScreen.TAB_INDEX = 0;
			ExchangeSegment.SELECTED_CATEGORY = 3;
			appModel.navigator.addLog(loc("popup_select_name_2"));
			setTimeout(appModel.navigator.popScreen, 700);
			close();
			return;
		}
		showError(loc("popup_select_name_" + response, [game.loginData.nameMinLen, game.loginData.nameMaxLen] ));
		return;
	}
	
	if( player.nickName != "guest" )
		exchanger.exchange(eItem, 0);
	player.nickName = textInput.text;
	dispatchEventWith( Event.COMPLETE );
	close();
}

private function showError(message:String) : void 
{
	errorDisplay.text = message;
	errorDisplay.alpha = 1;
	Starling.juggler.tween(errorDisplay, 1, {delay:2, alpha:0});
}

private function isBad(name:String) : Boolean
{
	name = StrUtils.getSimpleString(name.toLowerCase());
	if( name.substr(name.length - 2) == " " || name.substr(0, 1) == " " )
		return true;
	
	var badNames:Array = ["  ", "admin", "super-", "root", "koot", "oot", "koo", "ko ", "manager", "bot", "sex", "ادمین", "کوت", "سازنده", "مدیر", "کیر", "کون", "جنده", "بات"];
	for each( var b:String in badNames )
		if( name.search(b) > -1 )
			return true;
	return false;
}

override public function dispose() : void
{
	Starling.juggler.removeTweens(errorDisplay);
	super.dispose();
}
}
}