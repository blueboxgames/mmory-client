package com.gerantech.towercraft.controls.groups 
{
import com.gerantech.towercraft.Game;
import com.gerantech.towercraft.controls.TowersLayout;
import com.gerantech.towercraft.controls.buttons.SimpleLayoutButton;
import com.gerantech.towercraft.controls.items.offers.BuddyOfferItem;
import com.gerantech.towercraft.controls.screens.DashboardScreen;
import com.gerantech.towercraft.controls.segments.SocialSegment;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.MainTheme;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.skins.ImageSkin;
import flash.geom.Rectangle;
import flash.utils.clearInterval;
import flash.utils.setInterval;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;
import starling.utils.Color;
import starling.events.Event;

/**
* ...
* @author Mansour Djawadi
*/
public class OfferView extends SimpleLayoutButton 
{
public static const INVITE_BUDDY:String = "inviteBuddy";
private var hasItem:Boolean;
private var item:BuddyOfferItem;
private var intervalId:uint;

public function OfferView(){super();}
override protected function initialize() : void
{
	super.initialize();
	
	if( player.inTutorial() )
		return;
	
	layout = new AnchorLayout();
	if( SFSConnection.instance.buddyManager.buddyList.length < 5 )
		addItem(INVITE_BUDDY);
	
	if( !hasItem )
		return;

	var gradient:Image = new ImageSkin( Assets.getTexture("theme/gradeint-right") );
	gradient.scale9Grid = MainTheme.SHADOW_SIDE_SCALE9_GRID;
    gradient.color = Color.BLACK;
    gradient.alpha = 0.6;
	backgroundSkin = gradient;
	
	addEventListener(Event.TRIGGERED, item_triggeredHandler);
	
	alpha = 0;
	Starling.juggler.tween(this, 1, {delay:2, alpha:1, y:120, transition:Transitions.EASE_OUT});
	intervalId = setInterval(punchIcon, 8000);
}

private function punchIcon():void 
{
	alpha = 0.3;
	Starling.juggler.tween(this, 1, {alpha:1});
}

private function addItem(itemType:String):void 
{
	hasItem = true;
	switch( itemType )
	{
		case INVITE_BUDDY :
			item = new BuddyOfferItem(item);
			break;
	}
	item.touchable = false;
	item.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	addChild(item);
}

private function item_triggeredHandler(e:Event):void 
{
	if( item == null )
		return;
	switch( item.type )
	{
		case INVITE_BUDDY :
			DashboardScreen.TAB_INDEX = 3;
			SocialSegment.TAB_INDEX = 2;
			if( appModel.navigator.activeScreenID == Game.DASHBOARD_SCREEN )
			{
				DashboardScreen(appModel.navigator.activeScreen).gotoPage(3);
				return;
			}
			appModel.navigator.popAll();
			appModel.navigator.removeAllPopups();
			appModel.navigator.rootScreenID = Game.DASHBOARD_SCREEN;
		break;
	}
}
override public function dispose():void
{
	Starling.juggler.removeTweens(this);
	clearInterval(intervalId);
	super.dispose();
}
}
}