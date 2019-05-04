package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.themes.MainTheme;

import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.skins.ImageSkin;

import starling.events.Event;
import starling.events.Touch;

public class PlayersItemRenderer extends AbstractTouchableListItemRenderer
{
public function PlayersItemRenderer ()
{
	super();
}
private static const DEFAULT_TEXT_COLOR:uint = 0xDDFFFF;

private var mySkin:ImageSkin;
private var nameDisplay:RTLLabel;
private var idDisplay:RTLLabel;
private var versionDisplay:RTLLabel;
private var sessionsDisplay:RTLLabel;
private var firstDisplay:RTLLabel;
private var lastDisplay:RTLLabel;

override protected function initialize():void
{
	super.initialize();
	
	layout = new AnchorLayout();
	height = 120;
	var padding:int = 36;
	
	mySkin = new ImageSkin(appModel.theme.itemRendererUpSkinTexture);
	mySkin.scale9Grid = MainTheme.ITEM_RENDERER_SCALE9_GRID
	backgroundSkin = mySkin;

	idDisplay = new RTLLabel("", 0, null, null, false, null, 0.7);
	idDisplay.pixelSnapping = false;
	idDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?NaN:padding, NaN, appModel.isLTR?padding:NaN, NaN, -padding*0.7);
	addChild(idDisplay);
	
	nameDisplay = new RTLLabel("", 0, null, null, false, null, 0.6);
	nameDisplay.pixelSnapping = false;
	nameDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?NaN:padding, NaN, appModel.isLTR?padding:NaN, NaN, padding*0.5);
	addChild(nameDisplay);
	
	sessionsDisplay = new RTLLabel("", 1, "center", null, false, null, 0.7);
	sessionsDisplay.width = padding * 3
	sessionsDisplay.pixelSnapping = false;
	sessionsDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?padding*12:NaN, NaN, appModel.isLTR?NaN:padding*12, NaN, 0);
	addChild(sessionsDisplay);
	
	versionDisplay = new RTLLabel("", 1, "center", null, false, null, 0.7);
	versionDisplay.width = padding * 3
	versionDisplay.pixelSnapping = false;
	versionDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?padding*16:NaN, NaN, appModel.isLTR?NaN:padding*16, NaN, 0);
	addChild(versionDisplay);
	
	firstDisplay = new RTLLabel("", 1, "left", "ltr", false, null, 0.6);
	firstDisplay.pixelSnapping = false;
	firstDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?padding:NaN, NaN, appModel.isLTR?NaN:padding, NaN, -padding*0.7);
	addChild(firstDisplay);
	
	lastDisplay = new RTLLabel("", 0, "left", "ltr", false, null, 0.6);
	lastDisplay.pixelSnapping = false;
	lastDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?padding:NaN, NaN, appModel.isLTR?NaN:padding, NaN, padding*0.5);
	addChild(lastDisplay);
	
	addEventListener(Event.TRIGGERED, item_triggeredHandler);
}

override protected function commitData():void
{
	super.commitData();
	if(_data ==null || _owner==null)
		return;
	
	idDisplay.text = "" + _data.id ;
	nameDisplay.text = _data.name;
	versionDisplay.text = "" + _data.app_version;
	sessionsDisplay.text = "" + _data.sessions_count;
	firstDisplay.text = "F: " + _data.create_at;
	lastDisplay.text = "L: " + _data.last_login;
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