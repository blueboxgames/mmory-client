package com.gerantech.towercraft.controls.items.lobby
{
import com.gerantech.towercraft.controls.items.AbstractTouchableListItemRenderer;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.MainTheme;
import com.gerantech.towercraft.utils.StrUtils;
import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import flash.geom.Rectangle;
import starling.display.Image;

public class LobbyItemRenderer extends AbstractTouchableListItemRenderer
{
static public var RANK_LAYOUT:AnchorLayoutData;
static public var NAME_LAYOUT:AnchorLayoutData;
static public var EMBLEM_LAYOUT:AnchorLayoutData;
static public var MEMBER_LAYOUT:AnchorLayoutData;
static public var ACTIVITY_LAYOUT:AnchorLayoutData;
static public var MEMBER_BG_LAYOUT:AnchorLayoutData;
static public var MEMBER_LBL_LAYOUT:AnchorLayoutData;
static public var ACTIVITY_BG_LAYOUT:AnchorLayoutData;
static private const MEMBER_SCALE9_GRID:Rectangle = new Rectangle(11, 11, 1, 1);

private var membersDisplay:RTLLabel;
private var rankDisplay:ShadowLabel;
private var nameDisplay:ShadowLabel;
private var emblemDisplay:ImageLoader;
private var activityDisplay:ShadowLabel;

public function LobbyItemRenderer(){}
override protected function initialize():void
{
	super.initialize();
	height = 110;
	layout = new AnchorLayout();

	var mySkin:Image = new Image(appModel.theme.itemRendererUpSkinTexture);
	mySkin.scale9Grid = MainTheme.ITEM_RENDERER_SCALE9_GRID;
	backgroundSkin = mySkin;
	
	var rankBackground:ImageLoader = new ImageLoader();
	rankBackground.scale9Grid = MainTheme.ROUND_SMALL_SCALE9_GRID;
	rankBackground.source = appModel.theme.roundSmallInnerSkin;
	rankBackground.width = rankBackground.height = 84;
	rankBackground.layoutData = RANK_LAYOUT;
	rankBackground.pixelSnapping = false;
	addChild(rankBackground);
	
	var activityBacground:ImageLoader = new ImageLoader();
	activityBacground.scale9Grid = MainTheme.ROUND_SMALL_SCALE9_GRID;
	activityBacground.source = appModel.theme.roundSmallInnerSkin;
	activityBacground.layoutData = ACTIVITY_BG_LAYOUT;
	activityBacground.pixelSnapping = false;
	activityBacground.color = 0x888888;
	activityBacground.height = 84;
	activityBacground.width = 220
	addChild(activityBacground);
	
	var membersBackground:ImageLoader = new ImageLoader();
	membersBackground.source = appModel.theme.roundSmallInnerSkin;
	membersBackground.scale9Grid = MEMBER_SCALE9_GRID;
	membersBackground.layoutData = MEMBER_BG_LAYOUT;
	membersBackground.width = 120;
	addChild(membersBackground);
	
	emblemDisplay = new ImageLoader();
	emblemDisplay.layoutData = EMBLEM_LAYOUT;
	addChild(emblemDisplay);
	
	// labels .........
	rankDisplay = new ShadowLabel(null, 1, 0, "center", null, false, null, 0.7);
	rankDisplay.layoutData = RANK_LAYOUT;
	rankDisplay.width = 80;
	addChild(rankDisplay);
	
	nameDisplay = new ShadowLabel(null, 1, 0, null, null, false, null, 0.8);
	nameDisplay.layoutData = NAME_LAYOUT;
	addChild(nameDisplay);
	
	var membersLabelDisplay:RTLLabel = new RTLLabel(loc("lobby_population"), 0, "center", null, false, null, 0.55);
	membersLabelDisplay.layoutData = MEMBER_LBL_LAYOUT;
	membersLabelDisplay.width = 120;
	addChild(membersLabelDisplay);
	
	membersDisplay = new RTLLabel(null, 0, "center", null, false, null, 0.66);
	membersDisplay.layoutData = MEMBER_LAYOUT;
	membersDisplay.width = 120;
	addChild(membersDisplay);
	
	activityDisplay = new ShadowLabel(null, 1, 0, "center", null, false, null, 0.8);
	activityDisplay.layoutData = ACTIVITY_LAYOUT;
	activityDisplay.width = 160;
	addChild(activityDisplay);
}

override protected function commitData():void
{
	super.commitData();
	if( _data == null || _owner == null )
		return;
	
	emblemDisplay.source = Assets.getTexture("emblems/emblem-" + StrUtils.getZeroNum(_data.pic + ""), "gui");
	rankDisplay.text = StrUtils.getNumber(index + 1);
	nameDisplay.text = _data.name;
    activityDisplay.text = StrUtils.getNumber(_data.act);
	membersDisplay.text = StrUtils.getNumber(_data.num + "/" + _data.max);
}
}
}