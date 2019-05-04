package com.gerantech.towercraft.controls.popups 
{
import com.gerantech.towercraft.controls.overlays.TransitionData;
import com.gerantech.towercraft.controls.switchers.Switcher;
import com.gerantech.towercraft.controls.texts.CustomTextInput;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.utils.StrUtils;
import com.gt.towers.constants.MessageTypes;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSObject;
import feathers.controls.LayoutGroup;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import flash.geom.Rectangle;
import flash.text.ReturnKeyLabel;
import flash.text.SoftKeyboardType;
import starling.events.Event;
/**
* ...
* @author Mansour Djawadi
*/
public class AdminBanPopup extends ConfirmPopup 
{
private var userId:int;
private var idInput:CustomTextInput;
private var lenInput:CustomTextInput;
private var messageInput:CustomTextInput;
private var errorDisplay:RTLLabel;
private var banModeSwitcher:Switcher;
private var offenderData:ISFSObject;
private var numBannedLabel:RTLLabel;

public function AdminBanPopup(userId:int)
{
	super(loc("popup_ban_button"), loc("popup_ban_button"), null);
	this.userId = userId;

	var sfs:ISFSObject = new SFSObject();
	sfs.putInt("id", userId);
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_getBannedHander);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.OFFENDER_DATA_GET, sfs);
}

protected function sfs_getBannedHander(e:SFSEvent):void 
{
	if( e.params.cmd != SFSCommands.OFFENDER_DATA_GET )
		return;
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_getBannedHander);
	offenderData  = e.params.params;
	if( transitionState >= TransitionData.STATE_IN_COMPLETED )
		insertData();
}

override protected function initialize():void
{
	super.initialize();
	transitionIn.destinationBound = transitionOut.sourceBound = new Rectangle(40, 420, stageWidth - 80, stageHeight - 760);
	transitionOut.destinationBound = transitionIn.sourceBound = new Rectangle(40, 400, stageWidth - 80, stageHeight - 800);
	rejustLayoutByTransitionData();	
}

protected override function transitionInCompleted():void
{
	super.transitionInCompleted();
	if( offenderData != null )
		insertData();
}

private function insertData():void 
{
	// line 1
	var l1:LayoutGroup = new LayoutGroup();
	l1.layout = new HorizontalLayout();
	l1.height = padding * 3;
	HorizontalLayout(l1.layout).gap = padding;
	container.addChild(l1);
	
	numBannedLabel = new RTLLabel("سوابق: " + offenderData.getInt("time"));
	numBannedLabel.width = padding * 8;
	l1.addChild(numBannedLabel);
	
	idInput = new CustomTextInput(SoftKeyboardType.NUMBER, ReturnKeyLabel.DEFAULT);
	idInput.layoutData = new HorizontalLayoutData(100);
	idInput.text = userId.toString();
	l1.addChild(idInput);
	
	// line 2
	var l2:LayoutGroup = new LayoutGroup();
	l2.layout = new HorizontalLayout();
	HorizontalLayout(l2.layout).gap = padding;
	container.addChild(l2);

	lenInput = new CustomTextInput(SoftKeyboardType.NUMBER, ReturnKeyLabel.DEFAULT);
	lenInput.width = padding * 5;
	lenInput.text = "72";
	l2.addChild(lenInput);
	
	banModeSwitcher = new Switcher(1, 2, 3, 1);
	banModeSwitcher.labelStringFactory = function (value:int):String { return loc("popup_ban_mode_" + value); }
	banModeSwitcher.layoutData = new HorizontalLayoutData(100);
	l2.addChild( banModeSwitcher );
	
	var message:String = "تخلفات شما:\n\n";
	var date:Date = new Date();
	for (var i:int = 0; i < offenderData.getSFSArray("infractions").size(); i++ )
	{
		var m:ISFSObject = offenderData.getSFSArray("infractions").getSFSObject(i);
		date.time = m.getLong("offend_at");
		message += "[" + StrUtils.getDateString(date, true) + "]: " + m.getUtfString("content").split("\n").join(" ") + "\n";
	}
	messageInput = new CustomTextInput(SoftKeyboardType.DEFAULT, ReturnKeyLabel.DEFAULT, 0, true, "justify", 0.6);
	messageInput.height = padding * 12;
	messageInput.text = message;
	container.addChild(messageInput);

	errorDisplay = new RTLLabel(null, 0xFF0000, "center", null, true, null, 0.8);
	container.addChild(errorDisplay);
}

protected override function acceptButton_triggeredHandler(event:Event):void
{
	var sfs:ISFSObject = new SFSObject();
	sfs.putInt("id", int(idInput.text));
	sfs.putInt("len", int(lenInput.text));
	sfs.putInt("mode", banModeSwitcher.value);
	sfs.putUtfString("msg", messageInput.text);
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_banResponseHander);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.BAN, sfs);
}

protected function sfs_banResponseHander(e:SFSEvent):void 
{
	if( e.params.cmd != SFSCommands.BAN )
		return;
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_banResponseHander);
	errorDisplay.text = loc( "popup_ban_response_" + e.params.params.getInt("response"));
	if( e.params.params.getInt("response") == MessageTypes.RESPONSE_SUCCEED )
	{
		offenderData.putInt("time", offenderData.getInt("time") + 1 );
		numBannedLabel.text = "سوابق: " + offenderData.getInt("time");
	}
}
}
}