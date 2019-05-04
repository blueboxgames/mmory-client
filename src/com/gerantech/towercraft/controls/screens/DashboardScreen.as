package com.gerantech.towercraft.controls.screens
{
import com.gerantech.towercraft.Game;
import com.gerantech.towercraft.controls.buttons.Indicator;
import com.gerantech.towercraft.controls.items.DashboardTabItemRenderer;
import com.gerantech.towercraft.controls.items.SegmentsItemRenderer;
import com.gerantech.towercraft.controls.overlays.OpenBookOverlay;
import com.gerantech.towercraft.controls.popups.ConfirmPopup;
import com.gerantech.towercraft.controls.segments.ExchangeSegment;
import com.gerantech.towercraft.events.LoadingEvent;
import com.gerantech.towercraft.managers.SoundManager;
import com.gerantech.towercraft.managers.net.LoadingManager;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.vo.TabItemData;
import com.gerantech.towercraft.models.vo.UserData;
import com.gerantech.towercraft.themes.MainTheme;
import com.gt.towers.constants.ExchangeType;
import com.gt.towers.constants.PrefsTypes;
import com.gt.towers.constants.ResourceType;
import com.gt.towers.constants.SegmentType;
import feathers.controls.AutoSizeMode;
import feathers.controls.ImageLoader;
import feathers.controls.List;
import feathers.controls.ScrollBarDisplayMode;
import feathers.controls.ScrollPolicy;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;
import flash.desktop.NativeApplication;
import flash.geom.Rectangle;
import flash.utils.setTimeout;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.events.Event;

public class DashboardScreen extends BaseCustomScreen
{
static public const FOOTER_SIZE:int = 200;
static public var TAB_INDEX:int = 2;
private var pageList:List;
private var tabsList:List;
private var tabSize:int;
private var segmentsCollection:ListCollection;
private var tabSelection:ImageLoader;

public function DashboardScreen()
{
	if( !Assets.animationAssetsLoaded )
		Assets.loadAnimationAssets(initialize, "factions", "packs");
}

override protected function initialize():void
{
	if( !Assets.animationAssetsLoaded )
		return;
	OpenBookOverlay.createFactory();
	
	super.initialize();
	if( stage == null )
		addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
	else
		addedToStageHandler(null);
}

protected function addedToStageHandler(event:Event):void
{
	removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
	
	autoSizeMode = AutoSizeMode.STAGE;
	layout = new AnchorLayout();
	visible = false;	
	
	if( appModel.loadingManager.state < LoadingManager.STATE_LOADED )
		appModel.loadingManager.addEventListener(LoadingEvent.LOADED, loadingManager_loadedHandler);
	else
		loadingManager_loadedHandler(null);
}

protected function loadingManager_loadedHandler(event:LoadingEvent):void
{
	appModel.loadingManager.removeEventListener(LoadingEvent.LOADED, loadingManager_loadedHandler);
	UserData.instance.prefs.setInt(PrefsTypes.TUTOR, PrefsTypes.T_000_FIRST_RUN);

	// return to last open game
	if( appModel.loadingManager.serverData.getBool("inBattle") )
	{
		appModel.navigator.runBattle(0);
		return;
	}

		// =-=-=-=-=-=-=-=-=-=-=-=- page -=-=-=-=-=-=-=-=-=-=-=-=
	var pageLayout:HorizontalLayout = new HorizontalLayout();
	pageLayout.gap = 0;
	pageLayout.horizontalAlign = HorizontalAlign.CENTER;
	pageLayout.verticalAlign = VerticalAlign.JUSTIFY;
	pageLayout.typicalItemWidth = stage.stageWidth;
	pageLayout.useVirtualLayout = false;
	
	pageList = new List();
	pageList.snapToPages = true;
	pageList.layout = pageLayout;
	pageList.layoutData = new AnchorLayoutData(0, 0, FOOTER_SIZE, 0);
	pageList.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
	pageList.addEventListener(FeathersEventType.FOCUS_IN, pageList_focusInHandler);
	pageList.verticalScrollPolicy = ScrollPolicy.OFF;
	pageList.itemRendererFactory = function ():IListItemRenderer { return new SegmentsItemRenderer(); }
	addChild(pageList);
	
	var shadowTop:ImageLoader = new ImageLoader();
	shadowTop.source = Assets.getTexture("theme/gradeint-top", "gui");
	shadowTop.layoutData = new AnchorLayoutData(-30, -30, NaN, -30);
	shadowTop.maintainAspectRatio = false;
	shadowTop.touchable = false;
	shadowTop.height = 200;
	shadowTop.alpha = 0.4;
	shadowTop.color = 0;
	addChild(shadowTop);
	
	var shadowBottom:ImageLoader = new ImageLoader();
	shadowBottom.source = Assets.getTexture("theme/gradeint-bottom", "gui");
	shadowBottom.layoutData = new AnchorLayoutData(NaN, -20, FOOTER_SIZE - 20, -20);
	shadowBottom.maintainAspectRatio = false;
	shadowBottom.touchable = false;
	shadowBottom.height = 80;
	shadowBottom.alpha = 0.4;
	shadowBottom.color = 0;
	addChild(shadowBottom);
	
	// =-=-=-=-=-=-=-=-=-=-=-=- tabs -=-=-=-=-=-=-=-=-=-=-=-=
	tabSize = stage.stageWidth / 5;
	
	var footerBG:ImageLoader = new ImageLoader();
	footerBG.height = FOOTER_SIZE;
	footerBG.source = Assets.getTexture("home/dash-bg");
	footerBG.scale9Grid = new Rectangle(13, 10, 5, 66);
	footerBG.layoutData = new AnchorLayoutData(NaN, 0, 0, 0);
	footerBG.touchable = false;
	addChild(footerBG);
	
	tabSelection = new ImageLoader();
	tabSelection.touchable = false;
	tabSelection.source = Assets.getTexture("home/dash-selection");
	tabSelection.height = FOOTER_SIZE;
	tabSelection.width = tabSize * 1.2;
	tabSelection.scale9Grid = new Rectangle(25, 17, 2, 183);
	//tabSelection.height = footerSize;
	tabSelection.layoutData = new AnchorLayoutData(NaN, NaN, 0, NaN);
	addChild(tabSelection);
	
	var tabLayout:HorizontalLayout = new HorizontalLayout();
	tabLayout.verticalAlign = VerticalAlign.JUSTIFY;
	tabLayout.useVirtualLayout = false;
	tabLayout.hasVariableItemDimensions = true;	
	
	tabsList = new List();
	tabsList.layout = tabLayout;
	tabsList.layoutData = new AnchorLayoutData(NaN, 0, 0, 0);
	tabsList.height = FOOTER_SIZE * 1.0;
	tabsList.clipContent = false;
	tabsList.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
    tabsList.verticalScrollPolicy = ScrollPolicy.OFF;
	tabsList.addEventListener(Event.SELECT, tabsList_selectHandler);
	tabsList.itemRendererFactory = function ():IListItemRenderer { return new DashboardTabItemRenderer(tabSize); }
	addChild(tabsList);
	
	var indicatorHC:Indicator = new Indicator("rtl", ResourceType.R4_CURRENCY_HARD);
	indicatorHC.layoutData = new AnchorLayoutData(18, 36);
	addChild(indicatorHC);
	
	var indicatorSC:Indicator = new Indicator("rtl", ResourceType.R3_CURRENCY_SOFT);
	indicatorSC.layoutData = new AnchorLayoutData(18, NaN, NaN, NaN, 0);
	addChild(indicatorSC);
	
	if( player.get_arena(0) > 0 )
	{
		var indicatorCT:Indicator = new Indicator("rtl", ResourceType.R6_TICKET);
		indicatorCT.layoutData = new AnchorLayoutData(18, NaN, NaN, 42);
		addChild(indicatorCT);
	}
	
	// tutorial mode
	if( player.get_battleswins() == 0 )
	{
		if( player.tutorialMode == 0 )
			appModel.navigator.pushScreen(Game.OPERATIONS_SCREEN);
		else if( player.tutorialMode == 1 )
			appModel.navigator.runBattle(0);
		return;
	}
	
	segmentsCollection = getListData();

	pageList.dataProvider = segmentsCollection;
	pageList.horizontalScrollPolicy = player.dashboadTabEnabled(-1) ? ScrollPolicy.AUTO : ScrollPolicy.OFF;
	pageList.addEventListener(Event.READY, pageList_readyHandler);
	pageList.addEventListener(FeathersEventType.SCROLL_COMPLETE, pageList_scrollCompleteHandler);
	tabsList.dataProvider = segmentsCollection;
	setTimeout(gotoPage, 10, TAB_INDEX, 0.1);
	visible = true;
	
	appModel.sounds.addAndPlay("main-theme", null, SoundManager.CATE_THEME, SoundManager.SINGLE_BYPASS_THIS, 100);
	
	appModel.navigator.handleInvokes();
	exchangeManager.addEventListener(FeathersEventType.END_INTERACTION, exchangeManager_endHandler);
	
	SFSConnection.instance.lobbyManager.addEventListener(Event.UPDATE, lobbyManager_updateHandler);
}

private function pageList_readyHandler(event:Event):void
{
	tabsList.isEnabled = event.data;
	pageList.horizontalScrollPolicy = event.data ? ScrollPolicy.AUTO : ScrollPolicy.OFF;
}
protected function exchangeManager_endHandler(event:Event):void
{
	if( ExchangeType.getCategory(event.data.type) == ExchangeType.C110_BATTLES )//open first pack
		segmentsCollection.updateItemAt(1);
	else if( event.data.type == -100 )//upgrade initial card
		segmentsCollection.updateItemAt(2);
}
private function getListData():ListCollection
{
	var ret:ListCollection = new ListCollection();
	for each( var p:int in SegmentType.getDashboardsSegments()._list )
		ret.addItem(new TabItemData(p));
	return ret;
}

private function pageList_scrollCompleteHandler(e:Event):void 
{
	if( !pageList.hasEventListener(FeathersEventType.FOCUS_IN) )
		pageList.addEventListener(FeathersEventType.FOCUS_IN, pageList_focusInHandler);
}

private function pageList_focusInHandler(event:Event):void
{
	tabsList.removeEventListeners(Event.SELECT);
	var focusIndex:int = event.data as int;
	if( tabsList.selectedIndex != focusIndex )
		gotoPage(focusIndex, 0.5, false);
	tabsList.addEventListener(Event.SELECT, tabsList_selectHandler);
}

private function tabsList_selectHandler(event:Event):void
{
	if( !player.dashboadTabEnabled(tabsList.selectedIndex) )
		return;
	pageList.removeEventListeners(FeathersEventType.FOCUS_IN);
	gotoPage(tabsList.selectedIndex);
}
public function gotoPage(pageIndex:int, animDuration:Number = 0.3, scrollPage:Boolean = true):void
{
	trace("gotoPage", TAB_INDEX, pageIndex, ExchangeSegment.SELECTED_CATEGORY, pageList.selectedIndex, tabsList.selectedIndex)
	tabsList.selectedIndex = TAB_INDEX = pageIndex;
	if( scrollPage )
		pageList.scrollToDisplayIndex(pageIndex, animDuration);
	if( animDuration > 0 )
		appModel.sounds.addAndPlay("tab");
	appModel.navigator.dispatchEventWith("dashboardTabChanged", false, animDuration);
	Starling.juggler.tween(tabSelection, animDuration, {x:pageIndex * tabSize - tabSize * 0.1, transition:Transitions.EASE_OUT});
}

private function lobbyManager_updateHandler(event:Event):void
{
	TabItemData(segmentsCollection.getItemAt(3)).badgeNumber = SFSConnection.instance.lobbyManager.numUnreads();
}

override protected function backButtonFunction():void
{
	var confirm:ConfirmPopup = new ConfirmPopup(loc("popup_exit_message"), loc("popup_exit_label"));
	confirm.acceptStyle = MainTheme.STYLE_BUTTON_SMALL_DANGER;
	confirm.declineStyle = MainTheme.STYLE_BUTTON_SMALL_NEUTRAL;
	confirm.addEventListener(Event.SELECT, confirm_selectHandler);
	appModel.navigator.addPopup(confirm);
	function confirm_selectHandler(event:Event) : void
	{
		confirm.removeEventListener(Event.SELECT, confirm_selectHandler);
		NativeApplication.nativeApplication.exit();
	}
}

override public function dispose():void
{
	if( appModel != null )
		appModel.loadingManager.removeEventListener(LoadingEvent.LOADED, loadingManager_loadedHandler);
	super.dispose();
}
}
}