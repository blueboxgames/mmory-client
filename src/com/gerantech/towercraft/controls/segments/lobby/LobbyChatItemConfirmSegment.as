package com.gerantech.towercraft.controls.segments.lobby
{
import com.gerantech.towercraft.controls.FastList;
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.buttons.IndicatorButton;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.themes.MainTheme;
import com.gt.towers.constants.MessageTypes;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import feathers.controls.Button;

import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayoutData;

import starling.events.Event;

public class LobbyChatItemConfirmSegment extends LobbyChatItemSegment
{
	
private var messageDisplay:RTLLabel;
private var acceptButton:Button;
private var declineButton:Button;

public function LobbyChatItemConfirmSegment(owner:FastList) { super(owner); }
override public function init():void
{
	super.init();
	height = 300;
	backgroundFactory();

	acceptButton = new Button();
	acceptButton.width = 280;
	acceptButton.height = 100;
	acceptButton.label = loc("popup_accept_label");
	acceptButton.styleName = MainTheme.STYLE_BUTTON_SMALL_NORMAL;
	acceptButton.name = MessageTypes.M16_COMMENT_JOIN_ACCEPT.toString();
	acceptButton.layoutData = new AnchorLayoutData(NaN, 160, 50);
	acceptButton.addEventListener(Event.TRIGGERED, buttons_triggeredHandler);
	addChild(acceptButton);
	
	declineButton = new Button();
	declineButton.width = 280;
	declineButton.height = 100;
	declineButton.label = loc("popup_cancel_label");
	declineButton.styleName = MainTheme.STYLE_BUTTON_SMALL_DANGER;
	declineButton.name = MessageTypes.M17_COMMENT_JOIN_REJECT.toString();
	declineButton.layoutData = new AnchorLayoutData(NaN, NaN, 50, 160);
	declineButton.addEventListener(Event.TRIGGERED, buttons_triggeredHandler);
	addChild(declineButton);
	
	var infoButton:IndicatorButton = new IndicatorButton();
	infoButton.label = "i";
	infoButton.height = infoButton.width = 64;
	infoButton.name = MessageTypes.M10_COMMENT_JOINT.toString();;
	infoButton.layoutData = new AnchorLayoutData(30, 50);
	infoButton.addEventListener(Event.TRIGGERED, buttons_triggeredHandler);
	addChild(infoButton);
}

private function buttons_triggeredHandler(event:Event):void
{
	dispatchEventWith( Event.TRIGGERED, false, event.currentTarget );
}

override public function commitData(_data:ISFSObject, index:int):void
{
	super.commitData(_data, index);
	messageDisplayFactory();
}

private function messageDisplayFactory():void
{
	if( messageDisplay == null )
	{
		messageDisplay = new RTLLabel(null, MainTheme.PRIMARY_BACKGROUND_COLOR, "center", null, false, null, 0.8);
		messageDisplay.layoutData = new AnchorLayoutData(40, 20, NaN, 20);
		addChildAt(messageDisplay, 1);
	}
	messageDisplay.text = loc("lobby_join_request", [data.getUtfString("on")]);
}
}
}