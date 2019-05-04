package com.gerantech.towercraft.controls.headers
{
import com.gerantech.towercraft.controls.TowersLayout;
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.themes.MainTheme;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import starling.display.Image;
import starling.events.Event;

public class CloseFooter extends TowersLayout
{
private var _label:String;
private var size:int = 0;
private var closeButton:CustomButton;
public function CloseFooter(size:int = 0)
{
	super();
	this.size = size == 0 ? 150 : size;
}
override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout();
	backgroundSkin = new Image(appModel.theme.tabUpSkinTexture);
	Image(backgroundSkin).scale9Grid = MainTheme.TAB_SCALE9_GRID;
	height = size;
	
	closeButton = new CustomButton();
	closeButton.layoutData = new AnchorLayoutData(16, NaN, 12, NaN, 0);
	closeButton.addEventListener(Event.TRIGGERED, backButtonHandler);
	addChild(closeButton);
	label = loc("close_button");
}

public function get label():String
{
	return _label;
}
public function set label(value:String):void
{
	if( _label == value )
		return;
	
	_label = value;
	if( closeButton )
		closeButton.label = _label;
}

private function backButtonHandler(event:Event):void
{
	dispatchEventWith(Event.CLOSE);
}
}
}