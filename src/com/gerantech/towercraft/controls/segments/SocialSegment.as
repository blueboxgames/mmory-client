package com.gerantech.towercraft.controls.segments
{
import com.gerantech.towercraft.controls.headers.TabsHeader;
import com.gerantech.towercraft.controls.items.SegmentsItemRenderer;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.vo.TabItemData;
import com.gerantech.towercraft.themes.MainTheme;
import com.gt.towers.constants.SegmentType;

import feathers.controls.ImageLoader;
import feathers.controls.List;
import feathers.controls.ScrollBarDisplayMode;
import feathers.controls.ScrollPolicy;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;

import flash.utils.setTimeout;

import starling.events.Event;

public class SocialSegment extends Segment
{
static public var TAB_INDEX:int = 0;
private var pageList:List;
private var tabsList:TabsHeader;
private var tabsHeight:int = 100;
private var scrollTime:Number = 0.01;
private var listCollection:ListCollection;
public function SocialSegment() { super(); }
override protected function initialize() : void
{
	super.initialize();
	layout = new AnchorLayout();
	var backgroundDisplay:ImageLoader = new ImageLoader();
	backgroundDisplay.source = appModel.theme.popupInsideBackgroundSkinTexture;
	backgroundDisplay.scale9Grid = MainTheme.POPUP_INSIDE_SCALE9_GRID;
	backgroundDisplay.layoutData = new AnchorLayoutData(tabsHeight + 9, 0, -10, 0);
	addChild(backgroundDisplay);
}	
override public function init():void
{
	if( initializeCompleted )
		return;
	super.init();
	
	if( player.get_arena(0) < 1 )
	{
		var labelDisplay:ShadowLabel = new ShadowLabel(loc("availableat_messeage", [loc("tab-3"), loc("arena_text") + " " + loc("num_2")]), 1, 0, "center");
		labelDisplay.width = width;
		labelDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, NaN, 0);
		addChild(labelDisplay);
		return;
	}
	
	var pageLayout:HorizontalLayout = new HorizontalLayout();
	pageLayout.horizontalAlign = HorizontalAlign.CENTER;
	pageLayout.verticalAlign = VerticalAlign.JUSTIFY;
	pageLayout.useVirtualLayout = true;
	
	refreshListData();
	
	pageList = new List();
	pageList.snapToPages = true;
	pageList.layout = pageLayout;
	pageList.layoutData = new AnchorLayoutData(tabsHeight + 10, paddingH, 0, paddingH);
	pageList.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
	pageList.horizontalScrollPolicy = pageList.verticalScrollPolicy = ScrollPolicy.OFF;
	pageList.itemRendererFactory = function ():IListItemRenderer { return new SegmentsItemRenderer(); }
	pageList.dataProvider = listCollection;
	addChild(pageList);
	
	tabsList = new TabsHeader();
	tabsList.layoutData = new AnchorLayoutData(10, paddingH + 10, NaN, paddingH + 10);
	tabsList.height = tabsHeight;
	tabsList.dataProvider = listCollection;
	tabsList.addEventListener(Event.CHANGE, tabsList_changeHandler);
	tabsList.selectedIndex = TAB_INDEX;
	addChild(tabsList);
	
	pageList.addEventListener(Event.UPDATE, pageList_updateHandler);
	pageList.addEventListener(Event.READY, pageList_readyHandler);
	initializeCompleted = true;
}

private function pageList_readyHandler(event:Event):void
{
	tabsList.isEnabled = event.data;
	pageList.horizontalScrollPolicy = event.data ? ScrollPolicy.AUTO : ScrollPolicy.OFF;
}

private function pageList_updateHandler(event:Event):void
{
	listCollection.removeAll();
	setTimeout(function():void{
		tabsList.selectedIndex = -1;
		refreshListData();
		tabsList.selectedIndex = 0
		;
	}, 100);
}

private function tabsList_changeHandler(event:Event):void
{
	if( player.inTutorial() && tabsList.selectedIndex != 1 )
		return;
	pageList.selectedIndex = TAB_INDEX = tabsList.selectedIndex;
	pageList.scrollToDisplayIndex(tabsList.selectedIndex, scrollTime);
	scrollTime = 0.5;
	
	appModel.sounds.addAndPlay("tab");
}

private function refreshListData(): void
{
	SFSConnection.instance.lobbyManager.initialize();
	
	if( listCollection == null )
		listCollection = new ListCollection();
	else
		listCollection.removeAll();
	
	var ret:Array = new Array();
	for each(var p:int in SegmentType.getSocialSegments(SFSConnection.instance.lobbyManager.lobby != null)._list)
	{
		var tid:TabItemData = new TabItemData(p);
		tid.width = p == SegmentType.S11_LOBBY_SEARCH ? 110 : 310;
		tid.icon = p == SegmentType.S11_LOBBY_SEARCH ? "search-icon" : null;
		tid.label = p == SegmentType.S11_LOBBY_SEARCH ? null : loc("tab-" + p);
		ret.push(tid);
	}
	listCollection.data = ret;
}
override public function dispose():void
{
	if( pageList != null )
		pageList.removeEventListener(Event.UPDATE, pageList_updateHandler);
	super.dispose();
}
}
}