package com.gerantech.towercraft.controls.segments
{
import com.gerantech.extensions.share.Share;
import com.gerantech.mmory.core.others.TrophyReward;
import com.gerantech.towercraft.Game;
import com.gerantech.towercraft.controls.FastList;
import com.gerantech.towercraft.controls.groups.ShareImageFactory;
import com.gerantech.towercraft.controls.items.BuddyItemRenderer;
import com.gerantech.towercraft.controls.items.LeagueItemRenderer;
import com.gerantech.towercraft.controls.items.RankItemRenderer;
import com.gerantech.towercraft.controls.overlays.TransitionData;
import com.gerantech.towercraft.controls.popups.ConfirmPopup;
import com.gerantech.towercraft.controls.popups.ProfilePopup;
import com.gerantech.towercraft.controls.popups.SimpleListPopup;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.tutorials.TutorialData;
import com.gerantech.towercraft.models.tutorials.TutorialTask;
import com.gerantech.towercraft.models.vo.FriendData;
import com.gerantech.towercraft.themes.MainTheme;
import com.gerantech.towercraft.utils.Localizations;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSObject;

import feathers.controls.Button;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalLayout;

import flash.geom.Rectangle;

import starling.animation.Transitions;
import starling.events.Event;
import com.gerantech.mmory.core.constants.MessageTypes;

public class BuddiesSegment extends Segment
{
private var list:FastList;
private var buttonsPopup:SimpleListPopup;
private var collection:ListCollection;
private var _buttonsEnabled:Boolean = true;
private var share:ShareImageFactory;
public function BuddiesSegment()
{
	collection = new ListCollection();
	collection.addItem( new FriendData().init(player.id, player.nickName, player.get_point(), 1, 0) );
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, this.sfs_responseHandler);
}

override public function updateData():void
{
	super.updateData();
	SFSConnection.instance.sendExtensionRequest(SFSCommands.BUDDY_DATA);
}
override public function init():void
{
	super.init();
	if( initializeCompleted )
		return;
	
	layout = new AnchorLayout();
	share = new ShareImageFactory();
	updateData();
	
	var padding:int = 72;

	BuddyItemRenderer.STATUS_LAYOUT = new AnchorLayoutData(0, appModel.isLTR?NaN:0, 0, appModel.isLTR?0:NaN);
	RankItemRenderer.RANK_LAYOUT = new AnchorLayoutData(NaN, appModel.isLTR?NaN:36, NaN, appModel.isLTR?36:NaN, NaN, 0);
	RankItemRenderer.POINT_LAYOUT = new AnchorLayoutData(NaN, appModel.isLTR?116:NaN, NaN, appModel.isLTR?NaN:116, NaN, 0);
	RankItemRenderer.NAME_LAYOUT = new AnchorLayoutData(NaN, appModel.isLTR?NaN:225, NaN, appModel.isLTR?225:NaN, NaN, 0);
	RankItemRenderer.POINT_BG_LAYOUT = new AnchorLayoutData(NaN, appModel.isLTR?16:NaN, NaN, appModel.isLTR?NaN:16, NaN, 0);
	RankItemRenderer.LEAGUE_BG_LAYOUT = new AnchorLayoutData(NaN, appModel.isLTR?NaN:132, NaN, appModel.isLTR?132:NaN, NaN, 0);
	RankItemRenderer.LEAGUE_IC_LAYOUT = new AnchorLayoutData(NaN, appModel.isLTR?NaN:142, NaN, appModel.isLTR?142:NaN, NaN, -5);
	
	var listLayout:VerticalLayout = new VerticalLayout();
	listLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
	listLayout.paddingTop = 200;
	listLayout.gap = 16;
	
	list = new FastList();
	list.layout = listLayout;
	list.layoutData = new AnchorLayoutData(padding, padding, padding, padding);
	list.addEventListener(FeathersEventType.FOCUS_IN, list_focusInHandler);
	list.itemRendererFactory = function():IListItemRenderer { return new BuddyItemRenderer(); }
	list.dataProvider = collection;
	addChild(list);

	var invitationButton:Button = new Button();
	invitationButton.height = 150;
	invitationButton.label = loc("invite_friend");
	invitationButton.styleName = MainTheme.STYLE_BUTTON_SMALL_HILIGHT;
	invitationButton.layoutData = new AnchorLayoutData(padding, padding, NaN, padding);
	invitationButton.addEventListener(Event.TRIGGERED, invitationButton_triggeredHandler);
	addChild(invitationButton);

	initializeCompleted = true;
}

protected function sfs_responseHandler(event:SFSEvent):void
{
	var params:SFSObject = SFSObject(event.params.params);
	if( event.params.cmd == SFSCommands.BUDDY_DATA )
	{
		if( !params.containsKey("items") )
			return;
		var items:ISFSArray = params.getSFSArray("items");
		var len:int = items.size();
		for(var i:int = 0; i < len; i++)
		{
			var item:ISFSObject = items.getSFSObject(i);
			var index:int = find(item.getInt("id"));
			if( index > -1 )
			{
				FriendData(collection[index]).update(item);
				collection.updateItemAt(index);
			}
			else
			{
				collection.addItem(new FriendData().update(item));
			}
		}
	}

	if( event.params.cmd == SFSCommands.BUDDY_REMOVE && params.getInt("response") == MessageTypes.RESPONSE_SUCCEED )
	{
		index = find(params.getInt("id"));
		if( index > -1 )
			collection.removeItemAt(index);
		appModel.navigator.addLog(loc("buddy_remove_message"));
	}


	function find(id:int):int{
		for(var b:int = 0; b < collection.length; b++)
			if(collection.getItemAt(b).id == id)
				return b;
		return -1;
	}

	showTutorials();
}

private function showTutorials():void
{
	if( collection.length >= 3 || game.sessionsCount % 3 != 0 || Math.random() > 0.3 )
		return;
	var tutorialData:TutorialData = new TutorialData("buddy_tutorial");
	var prize:int = TrophyReward(game.friendRoad.rewards[0]).value;
	tutorialData.addTask(new TutorialTask(TutorialTask.TYPE_MESSAGE, loc("tutor_buddy_0", [prize, prize]), null, 1000, 1000, 0));
	tutorials.show(tutorialData);
}

protected function invitationButton_triggeredHandler(event:Event):void
{
	var subject:String = loc("invite_friend");
	var text:String = loc("invite_friend_message") + "\n" + Localizations.instance.get("buddy_invite_url", [player.invitationCode]);
	Share.instance.shareImage(share.export(), subject, text);
	trace(subject, text);
}

protected function list_focusInHandler(event:Event):void
{
	var selectedItem:BuddyItemRenderer = event.data as BuddyItemRenderer;
	if( selectedItem == null )
		return;
	
	var friend:FriendData = selectedItem.data as FriendData;
	if( friend.id == player.id )
		buttonsPopup = new SimpleListPopup("buddy_profile");
	else
		buttonsPopup = new SimpleListPopup("buddy_road", "buddy_profile", "buddy_remove", friend.status==2?"buddy_spectate":"buddy_battle");
	buttonsPopup.data = friend;
	buttonsPopup.addEventListener(Event.SELECT, buttonsPopup_selectHandler);
	buttonsPopup.addEventListener(Event.CLOSE, buttonsPopup_selectHandler);
	buttonsPopup.buttonsWidth = 360;
	buttonsPopup.buttonHeight = 120;
	var floatingW:int = buttonsPopup.buttonsWidth + buttonsPopup.padding * 2;
	var floatingH:int = buttonsPopup.buttonHeight * buttonsPopup.buttons.length + buttonsPopup.padding * 2;
	var floatingY:int = selectedItem.getBounds(stage).y;
	var ti:TransitionData = new TransitionData(0.2);
	var to:TransitionData = new TransitionData(0.2);
	to.sourceConstrain = ti.destinationConstrain = this.getBounds(stage);
	ti.transition = Transitions.EASE_OUT_BACK;
	to.sourceAlpha = 1;
	to.destinationAlpha = 0;
	to.destinationBound = ti.sourceBound = new Rectangle(selectedItem.getTouch().globalX - floatingW * 0.5, floatingY + buttonsPopup.buttonHeight * 0.5 - floatingH * 0.4, floatingW, floatingH * 0.8);
	to.sourceBound = ti.destinationBound = new Rectangle(selectedItem.getTouch().globalX - floatingW * 0.5, floatingY + buttonsPopup.buttonHeight * 0.5 - floatingH * 0.5, floatingW, floatingH);
	buttonsPopup.transitionIn = ti;
	buttonsPopup.transitionOut = to;
	appModel.navigator.addPopup(buttonsPopup);
}

private function buttonsPopup_selectHandler(event:Event):void
{
	event.currentTarget.removeEventListener(Event.SELECT, buttonsPopup_selectHandler);
	event.currentTarget.removeEventListener(Event.CLOSE, buttonsPopup_selectHandler);
	
	if( event.type == Event.CLOSE )
		return;
	
	var buttonsPopup:SimpleListPopup = event.currentTarget as SimpleListPopup;
	var friend:FriendData = buttonsPopup.data as FriendData;
	switch( event.data )
	{
		case "buddy_road":
      LeagueItemRenderer.STEP = friend.step;
      LeagueItemRenderer.LEAGUE = friend.id;
      LeagueItemRenderer.POINT = friend.point;
			appModel.navigator.getScreen(Game.BUDDY_ROAD).properties.title = loc("buddy_road_title", [friend.name]);
			appModel.navigator.pushScreen(Game.BUDDY_ROAD);
			break;
		case "buddy_profile":
			appModel.navigator.addPopup( new ProfilePopup({name:friend.name, id:friend.id}) );
			break;
		case "buddy_battle":
			appModel.navigator.invokeBuddyBattle(friend);
			break;
		case "buddy_remove":
			removeFriend(friend.id);
			break;
		case "buddy_spectate":
			spectate(friend);
			break;
	}
}


private function spectate(friend:FriendData):void
{
	if( friend.status < 2 )
		return;
	appModel.navigator.runBattle(0, false, friend.id+"", 2);
}

private function removeFriend(friendId:int):void
{
	var confirm:ConfirmPopup = new ConfirmPopup(loc("buddy_remove_confirm"), loc("popup_yes_label"));
	confirm.addEventListener(Event.SELECT, confirm_selectHandler);
	confirm.acceptStyle = MainTheme.STYLE_BUTTON_SMALL_DANGER;
	confirm.declineStyle = MainTheme.STYLE_BUTTON_SMALL_NEUTRAL;
	appModel.navigator.addPopup(confirm);
	function confirm_selectHandler ( event:Event ):void {
		confirm.removeEventListener(Event.SELECT, confirm_selectHandler);
		var params:SFSObject = new SFSObject();
		params.putInt("id", friendId);
		SFSConnection.instance.sendExtensionRequest(SFSCommands.BUDDY_REMOVE, params);
	}
}

public function set buttonsEnabled(value:Boolean):void
{
	if( _buttonsEnabled == value )
		return;
	
	_buttonsEnabled = value;
	dispatchEventWith(Event.READY, true, _buttonsEnabled);
	list.isEnabled = _buttonsEnabled;
}

override public function dispose():void
{
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, this.sfs_responseHandler);
	super.dispose();
}
}
}