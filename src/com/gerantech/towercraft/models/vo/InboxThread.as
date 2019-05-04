package com.gerantech.towercraft.models.vo 
{
/**
 * ...
 * @author Mansour Djawadi
 */
public class InboxThread 
{
	public var status:int;
	public var ownerId:int;
	public var owner:String;
	public var text:String;
	public var isSender:Boolean;
	public var timestamp:Number;
	public function InboxThread(data:Object) 
	{
		isSender = data.hasOwnProperty("sender");
		owner = String(isSender ? data.sender : data.receiver);
		ownerId = int(isSender ? data.senderId : data.receiverId);
		text = data.text as String;
		status = data.status as int;
		timestamp = data.timestamp as Number;
	}
}
}