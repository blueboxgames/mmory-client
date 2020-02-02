package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.utils.StrUtils;
import com.smartfoxserver.v2.entities.Buddy;

import feathers.controls.LayoutGroup;
import feathers.events.FeathersEventType;
import feathers.skins.ImageSkin;

import starling.events.Event;
import starling.events.Touch;

public class BuddyItemRenderer extends RankItemRenderer
{
	private var buddy:Buddy;
	private var statusSkin:ImageSkin;
	private var statusDisplay:LayoutGroup;

	public function getTouch():Touch
	{
		return touch;
	}

	public function BuddyItemRenderer(){ }
	override protected function initialize():void
	{
		super.initialize();
		
		// statusSkin = new ImageSkin(appModel.theme.buttonUpSkinTexture);
		// statusSkin.scale9Grid = MainTheme.BUTTON_SCALE9_GRID;
		// statusSkin.setTextureForState("Available", appModel.theme.buttonUpSkinTexture );
		// statusSkin.setTextureForState("Away", appModel.theme.buttonDisabledSkinTexture );
		// statusSkin.setTextureForState("Occupied", appModel.theme.buttonDangerUpSkinTexture );

		this.height = 110;
		this.addEventListener(Event.TRIGGERED, item_triggeredHandler);
	}

	override protected function commitData():void
	{
		if(_data == null || _owner == null)
			return;
		this.buddy = _data as Buddy;
		var point:int = buddy.containsVariable("$point") ? buddy.getVariable("$point").getIntValue() : 0;
		this.leagueIndex = player.get_arena(point);
		
		this.nameDisplay.text = buddy.nickName ;
		this.pointDisplay.text = point > 0 ? StrUtils.getNumber(point) : "";
		this.mySkin.color = buddy.nickName == player.nickName ? 0xAAFFFF : 0xFFFFFF;
		this.rankDisplay.text = StrUtils.getNumber(index + 1);
		this.leagueIconDisplay.source = appModel.assets.getTexture("leagues/" + Math.floor(leagueIndex * 0.5));
		this.leagueBGDisplay.source = appModel.assets.getTexture("leagues/circle-" + (leagueIndex % 2) + "-small");
		
		// // Set status display
		// buddy.setVariable( new SFSBuddyVariable("$__BV_STATE__", buddy.isOnline?(buddy.state!="Occupied"?"Available":"Occupied"):"Away") as BuddyVariable);
		// statusSkin.defaultTexture = statusSkin.getTextureForState(buddy.state);
		//trace(buddy.nickName, buddy.state, buddy.isOnline)
	}

	private function item_triggeredHandler(event:Event):void
	{
		owner.dispatchEventWith(FeathersEventType.FOCUS_IN, false, this);
	}
} 
}