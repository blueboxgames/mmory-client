package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.MainTheme;
import com.smartfoxserver.v2.entities.Buddy;
import com.smartfoxserver.v2.entities.variables.SFSBuddyVariable;
import feathers.controls.ImageLoader;
import feathers.controls.LayoutGroup;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.skins.ImageSkin;
import flash.text.engine.ElementFormat;
import starling.events.Event;
import starling.events.Touch;

public class BuddyItemRenderer extends AbstractTouchableListItemRenderer
{
private static const DEFAULT_TEXT_COLOR:uint = 0xDDFFFF;

private var nameDisplay:RTLLabel;
private var nameShadowDisplay:RTLLabel;
private var pointDisplay:RTLLabel;
private var pointIconDisplay:ImageLoader;
private var inviteDisplay:RTLLabel;
private var _isInviteButton:Boolean;
private var mySkin:ImageSkin;
private var statusSkin:ImageSkin;
private var buddy:Buddy;
private var statusDisplay:LayoutGroup;

public function getTouch():Touch
{
	return touch;
}

public function BuddyItemRenderer(){}
override protected function initialize():void
{
	super.initialize();
	
	layout = new AnchorLayout();
	var padding:int = 36;
	
	mySkin = new ImageSkin(appModel.theme.itemRendererUpSkinTexture);
	mySkin.scale9Grid = MainTheme.ITEM_RENDERER_SCALE9_GRID
	backgroundSkin = mySkin;

	statusSkin = new ImageSkin(appModel.theme.buttonUpSkinTexture);
	statusSkin.scale9Grid = MainTheme.BUTTON_SCALE9_GRID;
	statusSkin.setTextureForState("Available", appModel.theme.buttonUpSkinTexture );
	statusSkin.setTextureForState("Away", appModel.theme.buttonDisabledSkinTexture );
	statusSkin.setTextureForState("Occupied", appModel.theme.buttonDangerUpSkinTexture );
	
	statusDisplay = new LayoutGroup();
	statusDisplay.backgroundSkin = statusSkin;
	statusDisplay.width = statusDisplay.height = 50;
	statusDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?NaN:padding, NaN, appModel.isLTR?padding:NaN, NaN, -padding/10);
	addChild(statusDisplay);
	
	nameShadowDisplay = new RTLLabel("", 0, null, null, false, null, 0.8);
	nameShadowDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?NaN:padding*3, NaN, appModel.isLTR?padding*3:NaN, NaN, 0);
	nameShadowDisplay.pixelSnapping = false;
	addChild(nameShadowDisplay);
	
	nameDisplay = new RTLLabel("", DEFAULT_TEXT_COLOR, null, null, false, null, 0.8);
	nameDisplay.pixelSnapping = false;
	nameDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?NaN:padding*3, NaN, appModel.isLTR?padding*3:NaN, NaN, -padding/12);
	addChild(nameDisplay);
	
	pointDisplay = new RTLLabel("", 1, appModel.isLTR?"right":"left", null, false, null, 1);
	pointDisplay.pixelSnapping = false;
	pointDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?padding*3.2:NaN, NaN, appModel.isLTR?NaN:padding*3.2, NaN, 0);
	addChild(pointDisplay);
	
	pointIconDisplay = new ImageLoader();
	pointIconDisplay.width = 80;
	pointIconDisplay.layoutData = new AnchorLayoutData(padding/3, appModel.isLTR?padding/2:NaN, padding/2, appModel.isLTR?NaN:padding/2);
	addChild(pointIconDisplay);
	
	inviteDisplay = new RTLLabel(loc("invite_friend"), DEFAULT_TEXT_COLOR, "center");
	inviteDisplay.pixelSnapping = false;
	inviteDisplay.layoutData = new AnchorLayoutData(NaN, padding, NaN, padding, NaN, -padding/12);
	addChild(inviteDisplay);
	
	addEventListener(Event.TRIGGERED, item_triggeredHandler);
}

override protected function commitData():void
{
	super.commitData();
	if(_data == null || _owner == null)
		return;
	buddy = _data as Buddy;
	
	isInviteButton = buddy == null;
	height = (isInviteButton?160:120);
	statusDisplay.visible = !isInviteButton;
	if( isInviteButton )
		return;
	
	var rankIndex:int = index+1;
	nameDisplay.text = rankIndex + ".  " + buddy.nickName ;
	nameShadowDisplay.text = rankIndex + ".  " + buddy.nickName ;
	var point:int = buddy.containsVariable("$point") ? buddy.getVariable("$point").getIntValue() : 0;
	pointDisplay.text = point>0 ? ("" + point) : "";
	pointIconDisplay.source = Assets.getTexture("leagues/" + player.get_arena(point), "gui");
	//trace(_data.i, player.id);
	var itsMe:Boolean = buddy.nickName == player.nickName;
	var fs:int = AppModel.instance.theme.gameFontSize * (itsMe?1:0.9);
	var fc:int = itsMe?MainTheme.PRIMARY_TEXT_COLOR:DEFAULT_TEXT_COLOR;
	if( fs != nameDisplay.fontSize )
	{
		nameDisplay.fontSize = fs;
		nameShadowDisplay.fontSize = fs;
		
		nameDisplay.elementFormat = new ElementFormat(nameDisplay.fontDescription, fs, fc);
		nameShadowDisplay.elementFormat = new ElementFormat(nameShadowDisplay.fontDescription, fs, nameShadowDisplay.color);
	}
	mySkin.defaultTexture = itsMe ? appModel.theme.itemRendererSelectedSkinTexture : appModel.theme.itemRendererUpSkinTexture;
	
	// Set status display
	buddy.setVariable( new SFSBuddyVariable("$__BV_STATE__", buddy.isOnline?(buddy.state!="Occupied"?"Available":"Occupied"):"Away"));
	statusSkin.defaultTexture = statusSkin.getTextureForState(buddy.state);
	//trace(buddy.nickName, buddy.state, buddy.isOnline)
}

private function item_triggeredHandler(event:Event):void
{
	owner.dispatchEventWith(FeathersEventType.FOCUS_IN, false, this);
}

public function get isInviteButton():Boolean
{
	return _isInviteButton;
}
public function set isInviteButton(value:Boolean):void
{
	_isInviteButton = value;

	nameDisplay.visible = !_isInviteButton;
	nameShadowDisplay.visible = !_isInviteButton;
	pointDisplay.visible = !_isInviteButton;
	pointIconDisplay.visible = !_isInviteButton;
	inviteDisplay.visible = _isInviteButton;
	
	if( !_isInviteButton )
		return;
	
	mySkin.defaultTexture = _isInviteButton ? appModel.theme.itemRendererSelectedSkinTexture : appModel.theme.itemRendererUpSkinTexture;
/*	tutorials.addEventListener(GameEvent.TUTORIAL_TASKS_FINISH, tutorials_completeHandler);
}

private function tutorials_completeHandler(event:Event):void
{
	if( event.data.name != "buddy_tutorial" || stage == null )
		return;
	var tutorialArrow:TutorialArrow = new TutorialArrow(true);
	tutorialArrow.layoutData = new AnchorLayoutData(height, NaN, NaN, NaN, 0);
	addChild(tutorialArrow);
	UserData.instance.prefs.setInt(PrefsTypes.OFFER_33_FRIENDSHIP, player.prefs.getAsInt(PrefsTypes.OFFER_33_FRIENDSHIP)+50);
*/}
} 
}