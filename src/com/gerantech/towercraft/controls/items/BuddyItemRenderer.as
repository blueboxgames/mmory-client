package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.controls.groups.GradientHilight;
import com.gerantech.towercraft.models.vo.FriendData;
import com.gerantech.towercraft.themes.MainTheme;
import com.gerantech.towercraft.utils.StrUtils;

import feathers.controls.ImageLoader;
import feathers.controls.LayoutGroup;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayoutData;
import feathers.layout.RelativePosition;

import starling.events.Event;
import starling.events.Touch;

public class BuddyItemRenderer extends RankItemRenderer
{
	static public var STATUS_LAYOUT:AnchorLayoutData;
	
	public var collectible:Boolean;
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
		this.leagueIndex = player.get_arena(friend.point);
		this.collectible = friend.step < game.friendRoad.calculateStep(friend.point - friend.start);

		this.nameDisplay.text = friend.name ;
		this.pointDisplay.text = friend.point > 0 ? StrUtils.getNumber(friend.point) : "";
		this.rankDisplay.text = StrUtils.getNumber(index + 1);
		this.leagueIconDisplay.source = appModel.assets.getTexture("leagues/" + Math.floor(leagueIndex * 0.5));
		this.leagueBGDisplay.source = appModel.assets.getTexture("leagues/circle-" + (leagueIndex % 2) + "-small");
		
		// Set status display
		if( friend.status > 0 )
			statusSkin.source = friend.status == 1 ? appModel.theme.buttonSmallUpSkinTexture : appModel.theme.buttonSmallDangerUpSkinTexture;
		else
			statusSkin.source = appModel.theme.buttonSmallDisabledSkinTexture;
		
		this.changeBackground();
	}

	private function item_triggeredHandler(event:Event):void
	{
		owner.dispatchEventWith(FeathersEventType.FOCUS_IN, false, this);
	}

	private function changeBackground():void
	{
		this.mySkin.color = friend.id == player.id ? 0x99FFFF : (this.collectible ? 0xf9d712 : 0xFFFFFF);
		if( this.collectible || friend.id == player.id )
			this.mySkin.texture = appModel.assets.getTexture("theme/item-renderer-white-skin")
		if( !this.collectible || friend.id == player.id )
			return;
		var hilight:GradientHilight = new GradientHilight();
		hilight.layoutData = new AnchorLayoutData(4, 4, 4, 4);
		hilight.direction = RelativePosition.RIGHT;
		hilight.alpha = 0.5;
		this.addChildAt(hilight, 1)
	}
} 
}