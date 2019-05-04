package com.gerantech.towercraft.controls.screens
{
import com.gerantech.towercraft.controls.segments.InboxChatSegment;
import com.gerantech.towercraft.managers.InboxService;
import com.gerantech.towercraft.models.vo.InboxThread;
import com.smartfoxserver.v2.entities.data.SFSObject;
import feathers.layout.AnchorLayoutData;
import starling.events.Event;

public class InboxScreen extends SimpleScreen
{
public var myId:int;
public var thread:InboxThread;
private var sfsData:SFSObject;
private var chatBox:InboxChatSegment;
public function InboxScreen() 
{
	showTileAnimationn = false;
	InboxService.instance.addEventListener(Event.COMPLETE, inboxService_completeHandler);
}

override protected function initialize():void
{
	title = thread.owner;
	super.initialize();
	
	chatBox = new InboxChatSegment(myId);
	chatBox.layoutData = new AnchorLayoutData(headerSize, 0, footerSize, 0);
	addChild(chatBox);
	if( sfsData != null )
		chatBox.setData(sfsData.getSFSArray("data"), thread);
}

protected function inboxService_completeHandler(event:Event) : void 
{
	sfsData = event.data as SFSObject;
	if( chatBox != null )
		chatBox.setData(sfsData.getSFSArray("data"), thread);
}

/*private function list_eventsHandler(event:Event):void
{
	var message:SFSObject = event.data as SFSObject;
	if( event.type == Event.OPEN )
	{
    	if( message.getInt("receiverId") > 1000 )
			SFSConnection.instance.sendExtensionRequest(SFSCommands.INBOX_OPEN, message);
		else
			UserData.instance.addOpenedBroadcasts(message.getInt("utc"));
		return;
	}
	if( event.type == Event.SELECT )
	{
		if( message.getShort("type") == MessageTypes.M50_URL )
			appModel.navigator.handleURL(message.getText("data"));
	}
	if( MessageTypes.isConfirm(message.getShort("type")) )
	{
		message.putBool("isAccept", event.type == Event.SELECT);
		SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_responseConfirmHandler);
		SFSConnection.instance.sendExtensionRequest(SFSCommands.INBOX_CONFIRM, message);
	}
}

protected function sfs_responseConfirmHandler(event:SFSEvent):void
{
	if( event.params.cmd != SFSCommands.INBOX_CONFIRM )
		return;
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_responseConfirmHandler);
}*/

override public function dispose() : void
{
	InboxService.instance.removeEventListener(Event.COMPLETE, inboxService_completeHandler);
	super.dispose();
}
}
}