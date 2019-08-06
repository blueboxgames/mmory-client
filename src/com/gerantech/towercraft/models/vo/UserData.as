package com.gerantech.towercraft.models.vo
{
import com.gerantech.towercraft.managers.UserPrefs;
import com.gerantech.towercraft.models.AppModel;

import flash.net.SharedObject;

public class UserData
{
public var id:int = -1;
public var prefs:UserPrefs;
public var challengeIndex:int;
public var password:String = "";
public var lastLobbeyMessageTime:int;
//public var oneSignalUserId:String;
//public var oneSignalPushToken:String;
public function UserData() {}
private static var _instance:UserData;
public static function get instance():UserData 
{
	if( _instance == null )
		_instance = new UserData();
	return _instance;
}
public function load():void
{
	var so:SharedObject = SharedObject.getLocal(AppModel.instance.descriptor.server + "-user-data");
	if( so.data.id == null )
		return;
	this.id = so.data.id;
	this.password = so.data.password;
	this.challengeIndex = so.data.challengeIndex;
	this.lastLobbeyMessageTime = so.data.lastLobbeyMessageTime;
}
public function save():void
{
	var so:SharedObject = SharedObject.getLocal(AppModel.instance.descriptor.server + "-user-data");
	so.data.id = this.id;
	so.data.password = this.password;
	so.data.challengeIndex = this.challengeIndex;
	so.data.lastLobbeyMessageTime = this.lastLobbeyMessageTime;
	so.flush(100000);
}
public function clear():void
{
	var so:SharedObject = SharedObject.getLocal(AppModel.instance.descriptor.server + "user-data");
	so.clear();
}


public function get registered():Boolean
{
	return id != 0;
}

public function getPurchaseActivity(authCode:String):String
{
	var so:SharedObject = SharedObject.getLocal(AppModel.instance.descriptor.server + "-purchase-data");
	if( so.data[authCode] == null )
		return null;
	return so.data[authCode];
}

public function setPurchaseActivity(sku:String, authCode:String):void
{
	var so:SharedObject = SharedObject.getLocal(AppModel.instance.descriptor.server + "-purchase-data");
	so.data[authCode] = sku;
	so.flush(100000);
}

public function clearPurchase(authCode:String):void
{
	var so:SharedObject = SharedObject.getLocal(AppModel.instance.descriptor.server + "-purchase-data");
	if( so.data[authCode] == null )
		return;
	so.data[authCode] = null;
	so.flush(100000);
}

public function clearPurchaseHistory():void
{
	var so:SharedObject = SharedObject.getLocal(AppModel.instance.descriptor.server + "-purchase-data");
	so.clear();
}
}
}