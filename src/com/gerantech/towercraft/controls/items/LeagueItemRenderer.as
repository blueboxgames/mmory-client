package com.gerantech.towercraft.controls.items
{
import com.gerantech.mmory.core.constants.CardTypes;
import com.gerantech.mmory.core.constants.MessageTypes;
import com.gerantech.mmory.core.constants.ResourceType;
import com.gerantech.mmory.core.others.Arena;
import com.gerantech.mmory.core.others.TrophyReward;
import com.gerantech.mmory.core.utils.maps.IntIntMap;
import com.gerantech.towercraft.controls.CardView;
import com.gerantech.towercraft.controls.buttons.LeagueButton;
import com.gerantech.towercraft.controls.buttons.SimpleLayoutButton;
import com.gerantech.towercraft.controls.items.challenges.ChallengeIndexItemRenderer;
import com.gerantech.towercraft.controls.overlays.EarnOverlay;
import com.gerantech.towercraft.controls.overlays.NewCardOverlay;
import com.gerantech.towercraft.controls.overlays.OpenBookOverlay;
import com.gerantech.towercraft.controls.popups.BundleDetailsPopup;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.themes.MainTheme;
import com.gerantech.towercraft.utils.StrUtils;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.data.SFSObject;

import feathers.controls.ImageLoader;
import feathers.controls.LayoutGroup;
import feathers.core.FeathersControl;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

import flash.geom.Rectangle;
import flash.utils.setTimeout;

import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;
import starling.events.Event;

public class LeagueItemRenderer extends AbstractListItemRenderer
{
static public var ITS_ME:Boolean = true;
static public var POINT:int;
static public var STEP:int;
static public var LEAGUE:int;
static public var HEIGHT:int;
static public const ICON_X:int = 300;
static public const ICON_WIDTH:int = 160;
static public const ICON_HEIGHT:int = 176;
static public const CARDS_WIDTH:int = 210;
static public const SLIDER_WIDTH:int = 48;
static private var ICON_LAYOUT_DATA:AnchorLayoutData = new AnchorLayoutData(-ICON_HEIGHT * 0.54, NaN, NaN, NaN, ICON_X);
static public const MIN_POINT_LAYOUT_DATA:AnchorLayoutData = new AnchorLayoutData(ICON_HEIGHT * 0.5, NaN, NaN, NaN, ICON_X);
static private const MIN_POINT_GRID:Rectangle = new Rectangle(39, 39, 1, 1);

private var league:Arena;
private var ready:Boolean;
private var commited:Boolean;
private var earnOverlay:EarnOverlay;
public function LeagueItemRenderer(){ super(); }
override protected function initialize():void
{
	height = HEIGHT;
	super.initialize();
	layout = new AnchorLayout();
}

override protected function commitData():void
{
	super.commitData();
	if( index < 0 )
		return;
	
	league = _data as Arena;//trace(index, league.index , playerLeague)
	if( league.index == 0 )
		height = 300;
	
	ready = league.index > LEAGUE - 2 && league.index < LEAGUE + 3;
	if( ready )
	{
		createElements();
	}
	else
	{
		_owner.addEventListener(Event.OPEN, _owner_openHandler);
		_owner.addEventListener(Event.SCROLL, _owner_scrollHandler);
	}
}

private function _owner_scrollHandler():void
{
	visible = onScreen(getBounds(stage))
}

private function _owner_openHandler(event:starling.events.Event):void
{
	_owner.removeEventListener(Event.OPEN, _owner_openHandler);
	ready = true;
	if( visible )
		createElements();
	else
		setTimeout(createElements, 1200);
}

private function createElements():void
{
	if( commited || !ready )
		return;
	
	if( ITS_ME )
	{
		// icon
		var leagueIcon:LeagueButton = new LeagueButton(league.index);
		leagueIcon.layoutData = ICON_LAYOUT_DATA;
		leagueIcon.width = ICON_WIDTH;
		leagueIcon.height = ICON_HEIGHT;
		leagueIcon.pivotX = leagueIcon.width * 0.5;
		leagueIcon.pivotY = leagueIcon.height * 0.5;
		leagueIcon.touchable = false;
		addChild(leagueIcon);
		if( league.index == LEAGUE )
		{
			leagueIcon.scale = 1.2;
			Starling.juggler.tween(leagueIcon, 0.3, {scale:1});
		}
	}
	
	if( league.index <= 0 )
	{
		commited = true;
		return;
	}

	
	// rewards items
	for ( var r:int = 0; r < league.rewards.length; r++ )
		createRewardItem(r);
	 
	// progress bar
	var currentLeague:Arena = game.arenas.get(LEAGUE);
	if( LEAGUE  >= league.index )
	{
		var sliderFill:ImageLoader = new ImageLoader();
		sliderFill.layoutData = new AnchorLayoutData(0, NaN, 0, NaN, ICON_X);
		sliderFill.source = appModel.assets.getTexture("leagues/slider-fill");
		sliderFill.scale9Grid = MainTheme.SMALL_BACKGROUND_SCALE9_GRID;
		sliderFill.width = SLIDER_WIDTH;
		addChildAt(sliderFill, 0);
		
		if( LEAGUE  == league.index )
		{
			var stepH:int = HEIGHT / league.rewards.length;
			var bottomStep:TrophyReward, topStep:TrophyReward;
			for(var i:int = 0; i < league.rewards.length; i++ )
			{
				if( POINT <= league.rewards[i].point )
				{
					bottomStep = i < 1 ? new TrophyReward(game, league.index, -1, league.min, 0, 0, -1) : league.rewards[i-1];
					topStep = league.rewards[i];
					break;
				}
			}
			var fillHeight:Number = HEIGHT - stepH * (1 + bottomStep.index + (POINT - bottomStep.point) / (topStep.point - bottomStep.point));

			var pointRect:ImageLoader = new ImageLoader();
			pointRect.source = appModel.assets.getTexture("leagues/point-rect");
			pointRect.width = 150;
			pointRect.height = 72;
			pointRect.scale9Grid = new Rectangle(17, 17, 2, 2);
			pointRect.layoutData = new AnchorLayoutData(fillHeight - pointRect.height * 0.5, -10)
			addChild(pointRect);
			
			var pointLine:ImageLoader = new ImageLoader();
			pointLine.source = appModel.theme.quadSkin;
			pointLine.scale9Grid = MainTheme.QUAD_SCALE9_GRID;
			pointLine.width = 100;
			pointLine.height = 4;
			pointLine.x = stageWidth * 0.5 + ICON_X;
			pointLine.y = fillHeight - pointLine.height * 0.5;
			addChildAt(pointLine, 1);
			
			var pointIcon:ImageLoader = new ImageLoader();
			pointIcon.source = appModel.assets.getTexture("res-2");
			pointIcon.width = pointIcon.height = 52;
			pointIcon.layoutData = new AnchorLayoutData(fillHeight - pointIcon.height * 0.5, pointRect.width - 70);
			addChild(pointIcon);

			AnchorLayoutData(sliderFill.layoutData).top = fillHeight;
		}
	}
	
	if( LEAGUE <= league.index )
	{
		var sliderBackground:ImageLoader = new ImageLoader();
		sliderBackground.source = appModel.assets.getTexture("leagues/slider-background");
		sliderBackground.layoutData = new AnchorLayoutData(0, NaN, 0, NaN, ICON_LAYOUT_DATA.horizontalCenter);
		sliderBackground.scale9Grid = MainTheme.SMALL_BACKGROUND_SCALE9_GRID;
		sliderBackground.width = SLIDER_WIDTH;
		addChildAt(sliderBackground, 0);
	}

	if( ITS_ME && league.index > 0 )
	{
		var minPointRect:ImageLoader = new ImageLoader();
		minPointRect.source = appModel.assets.getTexture("leagues/min-point-rect");
		minPointRect.layoutData = MIN_POINT_LAYOUT_DATA;
		minPointRect.scale9Grid = MIN_POINT_GRID;
		minPointRect.width = 180;
		minPointRect.height = 68;
		addChild(minPointRect);
	}

	if( LEAGUE == league.index )
	{
		var pointLabel:RTLLabel = new RTLLabel(StrUtils.getNumber(POINT), 1, "center", null, false, "center", 0.7);
		pointLabel.layoutData = new AnchorLayoutData(fillHeight - pointRect.height * 0.5 + 5, -10);
		pointLabel.width = pointRect.width - 40;
		addChild(pointLabel);
	}

	if( ITS_ME && league.index > 0 )
	{
		var minPointLabel:RTLLabel = new RTLLabel(StrUtils.getNumber(league.max + "+"), 1, "center", null, false, null, 0.8);
		minPointLabel.layoutData = MIN_POINT_LAYOUT_DATA;
		addChild(minPointLabel);
	}

	if( league.index == LEAGUE && _owner != null )
		setTimeout(_owner.dispatchEventWith, 500, Event.OPEN);
	commited = true;
}


private function createRewardItem(r:int) : void 
{
	if( !ITS_ME && r == league.rewards.length - 1 )
		return;
	var reward:TrophyReward = league.rewards[r];
	var reached:Boolean = reward.reached(POINT);
	var collectible:Boolean = reward.collectible(POINT, STEP);
	var colW:int = 240;
	var itemX:int = 60;
	var itemY:int = HEIGHT - (r+1) / league.rewards.length * HEIGHT;
	var itemW:int = 660;
	var isCard:Boolean = ResourceType.isCard(reward.key);

	if( ResourceType.isEvent(reward.key) )
	{
		createEventItem(itemX, itemY, itemW, reward, reached, collectible);
		createPoint(reward, itemY);
		return;
	}

	var item:SimpleLayoutButton = new SimpleLayoutButton();
	item.layout = new AnchorLayout();
	item.touchGroup = true;
	item.data = {index:r, reward:reward};
	item.width = itemW;
	item.height = 340;
	item.pivotX = item.width * 0.5;
	item.pivotY = item.height * 0.5;
	item.x = itemX + item.pivotX;
	item.y = itemY;
	
	var itemSkin:Image = new Image(appModel.assets.getTexture(reached ? (collectible ? "events/index-bg-10-up" : "events/index-bg-1-up") : "events/index-bg-0-up"));
	itemSkin.scale9Grid = ChallengeIndexItemRenderer.BG_SCALE_GRID;
	itemSkin.pixelSnapping = false;
	item.backgroundSkin = itemSkin;

	var shineImage:ImageLoader = new ImageLoader();
	shineImage.alpha = 0.8;
	shineImage.color = 0xFFFFCC;
	shineImage.pixelSnapping = false;
	shineImage.source = appModel.assets.getTexture("shop/shine-under-item");

	var itemIcon:FeathersControl;
	if( ResourceType.isCard(reward.key) )
	{
		itemIcon = new CardView();
		CardView(itemIcon).type = reward.key;
		CardView(itemIcon).availablity = CardTypes.AVAILABLITY_EXISTS;
		itemIcon.height = colW;
		itemIcon.width = colW / CardView.VERICAL_SCALE;
		shineImage.width = shineImage.height = colW * 1.2;
	}
	else
	{
		itemIcon = new ImageLoader();
		itemIcon.height = colW;
		itemIcon.width = colW * 0.9;
		ImageLoader(itemIcon).source = appModel.assets.getTexture(BundleDetailsPopup.getTexturURL(reward.key));
		shineImage.width = shineImage.height = colW * 0.9;
	}
	itemIcon.pivotX = itemIcon.width * 0.5;
	itemIcon.pivotY = itemIcon.height * 0.5;
	itemIcon.x = item.width - colW + itemIcon.width * 0.5 + 10;
	itemIcon.y = item.height * 0.43;
	item.addChild(itemIcon);

	shineImage.pivotX = shineImage.pivotY = shineImage.width * 0.5;
	shineImage.x = itemIcon.x;
	shineImage.y = itemIcon.y;
	Starling.juggler.tween(shineImage, 14, {rotation:Math.PI * 2, repeatCount:40});
	item.addChildAt(shineImage, 0);

	if( reached && !collectible )
	{
		var achievedImage:ImageLoader = new ImageLoader();
		achievedImage.layoutData = new AnchorLayoutData(NaN, NaN, 80, 20);
		achievedImage.source = appModel.theme.pickerListItemSelectedIconTexture;
		achievedImage.pixelSnapping = false;
		achievedImage.color = 0x1BFD06;
		item.addChild(achievedImage);
	}

	var messageDisplay:ShadowLabel = new ShadowLabel(messageFormatter(reward.key, reward.value), 1, 0, "center", null, false, null, 0.85);
	messageDisplay.layoutData = new AnchorLayoutData(NaN, 240, NaN, 20, NaN, -20);
	messageDisplay.pixelSnapping = false;
	item.addChild(messageDisplay);

	createPoint(reward, item.y);

	if( collectible )
	{
		item.addEventListener(Event.TRIGGERED, rewardItem_triggeredHandler);
		punchButton(item);
	}
	addChild(item);
}

private function messageFormatter(type:int, count:int) : String
{
	if( ResourceType.isBook(type) )
		return loc("exchange_title_" + type);
	if( ResourceType.isCard(type) )
		return loc("new_card_label");
	return loc("count_mid", [count, loc("resource_title_" + type)]);
}

private function punchButton(collectButton:LayoutGroup) : void
{
	Starling.juggler.tween(collectButton, 0.8, {delay:1 + Math.random(), scale:1, transition:Transitions.EASE_OUT_BACK,
	onComplete:punchButton, onCompleteArgs:[collectButton], onStart:function():void{collectButton.scale = 1.1;}});
}


private function createEventItem(x:int, y:int, width:int, reward:TrophyReward, reached:Boolean, collectible:Boolean):void
{
	var item:ChallengeIndexItemRenderer = new ChallengeIndexItemRenderer();
	ChallengeIndexItemRenderer.IS_FRIENDLY = true;
	item.width = width;
	item.height = reached ? 400 : 340;
	item.x = x;
	item.y = y - item.height * 0.5;
	item.data = reward.key % 10;
	addChild(item);
}
private function createPoint(reward:TrophyReward, y:int):void
{
	var pointDisplay:ShadowLabel = new ShadowLabel(StrUtils.getNumber(reward.point), 1, 0, "center", null, false, null, 1);
	pointDisplay.height = 100;
	pointDisplay.pivotY = pointDisplay.height * 0.5
	pointDisplay.y = y;
	pointDisplay.x = stageWidth - 160;
	addChild(pointDisplay);
}

protected function rewardItem_triggeredHandler(event:Event) : void 
{
	var item:SimpleLayoutButton = event.currentTarget as SimpleLayoutButton;
	item.removeEventListener(Event.TRIGGERED, rewardItem_triggeredHandler);
	var reward:TrophyReward = item.data.reward as TrophyReward;

	if( player.achieveReward(reward.league, reward.index as int) != MessageTypes.RESPONSE_SUCCEED )
	{
		appModel.navigator.addLog(loc("arena_reward_error"));
		Starling.juggler.delayCall(_owner.scrollToPosition, 0.1, NaN, _owner.verticalScrollPosition + 500, 1);
		return;
	}
	
	if( ResourceType.isBook(reward.key) )
	{
		earnOverlay = new OpenBookOverlay(reward.key) as EarnOverlay;
	}
	else
		earnOverlay = new NewCardOverlay(reward.key) as EarnOverlay;
	earnOverlay.data = reward as Object;
	appModel.navigator.addOverlay(earnOverlay);

	var params:SFSObject = new SFSObject();
	params.putInt("l", ITS_ME ? reward.league : 1000);
	params.putInt("i", reward.index);
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_responseHandler)
	SFSConnection.instance.sendExtensionRequest(SFSCommands.COLLECT_ROAD_REWARD, params);
}

protected function sfs_responseHandler(event:SFSEvent):void
{
	if( event.params.cmd != SFSCommands.COLLECT_ROAD_REWARD )
		return;
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_responseHandler);
	if( event.params.params.getInt("response") != MessageTypes.RESPONSE_SUCCEED )
		return;

	var outcomes:IntIntMap = EarnOverlay.getOutcomse(event.params.params.getSFSArray("outcomes"))		
	earnOverlay.outcomes = outcomes;
	earnOverlay.addEventListener(Event.CLOSE, earnOverlay_closeHandler);

	player.addResources(outcomes);
}

protected function earnOverlay_closeHandler(event:Event) : void 
{
	earnOverlay.removeEventListener(Event.CLOSE, earnOverlay_closeHandler);
	removeChildren();
	commited = false;
	createElements();
}
}
}