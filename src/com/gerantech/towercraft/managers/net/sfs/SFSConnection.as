package com.gerantech.towercraft.managers.net.sfs
{
import com.gerantech.mmory.core.constants.SFSCommands;
import com.gerantech.mmory.core.utils.lists.IntList;
import com.gerantech.mmory.core.utils.maps.IntIntMap;
import com.gerantech.towercraft.controls.overlays.LowConnectionOverlay;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.utils.GTStreamer;
import com.gerantech.towercraft.utils.LoadAndSaver;
import com.smartfoxserver.v2.SmartFox;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.Room;
import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSArray;
import com.smartfoxserver.v2.requests.ExtensionRequest;
import com.smartfoxserver.v2.requests.LoginRequest;
import com.smartfoxserver.v2.requests.LogoutRequest;
import com.smartfoxserver.v2.util.SFSErrorCodes;

import flash.desktop.NativeApplication;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.filesystem.File;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

import haxe.ds.StringMap;
import flash.utils.Dictionary;

[Event(name="succeed",			type="com.gerantech.towercraft.managers.net.sfs.SFSConnection")]
[Event(name="failure",			type="com.gerantech.towercraft.managers.net.sfs.SFSConnection")]

public class SFSConnection extends SmartFox
{
public static const SUCCEED:String = "succeed";
public static const FAILURE:String = "failure";
private static var _instance:SFSConnection;

public var userName:String;
public var password:String;
public var zoneName:String;
public var lobbyManager:LobbyManager;
public var publicLobbyManager:LobbyManager;

private var retryMax:int = 2;
private var retryIndex:int = 0;

private var loginParams:ISFSObject;
private var lowConnectionOverlay:LowConnectionOverlay;
private var commandsPool:Dictionary;

public function SFSConnection()
{
	// Create an instance of the SmartFox class
	// Turn on the debug feature
	//debug = false;
	
	addEventListener(SFSEvent.CONNECTION,			sfs_connectionHandler);
	addEventListener(SFSEvent.SOCKET_ERROR,			sfs_connectionHandler);
	addEventListener(SFSEvent.CONNECTION_LOST,		sfs_connectionLostHandler);
	
	//login:
	addEventListener(SFSEvent.LOGIN, 				sfs_loginHandler);
	addEventListener(SFSEvent.LOGOUT, 				sfs_logoutHandler);
	addEventListener(SFSEvent.LOGIN_ERROR, 			sfs_loginErrorHandler);
	

	addEventListener(SFSEvent.EXTENSION_RESPONSE,	sfs_extensionResponseHandler);
	commandsPool = new Dictionary();
	SFSErrorCodes.setErrorMessage(101, "{0}");
	SFSErrorCodes.setErrorMessage(110, "{0}");
	load(false);
}

public function load(force:Boolean) : void 
{
	var cnfFile:File = File.applicationStorageDirectory.resolvePath("config.xml");
	if( force )
	{
		var ips:* = {"local":"127.0.0.1", "iran":"85.208.252.20"}
		var cnfg:String = '<?xml version="1.0" encoding="UTF-8"?><SmartFoxConfig><ip>' + ips[AppModel.instance.descriptor.server] + '</ip><port>9933</port><zone>mmory</zone><debug>false</debug><httpPort>8080</httpPort><useBlueBox>true</useBlueBox><blueBoxPollingRate>500</blueBoxPollingRate></SmartFoxConfig>';
		new GTStreamer(cnfFile, saved, null, null, false, false).save(cnfg);
		function saved(gt:GTStreamer):void{
			loadConfig(cnfFile.url);
		}
		return;
	}

	var pattern:String = '<?xml version="1.0" encoding="UTF-8"?>\r\n<SmartFoxConfig>';
	var url:String = "http://blueboxgames.ir/configs/config.php?id=" + NativeApplication.nativeApplication.applicationID + "&server=" + AppModel.instance.descriptor.server + "&version=" + AppModel.instance.descriptor.versionCode + "&r=" + Math.round(Math.random() * 1000);
	var cnfLoader:LoadAndSaver = new LoadAndSaver(cnfFile.nativePath, url, null, false, false, 0, pattern);trace(url);
	cnfLoader.addEventListener(Event.COMPLETE,			cnfLoader_completeHandler);
	cnfLoader.addEventListener(IOErrorEvent.IO_ERROR,	cnfLoader_ioErrorHandler);
	cnfLoader.start();
	function cnfLoader_completeHandler(event:Event) : void
	{
		cnfLoader.removeEventListener(Event.COMPLETE,			cnfLoader_completeHandler);
		cnfLoader.removeEventListener(IOErrorEvent.IO_ERROR,	cnfLoader_ioErrorHandler);
		cnfLoader.closeLoader(false);
		loadConfig(cnfFile.url);
	}
	function cnfLoader_ioErrorHandler(event:IOErrorEvent) : void
	{
		cnfLoader.removeEventListener(Event.COMPLETE,			cnfLoader_completeHandler);
		cnfLoader.removeEventListener(IOErrorEvent.IO_ERROR,	cnfLoader_ioErrorHandler);
		if( !force )
		{
			load(true);
			return;
		}
		clearAndReset(null);
	}
}

public function login(userName:String="", password:String="", zoneName:String="", params:ISFSObject=null) : void
{
	if( !isConnected )
		return;
	
	this.userName = userName;
	this.password = password;
	this.zoneName = zoneName;
	this.loginParams = params;
	
	send( new LoginRequest(userName, password, zoneName, loginParams) );
}

public function logout():void
{
	if( !isConnected )
		return;
	send( new LogoutRequest() );
}


//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
// SFS2X event handlers
//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

/*protected function sfs_configLoadHandler(event:SFSEvent):void
{
	dispatchEvent(event.clone());
}*/

// Connection ....................................................
protected function sfs_connectionHandler(event:SFSEvent):void
{
	//trace("sfs_connectionHandler", event.params.success)//, "t["+(getTimer()-Tanks.t)+"]");
	if( event.type == SFSEvent.CONNECTION && event.params.success )
	{
		retryIndex = 0;
		if( hasEventListener( SFSConnection.SUCCEED ) )
			dispatchEvent(new SFSEvent(SFSConnection.SUCCEED, event.params));
	}
	else
	{
		if( retryIndex < retryMax )
		{
			disconnect();
			load(false);
			retryIndex ++;
			return;
		}
		if( hasEventListener(SFSConnection.FAILURE) )
			clearAndReset(event.params);
	}
}

private function clearAndReset(params:Object):void 
{
	var cnfFile:File = File.applicationStorageDirectory.resolvePath("config.xml");
	if( cnfFile.exists )
		cnfFile.deleteFile();
	dispatchEvent(new SFSEvent(SFSConnection.FAILURE, params));
}
protected function sfs_connectionLostHandler(event:SFSEvent):void
{
	trace("Connection was lost. Reason: " + event.params.reason);
	//NativeApplication.nativeApplication.exit();
	//dispatchEvent(event.clone());
}
// Login ....................................................
public function sfs_loginHandler(event:SFSEvent):void
{
	//addEventListener(SFSEvent.PING_PONG, sfs_pingPongHandler);
	//enableLagMonitor(true)
	//	trace("Login Succeed:", UserData.instance.userName, UserData.instance.password, "t["+(getTimer()-Tanks.t)+"]");
//	dispatchEvent(event.clone());
}
protected function sfs_logoutHandler(event:SFSEvent):void
{
	userName = password = zoneName = "";
//	dispatchEvent(event.clone());
}
public function sfs_loginErrorHandler(event:SFSEvent):void
{
	trace("Login failed: " + event.params.errorMessage);
	/*if(retryIndex < retryMax)
	{
		sfs.send( new LoginRequest(userName, password, zoneName, loginParams) );
		retryIndex ++;
	}
	else
	{*/
	//	dispatchEvent(event.clone());
	//}
}

// Response ....................................................
public function sendExtensionRequest(extCmd:String, params:ISFSObject=null, room:Room=null, useUDP:Boolean=false):void
{
	if( !isConnected )
		return;
	var canceledCommand:String = SFSCommands.getCanceled(extCmd);
	if( canceledCommand != null )
		removeFromCommands(canceledCommand);
	
	removeFromCommands(extCmd);
	var deadline:int = SFSCommands.getDeadline(extCmd);
	if( deadline > -1 )
		commandsPool[extCmd] = setTimeout(responseDeadlineCallback, deadline, extCmd);
	send(new ExtensionRequest(extCmd, params, room, useUDP));
}

protected function sfs_extensionResponseHandler(event:SFSEvent):void
{
	if( event.params.cmd == SFSCommands.BATTLE_CANCEL )
		removeFromCommands(SFSCommands.BATTLE_START);
	removeFromCommands(event.params.cmd);
}
public function removeFromCommands(command:String):void
{
	if( !commandsPool.hasOwnProperty(command) )
		return;
	clearTimeout(commandsPool[command] as uint);
	delete(commandsPool[command]);
	hideLowConnectionAlert(command);
}

private function responseDeadlineCallback(command:String):void
{
	if( !commandsPool.hasOwnProperty(command) )
		return;
	removeFromCommands(command);
	showLowConnectionAlert(command);
	trace("deadline", command);
}		
protected function sfs_pingPongHandler(event:SFSEvent):void
{
	//trace("lag:", event.params.lagValue);
	if( event.params.lagValue < 550 )
	{
		hideLowConnectionAlert();
		return;
	}
	showLowConnectionAlert();
}

private function showLowConnectionAlert(command:String=null):void
{
	if( lowConnectionOverlay != null )
		return;
	
	lowConnectionOverlay = new LowConnectionOverlay();
	lowConnectionOverlay.data = command;
	AppModel.instance.navigator.addOverlay(lowConnectionOverlay);			
}

private function hideLowConnectionAlert(command:String=null):void
{
	if( lowConnectionOverlay == null )
		return;
	
	if( command != null && lowConnectionOverlay.data != command )
		return;

	lowConnectionOverlay.close();
	lowConnectionOverlay = null;
}

/*public function destroy():void
{
	//TODO: connection lost bayad dobare ezafe shavad amma dar classe playOnlineSFS na inja
	trace("Connector is destroying...");
	// Add SFS2X event listeners
	//disconnect

	//sfs.removeEventListener(SFSEvent.CONFIG_LOAD_SUCCESS,	sfs_configLoadSuccessHandler)
	//sfs.removeEventListener(SFSEvent.CONFIG_LOAD_FAILURE,	sfs_configLoadFailureHandler)
		
	sfs.removeEventListener(SFSEvent.CONNECTION,			sfs_connectionHandler);
	sfs.removeEventListener(SFSEvent.SOCKET_ERROR,			sfs_socketErrorHandler);
	sfs.removeEventListener(SFSEvent.CONNECTION_LOST,		sfs_connectionLostHandler);
	//login:
	sfs.removeEventListener(SFSEvent.LOGIN,					sfs_loginHandler);
	sfs.removeEventListener(SFSEvent.LOGIN_ERROR,			sfs_loginErrorHandler);
	sfs.removeEventListener(SFSEvent.EXTENSION_RESPONSE,	sfs_extensionResponseHandler);
}*/
public function getLobby(isPublic:Boolean=false):Room
{
	for each (var r:Room in SFSConnection.instance.roomList)
		if( r.groupId == (isPublic?"publics":"lobbies") )
			return r;
	return null;
}

static public function ArrayToMap(array:Array):IntIntMap
{
	var ret :IntIntMap = new IntIntMap();
	for (var i:int = 0; i < array.length; i++)
		ret.set(i, int(array[i]));
	return ret;
}
static public function ToMap(array:ISFSArray) : IntIntMap
{
	var ret:IntIntMap = new IntIntMap();
	for (var i:int = 0; i < array.size(); i++)
		ret.set(array.getSFSObject(i).getInt("key"), array.getSFSObject(i).getInt("value"));
	return ret;
}
static public function ToList(array:ISFSArray) : IntList 
{
	var ret:IntList = new IntList();
	for (var i:int = 0; i < array.size(); i++)
		ret.push(array.getInt(i));
	return ret;
}
static public function ToArray(sfsArray:SFSArray) : Array 
{
	var ret:Array = new Array();
	for (var i:int = 0; i < sfsArray.size(); i++)
		ret.push(sfsArray.getSFSObject(i));
	return ret;
}

public static function get instance():SFSConnection
{
	if( _instance == null )
		_instance = new SFSConnection();
	return _instance;
}

public static function dispose():void
{
	_instance = null
}	

}
}