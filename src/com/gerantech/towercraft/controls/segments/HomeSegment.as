package com.gerantech.towercraft.controls.segments
{
import com.gerantech.towercraft.Game;
import com.gerantech.towercraft.controls.TileBackground;
import com.gerantech.towercraft.controls.buttons.CollectableLeaguesButton;
import com.gerantech.towercraft.controls.buttons.HomeButton;
import com.gerantech.towercraft.controls.buttons.BattleButton;
import com.gerantech.towercraft.controls.buttons.CollectableQuestsButton;
import com.gerantech.towercraft.controls.buttons.CollectableStarsButton;
import com.gerantech.towercraft.controls.buttons.IconButton;
import com.gerantech.towercraft.controls.buttons.Indicator;
import com.gerantech.towercraft.controls.buttons.LeagueButton;
import com.gerantech.towercraft.controls.buttons.SimpleLayoutButton;
import com.gerantech.towercraft.controls.groups.HomeBooksLine;
import com.gerantech.towercraft.controls.groups.OfferView;
import com.gerantech.towercraft.controls.groups.Profile;
import com.gerantech.towercraft.controls.items.challenges.ChallengeIndexItemRenderer;
import com.gerantech.towercraft.controls.popups.RankingPopup;
import com.gerantech.towercraft.controls.popups.SelectNamePopup;
import com.gerantech.towercraft.controls.sliders.LabeledProgressBar;
import com.gerantech.towercraft.controls.texts.CountdownLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.controls.tooltips.BaseTooltip;
import com.gerantech.towercraft.events.GameEvent;
import com.gerantech.towercraft.managers.net.LoadingManager;
import com.gerantech.towercraft.managers.oauth.OAuthManager;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.tutorials.TutorialData;
import com.gerantech.towercraft.models.tutorials.TutorialTask;
import com.gerantech.towercraft.models.vo.UserData;
import com.gerantech.towercraft.utils.StrUtils;
import com.gt.towers.battle.fieldes.FieldData;
import com.gt.towers.constants.ExchangeType;
import com.gt.towers.constants.PrefsTypes;
import com.gt.towers.socials.Challenge;
import dragonBones.starling.StarlingArmatureDisplay;
import feathers.controls.Button;
import feathers.controls.ImageLoader;
import feathers.controls.List;
import feathers.controls.ScrollPolicy;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalLayout;
import flash.geom.Rectangle;
import flash.utils.setTimeout;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.events.Event;

public class HomeSegment extends Segment
{
static private var SOCIAL_AUTH_WARNED:Boolean
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
	var padding:int = 32;
	league = player.get_arena(0);
	initializeCompleted = true;
	layout = new AnchorLayout();
	
	// =-=-=-=-=-=-=-=-=-=-=-=- background -=-=-=-=-=-=-=-=-=-=-=-=
	var tileBacground:TileBackground = new TileBackground("home/pistole-tile", 0.3, true);
	tileBacground.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	addChild(tileBacground);

	// events button
	ChallengeIndexItemRenderer.IN_HOME = true;
	ChallengeIndexItemRenderer.SHOW_INFO = false;
	ChallengeIndexItemRenderer.ARENA = league;
	var listLayout:VerticalLayout = new VerticalLayout();
	listLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
	listLayout.typicalItemHeight = Math.min(410, stageHeight * 0.23);
	listLayout.padding = 50;
	listLayout.paddingTop = 280;
	var eventsButton:List = new List();
	eventsButton.layout = listLayout;
	eventsButton.horizontalScrollPolicy = eventsButton.verticalScrollPolicy = ScrollPolicy.OFF;
	eventsButton.itemRendererFactory = function () : IListItemRenderer { return new ChallengeIndexItemRenderer(); };
	eventsButton.dataProvider = new ListCollection([UserData.instance.challengeIndex]);
	eventsButton.layoutData = new AnchorLayoutData(NaN, 100, NaN, 100, NaN, -stageHeight * 0.05);
	eventsButton.height = listLayout.typicalItemHeight + listLayout.padding + listLayout.paddingTop;
	addButton(eventsButton, "eventsButton");
	
	// battle button
	var battleButton:BattleButton = new BattleButton("button-battle", loc("button_battle"), stageWidth * 0.5 - 210, stageHeight * 0.64 - Math.min(130, stageHeight * 0.08), 420, Math.min(260, stageHeight * 0.16), new Rectangle(75, 75, 1, 35), new Rectangle(0, 0, 0, 30));
	addButton(battleButton, "battleButton");
	
	// bookline
	var bookLine:HomeBooksLine = new HomeBooksLine();
	bookLine.layoutData = new AnchorLayoutData(NaN, 0, stageHeight * 0.015, 0);
	addChild(bookLine);

	if( player.admin ) // hidden admin button
	{
		var adminButton:Button = new Button();
		adminButton.alpha = 0;
		adminButton.isLongPressEnabled = true;
		adminButton.longPressDuration = 1;
		adminButton.width = adminButton.height = 200;
		adminButton.addEventListener(FeathersEventType.LONG_PRESS, function():void{appModel.navigator.pushScreen(Game.ADMIN_SCREEN)});
		adminButton.layoutData = new AnchorLayoutData(NaN, 0, bookLine.height);
		addChild(adminButton);
	}
	showTutorial();
	
	if( league < 1 )
	{
		var tutorProgressLayout:AnchorLayoutData = new AnchorLayoutData(stageHeight * 0.21, NaN, NaN, NaN, 10); 
		var tutorialProgress:Indicator = new Indicator("ltr", 60, true, false, false);
		tutorialProgress.addEventListener(FeathersEventType.CREATION_COMPLETE, function() : void {
			AnchorLayoutData(tutorialProgress.iconDisplay.layoutData).left = -60; tutorialProgress.iconDisplay.width = tutorialProgress.iconDisplay.height = tutorialProgress.height + 76; });
		tutorialProgress.formatValueFactory = function(value:Number, minimum:Number, maximum:Number) : String { return StrUtils.getNumber(Math.round(value) + "/4"); }
		tutorialProgress.setData(0, player.get_battleswins(), 4, 1);
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
	profile.layoutData = new AnchorLayoutData(130, 32, NaN, 120);
	profile.name = "profile";
	addChild(profile);

	var leaguesButton:CollectableLeaguesButton = new CollectableLeaguesButton();
	leaguesButton.layoutData = new AnchorLayoutData(120, NaN, NaN, padding);
	addButton(leaguesButton, "leaguesButton");
	
	var starsButton:CollectableStarsButton = new CollectableStarsButton();
	starsButton.layoutData = new AnchorLayoutData(330, padding);
	starsButton.height = 140;
	starsButton.width = 410;
	addButton(starsButton, "starsButton");
	
	questsButton = new CollectableQuestsButton();
	questsButton.layoutData = new AnchorLayoutData(NaN, NaN, NaN, padding, NaN, stageHeight * 0.15);
	questsButton.width = questsButton.height = 140;
	addButton(questsButton, "questsButton");
	
	var rankButton:IconButton = new IconButton(Assets.getTexture("home/ranking"), 0.6, Assets.getTexture("home/button-bg-0"), new Rectangle(22, 38, 4, 4));
	rankButton.layoutData = new AnchorLayoutData(NaN, padding, NaN, NaN, NaN, stageHeight * 0.15);
	rankButton.width = rankButton.height = 140;
	addButton(rankButton, "rankButton");
	
	if( player.get_battleswins() > 5 && !player.prefs.getAsBool(PrefsTypes.AUTH_41_GOOGLE) )
	{
		googleButton = new IconButton(Assets.getTexture("settings/41"), 0.6, Assets.getTexture("home/button-bg-0"), new Rectangle(22, 38, 4, 4));
		googleButton.layoutData = new AnchorLayoutData(330, padding * 1.7 + starsButton.width);
		googleButton.width = googleButton.height = 140;
		addButton(googleButton, "googleButton");
		
		if( !SOCIAL_AUTH_WARNED )
		{
			setTimeout(warnAuthentication, 1000);
			function warnAuthentication () : void {
				appModel.navigator.addChild(new BaseTooltip(loc("socials_signin_warn"), googleButton.getBounds(appModel.navigator)));
			}
			SOCIAL_AUTH_WARNED = true;
		}
	}
	
	/*adsButton = new NotifierButton(Assets.getTexture("button-spectate"));
	adsButton.width = adsButton.height = 140;
	adsButton.layoutData = new AnchorLayoutData(120, NaN, NaN, 20);
	if( exchanger.items.get(ExchangeType.C43_ADS).getState(timeManager.now) == ExchangeItem.CHEST_STATE_READY )
		adsButton.badgeLabel = "!";
	adsButton.addEventListener(Event.TRIGGERED, mainButtons_triggeredHandler);
	addChild(adsButton);*/
}
override public function focus():void
{
	if( initializeCompleted )
		showTutorial();
}

private function showOffers():void 
{
	var offers:OfferView = new OfferView();
	offers.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?NaN:0, NaN, appModel.isLTR?0:NaN);
	offers.width = 780;
	offers.height = 160;
	offers.y = 50;
	addChild(offers);
}

private function addButton(button:DisplayObject, name:String, x:int=0, y:int=0, delay:Number=0, scale:Number = 1):void
{
	//button.x = x;
	//button.y = y;
	//button.scale = scale * 0.5;
	//button.alpha = 0;
	//Starling.juggler.tween(button, 0.5, {delay:delay, scale:scale, alpha:1, transition:Transitions.EASE_OUT_BACK});
	button.addEventListener(Event.TRIGGERED, mainButtons_triggeredHandler);
	button.name = name;
	addChild(button);
}	

// show tutorial steps
private function showTutorial():void
{
	var tutorStep:int = player.getTutorStep();
	trace("player.inTutorial: ", player.inTutorial(), "tutorStep: ", tutorStep);

	if( (player.get_battleswins() < 2 && player.getTutorStep() >= PrefsTypes.T_018_CARD_UPGRADED) || (league > 0 && player.getTutorStep() == PrefsTypes.T_74_CHALLENGE_SELECTED) )
	{
		SimpleLayoutButton(getChildByName("battleButton")).showTutorHint();
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
			
			// show challenge tutorial
			var tutorialData:TutorialData = new TutorialData("challenge_tutorial");
			tutorialData.addTask(new TutorialTask(TutorialTask.TYPE_MESSAGE, "tutor_challenge_0", null, 500, 1500, 0));
			tutorials.show(tutorialData);
		}
	}
}

private function mainButtons_triggeredHandler(event:Event):void
{
	var buttonName:String = DisplayObject(event.currentTarget).name;
	switch( buttonName )
	{
		case "eventsButton":	appModel.navigator.pushScreen( Game.CHALLENGES_SCREEN );				return;
		case "battleButton":	appModel.navigator.runBattle(UserData.instance.challengeIndex);			return;
	}
	
	if( league <= 0 )
	{
		appModel.navigator.addLog(loc("try_to_league_up"));
		return;
	}
	
	switch( buttonName )
	{
		case "leaguesButton":	appModel.navigator.pushScreen( Game.LEAGUES_SCREEN );					return;
		case "questsButton":	appModel.navigator.pushScreen( Game.QUESTS_SCREEN );					return;
		case "rankButton": 		appModel.navigator.addPopup( new RankingPopup() );						return;
		case "starsButton":		exchangeManager.process(exchanger.items.get(ExchangeType.C104_STARS));	return;
		case "adsButton":		exchangeManager.process(exchanger.items.get(ExchangeType.C43_ADS)); 	return;
		case "googleButton":	socialSignin();														 	return;
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
}
}