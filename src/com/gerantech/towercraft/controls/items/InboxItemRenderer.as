package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.themes.MainTheme;
import com.gerantech.towercraft.utils.StrUtils;
import com.gt.towers.constants.MessageTypes;
import com.smartfoxserver.v2.entities.data.SFSObject;

import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;
import starling.events.Event;


public class InboxItemRenderer extends AbstractTouchableListItemRenderer
{
private static const READ_TEXT_COLOR:uint = 0xEEFFFF;
private static const TWEEN_TIME:Number = 0.3;

private var offsetY:Number;
private var padding:int;
private var senderLayout:AnchorLayoutData;
private var messageLayout:AnchorLayoutData;
private var dateLayout:AnchorLayoutData;

private var mySkin:Image;
private var senderDisplay:RTLLabel;
private var messageDisplay:RTLLabel;
private var dateDisplay:RTLLabel;
private var date:Date;
private var acceptButton:CustomButton;
private var declineButton:CustomButton;
private var message:SFSObject;
private var readOnSelect:Boolean;
private var infoButton:com.gerantech.towercraft.controls.buttons.CustomButton;
private var adminMode:Boolean;

public function InboxItemRenderer(readOnSelect:Boolean = true, adminMode:Boolean = false)
{
	this.readOnSelect = readOnSelect;
	this.adminMode = adminMode;
}

override protected function initialize():void
{
	super.initialize();
	
	layout = new AnchorLayout();
	height = 140;
	padding = 32;
	offsetY = -8
	date = new Date();
	
	mySkin = new Image(appModel.theme.itemRendererDisabledSkinTexture);
	mySkin.scale9Grid = MainTheme.ITEM_RENDERER_SCALE9_GRID;
	backgroundSkin = mySkin;
	
	senderLayout = new AnchorLayoutData( NaN, appModel.isLTR?NaN:padding, NaN, appModel.isLTR?padding:NaN , NaN, offsetY);
	senderDisplay = new RTLLabel("", 1, null, null, false, null, 0.72);
	senderDisplay.width = padding * 12;
	senderDisplay.layoutData = senderLayout;
	addChild(senderDisplay);

	messageLayout = new AnchorLayoutData( NaN, padding*(appModel.isLTR?6:8), NaN, padding*(appModel.isLTR?8:6) , NaN, offsetY);
	messageDisplay = new RTLLabel("", 0xDDEEEE, "justify", null, true, null, 0.6);
	messageDisplay.wordWrap = false;
	messageDisplay.touchable = false;
	messageDisplay.layoutData = messageLayout;
	addChild(messageDisplay);
	
	dateLayout = new AnchorLayoutData( NaN, appModel.isLTR?padding:NaN, NaN, appModel.isLTR?NaN:padding, NaN, 0 );
	dateDisplay = new RTLLabel("", READ_TEXT_COLOR, null, null, false, null, 0.6);
	dateDisplay.touchable = false;
	dateDisplay.alpha = 0.8;
	dateDisplay.layoutData = dateLayout;
	addChild(dateDisplay);
	
	acceptButton = new CustomButton();
	acceptButton.alpha = 0;
	acceptButton.height = padding * 3;
	acceptButton.label = loc("popup_accept_label");
	acceptButton.layoutData = new AnchorLayoutData( NaN, NaN, padding, padding);
	acceptButton.addEventListener(Event.TRIGGERED, buttons_eventHandler);
	
	declineButton = new CustomButton();
	declineButton.alpha = 0;
	declineButton.height = padding * 3;
	declineButton.style = "danger";
	declineButton.label = loc("popup_cancel_label");
	declineButton.layoutData = new AnchorLayoutData( NaN, NaN, padding, padding*9);
	declineButton.addEventListener(Event.TRIGGERED, buttons_eventHandler);
	
	if( adminMode )
	{
		infoButton = new CustomButton();
		infoButton.height = infoButton.width = padding * 2;
		infoButton.label = "i";
		infoButton.layoutData = new AnchorLayoutData( padding * 0.5, padding * 0.5 );
		infoButton.addEventListener(Event.TRIGGERED, buttons_eventHandler);
	}
}

override protected function commitData():void
{
	super.commitData();
	if( _data == null || _owner == null )
		return;

	message = _data as SFSObject;
	date.time = message.getInt("utc") * 1000;
	var txt:String = message.getUtfString("text");
	messageDisplay.text = txt.substr(0,2)=="__"?loc(txt.substr(2), [message.getUtfString("sender")]):txt;
	dateDisplay.text = StrUtils.getDateString(date);
	acceptButton.label = loc(message.getShort("type") == MessageTypes.M50_URL ? "go_label" : "popup_accept_label");
	updateSkin();
}

private function updateSkin():void
{
	if( isSelected )
		mySkin.texture = appModel.theme.itemRendererUpSkinTexture;
	else
	{
		switch(message.getShort("read"))
		{
			case 1:		mySkin.texture = appModel.theme.itemRendererDisabledSkinTexture; break;
			case 2:		mySkin.texture = appModel.theme.itemRendererDangerSkinTexture; break;
			default:	mySkin.texture = appModel.theme.itemRendererSelectedSkinTexture; break;
		}
	}
	senderDisplay.text = message.getUtfString("sender") + (isSelected && adminMode ? ("  " + message.getInt("senderId")) : "");
	senderDisplay.alpha = message.getShort("read")==0 || isSelected ? 1 : 0.8;
	messageDisplay.alpha = message.getShort("read")==0 || isSelected ? 0.92 : 0.8;
}

override public function set isSelected(value:Boolean):void
{
	var needSchange:Boolean = super.isSelected != value
	super.isSelected = value;
	if( !needSchange )
		return;
	updateSkin();
	
	if( readOnSelect && value && message.getShort("read") == 0 )
	{
		message.putShort("read", 1)
		_owner.dispatchEventWith(Event.OPEN, false, message);
	}
	
	senderLayout.top = value ? padding*0.8 : NaN;
	//senderDisplay.width = padding*(value?12:6.4);
	senderLayout.verticalCenter = value ? NaN : offsetY;
	if( adminMode )
	{
		senderLayout.left = appModel.isLTR ? (value ?3:1) * padding : NaN;
		senderLayout.right = appModel.isLTR ? NaN : (value ?3:1) * padding;
	}
	
	messageDisplay.height = value ? NaN : 40;
	messageLayout.top = value ? padding*2.4 : NaN;
	messageLayout.verticalCenter = value ? NaN : offsetY;
	messageLayout.right = padding*(value?1:(appModel.isLTR?6:8));
	messageLayout.left = padding*(value?1:(appModel.isLTR?8:6));
	
	messageDisplay.wordWrap = value;
	messageDisplay.validate();
	
	dateLayout.top = value ? padding*0.6 : NaN;
	dateLayout.right = value ? (appModel.isLTR?padding*0.7:NaN) : (appModel.isLTR?padding:NaN);
	dateLayout.left = value ? (appModel.isLTR?NaN:padding*0.7) : (appModel.isLTR?NaN:padding);
	dateLayout.verticalCenter = value ? NaN : offsetY;
	dateDisplay.text = StrUtils.getDateString(date, value);

	if( !value )
	{
		acceptButton.removeFromParent();
		declineButton.removeFromParent();
		if( adminMode )
			infoButton.removeFromParent();
	}
	
	var hasButton:Boolean = MessageTypes.isConfirm(message.getShort("type")) || message.getShort("type") == MessageTypes.M50_URL;
	var _h:Number = value?(messageDisplay.height+padding*(4/messageDisplay.numLines)+padding+(hasButton?declineButton.height:0) ):(140);
	Starling.juggler.tween(this, TWEEN_TIME, {height:_h, transition:Transitions.EASE_IN_OUT, onComplete:tweenCompleted, onCompleteArgs:[value]});
	function tweenCompleted(_selected:Boolean):void
	{
		if( !value )
			return;
		
		if( hasButton )
		{
			appear(acceptButton);
			if( MessageTypes.isConfirm(message.getShort("type")) )
				appear(declineButton)
		}
		if( adminMode )
			appear(infoButton);	
	}
}

private function appear(button:CustomButton):void
{
	button.alpha = 0;
	addChild(button);
	Starling.juggler.tween(button, TWEEN_TIME, {alpha:1});
}

private function buttons_eventHandler(event:Event):void
{
	if( event.currentTarget == acceptButton )
		_owner.dispatchEventWith(Event.SELECT, false, message);
	else if( event.currentTarget == declineButton )
		_owner.dispatchEventWith(Event.CANCEL, false, message);
	else if( event.currentTarget == infoButton )
		_owner.dispatchEventWith(Event.READY, false, message);
}

override public function dispose():void
{
	Starling.juggler.removeTweens(this);
	Starling.juggler.removeTweens(acceptButton);
	Starling.juggler.removeTweens(declineButton);
	super.dispose();
}
}
}