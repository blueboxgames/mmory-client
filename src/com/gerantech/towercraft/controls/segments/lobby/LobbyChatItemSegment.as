package com.gerantech.towercraft.controls.segments.lobby
{
import com.gerantech.towercraft.controls.FastList;
import com.gerantech.towercraft.controls.segments.Segment;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.Assets;
import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSObject;
import feathers.layout.AnchorLayout;
import flash.geom.Rectangle;
import starling.display.Image;


public class LobbyChatItemSegment extends Segment
{
static public var BALLOON_RECT:Rectangle = new Rectangle(49, 32, 2, 2);
public var data:ISFSObject;
public var owner:FastList;
protected var itsMe:Boolean;
protected var user:ISFSObject;
public function LobbyChatItemSegment(owner:FastList) { this.owner = owner; }
override public function init():void
{
	super.init();
	layout = new AnchorLayout();
}

protected function backgroundFactory() : void
{
	var background:Image = new Image(Assets.getTexture("socials/balloon", "gui"));
	background.scale9Grid = LobbyChatItemSegment.BALLOON_RECT;
	backgroundSkin = background;
}

public function commitData(_data:ISFSObject, index:int) : void
{
	this.data = _data as SFSObject;
	itsMe = data.getInt("i") == player.id;
	user = findUser(data.getInt("i"));
	if( !initializeStarted )
		init();
}
	
private function findUser(uid:int):ISFSObject
{
	var all:ISFSArray = SFSConnection.instance.lobbyManager.members;//lobby.getSFSArray("all");
    if( all == null )
        return null;
    var allSize:int = all.size();
	for( var i:int=0; i<allSize; i++ )
		if( all.getSFSObject(i).getInt("id") == uid )
			return all.getSFSObject(i);
	return null;
}		
}
}