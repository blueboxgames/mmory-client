package com.gerantech.towercraft.controls.popups
{
import com.gerantech.towercraft.Game;
import com.gerantech.towercraft.controls.BuildingCard;
import com.gerantech.towercraft.controls.FastList;
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.buttons.Indicator;
import com.gerantech.towercraft.controls.buttons.IndicatorButton;
import com.gerantech.towercraft.controls.buttons.IndicatorXP;
import com.gerantech.towercraft.controls.buttons.MMOryButton;
import com.gerantech.towercraft.controls.groups.RewardsPalette;
import com.gerantech.towercraft.controls.headers.BattleHeader;
import com.gerantech.towercraft.controls.items.CardItemRenderer;
import com.gerantech.towercraft.controls.items.ProfileBuildingItemRenderer;
import com.gerantech.towercraft.controls.items.ProfileFeatureItemRenderer;
import com.gerantech.towercraft.controls.overlays.TransitionData;
import com.gerantech.towercraft.controls.screens.IssuesScreen;
import com.gerantech.towercraft.controls.segments.InboxSegment;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.MainTheme;
import com.gerantech.towercraft.utils.StrUtils;
import com.gt.towers.constants.CardTypes;
import com.gt.towers.constants.ResourceType;
import com.gt.towers.scripts.ScriptEngine;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSObject;
import feathers.controls.ImageLoader;
import feathers.controls.List;
import feathers.controls.ScrollBarDisplayMode;
import feathers.controls.ScrollContainer;
import feathers.controls.ScrollPolicy;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.TiledRowsLayout;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import flash.geom.Rectangle;
import starling.core.Starling;
import starling.display.Image;
import starling.events.Event;

public class ProfilePopup extends SimplePopup 
{
private var user:Object;
private var adminMode:Boolean;
private var playerData:ISFSObject;
private var resourcesData:ISFSArray;

public function ProfilePopup(user:Object, getFullPlayerData:Boolean = false)
{
	this.user = user;
	this.adminMode = player.admin;
	
	var params:SFSObject = new SFSObject();
	params.putInt("id", user.id);
	if( adminMode )
		params.putBool("am", true);
	if( getFullPlayerData )
		params.putBool("pd", true);
	if( user.ln == null )
		params.putInt("lp", 0);
	
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_responceHandler);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.PROFILE, params);
}

override protected function initialize():void
{
	var _h:int = adminMode ? 1800 : 1200;
	var _p:int = 48;
	transitionIn = new TransitionData();
	transitionOut = new TransitionData();
	transitionOut.destinationAlpha = 0;
	transitionIn.sourceBound = transitionOut.destinationBound = new Rectangle(_p,	stageHeight* 0.5 - _h * 0.4,	stageWidth - _p * 2,	_h * 0.8);
	transitionOut.sourceBound = transitionIn.destinationBound = new Rectangle(_p,	stageHeight* 0.5 - _h * 0.5,	stageWidth - _p * 2,	_h * 1.0);
	super.initialize();
}
protected override function transitionInCompleted():void
{
	super.transitionInCompleted();
	if( playerData != null )
		showProfile();
}
protected function sfsConnection_responceHandler(event:SFSEvent):void
{
	if( event.params.cmd != SFSCommands.PROFILE )
		return;
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_responceHandler);
	playerData = event.params.params as SFSObject;
	resourcesData = playerData.getSFSArray("resources");
	
	if( playerData.containsKey("ln") )
		user.ln = playerData.getText("ln");
	else if( user.ln == null )
		user.ln = loc("lobby_no");
	
	if( playerData.containsKey("lp") )
		user.lp = playerData.getInt("lp");
	else if( user.lp == null )
		user.lp = 110;

	if( transitionState >= TransitionData.STATE_IN_COMPLETED )
		showProfile();
}

private function showProfile():void
{
	var lobbyIconDisplay:ImageLoader = new ImageLoader();
	lobbyIconDisplay.height = lobbyIconDisplay.width = padding * 3.5;
	lobbyIconDisplay.source = Assets.getTexture("emblems/emblem-" + StrUtils.getZeroNum(user.lp + ""), "gui");
	lobbyIconDisplay.layoutData = new AnchorLayoutData(padding, appModel.isLTR?NaN:padding, NaN, appModel.isLTR?padding:NaN);
	addChild(lobbyIconDisplay);
	
	var nameDisplay:ShadowLabel = new ShadowLabel(playerData.containsKey("pd")?playerData.getSFSObject("pd").getText("name"):user.name, 1, 0, null, null, true, "center", 0.9);
	nameDisplay.layoutData = new AnchorLayoutData(padding * 0.8, appModel.isLTR?NaN:padding * 5, NaN, appModel.isLTR?padding * 7:NaN);
	addChild(nameDisplay);
	
	var tagDisplay:RTLLabel = new RTLLabel("#" + playerData.getText("tag") + (adminMode?(" => " + user.id) : ""), 0xAABBBB, null, "ltr", true, null, 0.58);
	tagDisplay.layoutData = new AnchorLayoutData(padding * 2.5, appModel.isLTR?NaN:padding * 5, NaN, appModel.isLTR?padding * 7:NaN);
	addChild(tagDisplay);
	
	var lobbyNameDisplay:RTLLabel = new RTLLabel(user.ln, 0xAABBBB, null, "ltr", true, null, 0.6);
	lobbyNameDisplay.layoutData = new AnchorLayoutData(padding * 3.3, appModel.isLTR?NaN:padding * 5, NaN, appModel.isLTR?padding * 7:NaN);
	addChild(lobbyNameDisplay);
	
	var closeButton:MMOryButton = new MMOryButton();
	closeButton.alpha = 0;
	closeButton.width = 88;
	closeButton.height = 74
	closeButton.layoutData = new AnchorLayoutData(-20, -20);
	closeButton.styleName = MainTheme.STYLE_BUTTON_SMALL_DANGER;
	Starling.juggler.tween(closeButton, 0.2, {delay:0.8, alpha:1});
	closeButton.iconTexture = Assets.getTexture("theme/icon-cross", "gui");
	closeButton.addEventListener(Event.TRIGGERED, close_triggeredHandler);
	addChild(closeButton);
	
	if( adminMode )
	{
		var banButton:IndicatorButton = new IndicatorButton();
		banButton.label = "ban";
		banButton.styleName = MainTheme.STYLE_BUTTON_SMALL_DANGER;
		//banButton.width = banButton.height = padding * 2;
		banButton.layoutData = new AnchorLayoutData(NaN, padding * 0.5, -padding);
		banButton.addEventListener(Event.TRIGGERED, adminButtons_triggeredHandler);
		addChild(banButton);
		
		var issuesButton:IndicatorButton = new IndicatorButton();
		issuesButton.label = "issues";
		issuesButton.styleName = MainTheme.STYLE_BUTTON_SMALL_NEUTRAL;
		//issuesButton.width = issuesButton.height = padding * 2;
		issuesButton.layoutData = new AnchorLayoutData(NaN, padding * 5, -padding);
		issuesButton.addEventListener(Event.TRIGGERED, adminButtons_triggeredHandler);
		addChild(issuesButton);
		
		var offendsButton:IndicatorButton = new IndicatorButton();
		offendsButton.label = "offends";
		//offendsButton.width = offendsButton.height = padding * 2;
		offendsButton.layoutData = new AnchorLayoutData(NaN, NaN, -padding, 0);
		offendsButton.addEventListener(Event.TRIGGERED, adminButtons_triggeredHandler);
		addChild(offendsButton);
		
		var reportsButton:IndicatorButton = new IndicatorButton();
		reportsButton.label = "reports";
		//reportsButton.width = reportsButton.height = padding * 2;
		reportsButton.layoutData = new AnchorLayoutData(NaN, NaN, -padding, padding * 7);
		reportsButton.addEventListener(Event.TRIGGERED, adminButtons_triggeredHandler);
		addChild(reportsButton);
		
		var bannesButton:IndicatorButton = new IndicatorButton();
		bannesButton.label = "banns";
		//bannesButton.width = bannesButton.height = padding * 2;
		bannesButton.layoutData = new AnchorLayoutData(NaN, NaN, -padding, NaN, padding);
		bannesButton.addEventListener(Event.TRIGGERED, adminButtons_triggeredHandler);
		addChild(bannesButton);
		
		function adminButtons_triggeredHandler(event:Event):void
		{
			if( event.currentTarget == banButton )
			{
				appModel.navigator.addPopup(new AdminBanPopup(user.id));
				return;
			}
			
			if( event.currentTarget == issuesButton )
			{
				/*if( appModel.navigator.activeScreen is IssuesScreen )
				{
					IssuesScreen(appModel.navigator.activeScreen).reporter = user.id;
					IssuesScreen(appModel.navigator.activeScreen).requestIssues();
					close();
					return;
				}
				appModel.navigator.getScreen( Game.ISSUES_SCREEN ).properties.reporter = user.id;*/
				InboxSegment.openThread({receiver:user.name, receiverId:user.id}, true); 
				close();
			}
			
			if( event.currentTarget == offendsButton || event.currentTarget == reportsButton )
			{
				appModel.navigator.getScreen( Game.OFFENDS_SCREEN ).properties.target = user.id * (event.currentTarget == reportsButton ? -1 : 1);
				appModel.navigator.pushScreen( Game.OFFENDS_SCREEN );
			}
			
			if( event.currentTarget == bannesButton )
			{
				appModel.navigator.getScreen( Game.BANNEDS_SCREEN).properties.target = user.id;
				appModel.navigator.pushScreen( Game.BANNEDS_SCREEN );
			}
		}
	}
	
	var featureCollection:ListCollection = new ListCollection();
	var xp:int;
	var point:int;
	for( var i:int = 0; i < resourcesData.size(); i++ )
	{
		if( resourcesData.getSFSObject(i).getInt("type") == ResourceType.R1_XP )
			xp = resourcesData.getSFSObject(i).getInt("count");
		else if( resourcesData.getSFSObject(i).getInt("type") == ResourceType.R2_POINT )
			point = resourcesData.getSFSObject(i).getInt("count");
		else if( !ResourceType.isCard(resourcesData.getSFSObject(i).getInt("type")) )
			featureCollection.addItem(resourcesData.getSFSObject(i));
	}

	var indicatorXP:IndicatorXP = new IndicatorXP("ltr", false);
	indicatorXP.setData(NaN, xp, NaN);
	indicatorXP.width = padding * 7;
	indicatorXP.height = padding * 1.5;
	indicatorXP.layoutData = new AnchorLayoutData(padding, appModel.isLTR?padding * 1.5:NaN, NaN, appModel.isLTR?NaN:padding * 1.5);
	addChild(indicatorXP);
	
	var indicatorPoint:Indicator = new Indicator("ltr", ResourceType.R2_POINT, false, false, false);
	indicatorPoint.setData(0, point, Number.MAX_VALUE);
	indicatorPoint.width = padding * 7;
	indicatorPoint.height = padding * 1.5;
	indicatorPoint.layoutData = new AnchorLayoutData(padding * 3, appModel.isLTR?padding * 1.5:NaN, NaN, appModel.isLTR?NaN:padding * 1.5);
	addChild(indicatorPoint);
	
	var scroller:ScrollContainer = new ScrollContainer();
	scroller.backgroundSkin = new Image(appModel.theme.roundSmallInnerSkin);
	Image(scroller.backgroundSkin).scale9Grid = MainTheme.ROUND_MEDIUM_SCALE9_GRID;
	scroller.backgroundSkin.alpha = 0.2;
	scroller.layout = new AnchorLayout();
	scroller.layoutData = new AnchorLayoutData(padding * 5, padding, padding * 2, padding);
	scroller.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
	addChild(scroller);
	
	// features
	var featureList:List = new List();
	featureList.horizontalScrollPolicy = ScrollPolicy.OFF;
	featureList.itemRendererFactory = function ():IListItemRenderer { return new ProfileFeatureItemRenderer(); }
	featureList.verticalScrollPolicy = featureList.horizontalScrollPolicy = ScrollPolicy.OFF;
	featureList.dataProvider = featureCollection;
	featureList.layoutData = new AnchorLayoutData(10, 10, NaN, 10);
	scroller.addChild(featureList);
	
	var featureLayout:VerticalLayout = new VerticalLayout();
	featureLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
	featureLayout.verticalAlign = VerticalAlign.MIDDLE;
	featureList.layout = featureLayout;
	
	// buildings
	if( adminMode )
	{
		var listLayout:TiledRowsLayout = new TiledRowsLayout();
		listLayout.padding = 0;
		listLayout.gap = padding * 0.2;
		listLayout.useSquareTiles = false;
		listLayout.requestedColumnCount = 10;
		listLayout.typicalItemWidth = (width - listLayout.padding * (listLayout.requestedColumnCount + 1)) / listLayout.requestedColumnCount;
		listLayout.typicalItemHeight = listLayout.typicalItemWidth * BuildingCard.VERICAL_SCALE;
		
		var buildingslist:FastList = new FastList();
		buildingslist.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
		buildingslist.layout = listLayout;
		buildingslist.verticalScrollPolicy = buildingslist.horizontalScrollPolicy = ScrollPolicy.OFF;
		buildingslist.layoutData = new AnchorLayoutData(featureCollection.length * 50, 0, NaN, 0);
		buildingslist.itemRendererFactory = function():IListItemRenderer { return new ProfileBuildingItemRenderer(); }
		buildingslist.dataProvider = getBuildingData();
		scroller.addChild(buildingslist);		
	}
	
	// deck
	var top:int = adminMode ? 430 : 20;
    var deckHeader:BattleHeader = new BattleHeader(loc("deck_label"), true, -1);
    deckHeader.width = transitionIn.destinationBound.width * 0.8;
    deckHeader.height = 120;
    deckHeader.layoutData = new AnchorLayoutData(featureList.dataProvider.length * 50 + top, NaN, NaN, NaN, 0);
	deckHeader.addEventListener(FeathersEventType.CREATION_COMPLETE, function():void{	deckHeader.scale = 0.80;});
    scroller.addChild(deckHeader);
    
    var deckLayout:TiledRowsLayout = new TiledRowsLayout();
    deckLayout.gap = padding * 0.3;
    deckLayout.useSquareTiles = false;
    deckLayout.useVirtualLayout = false;
    deckLayout.requestedColumnCount = 4;
    deckLayout.typicalItemWidth = (width - deckLayout.gap * (deckLayout.requestedColumnCount - 1) - padding * 4) / deckLayout.requestedColumnCount;
    deckLayout.typicalItemHeight = deckLayout.typicalItemWidth * BuildingCard.VERICAL_SCALE;
	
	var deckList:List = new List();
    deckList.layout = deckLayout;
    deckList.height = deckLayout.typicalItemHeight * 2 + deckLayout.gap;
    deckList.verticalScrollPolicy = deckList.horizontalScrollPolicy = ScrollPolicy.OFF;
    deckList.layoutData = new AnchorLayoutData(featureList.dataProvider.length * 50 + top + 150, 0, NaN, 0);
    deckList.itemRendererFactory = function():IListItemRenderer { return new CardItemRenderer(true, false); }
    deckList.dataProvider = getDeckData();
    scroller.addChild(deckList);
    deckList.alpha = 0;
    Starling.juggler.tween(deckList, 0.2, {delay:0.6, alpha:1});
}

private function getBuildingData():ListCollection
{
	var ret:ListCollection = new ListCollection();
	var buildings:Array = ScriptEngine.get(1, -1);
	for ( var i:int = 0; i < buildings.length; i++ )
		buildings[i] = {type:buildings[i], level:getLevel(buildings[i])};
	return new ListCollection(buildings);
}

private function getLevel(type:int):int
{
	var bLen:int = resourcesData.size()
	for (var i:int = 0; i < bLen; i++)
		if( resourcesData.getSFSObject(i).getInt("type") == type ) 
			return resourcesData.getSFSObject(i).getInt("level");
	return 0;
}		
	
private function getDeckData():ListCollection
{
    var decks:ISFSArray = playerData.getSFSArray("decks");
    var ret:ListCollection = new ListCollection();
    for (var i:int = 0; i < decks.size(); i++) 
        ret.addItem({type:decks.getSFSObject(i).getInt("type"), level:decks.getSFSObject(i).getInt("level")});
    return ret;
}

private function close_triggeredHandler(event:Event):void
{
	close();
}
}
}