package com.gerantech.towercraft.controls.items
{
import com.gerantech.mmory.core.constants.CardTypes;
import com.gerantech.mmory.core.constants.MessageTypes;
import com.gerantech.mmory.core.constants.ResourceType;
import com.gerantech.mmory.core.others.Arena;
import com.gerantech.mmory.core.utils.Int3;
import com.gerantech.towercraft.controls.CardView;
import com.gerantech.towercraft.controls.buttons.LeagueButton;
import com.gerantech.towercraft.controls.buttons.SimpleLayoutButton;
import com.gerantech.towercraft.controls.items.challenges.ChallengeIndexItemRenderer;
import com.gerantech.towercraft.controls.overlays.NewCardOverlay;
import com.gerantech.towercraft.controls.popups.BundleDetailsPopup;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.MainTheme;
import com.gerantech.towercraft.utils.StrUtils;

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
static public var LEAGUE:int;
static public var HEIGHT:int;
static public const ICON_X:int = 310;
static public const ICON_WIDTH:int = 160;
static public const ICON_HEIGHT:int = 176;
static public const CARDS_WIDTH:int = 210;
static public const SLIDER_WIDTH:int = 48;
static private var ICON_LAYOUT_DATA:AnchorLayoutData = new AnchorLayoutData(-ICON_HEIGHT * 0.54, NaN, NaN, NaN, ICON_X);
static public const MIN_POINT_LAYOUT_DATA:AnchorLayoutData = new AnchorLayoutData(ICON_HEIGHT * 0.5, NaN, NaN, NaN, ICON_X);
static private const MIN_POINT_GRID:Rectangle = new Rectangle(39, 39, 1, 1);
private var ready:Boolean;
private var league:Arena;
private var commited:Boolean;
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
		var fillHeight:Number = HEIGHT * (currentLeague.max  - player.get_point()) / (currentLeague.max - currentLeague.min);
		var sliderFill:ImageLoader = new ImageLoader();
		sliderFill.layoutData = new AnchorLayoutData(LEAGUE  > league.index ? 0 : fillHeight, NaN, 0, NaN, ICON_X);
		sliderFill.source = Assets.getTexture("leagues/slider-fill", "gui");
		sliderFill.scale9Grid = MainTheme.SMALL_BACKGROUND_SCALE9_GRID;
		sliderFill.width = SLIDER_WIDTH;
		addChildAt(sliderFill, 0);
		
		if( LEAGUE  == league.index )
		{
			var pointRect:ImageLoader = new ImageLoader();
			pointRect.source = Assets.getTexture("leagues/point-rect", "gui");
			pointRect.width = 150;
			pointRect.height = 72;
			pointRect.scale9Grid = new Rectangle(17, 17, 2, 2);
			pointRect.layoutData = new AnchorLayoutData(fillHeight - pointRect.height * 0.5, -10);
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
			pointIcon.source = Assets.getTexture("res-2", "gui");
			pointIcon.width = pointIcon.height = 52;
			pointIcon.layoutData = new AnchorLayoutData(fillHeight - pointIcon.height * 0.5, pointRect.width - 70);
			addChild(pointIcon);
		}
	}
	
	if( LEAGUE <= league.index )
	{
		var sliderBackground:ImageLoader = new ImageLoader();
		sliderBackground.source = Assets.getTexture("leagues/slider-background", "gui");
		sliderBackground.layoutData = new AnchorLayoutData(0, NaN, 0, NaN, ICON_LAYOUT_DATA.horizontalCenter);
		sliderBackground.scale9Grid = MainTheme.SMALL_BACKGROUND_SCALE9_GRID;
		sliderBackground.width = SLIDER_WIDTH;
		addChildAt(sliderBackground, 0);
	}

	if( league.index > 0 )
	{
		var minPointRect:ImageLoader = new ImageLoader();
		minPointRect.source = Assets.getTexture("leagues/min-point-rect", "gui");
		minPointRect.layoutData = MIN_POINT_LAYOUT_DATA;
		minPointRect.scale9Grid = MIN_POINT_GRID;
		minPointRect.width = 180;
		minPointRect.height = 68;
		addChild(minPointRect);
	}

	if( LEAGUE == league.index )
	{
		var pointLabel:RTLLabel = new RTLLabel(StrUtils.getNumber(player.get_point()), 1, "center", null, false, "center", 0.7);
		pointLabel.layoutData = new AnchorLayoutData(fillHeight - pointRect.height * 0.5 + 5, -10);
		pointLabel.width = pointRect.width - 40;
		addChild(pointLabel);
	}

	if( league.index > 0 )
	{
		var minPointLabel:RTLLabel = new RTLLabel(StrUtils.getNumber(league.max + "+"), 1, "center", null, false, null, 0.8);
		minPointLabel.layoutData = MIN_POINT_LAYOUT_DATA;
		addChild(minPointLabel);
	}


	if( league.index == LEAGUE )
		setTimeout(_owner.dispatchEventWith, 500, Event.OPEN);
	commited = true;
}


private function createRewardItem(r:int) : void 
{
	var colW:int = 240;
	var reward:Int3 = league.rewards[r];
	var rewardId:int = (league.index - 1) * 3 + r;
	var reached:Boolean = reward.i < player.get_point();
	var collectible:Boolean = reached && player.getRewardStep() < rewardId;
	var rewardType:int = reward.j;
	var rewardCount:int = reward.k;

	var item:SimpleLayoutButton = new SimpleLayoutButton();
	item.layout = new AnchorLayout();
	item.data = {index:r, reward:reward};
	item.width = 666;
	item.height = 330;
	item.pivotX = item.width * 0.5;
	item.pivotY = item.height * 0.5;
	item.x = 60 + item.pivotX;
	item.y = HEIGHT - (reward.i - league.min) / (league.max - league.min) * HEIGHT;

	var itemSkin:Image = new Image(Assets.getTexture(reached ? (collectible ? "events/index-bg-10-up" : "events/index-bg-1-up") : "events/index-bg-4-up", "gui"));
	itemSkin.scale9Grid = ChallengeIndexItemRenderer.BG_SCALE_GRID;
	itemSkin.pixelSnapping = false;
	item.backgroundSkin = itemSkin;

	var shineImage:ImageLoader = new ImageLoader();
	shineImage.alpha = 0.8;
	shineImage.color = 0xFFFFCC;
	shineImage.pixelSnapping = false;
	shineImage.source = Assets.getTexture("shop/shine-under-item", "gui");

	var itemIcon:FeathersControl;
	if( ResourceType.isCard(rewardType) )
	{
		itemIcon = new CardView();
		CardView(itemIcon).type = rewardType;
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
		ImageLoader(itemIcon).source = Assets.getTexture(BundleDetailsPopup.getTexturURL(rewardType), "gui");
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

	var titleDisplay:RTLLabel = new RTLLabel(titleFormatter(rewardType, rewardCount), collectible ? 0 : 0x1FA8FF, "center", null, false, null, 0.95);
	titleDisplay.pixelSnapping = false;
	titleDisplay.layoutData = new AnchorLayoutData(60, 260, NaN, 20);
	item.addChild(titleDisplay);

	var messageDisplay:ShadowLabel = new ShadowLabel(messageFormatter(rewardType, rewardCount), 1, 0, "center", null, false, null, 1);
	messageDisplay.pixelSnapping = false;
	messageDisplay.layoutData = new AnchorLayoutData(NaN, 260, 100, 20);
	item.addChild(messageDisplay);

	var pointDisplay:ShadowLabel = new ShadowLabel(StrUtils.getNumber(reward.i), 1, 0, "center", null, false, null, 1);
	pointDisplay.height = 100;
	pointDisplay.pivotY = pointDisplay.height * 0.5
	pointDisplay.y = item.y;
	pointDisplay.x = stageWidth - 140;
	addChild(pointDisplay);

	if( collectible )
	{
		item.addEventListener(Event.TRIGGERED, rewaardItem_triggeredHandler);
		punchButton(item);
	}
	addChild(item);
}

private function titleFormatter(type:int, count:int) : String
{
	if( ResourceType.isBook(type) )
		return StrUtils.loc("exchange_title_" + type);
	if( ResourceType.isCard(type) )
		return StrUtils.loc("card_title_" + type);
	return StrUtils.loc("resource_title_" + type);
}

private function messageFormatter(type:int, count:int) : String
{
	if( ResourceType.isBook(type) )
		return StrUtils.loc("arena_text") + " " + StrUtils.loc("num_" + (count + 1));
	return "x" + StrUtils.getNumber(count);
}

private function punchButton(collectButton:LayoutGroup) : void
{
	Starling.juggler.tween(collectButton, 0.8, {delay:1 + Math.random(), scale:1, transition:Transitions.EASE_OUT_BACK,
	onComplete:punchButton, onCompleteArgs:[collectButton], onStart:function():void{collectButton.scale = 1.1;}});
}



protected function rewaardItem_triggeredHandler(event:Event) : void 
{
	var item:SimpleLayoutButton = event.currentTarget as SimpleLayoutButton;
	item.removeEventListener(Event.TRIGGERED, rewaardItem_triggeredHandler);
	var rewardIndex:int = (league.index - 1) * 3 + int(item.data.index);

	if(player.achieveReward(league.index, item.data.index as int) != MessageTypes.RESPONSE_SUCCEED )
	{
		appModel.navigator.addLog("Not Allowed!");
		return;
	}
/* 	var overlay:NewCardOverlay = new NewCardOverlay(cardType);
	overlay.addEventListener(Event.CLOSE, overlay_closeHandler);
	appModel.navigator.addOverlay(overlay); */
}

protected function overlay_closeHandler(event:Event) : void 
{
	var overlay:NewCardOverlay = event.currentTarget as NewCardOverlay;
	overlay.removeEventListener(Event.CLOSE, overlay_closeHandler);
	removeChildren();
	commited = false;
	createElements();
}
}
}