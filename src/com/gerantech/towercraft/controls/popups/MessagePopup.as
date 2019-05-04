package com.gerantech.towercraft.controls.popups
{
public class MessagePopup extends ConfirmPopup
{
public function MessagePopup(message:String, acceptLabel:String = null)
{
	if( acceptLabel == null )
		acceptLabel = loc("popup_ok_label");
	super(message, acceptLabel, null);
}
override protected function initialize():void
{
	super.initialize();
	acceptButton.width = 350;
	declineButton.removeFromParent();
	rejustLayoutByTransitionData();
}
}
}