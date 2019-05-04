package com.gerantech.towercraft.controls.segments.lobby
{
import com.gerantech.towercraft.controls.FastList;
import com.gerantech.towercraft.controls.segments.ChatSegment;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import dragonBones.events.EventObject;
import dragonBones.starling.StarlingArmatureDisplay;
import dragonBones.starling.StarlingEvent;
import feathers.layout.AnchorLayoutData;
import starling.events.Event;

public class LobbyChatItemBalloonEmoteSegment extends LobbyChatItemBalloonSegment
{
private var labelDisplay:ShadowLabel;
private var emoteArmature:StarlingArmatureDisplay;

public function LobbyChatItemBalloonEmoteSegment(owner:FastList) { super(owner); }
override public function init():void
{
	super.init();
	height = 280;
	whoSkinLayout.right = mySkinLayout.left = 600;

	emoteArmature = ChatSegment.factory.buildArmatureDisplay("emote");
	emoteArmature.touchable = false;
	emoteArmature.y = height - 20;
	addChild(emoteArmature);
	
	addEventListener(Event.TRIGGERED, triggeredHandler);
}

override public function commitData(_data:ISFSObject, index:int):void
{
	super.commitData(_data, index);
	emoteArmature.x = itsMe ? 840 : 240;
	play();
}

private function play():void 
{
	if(!emoteArmature.hasEventListener(EventObject.FRAME_EVENT) )
		emoteArmature.addEventListener(EventObject.FRAME_EVENT, emoteArmature_frameEventHandler);
	emoteArmature.animation.gotoAndPlayByTime("st-" + data.getInt("e"), 0, 1);	
}

protected function emoteArmature_frameEventHandler(event:StarlingEvent) : void 
{
	emoteArmature.removeEventListener(EventObject.FRAME_EVENT, emoteArmature_frameEventHandler);
	if( event.eventObject.name == "loops" )
		emoteArmature.animation.gotoAndPlayByTime(event.eventObject.animationState.name, 0, event.eventObject.data.getInt(0));
}

protected function triggeredHandler(event:Event) : void 
{
	play();
}
}
}