package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.MainTheme;
import com.gerantech.towercraft.utils.StrUtils;
import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import starling.display.Image;

public class RankItemRenderer extends AbstractTouchableListItemRenderer
{
static public var RANK_LAYOUT:AnchorLayoutData;
static public var NAME_LAYOUT:AnchorLayoutData;
static public var POINT_LAYOUT:AnchorLayoutData;
static public var POINT_BG_LAYOUT:AnchorLayoutData;
static public var LEAGUE_IC_LAYOUT:AnchorLayoutData;
static public var LEAGUE_BG_LAYOUT:AnchorLayoutData;

private var _visibility:Boolean = true;
private var leagueIconDisplay:ImageLoader;
private var leagueBGDisplay:ImageLoader;
private var pointDisplay:ShadowLabel;
private var rankDisplay:ShadowLabel;
private var nameDisplay:ShadowLabel;
private var leagueIndex:int;
private var mySkin:Image;

public function RankItemRenderer(){}
override protected function initialize():void
{
	super.initialize();
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
	pointBackground.width = 250
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

	rankDisplay = new ShadowLabel("", 1, 0, "center", null, false, null, 0.7);
	rankDisplay.layoutData = RANK_LAYOUT;
	rankDisplay.width = 84;
	addChild(rankDisplay);
	
	nameDisplay = new ShadowLabel("", 1, 0, null, null, false, null, 0.8);
	nameDisplay.layoutData = NAME_LAYOUT;
	addChild(nameDisplay);
	
	pointDisplay = new ShadowLabel("", 1, 0, "center", null, false, null, 0.7);
	pointDisplay.width = 160;
	pointDisplay.layoutData = POINT_LAYOUT;
	addChild(pointDisplay);
}

override protected function commitData():void
{
	super.commitData();
	if( _data == null || _owner == null )
		return;
	
	visibility = _data.n != undefined;
	height = _visibility ? 110 : 60;
	if( !_visibility )
		return;

	nameDisplay.text = _data.n ;
	leagueIndex = player.get_arena(_data.p);
	pointDisplay.text = StrUtils.getNumber(_data.p);
	mySkin.color = _data.i == player.id ? 0xAAFFFF : 0xFFFFFF;
	rankDisplay.text = StrUtils.getNumber(_data.s ? (_data.s + 1) : (index + 1));
	leagueIconDisplay.source = Assets.getTexture("leagues/" + Math.floor(leagueIndex * 0.5), "gui");
	leagueBGDisplay.source = Assets.getTexture("leagues/circle-" + (leagueIndex % 2) + "-small", "gui");
}

private function set visibility(value:Boolean):void 
{
	if( _visibility == value )
		return;
	_visibility = value;
	backgroundSkin.visible = _visibility;
	for ( var i:int = 0; i < numChildren; i++ )
		getChildAt(i).visible = _visibility;
}
} 
}