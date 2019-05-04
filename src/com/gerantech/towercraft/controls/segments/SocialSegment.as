package com.gerantech.towercraft.controls.segments
{
import com.gerantech.towercraft.controls.headers.TabsHeader;
import com.gerantech.towercraft.controls.items.SegmentsItemRenderer;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.vo.TabItemData;
import com.gerantech.towercraft.themes.MainTheme;
import com.gerantech.towercraft.utils.StrUtils;
import com.gt.towers.constants.SegmentType;
import com.smartfoxserver.v2.entities.data.ISFSObject;
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
import starling.display.Image;
import starling.events.Event;

public class SocialSegment extends Segment
{
public static var TAB_INDEX:int = 0;
private var pageList:List;
private var tabsList:TabsHeader;
private var scrollTime:Number = 0.01;
private var listCollection:ListCollection;
private var tabSize:int;
public function SocialSegment() { super(); }
override protected function initialize() : void
{
	super.initialize();
	layout = new AnchorLayout();
	var backgroundDisplay:ImageLoader = new ImageLoader();
	backgroundDisplay.source = appModel.theme.popupInsideBackgroundSkinTexture;
	backgroundDisplay.scale9Grid = MainTheme.POPUP_INSIDE_SCALE9_GRID;
	backgroundDisplay.layoutData = new AnchorLayoutData(198, 0, -10, 0);
	addChild(backgroundDisplay);

}	
override public function init():void
{
	if( initializeCompleted )
		return;
	super.init();
	
	var labelDisplay:ShadowLabel;
	if( player.get_arena(0) < 1 )
	{
		labelDisplay = new ShadowLabel(loc("availableat_messeage", [loc("tab-3"), loc("arena_text") + " " + loc("num_2")]), 1, 0, "center");
		labelDisplay.width = width;
		labelDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, NaN, 0);
		addChild(labelDisplay);
		return;
	}
	
	var ban:ISFSObject = appModel.loadingManager.serverData.containsKey("ban") ? appModel.loadingManager.serverData.getSFSObject("ban") : null;
    if( ban != null && ban.getInt("mode") > 1 )// banned user
    {
		backgroundSkin = new Image(appModel.theme.backgroundDisabledSkinTexture);
		Image(backgroundSkin).scale9Grid = MainTheme.DEFAULT_BACKGROUND_SCALE9_GRID;
		backgroundSkin.alpha = 0.6;
		
		labelDisplay = new ShadowLabel(loc("lobby_banned", [StrUtils.toTimeFormat(ban.getLong("until"))]), 1, 0, "center", null, true, null, 0.9);
		labelDisplay.width = width;
		labelDisplay.layoutData = new AnchorLayoutData(NaN, 20, NaN, 20, NaN, 0);
		addChild(labelDisplay);
		
		var descDisplay:RTLLabel = new RTLLabel(ban.getUtfString("message"), 1, null, null, true, null, 0.6);
		descDisplay.layoutData = new AnchorLayoutData(NaN, 20, NaN, 20, NaN, 0);
		addChild(descDisplay);
		return;
    }
	
	var tabsSize:int = 100;
	var pageLayout:HorizontalLayout = new HorizontalLayout();
	pageLayout.horizontalAlign = HorizontalAlign.CENTER;
	pageLayout.verticalAlign = VerticalAlign.JUSTIFY;
	pageLayout.useVirtualLayout = true;
	
	refreshListData();
	
	pageList = new List();
	pageList.layout = pageLayout;
	pageList.layoutData = new AnchorLayoutData(tabsSize*2, 0, 0, 0);
	pageList.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
	pageList.snapToPages = true;
	pageList.horizontalScrollPolicy = pageList.verticalScrollPolicy = ScrollPolicy.OFF;
	pageList.itemRendererFactory = function ():IListItemRenderer { return new SegmentsItemRenderer(); }
	pageList.dataProvider = listCollection;
	addChild(pageList);
	
	tabSize = stage.stageWidth / listCollection.length;
	
	tabsList = new TabsHeader();
	tabsList.layoutData = new AnchorLayoutData(tabsSize, 10, NaN, 10);
	tabsList.height = tabsSize;
	//tabsList.itemRendererFactory = function ():IListItemRenderer { return new SocialTabItemRenderer(tabSize); }
	tabsList.dataProvider = listCollection;
	tabsList.selectedIndex = TAB_INDEX;
	tabsList.addEventListener(Event.CHANGE, tabsList_changeHandler);
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
	setTimeout(refreshListData, 1000);
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