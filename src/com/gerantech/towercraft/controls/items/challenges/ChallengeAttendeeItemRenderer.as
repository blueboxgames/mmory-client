package com.gerantech.towercraft.controls.items.challenges
{
import com.gerantech.towercraft.controls.items.AbstractTouchableListItemRenderer;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.MainTheme;
import com.gerantech.towercraft.utils.StrUtils;
import com.gt.towers.constants.ResourceType;
import com.gt.towers.socials.Attendee;
import com.gt.towers.socials.Challenge;
import com.gt.towers.utils.maps.IntIntMap;
import feathers.controls.ImageLoader;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.TiledRowsLayout;
import feathers.layout.VerticalLayout;
import feathers.skins.ImageSkin;
import flash.text.engine.ElementFormat;
import haxe.ds.IntMap;
import starling.events.Event;
import starling.events.Touch;

public class ChallengeAttendeeItemRenderer extends AbstractTouchableListItemRenderer
{
public function ChallengeAttendeeItemRenderer(challenge:Challenge){ super(); this.challenge = challenge; }
private static const DEFAULT_TEXT_COLOR:uint = 0xDDFFFF;
private var challenge:Challenge;
private var nameDisplay:ShadowLabel;
private var pointDisplay:RTLLabel;
private var prizeCountDisplay:RTLLabel;
private var prizeIconDisplay:ImageLoader;
private var mySkin:ImageSkin;

override protected function initialize():void
{
	super.initialize();
	
	layout = new AnchorLayout();
	height = 120;
	var ltr:Boolean = appModel.isLTR;
	mySkin = new ImageSkin(appModel.theme.itemRendererUpSkinTexture);
	mySkin.scale9Grid = MainTheme.ITEM_RENDERER_SCALE9_GRID
	backgroundSkin = mySkin;
	
	prizeIconDisplay = new ImageLoader();
	prizeIconDisplay.layoutData = new AnchorLayoutData(5, ltr?5:NaN, 5, ltr?NaN:5);
	addChild(prizeIconDisplay);

	prizeCountDisplay = new RTLLabel("", 1, "left", null, false, "left", 0.9);
	prizeCountDisplay.layoutData = new AnchorLayoutData(NaN, ltr?90:NaN, NaN, ltr?NaN:90, NaN, -3);
	addChild(prizeCountDisplay);
	
	pointDisplay = new RTLLabel("", 1, "center", null, false, "center", 0.8);
	pointDisplay.width = 120;
	pointDisplay.pixelSnapping = false;
	pointDisplay.layoutData = new AnchorLayoutData(NaN, ltr?300:NaN, NaN, ltr?NaN:300, NaN, -3);
	addChild(pointDisplay);
	
	nameDisplay = new ShadowLabel("", 1, 0, null, null, false, null, 0.8);
	nameDisplay.layoutData = new AnchorLayoutData(NaN, ltr?400:20, NaN, ltr?20:400, NaN, -2);
	addChild(nameDisplay);
	
	addEventListener(Event.TRIGGERED, item_triggeredHandler);
}

override protected function commitData():void
{
	super.commitData();
	if( _data == null || _owner == null )
		return;

	var attendee:Attendee = _data as Attendee
	var rankIndex:int = index + 1;
	nameDisplay.text = rankIndex + ".   " + attendee.name;
	pointDisplay.text = "" + attendee.point;

	var m:IntIntMap = challenge.getRewardByRank(rankIndex);
	var prizeKey:int = m.keys()[0];
	if( ResourceType.isBook(prizeKey) )
	{
		prizeIconDisplay.source = Assets.getTexture("books/" + prizeKey, "gui");
		prizeCountDisplay.visible = false;
	}
	else
	{
		prizeIconDisplay.source = Assets.getTexture("cards/" + prizeKey, "gui");
		prizeCountDisplay.text = prizeKey == -1 ? "---" : ("      x " +  m.get(prizeKey));
		prizeCountDisplay.visible = true;
	}
		
	mySkin.defaultTexture = attendee.id == player.id ? appModel.theme.itemRendererSelectedSkinTexture : appModel.theme.itemRendererUpSkinTexture;
}
protected function item_triggeredHandler(event:Event):void
{
	owner.dispatchEventWith(FeathersEventType.FOCUS_IN, false, _data);
}
}
}