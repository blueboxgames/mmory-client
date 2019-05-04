package com.gerantech.towercraft.managers.net
{
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.smartfoxserver.v2.entities.Room;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSArray;
import com.smartfoxserver.v2.entities.data.SFSObject;

public class ResponseSender
{
public var room:Room;
public var actived:Boolean = true;
public function ResponseSender(room:Room)
{
	this.room = room;
}

public function summonUnit(type:int, x:Number, y:Number):void
{
	var params:ISFSObject = new SFSObject();
	params.putInt("t", type);
	params.putDouble("x", x);
	params.putDouble("y", y);
	send(SFSCommands.BATTLE_SUMMON_UNIT, params, room);
}

/*public function hitTroop(troopId:int, damage:Number):void
{
	//trace("hitTroop", troopId);
	var sfsObj:SFSObject = new SFSObject();
	sfsObj.putInt("i", troopId);
	sfsObj.putDouble("d", damage);
	send(SFSCommands.HIT, sfsObj, room);			
}*/

public function leave(retryMode:Boolean=false):void
{
	var params:SFSObject = new SFSObject();
	if( retryMode )
		params.putBool("retryMode", true);
	send(SFSCommands.BATTLE_LEAVE, params, room, false);			
}

public function sendSticker(stickerType:int):void
{
	var sfsObj:SFSObject = new SFSObject();
	sfsObj.putInt("t", stickerType);
	send(SFSCommands.BATTLE_SEND_STICKER, sfsObj, room);			
}

private function send (extCmd:String, params:ISFSObject, room:Room, dislabledForSpectators:Boolean=true) : Boolean
{
	if( !actived )
		return false;
	if( dislabledForSpectators && SFSConnection.instance.mySelf.isSpectator )
		return false;
	SFSConnection.instance.sendExtensionRequest(extCmd, params, room);
	return true;
}
}
}