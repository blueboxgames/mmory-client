package com.gerantech.towercraft.controls.segments
{
import com.gerantech.mmory.core.constants.ExchangeType;
import com.gerantech.mmory.core.constants.PrefsTypes;
import com.gerantech.towercraft.Game;
import com.gerantech.towercraft.controls.buttons.BattleButton;
import com.gerantech.towercraft.controls.buttons.CollectableLeaguesButton;
import com.gerantech.towercraft.controls.buttons.CollectableQuestsButton;
import com.gerantech.towercraft.controls.buttons.CollectableStarsButton;
import com.gerantech.towercraft.controls.buttons.IconButton;
import com.gerantech.towercraft.controls.buttons.Indicator;
import com.gerantech.towercraft.controls.buttons.SimpleLayoutButton;
import com.gerantech.towercraft.controls.groups.HomeBooksLine;
import com.gerantech.towercraft.controls.groups.Profile;
import com.gerantech.towercraft.controls.items.challenges.ChallengeIndexItemRenderer;
import com.gerantech.towercraft.controls.popups.BundleDetailsPopup;
import com.gerantech.towercraft.controls.popups.RankingPopup;
import com.gerantech.towercraft.controls.popups.SelectNamePopup;
import com.gerantech.towercraft.controls.screens.DashboardScreen;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.controls.tooltips.BaseTooltip;
import com.gerantech.towercraft.managers.net.LoadingManager;
import com.gerantech.towercraft.managers.oauth.OAuthManager;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.tutorials.TutorialData;
import com.gerantech.towercraft.models.tutorials.TutorialTask;
import com.gerantech.towercraft.models.vo.UserData;
import com.gerantech.towercraft.themes.MainTheme;
import com.gerantech.towercraft.utils.StrUtils;

import feathers.controls.Button;
import feathers.controls.ImageLoader;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

import flash.geom.Rectangle;

import starling.core.Starling;
import starling.display.DisplayObject;
import starling.events.Event;

public class HomeSegment extends Segment
{
static private var OFFER_BUNDLE:Boolean
static private var OFFER_SOCIAL_AUTH:Boolean
private var league:int;
private var battleTimeoutId:uint;
private var googleButton:IconButton;
private var questsButton:CollectableQuestsButton;
public function HomeSegment() { super(); }
override public function init():void
{
	super.init();
	if( initializeCompleted || appModel.loadingManager.state < LoadingManager.STATE_LOADED )
		return;
	league = player.get_arena(0);
	initializeCompleted = true;
	layout = new AnchorLayout();

	// events button
	ChallengeIndexItemRenderer.IN_HOME = true;
	ChallengeIndexItemRenderer.SHOW_INFO = false;
	ChallengeIndexItemRenderer.IS_FRIENDLY = false;
	var eventsButton:ChallengeIndexItemRenderer = new ChallengeIndexItemRenderer();
	eventsButton.width = 840;
	eventsButton.height = Math.min(410, stageHeight * 0.23)
	eventsButton.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, -stageHeight * 0.05);
	eventsButton.data = UserData.instance.challengeIndex;
	addButton(eventsButton, "eventsButton");
	
	// battle button
	var battleButton:BattleButton = new BattleButton("button-battle", loc("button_battle"), new Rectangle(75, 75, 1, 35), new Rectangle(0, 0, 0, 30));
	battleButton.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, stageHeight * 0.10);
	battleButton.height = Math.min(260, stageHeight * 0.16);
	battleButton.width = 420;
	addButton(battleButton, "battleButton");

	// battle button background panel
	var bg:ImageLoader = new ImageLoader();
	bg.source = appModel.theme.roundBigSkin;
	bg.scale9Grid = MainTheme.ROUND_BIG_SCALE9_GRID;
	bg.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, -stageHeight * 0.052);
	
	bg.height = eventsButton.height + 40;
	bg.width = eventsButton.width + 60;
	bg.color = 0x194685;
	addChildAt(bg, getChildIndex(eventsButton));
	
	var bgd:ImageLoader = new ImageLoader();
	bgd.source = appModel.theme.roundBigSkin;
	bgd.scale9Grid = MainTheme.ROUND_BIG_SCALE9_GRID;
	bgd.layoutData = battleButton.layoutData;
	bgd.height = battleButton.height + 90;
	bgd.width = battleButton.width + 60;
	bgd.color = bg.color;
	addChildAt(bgd, getChildIndex(eventsButton));
	
	// bookline
	Starling.juggler.delayCall(showBookline, 0.2);
	function showBookline() : void
	{
		var bookLine:HomeBooksLine = new HomeBooksLine();
		bookLine.layoutData = new AnchorLayoutData(NaN, paddingH, stageHeight * 0.015, paddingH);
		bookLine.alpha = 0;
		Starling.juggler.tween(bookLine, 0.2, {alpha:1});
		addChild(bookLine);

		if( player.admin ) // hidden admin button
		{
			var adminButton:Button = new Button();
			adminButton.alpha = 0;
			adminButton.isLongPressEnabled = true;
			adminButton.longPressDuration = 1;
			adminButton.width = adminButton.height = 200;
			adminButton.addEventListener(FeathersEventType.LONG_PRESS, function():void{appModel.navigator.pushScreen(Game.ADMIN_SCREEN)});
			adminButton.layoutData = new AnchorLayoutData(NaN, paddingH, bookLine.height);
			addChild(adminButton);
		}
	}
	showTutorial();
	if( league < 1 )
	{
		var tutorProgressLayout:AnchorLayoutData = new AnchorLayoutData(stageHeight * 0.21, NaN, NaN, NaN, 10); 
		var tutorialProgress:Indicator = new Indicator("ltr", 60, true, false, false);
		tutorialProgress.addEventListener(FeathersEventType.CREATION_COMPLETE, function() : void {
			AnchorLayoutData(tutorialProgress.iconDisplay.layoutData).left = -60; tutorialProgress.iconDisplay.width = tutorialProgress.iconDisplay.height = tutorialProgress.height + 76; });
		tutorialProgress.formatValueFactory = function(value:Number, minimum:Number, maximum:Number) : String { return StrUtils.getNumber(Math.round(value) + "/" + appModel.maxTutorBattles); }
		tutorialProgress.setData(0, player.get_battleswins(), appModel.maxTutorBattles, 1);
		tutorialProgress.layoutData = tutorProgressLayout;
		tutorialProgress.height = stageHeight * 0.031;
		tutorialProgress.width = stageWidth * 0.56;
		addChild(tutorialProgress);
		
		var tutorialTitle:ShadowLabel = new ShadowLabel(loc("tutor_home_title"), 0x3ECAFF, 0, null, null);
		tutorialTitle.layoutData = new AnchorLayoutData(tutorProgressLayout.top - 135, NaN, NaN, NaN, 0);
		addChild(tutorialTitle);
		
		var tutorialMessage:ShadowLabel = new ShadowLabel(loc("tutor_home_message"), 1, 0, null, null, false, null, 0.7);
		tutorialMessage.layoutData = new AnchorLayoutData(tutorProgressLayout.top - 60, NaN, NaN, NaN, 0);
		addChild(tutorialMessage);
		return;
	}
	
	var profile:Profile  = new Profile();
	profile.layoutData = new AnchorLayoutData(130, paddingH + 32, NaN, paddingH + 120);
	profile.name = "profile";
	addChild(profile);

	var leaguesButton:CollectableLeaguesButton = new CollectableLeaguesButton();
	leaguesButton.layoutData = new AnchorLayoutData(120, NaN, NaN, paddingH + 32);
	addButton(leaguesButton, "leaguesButton");
	
	var starsButton:CollectableStarsButton = new CollectableStarsButton();
	starsButton.layoutData = new AnchorLayoutData(330, paddingH + 32);
	starsButton.height = 140;
	starsButton.width = 410;
	addButton(starsButton, "starsButton");
	
	questsButton = new CollectableQuestsButton();
	questsButton.layoutData = new AnchorLayoutData(NaN, NaN, NaN, paddingH + 32, NaN, stageHeight * 0.15);
	questsButton.width = questsButton.height = 140;
	addButton(questsButton, "questsButton");
	
	var rankButton:IconButton = new IconButton(Assets.getTexture("home/ranking"), 0.6, Assets.getTexture("home/button-bg-0"), new Rectangle(22, 38, 4, 4));
	rankButton.layoutData = new AnchorLayoutData(NaN, paddingH + 32, NaN, NaN, NaN, stageHeight * 0.15);
	rankButton.width = rankButton.height = 140;
	addButton(rankButton, "rankButton");
	
	if( player.get_battleswins() > 10 && !player.prefs.getAsBool(PrefsTypes.AUTH_41_GOOGLE) )
	{
		googleButton = new IconButton(Assets.getTexture("settings/41"), 0.6, Assets.getTexture("home/button-bg-0"), new Rectangle(22, 38, 4, 4));
		googleButton.layoutData = new AnchorLayoutData(330, paddingH + 36 + starsButton.width);
		googleButton.width = googleButton.height = 140;
		addButton(googleButton, "googleButton");
	}

	Starling.juggler.delayCall(showOffers, 1.5);
}

private	function showOffers () : void
{
	if( DashboardScreen.TAB_INDEX != 2 )
		return;
	if( exchanger.items.exists(ExchangeType.C31_BUNDLE) && exchanger.items.get(ExchangeType.C31_BUNDLE).expiredAt > timeManager.now && !OFFER_BUNDLE )
	{
		OFFER_BUNDLE = true;
		appModel.navigator.addPopup(new BundleDetailsPopup(exchanger.items.get(ExchangeType.C31_BUNDLE)));
		return;
	}

	if( googleButton != null && !OFFER_SOCIAL_AUTH )
	{
		OFFER_SOCIAL_AUTH = true;
		var googleTooltip:BaseTooltip = new BaseTooltip(loc("socials_signin_warn"), new Rectangle(googleButton.x, googleButton.y, googleButton.width, googleButton.height));
		this.addChild(googleTooltip);
	}
}

override public function focus():void
{
	if( initializeCompleted )
		showTutorial();
}

private function addButton(button:DisplayObject, name:String, x:int=0, y:int=0, delay:Number=0, scale:Number = 1):void
{
	button.addEventListener(Event.TRIGGERED, mainButtons_triggeredHandler);
	button.name = name;
	addChild(button);
}	

// show tutorial steps
private function showTutorial():void
{
	var tutorStep:int = player.getTutorStep();
	trace("player.inTutorial: ", player.inTutorial(), "tutorStep: ", tutorStep);

	var challengeTutorialMode:Boolean = player.getTutorStep() == PrefsTypes.T_211_CHALLENGES_SELECTED || player.getTutorStep() == PrefsTypes.T_221_CHALLENGES_SELECTED || player.getTutorStep() == PrefsTypes.T_231_CHALLENGES_SELECTED;
	if( (player.get_battleswins() < 2 && player.getTutorStep() >= PrefsTypes.T_018_CARD_UPGRADED) || challengeTutorialMode )
	{
		SimpleLayoutButton(getChildByName("battleButton")).showTutorHint();
		if( challengeTutorialMode )
			UserData.instance.prefs.setInt(PrefsTypes.TUTOR, player.getTutorStep() + 1); 
		return;
	}
	
	if( league > 0 && player.nickName == "guest" )
	{
		var confirm:SelectNamePopup = new SelectNamePopup();
		confirm.addEventListener(Event.COMPLETE, confirm_eventsHandler);
		appModel.navigator.addPopup(confirm);
		function confirm_eventsHandler():void
		{
			confirm.removeEventListener(Event.COMPLETE, confirm_eventsHandler);
			UserData.instance.prefs.setInt(PrefsTypes.TUTOR, PrefsTypes.T_72_NAME_SELECTED);
			appModel.navigator.pushScreen( Game.LEAGUES_SCREEN );
		}
	}

	// show challenge tutorial
	if( player.getTutorStep() == PrefsTypes.T_210_CHALLENGES_FOCUS || player.getTutorStep() == PrefsTypes.T_220_CHALLENGES_FOCUS || player.getTutorStep() == PrefsTypes.T_230_CHALLENGES_FOCUS )
	{
		var tutorialData:TutorialData = new TutorialData("challenge_tutorial");
		tutorialData.addTask(new TutorialTask(TutorialTask.TYPE_MESSAGE, "tutor_challenge_" + player.getTutorStep(), null, 500, 1500, 0));
		tutorials.show(tutorialData);

	}
}

private function mainButtons_triggeredHandler(event:Event):void
{
	var buttonName:String = DisplayObject(event.currentTarget).name;
	switch( buttonName )
	{
		case "eventsButton":	if( player.get_battleswins() >= appModel.maxTutorBattles ) appModel.navigator.pushScreen( Game.CHALLENGES_SCREEN );				return;
		case "battleButton":	appModel.navigator.runBattle(UserData.instance.challengeIndex);	return;
	}
	
	if( league < 0 )
	{
		appModel.navigator.addLog(loc("try_to_league_up"));
		return;
	}
	
	switch( buttonName )
	{
		case "leaguesButton":	appModel.navigator.pushScreen( Game.LEAGUES_SCREEN );										return;
		case "questsButton":	appModel.navigator.pushScreen( Game.QUESTS_SCREEN );										return;
		case "rankButton": 		appModel.navigator.addPopup( new RankingPopup() );											return;
		case "starsButton":		exchangeManager.process(exchanger.items.get(ExchangeType.C104_STARS));	return;
		case "adsButton":			exchangeManager.process(exchanger.items.get(ExchangeType.C43_ADS)); 		return;
		case "googleButton":	socialSignin();														 															return;
	}
}

private function socialSignin():void 
{
	OAuthManager.instance.addEventListener(OAuthManager.SINGIN, socialManager_signinHandler);
	OAuthManager.instance.signin();
}

private function socialManager_signinHandler(e:Event):void 
{
	OAuthManager.instance.removeEventListener(OAuthManager.SINGIN, socialManager_signinHandler);
	googleButton.removeFromParent();
}

override public function dispose():void
{
	Starling.juggler.removeDelayedCalls(showOffers);
	super.dispose();
} 
}
}