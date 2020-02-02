package com.gerantech.towercraft.controls.segments
{
import com.gerantech.extensions.share.Share;
import com.gerantech.mmory.core.socials.Lobby;
import com.gerantech.towercraft.controls.FastList;
import com.gerantech.towercraft.controls.groups.ShareImageFactory;
import com.gerantech.towercraft.controls.items.BuddyItemRenderer;
import com.gerantech.towercraft.controls.items.RankItemRenderer;
import com.gerantech.towercraft.controls.overlays.TransitionData;
import com.gerantech.towercraft.controls.popups.ConfirmPopup;
import com.gerantech.towercraft.controls.popups.ProfilePopup;
import com.gerantech.towercraft.controls.popups.SimpleListPopup;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.models.tutorials.TutorialData;
import com.gerantech.towercraft.models.tutorials.TutorialTask;
import com.gerantech.towercraft.themes.MainTheme;
import com.gerantech.towercraft.utils.Localizations;
import com.smartfoxserver.v2.core.SFSBuddyEvent;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.Buddy;
import com.smartfoxserver.v2.entities.SFSBuddy;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSObject;
import com.smartfoxserver.v2.entities.variables.BuddyVariable;
import com.smartfoxserver.v2.entities.variables.SFSBuddyVariable;

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

public class BuddiesSegment extends Segment
{
private var list:FastList;
private var buttonsPopup:SimpleListPopup;
private var buddyCollection:ListCollection;
private var _buttonsEnabled:Boolean = true;
private var share:ShareImageFactory;
public function BuddiesSegment()
{
	SFSConnection.instance.buddyManager.setInited(true);
	SFSConnection.instance.addEventListener(SFSBuddyEvent.BUDDY_VARIABLES_UPDATE,		sfs_buddyVariablesUpdateHandler); 
	SFSConnection.instance.addEventListener(SFSBuddyEvent.BUDDY_ONLINE_STATE_UPDATE,	sfs_buddyVariablesUpdateHandler); 
	SFSConnection.instance.addEventListener(SFSBuddyEvent.BUDDY_ADD,					sfs_buddyChangeHandler); 
	SFSConnection.instance.addEventListener(SFSBuddyEvent.BUDDY_REMOVE,					sfs_buddyChangeHandler); 
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, 				sfs_buddyBattleHandler);
}

override public function updateData():void
{
	super.updateData();
}
override public function init():void
{
	super.init();
	if( initializeCompleted )
		return;
	
	layout = new AnchorLayout();
	
	var padding:int = 72;

	RankItemRenderer.RANK_LAYOUT = new AnchorLayoutData(NaN, appModel.isLTR?NaN:16, NaN, appModel.isLTR?16:NaN, NaN, 0);
	RankItemRenderer.POINT_LAYOUT = new AnchorLayoutData(NaN, appModel.isLTR?96:NaN, NaN, appModel.isLTR?NaN:96, NaN, 0);
	RankItemRenderer.NAME_LAYOUT = new AnchorLayoutData(NaN, appModel.isLTR?NaN:205, NaN, appModel.isLTR?205:NaN, NaN, 0);
	RankItemRenderer.POINT_BG_LAYOUT = new AnchorLayoutData(NaN, appModel.isLTR?16:NaN, NaN, appModel.isLTR?NaN:16, NaN, 0);
	RankItemRenderer.LEAGUE_BG_LAYOUT = new AnchorLayoutData(NaN, appModel.isLTR?NaN:112, NaN, appModel.isLTR?112:NaN, NaN, 0);
	RankItemRenderer.LEAGUE_IC_LAYOUT = new AnchorLayoutData(NaN, appModel.isLTR?NaN:122, NaN, appModel.isLTR?122:NaN, NaN, -5);
	
	var listLayout:VerticalLayout = new VerticalLayout();
	listLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
	listLayout.paddingTop = 200;
	listLayout.gap = 16;
	
	list = new FastList();
	list.layout = listLayout;
	list.layoutData = new AnchorLayoutData(padding, padding, padding, padding);
	addChild(list);
	
	buddyCollection = new ListCollection(SFSConnection.instance.buddyManager.buddyList);
	var me:SFSBuddy = new SFSBuddy(0, player.id + "");
	me.setVariable( new SFSBuddyVariable("$__BV_NICKNAME__", player.nickName) as BuddyVariable);
	me.setVariable( new SFSBuddyVariable("$__BV_STATE__", "Available") as BuddyVariable);
	me.setVariable( new SFSBuddyVariable("$point", player.get_point()) as BuddyVariable);
	//me.setVariable( new SFSBuddyVariable("$room", SFSConnection.instance.myLobby.name));
	buddyCollection.addItem( me );
	list.addEventListener(FeathersEventType.FOCUS_IN, list_focusInHandler);
	list.itemRendererFactory = function():IListItemRenderer { return new BuddyItemRenderer(); }
	list.dataProvider = buddyCollection;

	var invitationButton:Button = new Button();
	invitationButton.height = 150;
	invitationButton.label = loc("invite_friend");
	invitationButton.styleName = MainTheme.STYLE_BUTTON_SMALL_HILIGHT;
	invitationButton.layoutData = new AnchorLayoutData(padding, padding, NaN, padding);
	invitationButton.addEventListener(Event.TRIGGERED, invitationButton_triggeredHandler);
	addChild(invitationButton);

	initializeCompleted = true;
	
	showTutorials();
}

private function showTutorials():void
{
	share = new ShareImageFactory();
	// Starling.current.nativeStage.addChild(share);

	if( SFSConnection.instance.buddyManager.buddyList.length >= 3 || game.sessionsCount % 5 != 0 )
		return;
	var tutorialData:TutorialData = new TutorialData("buddy_tutorial");
	tutorialData.addTask(new TutorialTask(TutorialTask.TYPE_MESSAGE, loc("tutor_buddy_0", [Lobby.buddyInviterReward, Lobby.buddyInviteeReward]), null, 1000, 1000, 0));
	tutorials.show(tutorialData);
}

protected function sfs_buddyVariablesUpdateHandler(event:SFSBuddyEvent):void
{
	if( buddyCollection == null || buddyCollection.length == 0 )
		return;
	
	var buddy:Buddy = event.params.buddy as Buddy;
	var buddyIndex:int = buddyCollection.getItemIndex(buddy);
	buddyCollection.data[buddyIndex] = buddy;
	buddyCollection.updateItemAt(buddyIndex);
}
protected function sfs_buddyChangeHandler(event:SFSBuddyEvent):void
{
	if( buddyCollection == null || buddyCollection.length == 0 )
		return;
	
	var buddy:Buddy = event.params.buddy as Buddy;
	if( event.type == SFSBuddyEvent.BUDDY_ADD )
		buddyCollection.addItemAt(buddy, buddyCollection.length - 2);
	else if( event.type == SFSBuddyEvent.BUDDY_REMOVE )
		buddyCollection.removeItemAt(buddyCollection.getItemIndex(buddy));
}

protected function invitationButton_triggeredHandler(event:Event):void
{
	var subject:String = loc("invite_friend");
	var text:String = loc("invite_friend_message") + "\n" + Localizations.instance.get("buddy_invite_url", [player.invitationCode]);
	Share.instance.shareImage(share.export(), subject, text);
	// trace(subject, text);
}

protected function list_focusInHandler(event:Event):void
{
	var selectedItem:BuddyItemRenderer = event.data as BuddyItemRenderer;
	if( selectedItem == null )
		return;
	
	var buddy:Buddy = selectedItem.data as Buddy;
	if( buddy.nickName == player.nickName )
		buttonsPopup = new SimpleListPopup("buddy_profile");
	else
		buttonsPopup = new SimpleListPopup("buddy_profile", "buddy_remove", buddy.state == "Occupied"?"buddy_spectate$":"buddy_battle");
	buttonsPopup.data = buddy;
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
	var buddy:Buddy = buttonsPopup.data as Buddy;
	switch( event.data )
	{
		case "buddy_profile":
			appModel.navigator.addPopup( new ProfilePopup({name:buddy.nickName, id:int(buddy.name)}) );
			break;
		case "buddy_battle":
			appModel.navigator.invokeBuddyBattle(buddy);
			break;
		case "buddy_remove":
			removeFriend(buddy);
			break;
		case "buddy_spectate$":
			spectate(buddy);
			break;
	}
}

protected function sfs_buddyBattleHandler(event:SFSEvent):void
{
	if( event.params.cmd != SFSCommands.BUDDY_BATTLE )
		return;
	var p:ISFSObject = event.params.params as SFSObject;
	if( p.getInt("bs") == 0 && p.getInt("s") != AppModel.instance.game.player.id )
		return;
	buttonsEnabled = p.getInt("bs") > 0;
}

private function spectate(buddy:Buddy):void
{
	if( !buddy.containsVariable("br") )
		return;
	appModel.navigator.runBattle(0, false, buddy.name, 2);
}

private function removeFriend(buddy:Buddy):void
{
	var confirm:ConfirmPopup = new ConfirmPopup(loc("buddy_remove_confirm"), loc("popup_yes_label"));
	confirm.addEventListener(Event.SELECT, confirm_selectHandler);
	confirm.acceptStyle = MainTheme.STYLE_BUTTON_SMALL_DANGER
	appModel.navigator.addPopup(confirm);
	function confirm_selectHandler ( event:Event ):void {
		confirm.removeEventListener(Event.SELECT, confirm_selectHandler);
		var params:SFSObject = new SFSObject();
		params.putText("buddyId", buddy.name);
		SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_buddyRemoveHandler);
		SFSConnection.instance.sendExtensionRequest(SFSCommands.BUDDY_REMOVE, params);
	}
}

protected function sfs_buddyRemoveHandler(event:SFSEvent):void
{
	if( event.params.cmd != SFSCommands.BUDDY_REMOVE )
		return;
	
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_buddyRemoveHandler);
	appModel.navigator.addLog(loc("buddy_remove_message"));
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
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, 			sfs_buddyRemoveHandler);
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, 			sfs_buddyBattleHandler);
	SFSConnection.instance.removeEventListener(SFSBuddyEvent.BUDDY_VARIABLES_UPDATE,	sfs_buddyVariablesUpdateHandler); 
	SFSConnection.instance.removeEventListener(SFSBuddyEvent.BUDDY_ONLINE_STATE_UPDATE,	sfs_buddyVariablesUpdateHandler); 
	SFSConnection.instance.removeEventListener(SFSBuddyEvent.BUDDY_ADD,					sfs_buddyChangeHandler); 
	SFSConnection.instance.removeEventListener(SFSBuddyEvent.BUDDY_REMOVE,				sfs_buddyChangeHandler); 
	super.dispose();
}
}
}