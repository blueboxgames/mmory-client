package com.gerantech.towercraft.controls.screens
{
import com.gerantech.towercraft.controls.segments.InboxSegment;
import com.gerantech.towercraft.managers.InboxService;
import feathers.data.ListCollection;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import starling.events.Event;

public class IssuesScreen extends SimpleScreen
{
//public var reporter:int = -1;
private var inboxSegment:InboxSegment;
public function IssuesScreen()
{
	super();
	title = "Issues"
	headerSize = 120;
	showTileAnimationn = false;
}
override protected function initialize():void
{
	//title = "Issue Tracking";
	super.initialize();
	layout = new AnchorLayout();
	
	inboxSegment = new InboxSegment();
	inboxSegment.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	addChildAt(inboxSegment, getChildIndex(closeButton));
	
	InboxService.instance.addEventListener(Event.UPDATE, inboxService_updateHandler);
	InboxService.instance.requestThreads(10000);
}

protected function inboxService_updateHandler(event:Event) : void 
{
	InboxService.instance.removeEventListener(Event.UPDATE, inboxService_updateHandler);
	inboxSegment.issueMode = true;
	inboxSegment.threadsCollection = new ListCollection(event.data);
	inboxSegment.init();
}
/*
public function requestIssues() : void 
{
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_issuesResponseHandler);
	var params:SFSObject;
	if( reporter != -1 )
	{
		params = new SFSObject();
		params.putInt("id", reporter);
	}
	SFSConnection.instance.sendExtensionRequest(SFSCommands.ISSUE_GET, params);
}

protected function sfs_issuesResponseHandler(event:SFSEvent):void
{
	if( event.params.cmd != SFSCommands.ISSUE_GET )
		return;
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_issuesResponseHandler);
	issues.removeAll();
	var issueList:SFSArray = SFSArray(SFSObject(event.params.params).getSFSArray("issues"));
	for (var i:int = 0; i < issueList.size(); i++)
	{
		var sfs:ISFSObject = issueList.getSFSObject(i);
		var msg:SFSObject = new SFSObject();
		msg.putInt("id", sfs.getInt("id"));
		msg.putShort("read", sfs.getInt("status"));
		msg.putShort("type", 41);
		msg.putUtfString("text", sfs.getUtfString("description"));
		msg.putUtfString("sender", sfs.getUtfString("sender"));
		msg.putInt("senderId", sfs.getInt("player_id"));
		msg.putInt("utc", sfs.getInt("date"));
		issues.addItem(msg);
	}
}
private function bg_triggeredHandler(event:Event):void
{
	//list.selectedIndex = -1;
}

private function list_eventsHandler(event:Event):void
{
	var msg:SFSObject = event.data as SFSObject;
	if( event.type == Event.SELECT )
	{
		var msgPopup:BroadcastMessagePopup = new BroadcastMessagePopup(msg.getInt("senderId").toString(), msg.getInt("id").toString());
		msgPopup.addEventListener(Event.SELECT, msgPopup_selectHandler);
		appModel.navigator.addPopup(msgPopup);
		function msgPopup_selectHandler(e:Event):void
		{
			msg.putShort("read", 1);
			changeStatus(msg.getInt("id"), 1);
			list.selectedIndex = -1;
			msgPopup.close();
		}
	}
	else if ( event.type == Event.CANCEL )
	{
		msg.putShort("read", 2);
		changeStatus(msg.getInt("id"), 2);
		list.selectedIndex = -1;
	}
	else if ( event.type == Event.READY )
	{
		appModel.navigator.addPopup(new ProfilePopup({name:msg.getUtfString("sender"), id:msg.getInt("senderId")}));
	}
}

private function changeStatus(id:int, status:int):void
{
	var params:SFSObject = new SFSObject();
	params.putInt("id", id);
	params.putShort("status", status);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.ISSUE_TRACK , params);	
}*/
}
}