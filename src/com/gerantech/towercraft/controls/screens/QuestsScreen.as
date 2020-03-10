package com.gerantech.towercraft.controls.screens
{
import com.gerantech.mmory.core.constants.MessageTypes;
import com.gerantech.mmory.core.constants.PrefsTypes;
import com.gerantech.mmory.core.constants.ResourceType;
import com.gerantech.mmory.core.constants.SFSCommands;
import com.gerantech.mmory.core.exchanges.ExchangeItem;
import com.gerantech.mmory.core.others.Quest;
import com.gerantech.towercraft.Game;
import com.gerantech.towercraft.controls.buttons.Indicator;
import com.gerantech.towercraft.controls.buttons.IndicatorXP;
import com.gerantech.towercraft.controls.items.QuestItemRenderer;
import com.gerantech.towercraft.controls.segments.SocialSegment;
import com.gerantech.towercraft.managers.net.CoreLoader;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.vo.UserData;
import com.gerantech.towercraft.themes.MainTheme;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.data.SFSObject;

import feathers.controls.ImageLoader;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.layout.AnchorLayoutData;

import flash.geom.Rectangle;
import flash.net.URLRequest;
import flash.net.navigateToURL;

import starling.events.Event;

public class QuestsScreen extends ListScreen
{
public var readyToClose:Boolean = true;
public var questsCollection:ListCollection;
override protected function initialize():void
{
	title = loc("button_quests");
	virtualHeader = false;
	headerSize = 220;
	super.initialize();

	var gradient:ImageLoader = new ImageLoader();
	gradient.touchable = false;
	gradient.scale9Grid = MainTheme.SHADOW_SIDE_SCALE9_GRID;
	gradient.color = 0x001133;
	gradient.layoutData = new AnchorLayoutData(0, 0, NaN, 0);
	gradient.height = 440;
	gradient.source = appModel.assets.getTexture("theme/gradeint-top");
	addChildAt(gradient, numChildren - 2);

	var indicatorHC:Indicator = new Indicator("rtl", ResourceType.R4_CURRENCY_HARD);
	indicatorHC.layoutData = new AnchorLayoutData(20, 70);
	addChild(indicatorHC);
	
	var indicatorSC:Indicator = new Indicator("rtl", ResourceType.R3_CURRENCY_SOFT);
	indicatorSC.layoutData = new AnchorLayoutData(20, 390);
	addChild(indicatorSC);
	
	var indicatorXP:IndicatorXP = new IndicatorXP("ltr");
	indicatorXP.layoutData = new AnchorLayoutData(20, NaN, NaN, 70);
	addChild(indicatorXP);
	
	showQuests(true);
}

private function showQuests(needsLoad:Boolean):void 
{
	if( player.quests.length == 0 )
	{
		if( needsLoad )
			loadQuests();
		return;
	}

	questsCollection = new ListCollection();
	for each( var q:Quest in player.quests )
	{
		q.current = Quest.getCurrent(player, q.type, q.key);
		questsCollection.addItem(q);
	}
	
	listLayout.gap = 40;
	listLayout.padding = 50
	listLayout.paddingBottom = footerSize + 40;
	listLayout.paddingTop = headerSize + 40;
	listLayout.hasVariableItemDimensions = true;
	
	list.itemRendererFactory = function():IListItemRenderer { return new QuestItemRenderer(); }
	list.addEventListener(Event.SELECT, list_selectHandler);
	list.addEventListener(Event.UPDATE, list_updateHandler);
	list.dataProvider = questsCollection;
}

private function loadQuests():void 
{
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_questInitHandler);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.QUEST_INIT);
}

protected function sfs_questInitHandler(e:SFSEvent):void 
{
	if( e.params.cmd != SFSCommands.QUEST_INIT )
		return;
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_questInitHandler);
	CoreLoader.loadQuests(e.params.params);
	showQuests(false);
}

protected function list_selectHandler(e:Event):void 
{
	var questItem:QuestItemRenderer = e.data as QuestItemRenderer;
	if( questItem.quest.passed() )
	{
		passQuest(questItem);
		return;
	}

	// increase step
	if( !Quest.progressive(questItem.quest.type) && questItem.quest.current == -1 )
		UserData.instance.prefs.setInt(questItem.quest.key, player.prefs.getAsInt(questItem.quest.key) + 2);

	var nextScreen:String;	
	switch( questItem.quest.type )
	{
		//case Quest.TYPE_2_OPERATIONS :			appModel.navigator.pushScreen(Main.OPERATIONS_SCREEN);	return;
		
		// case Quest.TYPE_3_BATTLES :				
		// case Quest.TYPE_4_BATTLE_WINS :			appModel.navigator.runBattle();	return;
		// case Quest.TYPE_0_LEVELUP :
		case Quest.TYPE_1_LEAGUEUP :	nextScreen = Game.LEAGUES_SCREEN;	break;
		// case Quest.TYPE_9_BOOK_OPEN :			DashboardScreen.TAB_INDEX = 2;	break;
		case Quest.TYPE_5_FRIENDLY_BATTLES :	DashboardScreen.TAB_INDEX = 3;	break;
		// case Quest.TYPE_6_CHALLENGES :			DashboardScreen.TAB_INDEX = 4;	break;
		// case Quest.TYPE_7_CARD_COLLECT :
		case Quest.TYPE_8_CARD_UPGRADE :		DashboardScreen.TAB_INDEX = 1;	break;
		case Quest.TYPE_10_RATING :		appModel.navigator.confirmOffer(PrefsTypes.OFFER_30_RATING);	break;
		case Quest.TYPE_11_TELEGRAM:	navigateToURL(new URLRequest(loc("setting_value_311", null, false)));			break;
		case Quest.TYPE_12_INSTAGRAM: navigateToURL(new URLRequest(loc("setting_value_312", null, false)));			break;
		case Quest.TYPE_13_FRIENDSHIP:DashboardScreen.TAB_INDEX = 3;	SocialSegment.TAB_INDEX = 2;	break;
	}

	appModel.navigator.popScreen();
	if( nextScreen != null )
		appModel.navigator.pushScreen(nextScreen);
}

private function passQuest(questItem:QuestItemRenderer):void 
{
	var ex:ExchangeItem = Quest.getExchangeItem(questItem.quest.type, questItem.quest.nextStep);
	var response:int = exchanger.exchange(ex, 0, 0);
	if( response != MessageTypes.RESPONSE_SUCCEED )
	{
		trace("quests response:", response);
		return;
	}
	
	readyToClose = false;
	questItem.hide();
	
	var rect:Rectangle = questItem.getBounds(stage);
	rect.x += 150;
	rect.y += QuestItemRenderer.HEIGHT * 0.2;
	appModel.navigator.addMapAnimation(rect.x, rect.y, questItem.quest.rewards);
	appModel.sounds.addAndPlay("upgrade");
}

private function list_updateHandler(e:Event):void 
{
	var questItem:QuestItemRenderer = e.data as QuestItemRenderer;
	questsCollection.removeItemAt(questItem.index);
	player.quests.removeAt(questItem.index);
	var sfs:SFSObject = new SFSObject();
	sfs.putInt("id", questItem.quest.id);
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_rewardCollectHandler);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.QUEST_REWARD_COLLECT, sfs);
}

private function sfs_rewardCollectHandler(e:SFSEvent):void 
{
	if( e.params.cmd != SFSCommands.QUEST_REWARD_COLLECT )
		return;
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_rewardCollectHandler);
	if( e.params.params.getInt("response") != MessageTypes.RESPONSE_SUCCEED )
		return;
	
	var q:SFSObject = e.params.params.getSFSObject("quest");
	var quest:Quest = new Quest(q.getInt("id"), q.getInt("type"), q.getInt("key"), q.getInt("nextStep"), q.getInt("current"), q.getInt("target"), SFSConnection.ToMap(q.getSFSArray("rewards")));
	player.quests.push(quest);
	if( list.dataProvider != null )
		questsCollection.addItem(quest);
	readyToClose = true;
}

override protected function backButtonFunction():void
{
	if( readyToClose )
		super.backButtonFunction();
}
}
}