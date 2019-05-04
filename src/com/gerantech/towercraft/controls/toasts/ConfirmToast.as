package com.gerantech.towercraft.controls.toasts
{
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.themes.MainTheme;
import feathers.controls.ImageLoader;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import starling.events.Event;

public class ConfirmToast extends BaseToast
{
public var acceptStyle:String = "normal";
public var declineStyle:String = "normal";

private var message:String;
private var acceptLabel:String;
private var declineLabel:String;

public function ConfirmToast(message:String, acceptLabel:String="", declineLabel:String="")
{
	super();
	this.message = message;
	if( acceptLabel != null )
		this.acceptLabel = acceptLabel=="" ? loc("popup_accept_label") : acceptLabel;
	if( declineLabel != null )
		this.declineLabel = declineLabel=="" ? loc("popup_decline_label") : declineLabel;
}
	
override protected function initialize():void
{
	super.initialize();
	
	var hlayout:HorizontalLayout = new HorizontalLayout();
	hlayout.gap = hlayout.padding = 32;
	hlayout.verticalAlign = VerticalAlign.MIDDLE;
	layout = hlayout;

	var background:ImageLoader = new ImageLoader();
	background.source = appModel.theme.popupBackgroundSkinTexture;
	background.scale9Grid = MainTheme.POPUP_SCALE9_GRID;
	backgroundSkin = background;
	
	var messageDisplay:RTLLabel = new RTLLabel(message, 1, "center", null, true, null, 1);
	messageDisplay.layoutData = new HorizontalLayoutData(100);
	addChild(messageDisplay);
	
	if( declineLabel != null )
	{
		var declineButton:CustomButton = new CustomButton();
		declineButton.label = declineLabel;
		declineButton.style = declineStyle;
		declineButton.layoutData = new HorizontalLayoutData(NaN, 100);
		declineButton.addEventListener(Event.TRIGGERED, declineButton_triggeredHandler);
		addChild(declineButton);
	}
	
	if( acceptLabel != null )
	{
		var acceptButton:CustomButton = new CustomButton();
		acceptButton.label = acceptLabel;
		acceptButton.style = acceptStyle;
		acceptButton.layoutData = new HorizontalLayoutData(NaN, 100);
		acceptButton.addEventListener(Event.TRIGGERED, acceptButton_triggeredHandler);
		addChild(acceptButton);
	}
}

private function acceptButton_triggeredHandler(event:Event):void
{
	dispatchEventWith(Event.SELECT);
	close();
}

private function declineButton_triggeredHandler(event:Event):void
{
	dispatchEventWith(Event.CANCEL);
	close();
}
}
}