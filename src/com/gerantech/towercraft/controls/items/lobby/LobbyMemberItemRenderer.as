package com.gerantech.towercraft.controls.items.lobby
{
import com.gerantech.towercraft.controls.items.AbstractTouchableListItemRenderer;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.MainTheme;
import com.gerantech.towercraft.utils.StrUtils;
import feathers.controls.ImageLoader;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import flash.geom.Rectangle;
import starling.display.Image;
import starling.events.Event;
import starling.events.Touch;

public class LobbyMemberItemRenderer extends AbstractTouchableListItemRenderer
{
public function LobbyMemberItemRenderer(){ super(); }

static public var RANK_LAYOUT:AnchorLayoutData;
static public var NAME_LAYOUT:AnchorLayoutData;
static public var POINT_LAYOUT:AnchorLayoutData;
static public var ROLE_DISPLAY:AnchorLayoutData;
static public var ACTIVITY_LAYOUT:AnchorLayoutData;
static public var POINT_BG_LAYOUT:AnchorLayoutData;
static public var LEAGUE_IC_LAYOUT:AnchorLayoutData;
static public var LEAGUE_BG_LAYOUT:AnchorLayoutData;

private var leagueIconDisplay:ImageLoader;
private var leagueBGDisplay:ImageLoader;
private var pointDisplay:ShadowLabel;
private var rankDisplay:ShadowLabel;
private var nameDisplay:ShadowLabel;
private var activityDisplay:RTLLabel;
private var roleDisplay:RTLLabel;
private var leagueIndex:int;
private var mySkin:Image;

override protected function initialize():void
{
	super.initialize();
	height = 110;
	layout = new AnchorLayout();

	mySkin = new Image(appModel.theme.itemRendererUpSkinTexture);
	mySkin.scale9Grid = MainTheme.ITEM_RENDERER_SCALE9_GRID;
	backgroundSkin = mySkin;
	
	var rankBackground:ImageLoader = new ImageLoader();
	rankBackground.scale9Grid = MainTheme.ROUND_SMALL_SCALE9_GRID;
	rankBackground.source = appModel.theme.roundSmallInnerSkin;
	rankBackground.width = rankBackground.height = 84;
	rankBackground.layoutData = RANK_LAYOUT;
	rankBackground.pixelSnapping = false;
	addChild(rankBackground);
	
	var pointBackground:ImageLoader = new ImageLoader();
	pointBackground.scale9Grid = MainTheme.ROUND_SMALL_SCALE9_GRID;
	pointBackground.source = appModel.theme.roundSmallInnerSkin;
	pointBackground.layoutData = POINT_BG_LAYOUT;
	pointBackground.pixelSnapping = false;
	pointBackground.color = 0x888888;
	pointBackground.height = 84;
	pointBackground.width = 210
	addChild(pointBackground);
	
	var pointIconDisplay:ImageLoader = new ImageLoader();
	pointIconDisplay.source = Assets.getTexture("res-2", "gui");
	pointIconDisplay.height = pointIconDisplay.width = 76;
	pointIconDisplay.layoutData = POINT_BG_LAYOUT;
	addChild(pointIconDisplay);

	leagueBGDisplay = new ImageLoader();
	leagueBGDisplay.layoutData = LEAGUE_BG_LAYOUT;
	leagueBGDisplay.height = 88;
	leagueBGDisplay.width = 80;
	addChild(leagueBGDisplay);

	leagueIconDisplay = new ImageLoader();
	leagueIconDisplay.height = leagueIconDisplay.width = 60;
	leagueIconDisplay.layoutData = LEAGUE_IC_LAYOUT;
	addChild(leagueIconDisplay);
	
	// labels .........
	rankDisplay = new ShadowLabel("", 1, 0, "center", null, false, null, 0.7);
	rankDisplay.layoutData = RANK_LAYOUT;
	rankDisplay.width = 84;
	addChild(rankDisplay);
	
	nameDisplay = new ShadowLabel("", 1, 0, null, null, false, null, 0.7);
	nameDisplay.layoutData = NAME_LAYOUT;
	addChild(nameDisplay);
	
	pointDisplay = new ShadowLabel("", 1, 0, "center", null, false, null, 0.7);
	pointDisplay.width = 160;
	pointDisplay.layoutData = POINT_LAYOUT;
	addChild(pointDisplay);
	
	roleDisplay = new RTLLabel("", 0, null, null, false, null, 0.6);
	roleDisplay.layoutData = ROLE_DISPLAY;
	addChild(roleDisplay);

	/*rankDisplay = new ShadowLabel("", 1, 0, "center", null, false, null, 0.7);
	rankDisplay.width = 80;
	rankDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?NaN:20, NaN, appModel.isLTR?20:NaN, NaN, 0);
	addChild(rankDisplay);
	
	nameDisplay = new ShadowLabel("", 1, 0, null, null, false, null, 0.8);
	nameDisplay.layoutData = new AnchorLayoutData(10, appModel.isLTR?NaN:208, NaN, appModel.isLTR?205:NaN);
	addChild(nameDisplay);
	
	pointsDisplay = new RTLLabel("", 0, "center", null, false, null, 0.7);
	pointsDisplay.width = 180;
	pointsDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?280:NaN, NaN, appModel.isLTR?NaN:280, NaN, 0);
	addChild(pointsDisplay);*/
	
	activityDisplay = new RTLLabel("", 0, "center", null, false, null, 0.8);
	activityDisplay.width = 160;
	activityDisplay.layoutData = ACTIVITY_LAYOUT;
	addChild(activityDisplay);
	
	addEventListener(Event.TRIGGERED, item_triggeredHandler);
}

override protected function commitData():void
{
	super.commitData();
	if( _data == null || _owner == null )
		return;
	
	leagueIndex = player.get_arena(_data.point);
	rankDisplay.text = StrUtils.getNumber(index + 1);
	nameDisplay.text = _data.name ;
	roleDisplay.text = loc("lobby_role_" + _data.permission);
	pointDisplay.text = StrUtils.getNumber(_data.point);
	activityDisplay.text = StrUtils.getNumber(_data.activity);
	leagueBGDisplay.source = Assets.getTexture("leagues/circle-" + (leagueIndex % 2) + "-small", "gui");
	leagueIconDisplay.source = Assets.getTexture("leagues/" + Math.floor(leagueIndex * 0.5), "gui");
	mySkin.color = _data.id == player.id ? 0xAAFFFF : 0xFFFFFF;
}
protected function item_triggeredHandler(event:Event):void
{
	owner.dispatchEventWith(FeathersEventType.FOCUS_IN, false, this);
}
public function getTouch():Touch
{
	return touch;
}
}
}