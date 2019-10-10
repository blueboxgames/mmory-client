package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.controls.buttons.IndicatorButton;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.themes.MainTheme;
import com.gerantech.towercraft.utils.StrUtils;
import com.smartfoxserver.v2.entities.data.SFSObject;

import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

import starling.display.Image;
import starling.events.Event;

public class InfractionItemRenderer extends AbstractTouchableListItemRenderer
{
private var offsetY:Number;
private var padding:int;
private var senderLayout:AnchorLayoutData;
private var messageLayout:AnchorLayoutData;
private var dateLayout:AnchorLayoutData;
private var mySkin:Image;
private var senderDisplay:RTLLabel;
private var messageDisplay:RTLLabel;
private var dateDisplay:RTLLabel;
private var message:SFSObject;
private var banButton:IndicatorButton;
private var deleteButton:IndicatorButton;
private var offenderButton:IndicatorButton;
private var reporterButton:IndicatorButton;

public function InfractionItemRenderer(height:Number = 320){ this.height = height; }
override protected function initialize():void
{
	super.initialize();
	
	layout = new AnchorLayout();
	padding = 12;
	
	mySkin = new Image(appModel.theme.itemRendererBulgyUpSkinTexture);
	mySkin.scale9Grid = MainTheme.ITEM_RENDERER_BULGY_SCALE9_GRID;
	backgroundSkin = mySkin;
	
	offenderButton = new IndicatorButton();
	offenderButton.height = 70;
	offenderButton.width = 420;
	offenderButton.layoutData = new AnchorLayoutData(NaN, padding, 20);
	offenderButton.addEventListener(Event.TRIGGERED, buttons_eventHandler);
	addChild(offenderButton);
	
	reporterButton = new IndicatorButton();
	reporterButton.height = 70;
	reporterButton.width = 280;
	reporterButton.layoutData = new AnchorLayoutData(NaN, padding + 432, 20);
	reporterButton.addEventListener(Event.TRIGGERED, buttons_eventHandler);
	addChild(reporterButton);
	
	banButton = new IndicatorButton();
	//banButton.iconPosition.x = 7;
	//banButton.icon = appModel.assets.getTexture("settings-5");
	banButton.width = banButton.height = 100;
	banButton.styleName = MainTheme.STYLE_BUTTON_SMALL_DANGER;
	banButton.layoutData = new AnchorLayoutData(NaN, NaN, 20, padding );
	banButton.addEventListener(Event.TRIGGERED, buttons_eventHandler);
	addChild(banButton);
	
	deleteButton = new IndicatorButton();
	//deleteButton.iconPosition.x = 7;
	//deleteButton.icon = appModel.assets.getTexture("improve-1");
	deleteButton.width = deleteButton.height = 100;
	deleteButton.styleName = MainTheme.STYLE_BUTTON_SMALL_HILIGHT;
	deleteButton.layoutData = new AnchorLayoutData(NaN, NaN, 20, 96 + padding * 2 );
	deleteButton.addEventListener(Event.TRIGGERED, buttons_eventHandler);
	addChild(deleteButton);
	
	senderDisplay = new RTLLabel(null, 0, null, null, false, null, 0.72);
	senderDisplay.width = padding * 12;
	senderDisplay.layoutData = new AnchorLayoutData(padding, appModel.isLTR?NaN:padding, NaN, appModel.isLTR?padding:NaN);
	addChild(senderDisplay);

	messageDisplay = new RTLLabel(null, 0x444444, "justify", null, true, null, 0.55);
	messageDisplay.wordWrap = false;
	messageDisplay.touchable = false;
	messageDisplay.layoutData = new AnchorLayoutData(8, padding, NaN, padding );
	addChild(messageDisplay);
	
	dateDisplay = new RTLLabel(null, 0, "justify", null, false, null, 0.5);
	dateDisplay.touchable = false;
	dateDisplay.alpha = 0.8;
	dateDisplay.layoutData = new AnchorLayoutData(8, padding, NaN, padding);
	addChild(dateDisplay);
}

override protected function commitData():void
{
	super.commitData();
	if( _data == null || _owner == null )
		return;

	message = _data as SFSObject;
	dateDisplay.text = StrUtils.toElapsed(timeManager.now - message.getLong("offend_at") / 1000) + "   -   " + message.getText("lobby");
	messageDisplay.text = message.getUtfString("content");
	offenderButton.label = message.getText("name") + "   " + message.getInt("offender").toString();
	reporterButton.label = message.getInt("reporter").toString();
	mySkin.texture = message.getInt("proceed") == 1 ? appModel.theme.itemRendererBulgyDangerSkinTexture : appModel.theme.itemRendererBulgyUpSkinTexture;
}

private function buttons_eventHandler(event:Event):void
{
	if( event.currentTarget == banButton )
		_owner.dispatchEventWith(Event.SELECT, false, message);
	else if( event.currentTarget == deleteButton )
		_owner.dispatchEventWith(Event.CANCEL, false, message);
	else if( event.currentTarget == offenderButton )
		_owner.dispatchEventWith(Event.READY, false, message);
	else if( event.currentTarget == reporterButton )
		_owner.dispatchEventWith(Event.OPEN, false, message);
}
}
}