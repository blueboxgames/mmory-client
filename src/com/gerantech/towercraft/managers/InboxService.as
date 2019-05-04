package com.gerantech.towercraft.managers
{
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.vo.UserData;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.data.SFSArray;
import com.smartfoxserver.v2.entities.data.SFSObject;
import feathers.data.ListCollection;
import starling.events.Event;

[Event(name = "update", type = "starling.events.Event")]
[Event(name = "complete", type = "starling.events.Event")]
public class InboxService extends BaseManager
{
private static var _instance:InboxService;
public var threads:ListCollection;

public function InboxService(){}
public function requestThreads(id:int = -1) : void
{
	//if( threads != null )
	//	return;
	var params:SFSObject = new SFSObject();
	if( id > -1 )
		params.putInt("id", id);
	threads = new ListCollection();
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_threadsResponseHandler);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.INBOX_GET_THREADS, params);
}

protected function sfs_threadsResponseHandler(event:SFSEvent) : void
{
	if( event.params.cmd != SFSCommands.INBOX_GET_THREADS )
		return;
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_threadsResponseHandler);
	var params:SFSObject = event.params.params as SFSObject;
	var msgs:Array = SFSArray(params.getSFSArray("data")).toArray();
	msgs.sortOn("timestamp", Array.DESCENDING);
	/*var exists:Boolean = false;
	for( var i:int = 0; i < msgs.size(); i++ ) 
	{
		for( var j:int = 0; j < messages.length; j++ )
			if( !exists && msgs.getSFSObject(i).getInt("id") == messages.getItemAt(j).getInt("id") )
				exists = true;
		
		if( !exists )
		{
			// check if broadcasts readen 
			if( msgs.getSFSObject(i).getInt("receiverId") <= 1000 && UserData.instance.broadcasts != null )
				msgs.getSFSObject(i).putShort("read", UserData.instance.broadcasts.indexOf(msgs.getSFSObject(i).getInt("utc")) >-1 ? 1 : 0);
			
			if( msgs.size() == 1 )
				messages.addItemAt(msgs.getSFSObject(i), 0);
			else
				messages.addItem(msgs.getSFSObject(i));
		}
	}*/
	//trace(event.params.params.getDump())
	if( !params.containsKey("id") )
		threads.data = msgs;
dispatchEventWith(Event.UPDATE, false, msgs);
}

public function get numUnreads() : int
{
	if( threads == null )
		return 0;
	var ret:int = 0;
	for (var i:int = 0; i < threads.length; i++)
		if( threads.getItemAt(i).getShort("read") == 0 )
			ret ++;
	return ret;
}

public function requestRelations(id:int, me:int = -1) : void
{
	var params:SFSObject = new SFSObject();
	params.putInt("id", id);
	if( me > -1 )
		params.putInt("me", me);
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_relationsResponseHandler);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.INBOX_GET_RELATIONS, params);
}

protected function sfs_relationsResponseHandler(event:SFSEvent) : void
{
	if( event.params.cmd != SFSCommands.INBOX_GET_RELATIONS )
		return;
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_relationsResponseHandler);
	dispatchEventWith(Event.COMPLETE, false, event.params.params);
}



public static function get instance ():InboxService 
{
	if( _instance == null )
		_instance = new InboxService();
	return _instance;
}
}
}