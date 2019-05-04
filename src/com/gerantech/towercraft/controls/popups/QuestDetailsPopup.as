package com.gerantech.towercraft.controls.popups
{
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.utils.StrUtils;
import feathers.layout.AnchorLayoutData;
import starling.events.Event;

public class QuestDetailsPopup extends SimplePopup
{
private var operationIndex:int;
public function QuestDetailsPopup(questIndex:int)
{
	super();
	this.operationIndex = operationIndex;
}

override protected function initialize():void
{
	super.initialize();
	overlay.alpha = 0.2;
	
	var messageDisplay:ShadowLabel = new ShadowLabel(loc("operation_label") + " " + StrUtils.getNumber(operationIndex + 1));
	messageDisplay.layoutData = new AnchorLayoutData(padding, NaN, NaN, NaN, 0);
	addChild(messageDisplay);
	
	var buttonDisplay:CustomButton = new CustomButton();
	buttonDisplay.label = "حمله";
	buttonDisplay.width = transitionIn.destinationBound.width - padding * 2
	buttonDisplay.layoutData = new AnchorLayoutData(NaN, NaN, padding, NaN, 0);
	buttonDisplay.addEventListener(Event.TRIGGERED, buttonDisplay_triggredHandler);
	addChild(buttonDisplay);

}

private function buttonDisplay_triggredHandler():void
{
	dispatchEventWith(Event.SELECT, false, operationIndex);
}		
}
}