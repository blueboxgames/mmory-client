package com.gerantech.towercraft.controls.popups
{
import com.gerantech.towercraft.controls.texts.ShadowLabel;
public class ExistsGamePopup extends SimpleListPopup
{

public function ExistsGamePopup(buttons:Array)
{
	super(buttons);
	this.buttonsWidth = 750;
	this.paddingTop = 280;
	this.padding = 36;
}
override protected function initialize():void
{
	this.closeOnOverlay = this.closeOnStage = this.closeWithKeyboard = false;

	var titleDisplay:ShadowLabel = new ShadowLabel(loc("popup_user_exists"), 0xDDFFFF, 0, "center", null, true, "center", 0.9);
	titleDisplay.layoutData = new AnchorLayoutData(paddingTop * 0.1, NaN, NaN, NaN, 0);
	addChild(titleDisplay);
}
}
}