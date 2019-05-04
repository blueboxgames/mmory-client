package com.gerantech.towercraft.managers.net.sfs
{
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.models.vo.UserData;
import com.gt.towers.Player;
import com.gt.towers.constants.MessageTypes;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.Room;
import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSObject;

import feathers.data.ListCollection;

import starling.events.Event;
import starling.events.EventDispatcher;

public class LobbyManager extends EventDispatcher
{
public var isPublic:Boolean;
public var isReady:Boolean;
public var lobby:Room;

public var id:int;
public var name:String;
public var bio:String;
public var point:int;
public var emblem:int;
public var activeness:int;
public var members:ISFSArray;
public var messages:ListCollection;
private var player:Player;

public function LobbyManager(isPublic:Boolean = false)
{
	this.isPublic = isPublic;
	initialize();
}
public function joinToPublic() : void
{
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_joinPublicHandler);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.LOBBY_PUBLIC);	
}

public function initialize():void
{
	if( isPublic )
		return;
	
	var _lobby:Room = SFSConnection.instance.getLobby();
	if( _lobby == null )
	{
		dispose();
		return;
	}
	if( lobby != null && lobby.id == _lobby.id )
		return;
	
	var sdfs:* = _lobby.properties;
	for ( var s:String in _lobby.properties )
	trace(s, _lobby.properties[s]);
		
	dispose();
	lobby = _lobby;
	requestData();

	player = AppModel.instance.game.player;
}

public function requestData(broadcast:Boolean = false, skipMessages:Boolean = false):void
{
	var params:SFSObject = new SFSObject();
	params.putInt("id", lobby.id);
	if( broadcast )
		params.putBool("broadcast", true);
	if( skipMessages )
		params.putBool("nomsg", true);
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_getLobbyInfoHandler);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.LOBBY_INFO, params, lobby);	
}

protected function sfs_getLobbyInfoHandler(event:SFSEvent):void
{
	if( event.params.cmd != SFSCommands.LOBBY_INFO || lobby != event.params.room )
		return;

	var data:ISFSObject = event.params.params as SFSObject;
	id = data.getInt("id");
	point = data.getInt("sum");
	emblem = data.getInt("pic");
	activeness = data.getInt("act");
	members = data.getSFSArray("all");
	if( data.containsKey("messages") )
	{
		var u:ISFSObject = findUser(player.id);
		messages = new ListCollection();
		for( var i:int=0; i<data.getSFSArray("messages").size(); i++ )
		{
			var msg:ISFSObject = data.getSFSArray("messages").getSFSObject(i);
			if( isLegal(msg, u) )
				messages.addItem(data.getSFSArray("messages").getSFSObject(i));
		}
		SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_publicMessageHandler);
	}
	isReady = true;
	dispatchEventWith(Event.READY);
}

protected function sfs_joinPublicHandler(event:SFSEvent):void
{
	if( event.params.cmd != SFSCommands.LOBBY_PUBLIC )
		return;
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_joinPublicHandler);
	
	var _lobby:Room = SFSConnection.instance.getLobby(true);
	if( _lobby == null )
	{
		dispose();
		return;
	}
	if( lobby != null && lobby.id == _lobby.id )
		return;
	
	dispose();
	lobby = _lobby;
	
	player = AppModel.instance.game.player;
	if( lobby.containsVariable("msg") )
	{
		var _msgs:ISFSArray = lobby.getVariable("msg").getSFSArrayValue()
		messages = new ListCollection();
		for( var i:int=0; i<_msgs.size(); i++ )
			messages.addItem(_msgs.getSFSObject(i));
	}
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_publicMessageHandler);
	isReady = true;
	dispatchEventWith(Event.READY);
}

private function isLegal(msg:ISFSObject, u:ISFSObject):Boolean
{
	if( u == null )
		return player.admin;
	if( msg.getShort("m") == MessageTypes.M30_FRIENDLY_BATTLE && msg.getShort("st") > 2 )
		return false;
	if( MessageTypes.isConfirm(msg.getShort("m")) )
		if( u.getInt("permission") < 1 || msg.containsKey("pr") )
			return false
	return true;
}

protected function sfs_publicMessageHandler(event:SFSEvent):void
{
	if( event.params.cmd != SFSCommands.LOBBY_PUBLIC_MESSAGE || lobby != event.params.room )
		return;
	var msg:ISFSObject = event.params.params as SFSObject;
	if( msg.getShort("m") == MessageTypes.M0_TEXT )
	{
		var last:SFSObject = messages.length > 0 ? SFSObject(messages.getItemAt(messages.length-1)) : null;
		if( last != null && last.getShort("m") == MessageTypes.M0_TEXT && last.getInt("i") == msg.getInt("i") )
		{
			last.putInt("u", msg.getInt("u"));
			last.putUtfString("t", msg.getUtfString("t"));
			messages.updateItemAt(messages.length-1);
		}
		else
		{
			messages.addItem(msg);
		}
	}
	else if( msg.getShort("m") == MessageTypes.M30_FRIENDLY_BATTLE )
	{
		var lastBattleIndex:int = containBattle(msg.getInt("bid"));
		if( lastBattleIndex > -1 )
		{
			if( msg.getShort("st") > 2 )
			{
				messages.removeItemAt(lastBattleIndex);
			}
			else
			{
				var battleMsg:ISFSObject = messages.getItemAt(lastBattleIndex) as SFSObject;
				battleMsg.putShort("st", msg.getShort("st"));
				battleMsg.putInt("u", msg.getInt("u"));
				if( msg.containsKey("o") )
					battleMsg.putUtfString("o", msg.getUtfString("o"));
				messages.updateItemAt(lastBattleIndex);
				if( msg.getShort("st") == 1 && (msg.getUtfString("s") == player.nickName || msg.getUtfString("o") == player.nickName) )
					dispatchEventWith(Event.TRIGGERED, false, msg);// go to friendly battle
			}
		}
		else
		{
			messages.addItem(msg);
			dispatchEventWith(Event.OPEN, false, msg.getUtfString("s"));
		}
	}
	else if( MessageTypes.isComment(msg.getShort("m")) || MessageTypes.isEmote(msg.getShort("m"))  )
	{
		messages.addItem(msg);
	}
	else if( MessageTypes.isConfirm(msg.getShort("m")) )
	{
		var confirmIndex:int = getReplyedConfirm(msg);
		if( confirmIndex > -1 )
			messages.removeItemAt(confirmIndex);
		if( (!msg.containsKey("pr") && findUser(player.id).getInt("permission") > 0) || player.admin )
			messages.addItem(msg);
	}
	//traceList()
	dispatchEventWith(Event.UPDATE);
}

public function numUnreads():int
{
	var ret:int = -1;
	if( messages == null )
		return 0;
	for( var i:int=messages.length-1; i>=0; i-- )
	{
		if( UserData.instance.lastLobbeyMessageTime < messages.getItemAt(i).getInt("u") )
			ret ++;
	}
	return Math.max(0, ret);
}


private function getReplyedConfirm(msg:ISFSObject):int
{
	for (var i:int = messages.length - 1; i >= 0; i--)
		if( MessageTypes.isConfirm(messages.getItemAt(i).getShort("m")) && messages.getItemAt(i).getInt("o") == msg.getInt("o") )
			return i;
	return -1;
}
private function containBattle(battleId:int):int
{
	for (var i:int = 0; i < messages.length; i++) 
		if( messages.getItemAt(i).getShort("m") == MessageTypes.M30_FRIENDLY_BATTLE && messages.getItemAt(i).getInt("bid") == battleId )
			return i;
	return -1;
}
public function getMyRequestBattleIndex():int
{
	for (var i:int = 0; i < messages.length; i++) 
		if( messages.getItemAt(i).getShort("m") == MessageTypes.M30_FRIENDLY_BATTLE && messages.getItemAt(i).getInt("i") == player.id && messages.getItemAt(i).getShort("st") == 0 )
			return i;
	return -1;
}
public function getMyRequestBattleId():int
{
	for (var i:int = 0; i < messages.length; i++) 
		if( messages.getItemAt(i).getShort("m") == MessageTypes.M30_FRIENDLY_BATTLE && messages.getItemAt(i).getInt("i") == player.id && messages.getItemAt(i).getShort("st") == 0 )
			return messages.getItemAt(i).getInt("bid");
	return -1;
}
private function traceList():void
{
	for (var i:int = 0; i < messages.length; i++) 
	{
		var msg:SFSObject =  messages.getItemAt(i) as SFSObject;//trace(i, msg.getText("t"))
		trace(i, msg.getShort("m"), msg.getShort("st"), msg.getInt("i"), msg.containsKey("bid")?msg.getInt("bid"):"");
	}
}

public function findUser(id:int):ISFSObject
{
	for (var i:int=0; i<members.size(); i++)
		if( members.getSFSObject(i).getInt("id") == id )
			return members.getSFSObject(i);
	return null;
}

private function dispose():void
{
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_publicMessageHandler);
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_getLobbyInfoHandler);
	if( messages )
		messages.removeAll();
}
}
}