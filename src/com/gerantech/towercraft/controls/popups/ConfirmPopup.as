package com.gerantech.towercraft.controls.popups
{
import com.gerantech.towercraft.controls.buttons.MMOryButton;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.themes.MainTheme;
import feathers.controls.Button;
import feathers.controls.LayoutGroup;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import starling.events.Event;

public class ConfirmPopup extends SimplePopup
{
public var message:String;
public var acceptStyle:String = MainTheme.STYLE_BUTTON_SMALL_NEUTRAL;
public var declineStyle:String = MainTheme.STYLE_BUTTON_SMALL_DANGER;
public var acceptLabel:String;
public var declineLabel:String;
public var messageDisplay:RTLLabel;

protected var declineButton:Button;
protected var container:LayoutGroup;
protected var acceptButton:MMOryButton;
protected var buttonContainer:LayoutGroup;

public function ConfirmPopup(message:String, acceptLabel:String = null, declineLabel:String = null)
{
	super();
	this.message = message;
	this.acceptLabel = acceptLabel == null ? loc("popup_accept_label") : acceptLabel;
	this.declineLabel = declineLabel == null ? loc("popup_decline_label") : declineLabel;
}

override protected function initialize():void
{
	super.initialize();

	var containerLayout:VerticalLayout = new VerticalLayout();
	containerLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
	containerLayout.verticalAlign = VerticalAlign.MIDDLE;
	containerLayout.gap = padding;
	
	container = new LayoutGroup();
	container.layoutData = new AnchorLayoutData(padding, padding, 180, padding);
	container.layout = containerLayout;
	addChild(container);
	
	messageDisplay = new RTLLabel(message, 0, "center", null, true, "center", 1);
	container.addChild(messageDisplay);
	
	var buttonLayout:HorizontalLayout = new HorizontalLayout();
	buttonLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
	buttonLayout.verticalAlign = VerticalAlign.JUSTIFY;

	buttonLayout.gap = padding;
	buttonContainer = new LayoutGroup();
	buttonContainer.layoutData = new AnchorLayoutData (NaN, NaN, 60, NaN, 0);
	buttonContainer.height = 120;
	buttonContainer.layout = buttonLayout;
	addChild(buttonContainer);
	
	declineButton = new Button();
	declineButton.styleName = declineStyle;
	declineButton.width = 300;
	declineButton.label = declineLabel;
	declineButton.addEventListener(Event.TRIGGERED, decline_triggeredHandler);
	buttonContainer.addChild(declineButton);
	
	acceptButton = new MMOryButton();
	acceptButton.width = 300;
	acceptButton.styleName = acceptStyle;
	acceptButton.label = acceptLabel;
	acceptButton.addEventListener(Event.TRIGGERED, acceptButton_triggeredHandler);
	buttonContainer.addChild(acceptButton);
}

protected function decline_triggeredHandler(event:Event):void
{
	dispatchEventWith(Event.CANCEL);
	close();
}
protected function acceptButton_triggeredHandler(event:Event):void
{
	dispatchEventWith(Event.SELECT);
	close();
}

override public function dispose():void
{
	acceptButton.removeEventListener(Event.TRIGGERED, acceptButton_triggeredHandler);
	declineButton.removeEventListener(Event.TRIGGERED, decline_triggeredHandler);
	super.dispose();
}
}
}