package com.gerantech.towercraft.controls.popups 
{
/**
 * ...
 * @author Mansour Djawadi
 */

import com.gerantech.extensions.NativeAbilities;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.utils.StrUtils;
import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import feathers.layout.AnchorLayoutData;
import flash.desktop.NativeApplication;
import flash.geom.Rectangle;
import flash.net.URLRequest;
import flash.net.navigateToURL;
import starling.events.Event;

public class BanPopup extends ConfirmPopup
{
	public function BanPopup(data:ISFSObject)
	{
		super(loc("popup_ban_title",[StrUtils.toTimeFormat(data.getLong("until"))]), loc("popup_ban_protest"), loc("close_button"));
		this.data = data;
		closeOnOverlay = false;
		declineStyle = "danger";
	}
	
	override protected function initialize():void
	{
		super.initialize();
		transitionIn.destinationBound = transitionOut.sourceBound = new Rectangle(40, 500, stageWidth - 80, stageHeight - 1000);
		transitionOut.destinationBound = transitionIn.sourceBound = new Rectangle(40, 450, stageWidth - 80, stageHeight - 900);
		
		var descriptionDisplay:RTLLabel = new RTLLabel(data.getUtfString("message") + "\n" + loc("popup_ban_message"), 1, "justify", null, true, "center", 0.6);
		descriptionDisplay.layoutData = new AnchorLayoutData(padding * 4, padding, padding * 6, padding);
		container.addChild(descriptionDisplay);
		
		rejustLayoutByTransitionData();			
	}
	
	override protected function acceptButton_triggeredHandler(event:Event):void
	{
		navigateToURL(new URLRequest("mailto:towers@gerantech.com?subject=ban(udid:" + NativeAbilities.instance.deviceInfo.id + ")"));
		super.acceptButton_triggeredHandler(event);
	}
	
	override public function close(dispose:Boolean=true):void
	{
		super.close(dispose);
		NativeApplication.nativeApplication.exit();
	}
}
}