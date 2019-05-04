package com.gerantech.towercraft.controls.items.lobby
{
import com.gerantech.towercraft.controls.FastList;
import com.gerantech.towercraft.controls.items.AbstractTouchableListItemRenderer;
import com.gerantech.towercraft.controls.segments.lobby.LobbyChatItemBalloonTextSegment;
import com.gerantech.towercraft.controls.segments.lobby.LobbyChatItemBattleSegment;
import com.gerantech.towercraft.controls.segments.lobby.LobbyChatItemCommentSegment;
import com.gerantech.towercraft.controls.segments.lobby.LobbyChatItemConfirmSegment;
import com.gerantech.towercraft.controls.segments.lobby.LobbyChatItemBalloonEmoteSegment;
import com.gerantech.towercraft.controls.segments.lobby.LobbyChatItemBalloonSegment;
import com.gerantech.towercraft.controls.segments.lobby.LobbyChatItemSegment;
import com.gt.towers.constants.MessageTypes;
import com.smartfoxserver.v2.entities.data.SFSObject;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import starling.events.Event;
import starling.events.Touch;

public class LobbyChatItemRenderer extends AbstractTouchableListItemRenderer
{
protected static const TYPE_MESSAGE:int = 0;
protected static const TYPE_COMMENT:int = 10;
protected static const TYPE_DONATE:int = 20;
protected static const TYPE_BATTLE:int = 30;
protected static const TYPE_CONFIRM:int = 40;
protected static const TYPE_EMOTE:int = 51;
	
private var type:int;
private var messageSegment:LobbyChatItemBalloonSegment;
private var commentSegment:LobbyChatItemCommentSegment;
private var confirmSegment:LobbyChatItemConfirmSegment;
private var battleSegment:LobbyChatItemBattleSegment;
private var emoteSegment:LobbyChatItemBalloonEmoteSegment;
private var segment:LobbyChatItemSegment;
private var fitLayoutData:AnchorLayoutData;

public function LobbyChatItemRenderer(){}
public function getTouch():Touch
{
	return touch;
}
override protected function initialize():void
{
	super.initialize();
	deleyCommit = true;
	layout = new AnchorLayout();
	fitLayoutData = new AnchorLayoutData(0, 0, NaN, 0);
	
	addEventListener(Event.TRIGGERED, item_triggeredHandler);
}

private function item_triggeredHandler(event:Event):void
{
	owner.dispatchEventWith(FeathersEventType.FOCUS_IN, false, this);
	segment.dispatchEventWith(Event.TRIGGERED, false, this);
}

override protected function commitData():void
{
	super.commitData();
	if( _data == null )
		return;
	
	if( segment != null )
	{
		segment.removeFromParent();
		//segment = null;		
	}

	type = SFSObject(_data).getShort("m");
	if( MessageTypes.isComment(type) )
		type = TYPE_COMMENT;
	else if( MessageTypes.isConfirm(type) )
		type = TYPE_CONFIRM;

	segment = createSegment(type);
	segment.commitData(_data as SFSObject, index);//trace(index, type, segment.data.getDump())
	addChild(segment);
}
private function confirmSegment_triggeredHandler(event:Event):void
{
	
	segment.data.putShort( "pr", int(event.data.name));
	_owner.dispatchEventWith(Event.ROOT_CREATED, false, [this, segment.data]);
}

private function createSegment(type:int) : LobbyChatItemSegment 
{
	var segment:LobbyChatItemSegment;
	switch( type )
	{
		case TYPE_MESSAGE:	segment = messageSegment;	break;
		case TYPE_COMMENT:	segment = commentSegment;	break;
		case TYPE_CONFIRM:	segment = confirmSegment;	break;
		case TYPE_BATTLE:	segment = battleSegment;	break;
	}
	
	if( segment != null )
		return segment;
	switch( type )
	{
		case TYPE_MESSAGE:	segment = messageSegment	= new LobbyChatItemBalloonTextSegment(owner as FastList);	break;
		case TYPE_COMMENT:	segment = commentSegment	= new LobbyChatItemCommentSegment(owner as FastList);	break;
		case TYPE_BATTLE:	segment = battleSegment		= new LobbyChatItemBattleSegment( owner as FastList); 	break;
		case TYPE_EMOTE:	segment = emoteSegment		= new LobbyChatItemBalloonEmoteSegment( owner as FastList); 	break;
		case TYPE_CONFIRM:	segment = confirmSegment	= new LobbyChatItemConfirmSegment(owner as FastList); 
			segment.addEventListener(Event.TRIGGERED, confirmSegment_triggeredHandler);
			break;
	}
	
	segment.layoutData = fitLayoutData;
	return segment;
}
}
}