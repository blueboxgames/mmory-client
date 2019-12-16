/**
 * Created by ManJav on 4/27/2017.
 */
package com.gerantech.towercraft.managers.net
{
import com.gerantech.mmory.core.Game;
import com.gerantech.mmory.core.InitData;
import com.gerantech.mmory.core.constants.ResourceType;
import com.gerantech.mmory.core.exchanges.ExchangeItem;
import com.gerantech.mmory.core.others.Arena;
import com.gerantech.mmory.core.others.Quest;
import com.gerantech.mmory.core.scripts.ScriptEngine;
import com.gerantech.mmory.core.socials.Attendee;
import com.gerantech.mmory.core.socials.Challenge;
import com.gerantech.mmory.core.utils.maps.IntArenaMap;
import com.gerantech.mmory.core.utils.maps.IntChallengeMap;
import com.gerantech.mmory.core.utils.maps.IntIntMap;
import com.gerantech.mmory.core.utils.maps.IntShopMap;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.AppModel;
import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSObject;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.filesystem.File;

public class CoreLoader extends EventDispatcher
{
private var version:String;
private var serverData:SFSObject;
private var initData:InitData;

public function CoreLoader(serverData:SFSObject)
{
	this.serverData = serverData;
	this.version = this.serverData.getText("coreVersion");
// 	AppModel.instance.assets.enqueue(File.applicationStorageDirectory.resolvePath("assets/script-data.cs").nativePath)
// 	AppModel.instance.assets.loadQueue(this.script_loadCoallcack)
// }

// private function script_loadCoallcack():void
// {
	ScriptEngine.initialize(AppModel.instance.assets.getByteArray("script-data").toString(), this.serverData.getInt("forceVersion"));

	initServerData(serverData);
	
	AppModel.instance.game = new Game();
	AppModel.instance.game.init(initData);
	AppModel.instance.game.sessionsCount = serverData.getInt("sessionsCount");
	AppModel.instance.game.player.hasOperations = !serverData.containsKey("hasOperations") || serverData.getBool("hasOperations");
	AppModel.instance.game.player.tutorialMode = serverData.getInt("tutorialMode");
	AppModel.instance.game.player.invitationCode = serverData.getText("invitationCode");
	AppModel.instance.maxTutorBattles = ScriptEngine.getInt(ScriptEngine.T61_BATTLE_NUM_TUTORS, AppModel.instance.game.player.id);

	loadExchanges(serverData);
	loadChallenges(serverData, initData.id);
	loadQuests(serverData);
	dispatchEvent(new Event(Event.COMPLETE));
}

private function initServerData(sfsObj:SFSObject):void
{
	// create init data 
	initData = new InitData();
	initData.nickName = serverData.getText("name");
	initData.id = serverData.getInt("id");
	initData.appVersion = AppModel.instance.descriptor.versionCode;
	initData.market = AppModel.instance.descriptor.market;
	
	var elements:ISFSArray = sfsObj.getSFSArray("resources");
	var element:ISFSObject;
	for( var i:int=0; i<elements.size(); i++ )
	{
		element = elements.getSFSObject(i);
		initData.resources.set(element.getInt("type"), element.getInt("count"));
		if( ResourceType.isCard(element.getInt("type")) )
			initData.cardsLevel.set(element.getInt("type"), element.getInt("level"));
	}
	
	elements = sfsObj.getSFSArray("operations");
	for( i=0; i<elements.size(); i++ )
	{
		element = elements.getSFSObject(i);
		initData.operations.set(element.getInt("index"), element.getInt("score"));
	}
	
	elements = sfsObj.getSFSArray("prefs");
	for( i=0; i<elements.size(); i++ )
	{
		element = elements.getSFSObject(i);
		initData.prefs.set(int(element.getText("k")), element.getText("v"));
	}
	
    elements = sfsObj.getSFSArray("decks");
    for( i=0; i<elements.size(); i++ )
    {
        element = elements.getSFSObject(i);
        if( !initData.decks.exists(element.getInt("deck_index")) )
					initData.decks.set(element.getInt("deck_index"), new IntIntMap());
        
        initData.decks.get(element.getInt("deck_index")).set(element.getInt("index"), element.getInt("type"));
    }
}

static private function loadExchanges(serverData:SFSObject) : void 
{
	var exchange:ISFSObject;
	var item:ExchangeItem;
	var elements:ISFSArray;
	var element:ISFSObject;
	AppModel.instance.game.exchanger.items = new IntShopMap();
	for( var i:int = 0; i < serverData.getSFSArray("exchanges").size(); i++ )
	{
		exchange = serverData.getSFSArray("exchanges").getSFSObject(i);
		item = new ExchangeItem(exchange.getInt("type"), exchange.getInt("numExchanges"), exchange.getInt("expiredAt"));
		item.outcomes = SFSConnection.ToMap(exchange.getSFSArray("outcomes"));
		item.requirements = SFSConnection.ToMap(exchange.getSFSArray("requirements"));
		if( item.outcomes.keys().length > 0 )
			item.outcome = item.outcomes.keys()[0];
		
		AppModel.instance.game.exchanger.items.set(item.type, item);
	}
}

static public function loadChallenges(params:ISFSObject, playerId:int) : void 
{
	var challenges:IntChallengeMap = new IntChallengeMap();
	challenges.set(0, new Challenge(AppModel.instance.game, 0, ScriptEngine.getInt(ScriptEngine.T42_CHALLENGE_TYPE, 0, playerId), ScriptEngine.getInt(ScriptEngine.T41_CHALLENGE_MODE, 0, playerId)));
	challenges.set(1, new Challenge(AppModel.instance.game, 1, ScriptEngine.getInt(ScriptEngine.T42_CHALLENGE_TYPE, 1, playerId), ScriptEngine.getInt(ScriptEngine.T41_CHALLENGE_MODE, 1, playerId)));
	challenges.set(2, new Challenge(AppModel.instance.game, 2, ScriptEngine.getInt(ScriptEngine.T42_CHALLENGE_TYPE, 2, playerId), ScriptEngine.getInt(ScriptEngine.T41_CHALLENGE_MODE, 2, playerId)));
	challenges.set(3, new Challenge(AppModel.instance.game, 3, Challenge.TYPE_2_RANKING, 3));
	if( params.containsKey("challenges") )
	for( var i:int = 0; i < params.getSFSArray("challenges").size(); i++ )
	{
		var c:ISFSObject = params.getSFSArray("challenges").getSFSObject(i);
		var ch:Challenge = new Challenge(AppModel.instance.game, 2 + i, c.getInt("type"), c.getInt("mode"));
		ch.id = c.getInt("id");
		ch.startAt = c.getInt("start_at");
		ch.unlockAt = c.getInt("unlock_at");
		ch.duration = c.getInt("duration");
		ch.capacity = c.getInt("capacity");
		
		var item:ISFSObject = null;
		ch.joinRequirements = SFSConnection.ToMap(c.getSFSArray("joinRequirements"));
		ch.runRequirements = SFSConnection.ToMap(c.getSFSArray("runRequirements"));
		ch.rewards = new IntArenaMap();
		for (var j:int = 0; j < c.getSFSArray("rewards").size(); j++)
		{
			item = c.getSFSArray("rewards").getSFSObject(j);
			ch.rewards.set(item.getInt("key"), new Arena(null, item.getInt("key"), item.getInt("min"), item.getInt("max"), item.getInt("prize")));
		}
		
		ch.attendees = new Array();
		if( c.containsKey("attendees") )
		{
			for (j = 0; j < c.getSFSArray("attendees").size(); j++)
			{
				item = c.getSFSArray("attendees").getSFSObject(j);
				ch.attendees.push(new Attendee(item.getInt("id"), item.getText("name"), item.getInt("point"), item.getInt("updateAt")));
			}
		}
		challenges.set(ch.index, ch);
	}
	AppModel.instance.game.player.challenges = challenges;
}

static public function loadQuests(params:ISFSObject) : void 
{
	AppModel.instance.game.player.quests = new Array();
	if( !params.containsKey("quests") )
		return;
	for ( var i:int = 0; i < params.getSFSArray("quests").size(); i++ )
	{
		var q:ISFSObject = params.getSFSArray("quests").getSFSObject(i);
		AppModel.instance.game.player.quests.push(new Quest(q.getInt("id"), q.getInt("type"), q.getInt("key"), q.getInt("nextStep"), q.getInt("current"), q.getInt("target"), SFSConnection.ToMap(q.getSFSArray("rewards"))));
	}
}
}
}