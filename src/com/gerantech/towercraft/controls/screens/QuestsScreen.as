package com.gerantech.towercraft.controls.screens
{
import com.gerantech.towercraft.controls.buttons.Indicator;
import com.gerantech.towercraft.controls.buttons.IndicatorXP;
import com.gerantech.towercraft.controls.items.QuestItemRenderer;
import com.gerantech.towercraft.managers.net.CoreLoader;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gt.towers.constants.MessageTypes;
import com.gt.towers.constants.ResourceType;
import com.gt.towers.others.Quest;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSObject;

import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.layout.AnchorLayoutData;

import flash.geom.Rectangle;

import starling.events.Event;

public class QuestsScreen extends ListScreen
{
override protected function initialize():void
{
	title = loc("button_quests");
	virtualHeader = false;
	headerSize = 200;
	super.initialize();
	
	var indicatorHC:Indicator = new Indicator("rtl", ResourceType.R4_CURRENCY_HARD);
	indicatorHC.layoutData = new AnchorLayoutData(22, 40);
	addChild(indicatorHC);
	
	var indicatorSC:Indicator = new Indicator("rtl", ResourceType.R3_CURRENCY_SOFT);
	indicatorSC.layoutData = new AnchorLayoutData(22, 360);
	addChild(indicatorSC);
	
	var indicatorXP:IndicatorXP = new IndicatorXP("ltr");
	indicatorXP.layoutData = new AnchorLayoutData(22, NaN, NaN, 40);
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

	for each( var q:Quest in player.quests )
		q.current = Quest.getCurrent(player, q.type, q.key);
	
	listLayout.gap = 40;
	listLayout.padding = 50
	listLayout.paddingBottom = footerSize;
	listLayout.paddingTop = headerSize + 40;
	listLayout.hasVariableItemDimensions = true;
	
	list.itemRendererFactory = function():IListItemRenderer { return new QuestItemRenderer(); }
	list.addEventListener(Event.SELECT, list_selectHandler);
	list.addEventListener(Event.UPDATE, list_updateHandler);
	list.dataProvider = new ListCollection(player.quests);
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
	
	/*switch( questItem.quest.type )
	{
		//case Quest.TYPE_2_OPERATIONS :			appModel.navigator.pushScreen(Main.OPERATIONS_SCREEN);	return;
		
		case Quest.TYPE_3_BATTLES :				
		case Quest.TYPE_4_BATTLE_WINS :			appModel.navigator.runBattle();	return;
		case Quest.TYPE_0_LEVELUP :
		case Quest.TYPE_1_LEAGUEUP :
		case Quest.TYPE_9_BOOK_OPEN :			DashboardScreen.TAB_INDEX = 2;	break;
		case Quest.TYPE_5_FRIENDLY_BATTLES :	DashboardScreen.TAB_INDEX = 3;	break;
		case Quest.TYPE_6_CHALLENGES :			DashboardScreen.TAB_INDEX = 4;	break;
		case Quest.TYPE_7_CARD_COLLECT :
		case Quest.TYPE_8_CARD_UPGRADE :		DashboardScreen.TAB_INDEX = 1;	BuildingsSegment.SELECTED_CARD = questItem.quest.key;	break;
	}
	appModel.navigator.popScreen();*/
}

private function passQuest(questItem:QuestItemRenderer):void 
{
	var response:int = exchanger.exchange(Quest.getExchangeItem(questItem.quest.type, questItem.quest.nextStep), 0, 0);
	if( response != MessageTypes.RESPONSE_SUCCEED )
	{
		trace("quests response:", response);
		return;
	}
	
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
	list.dataProvider.removeItemAt(questItem.index);
	player.quests.removeAt(questItem.index);
	var sfs:ISFSObject = new SFSObject();
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
	
	var q:ISFSObject = e.params.params.getSFSObject("quest");
	var quest:Quest = new Quest(q.getInt("id"), q.getInt("type"), q.getInt("key"), q.getInt("nextStep"), q.getInt("current"), q.getInt("target"), SFSConnection.ToMap(q.getSFSArray("rewards")));
	//list.dataProvider.addItem(quest);
	player.quests.push(quest);
	if( list.dataProvider != null )
		list.dataProvider.updateAll();
}
}
}