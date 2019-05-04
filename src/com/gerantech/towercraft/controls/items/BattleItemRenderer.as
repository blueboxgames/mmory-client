package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.MainTheme;
import com.gerantech.towercraft.utils.StrUtils;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSObject;

import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.skins.ImageSkin;

import starling.events.Event;

public class BattleItemRenderer extends AbstractTouchableListItemRenderer
{
private static const DEFAULT_TEXT_COLOR:uint = 0xDDFFFF;

private var allisNameDisplay:RTLLabel;
private var axisNameDisplay:RTLLabel;
private var allisLobbyNameDisplay:RTLLabel;
private var axisLobbyNameDisplay:RTLLabel;
private var allisLobbyIconDisplay:ImageLoader;
private var axisLobbyIconDisplay:ImageLoader;
private var timeDisplay:RTLLabel;

private var room:SFSObject;
private var spectateButton:CustomButton;

public function BattleItemRenderer(){}
override protected function initialize():void
{
	super.initialize();
	
	layout = new AnchorLayout();
	height = 154;
	var padding:int = 16;
	
	var mySkin:ImageSkin = new ImageSkin(appModel.theme.itemRendererDisabledSkinTexture);
	mySkin.scale9Grid = MainTheme.ITEM_RENDERER_SCALE9_GRID
	backgroundSkin = mySkin;
	
	allisLobbyIconDisplay = new ImageLoader();
	allisLobbyIconDisplay.width = 90;
	allisLobbyIconDisplay.layoutData = new AnchorLayoutData(padding, padding, NaN, NaN);
	addChild(allisLobbyIconDisplay);
	
	axisLobbyIconDisplay = new ImageLoader();
	axisLobbyIconDisplay.width = 90;
	axisLobbyIconDisplay.layoutData = new AnchorLayoutData(padding, NaN, NaN, padding);
	addChild(axisLobbyIconDisplay);
	
	/*spectateButton = new CustomButton();
	spectateButton.height = padding * 6;
	spectateButton.label = loc("lobby_battle_spectate");
	spectateButton.layoutData = new AnchorLayoutData(NaN, padding, padding, NaN);
	addChild(spectateButton);*/

	allisNameDisplay = new RTLLabel("", 0x007AFF, null, null, false, null, 0.75);
	allisNameDisplay.pixelSnapping = false;
	allisNameDisplay.layoutData = new AnchorLayoutData(8, padding * 7);
	addChild(allisNameDisplay);
	
	allisLobbyNameDisplay = new RTLLabel("", 0x444444, null, null, false, null, 0.6);
	allisLobbyNameDisplay.pixelSnapping = false;
	allisLobbyNameDisplay.layoutData = new AnchorLayoutData(54, padding * 7);
	addChild(allisLobbyNameDisplay);
	
	axisNameDisplay = new RTLLabel("", 0xF20C1A, null, null, false, null, 0.75);
	axisNameDisplay.pixelSnapping = false;
	axisNameDisplay.layoutData = new AnchorLayoutData(8, NaN, NaN, padding * 7);
	addChild(axisNameDisplay);
	
	axisLobbyNameDisplay = new RTLLabel("", 0x444444, null, null, false, null, 0.6);
	axisLobbyNameDisplay.pixelSnapping = false;
	axisLobbyNameDisplay.layoutData = new AnchorLayoutData(54, NaN, NaN, padding * 7);
	addChild(axisLobbyNameDisplay);
	
	timeDisplay = new RTLLabel("", 0, null, null, false, null, 0.6);
	timeDisplay.pixelSnapping = false;
	timeDisplay.layoutData = new AnchorLayoutData(NaN, NaN, -2, padding);
	addChild(timeDisplay);
}

override protected function commitData():void
{
	super.commitData();
	if( _data ==null || _owner==null )
		return;
	
	timeManager.removeEventListener(Event.CHANGE, timeManager_changeHandler);
	timeManager.addEventListener(Event.CHANGE, timeManager_changeHandler);
	room = _data as SFSObject;
	
	var allis:ISFSObject = room.getSFSArray("players").getSFSObject(0);
	allisNameDisplay.text = allis.getText("n");
    allisLobbyNameDisplay.text = allis.containsKey("ln") ? allis.getText("ln") : loc("lobby_no");
    allisLobbyIconDisplay.source = Assets.getTexture("emblems/emblem-"+(allis.containsKey("lp") ? StrUtils.getZeroNum(allis.getInt("lp").toString()):"110"), "gui") ;
	
	if( room.getSFSArray("players").size() > 1 )
	{
        var axis:ISFSObject = room.getSFSArray("players").getSFSObject(1);
        axisNameDisplay.text = axis.getText("n");
        axisLobbyNameDisplay.text = axis.containsKey("ln") ? axis.getText("ln") : loc("lobby_no");
        axisLobbyIconDisplay.source = Assets.getTexture("emblems/emblem-"+(axis.containsKey("lp") ? StrUtils.getZeroNum(axis.getInt("lp").toString()):"110"), "gui") ;
	}
	
	timeDisplay.text =  StrUtils.toTimeFormat(timeManager.now - room.getInt("startAt")) ;
}

private function timeManager_changeHandler(event:Event):void
{
	timeDisplay.text =  StrUtils.toTimeFormat(timeManager.now - room.getInt("startAt")) ;
}

override public function dispose():void
{
	timeManager.removeEventListener(Event.CHANGE, timeManager_changeHandler);
	super.dispose();
}
}
}