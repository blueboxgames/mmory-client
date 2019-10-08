package com.gerantech.towercraft
{
import com.gerantech.towercraft.controls.StackNavigator;
import com.gerantech.towercraft.controls.screens.*;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.themes.MainTheme;

import feathers.controls.Drawers;
import feathers.controls.StackScreenNavigatorItem;
import feathers.core.IFeathersControl;
import feathers.motion.Cover;
import feathers.motion.Reveal;

import starling.events.Event;

public class Game extends Drawers
{
public static const DASHBOARD_SCREEN:String = "dashboardScreen";
public static const BATTLE_SCREEN:String = "battleScreen";
public static const OPERATIONS_SCREEN:String = "operationsScreen";
public static const LEAGUES_SCREEN:String = "leaguesScreen";
public static const ADMIN_SCREEN:String = "adminScreen";
public static const SPECTATE_SCREEN:String = "spectateScreen";
public static const INBOX_SCREEN:String = "inboxScreen";
public static const ISSUES_SCREEN:String = "issuesScreen";
public static const BANNEDS_SCREEN:String = "bannedsScreen";
public static const OFFENDS_SCREEN:String = "offendsScreen";
public static const PLAYERS_SCREEN:String = "playersScreen";
static public const CHALLENGES_SCREEN:String = "challengesScreen";
static public const QUESTS_SCREEN:String = "questsScreen";
static public const SEARCH_CHAT_SCREEN:String = "searchChatScreen";

public function Game(content:IFeathersControl=null)
{
	super(content);
	AppModel.instance.theme = new MainTheme();
}

override protected function initialize():void
{
	super.initialize();
	
	AppModel.instance.navigator =  new StackNavigator();
	this.content = AppModel.instance.navigator;
	stage.color = 0x3e92fb;

	addScreen(CHALLENGES_SCREEN,ChallengesScreen, false, false);
	addScreen(DASHBOARD_SCREEN,	DashboardScreen, false, false);
	addScreen(LEAGUES_SCREEN,	LeaguesScreen, false, false);
	addScreen(BATTLE_SCREEN, 	BattleScreen, false, false);
	addScreen(QUESTS_SCREEN,	QuestsScreen, false, false);
	addScreen(INBOX_SCREEN, 	InboxScreen);
	addScreen(ADMIN_SCREEN, 	AdminScreen);
	addScreen(ISSUES_SCREEN, 	IssuesScreen);
	addScreen(BANNEDS_SCREEN,	BanndsScreen);
	addScreen(OFFENDS_SCREEN,	OffendsScreen);
	addScreen(PLAYERS_SCREEN, 	SearchPlayersScreen);
	addScreen(SPECTATE_SCREEN, 	SpectateScreen);
	addScreen(SEARCH_CHAT_SCREEN,SearchChatScreen);
	AppModel.instance.navigator.rootScreenID = DASHBOARD_SCREEN;
}		
private function addScreen(screenType:String, screenClass:Object, hasPushTranstion:Boolean = true, hasPopTranstion:Boolean = true):void
{
	var item:StackScreenNavigatorItem = new StackScreenNavigatorItem(screenClass);
	if( hasPushTranstion )
		item.pushTransition = Cover.createCoverLeftTransition();
	if( hasPopTranstion )
		item.popTransition = Reveal.createRevealRightTransition();
	item.addPopEvent(Event.COMPLETE);
	AppModel.instance.navigator.addScreen(screenType, item);			
}
}
}