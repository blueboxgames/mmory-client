package com.gerantech.towercraft.controls.segments 
{
import com.gerantech.towercraft.controls.items.InboxChatItemRenderer;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.vo.InboxThread;
import com.gerantech.towercraft.utils.StrUtils;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.SFSObject;

import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

import flash.utils.setTimeout;

import starling.core.Starling;
import starling.events.Event;
/**
* @author Mansour Djawadi
*/
public class InboxChatSegment extends ChatSegment 
{
private var preText:String = "";
private var sfsData:ISFSArray;
private var thread:InboxThread;
private var threadCollection:ListCollection;
private var myId:int;

public function InboxChatSegment(myId:int){ this.myId = myId; }
public function setData(sfsData:ISFSArray, thread:InboxThread):void 
{
	this.sfsData = sfsData;
	this.thread = thread;
	layout = new AnchorLayout();

	threadCollection = new ListCollection();
	for( var i:int = 0; i < sfsData.size(); i++ )
		threadCollection.addItem(sfsData.getSFSObject(i));
	showElements();
}


override protected function showElements() : void
{
	super.showElements();
	chatList.itemRendererFactory = function ():IListItemRenderer { return new InboxChatItemRenderer(myId)};
	chatList.dataProvider = threadCollection;
}

override protected function chatTextInput_keyboardHandler(event:Event):void
{
	if( event.type == FeathersEventType.SOFT_KEYBOARD_ACTIVATE )
		AnchorLayoutData(chatTextInput.layoutData).bottom = Starling.current.nativeStage.softKeyboardRect.height * (stage.stageWidth / Starling.current.nativeStage.stageWidth) * 1.3;
	else
		setTimeout(enabledChatting, 100, false);
}

override protected function chatButton_triggeredHandler(event:Event):void
{
	super.chatButton_triggeredHandler(event);
	preText = "";
}

override protected function sendButton_triggeredHandler(event:Event):void
{
	if( chatTextInput.text == "" )
		return;

	if( checkVerbos() )
	{
		appModel.navigator.addLog(loc("lobby_message_limit"));
		return;
	}
	
	var params:SFSObject = new SFSObject();
	params.putInt("type", 0);
	params.putInt("senderId", myId);
	params.putBool("isPush", true);
	params.putUtfString("text", preText + StrUtils.getSimpleString(chatTextInput.text));
	params.putIntArray("receiverIds", [thread.ownerId]);
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsInstance_extensionResponseHandler);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.INBOX_BROADCAST, params);
	chatTextInput.text = preText = "";
	chatTextInput.clearFocus();
	
	// temp message
	params.putLong("timestamp", new Date().time);
	threadCollection.addItem(params);
}

private function sfsInstance_extensionResponseHandler(event:SFSEvent) : void 
{
	if( event.params.cmd != SFSCommands.INBOX_BROADCAST )
		return;
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfsInstance_extensionResponseHandler);
	threadCollection.getItemAt(threadCollection.length - 1).putInt("status", 0);
	setTimeout(threadCollection.updateItemAt, 500, threadCollection.length - 1);
}

private function checkVerbos() : Boolean 
{
	if( player.admin )
		return false;
	var ret:Boolean;
	var myMessages:int = 0;
	for( var i:int = 0; i < threadCollection.length; i++ )
	{
		if( threadCollection.getItemAt(i).getInt("senderId") != myId )
		{
			myMessages = 0;
			ret = false;
			continue;
		}
		myMessages ++;
		ret = myMessages >= 3;
	}
	return ret;
}
}
}