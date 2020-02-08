package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.models.vo.FriendData;
import com.gerantech.towercraft.themes.MainTheme;
import com.gerantech.towercraft.utils.StrUtils;

import feathers.controls.ImageLoader;
import feathers.controls.LayoutGroup;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayoutData;

import starling.events.Event;
import starling.events.Touch;

public class BuddyItemRenderer extends RankItemRenderer
{
	static public var STATUS_LAYOUT:AnchorLayoutData;
	
	private var friend:FriendData;
	private var statusSkin:ImageLoader;
	private var statusDisplay:LayoutGroup;

	public function getTouch():Touch
	{
		return touch;
	}

	public function BuddyItemRenderer(){ }
	override protected function initialize():void
	{
		super.initialize();
		
		statusSkin = new ImageLoader();
		statusSkin.scale9Grid = MainTheme.BUTTON_SMALL_SCALE9_GRID;
		statusSkin.layoutData = STATUS_LAYOUT;
		statusSkin.width = 20;
		addChild(statusSkin)

		this.height = 120;
		this.addEventListener(Event.TRIGGERED, item_triggeredHandler);
	}

	override protected function commitData():void
	{
		if(_data == null || _owner == null)
			return;
		this.friend = _data as FriendData;
		var point:int = friend.containsKey("point") ? friend.point : 0;
		this.leagueIndex = player.get_arena(point);
		
		this.nameDisplay.text = friend.name ;
		this.pointDisplay.text = point > 0 ? StrUtils.getNumber(point) : "";
		this.mySkin.color = friend.id == player.id ? 0xAAFFFF : 0xFFFFFF;
		this.rankDisplay.text = StrUtils.getNumber(index + 1);
		this.leagueIconDisplay.source = appModel.assets.getTexture("leagues/" + Math.floor(leagueIndex * 0.5));
		this.leagueBGDisplay.source = appModel.assets.getTexture("leagues/circle-" + (leagueIndex % 2) + "-small");
		
		// // Set status display
		if( friend.status > 0 )
			statusSkin.source = friend.status == 1 ? appModel.theme.buttonSmallUpSkinTexture : appModel.theme.buttonSmallDangerUpSkinTexture;
		else
			statusSkin.source = appModel.theme.buttonSmallDisabledSkinTexture;
	}

	private function item_triggeredHandler(event:Event):void
	{
		owner.dispatchEventWith(FeathersEventType.FOCUS_IN, false, this);
	}
} 
}