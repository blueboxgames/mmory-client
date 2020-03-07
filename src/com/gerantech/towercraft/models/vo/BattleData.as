package com.gerantech.towercraft.models.vo
{
import com.gerantech.mmory.core.Game;
import com.gerantech.mmory.core.InitData;
import com.gerantech.mmory.core.battle.BattleField;
import com.gerantech.mmory.core.battle.fieldes.FieldData;
import com.gerantech.mmory.core.constants.MessageTypes;
import com.gerantech.mmory.core.constants.ResourceType;
import com.gerantech.mmory.core.exchanges.ExchangeItem;
import com.gerantech.mmory.core.scripts.ScriptEngine;
import com.gerantech.mmory.core.socials.Challenge;
import com.gerantech.mmory.core.utils.maps.IntCardMap;
import com.gerantech.mmory.core.utils.maps.IntIntCardMap;
import com.gerantech.mmory.core.utils.maps.IntIntMap;
import com.gerantech.towercraft.managers.TimeManager;
import com.gerantech.towercraft.models.AppModel;
import com.smartfoxserver.v2.entities.data.ISFSObject;

import starling.events.Event;

public class BattleData
{
public var roomId:int = -1;
public var singleMode:Boolean;
public var battleField:BattleField;
public var isLeft:Boolean;
public var allise:ISFSObject;
public var axis:ISFSObject;
public var outcomes:Vector.<RewardData>;
public var stars:Vector.<int>;
public var sfsData:ISFSObject;
public var userType:int;
public var alliseGame:Game;
public var axisGame:Game;

public function BattleData(sfsData:ISFSObject)
{
	this.sfsData = sfsData;
	this.roomId = sfsData.getInt("id");
	this.userType = sfsData.getInt("userType");
	this.singleMode = sfsData.getBool("singleMode");
	this.allise = sfsData.getSFSObject("p" + sfsData.getInt("side"));
	this.axis = sfsData.getSFSObject(sfsData.getInt("side") == 0 ? "p1" : "p0");
	this.alliseGame =	instantiateGame(allise);
	this.axisGame =		instantiateGame(axis);

	function instantiateGame(gameSFS:ISFSObject) : Game
	{
		var game:Game = new Game();
		var initData:InitData = new InitData();
		initData.id = gameSFS.getInt("id");
		if( initData.id == AppModel.instance.game.player.id )
		{
			var rk:Vector.<int> = AppModel.instance.game.player.resources.keys();
			var len:int = rk.length
			for( var i:int = 0; i < len; i++ )
				initData.resources.set(rk[i],	AppModel.instance.game.player.resources.get(rk[i]));
		}
		initData.resources.set(ResourceType.R1_XP,	 	gameSFS.getInt("xp"));
		initData.resources.set(ResourceType.R2_POINT,	gameSFS.getInt("point"));
		initData.cardsLevel = new IntIntMap(					gameSFS.getText("deck"));
		game.init(initData);
		
		var cards:Array = gameSFS.getText("deck").split(",");
		game.loginData.deck = new Array();
		i = 0;
		while ( i < cards.length )
		{
			game.loginData.deck.push(int(cards[i].split(":")[0]));
			i++;
		}
		return game;
	}
}

public function start(startAt:int, now:Number):void
{
	// reduce battle cost
	var game:Game = AppModel.instance.game;
	if( sfsData.getInt("friendlyMode") == 0 )
	{
		var cost:IntIntMap = new IntIntMap(ScriptEngine.get(ScriptEngine.T52_CHALLENGE_RUN_REQS, sfsData.getInt("index")));
		var exItem:ExchangeItem = Challenge.getExchangeItem(sfsData.getInt("mode"), cost, game.player.get_arena(0));
		var response:int = game.exchanger.exchange(exItem, sfsData.getInt("startAt"), 0);
		if( response != MessageTypes.RESPONSE_SUCCEED )
			trace("battle cost data from server server is invalid!");
	}

	var side:int = sfsData.getInt("side");
	var map:Object = AppModel.instance.assets.getObject("map-" + sfsData.getInt("mode"));
	var f:FieldData = new FieldData(sfsData.getInt("mode"), JSON.stringify(map), AppModel.instance.descriptor.versionCode);
	this.battleField = new BattleField();
	this.battleField.debugMode = sfsData.getBool("debugMode");
	this.battleField.create(side == 0 ? alliseGame : axisGame, side == 0 ? axisGame : alliseGame, f, side, sfsData.getInt("createAt"), false, sfsData.getInt("friendlyMode"));
	this.battleField.decks = new IntIntCardMap();
	this.battleField.decks.set(0, BattleField.getDeckCards(this.battleField.games[0], this.battleField.games[0].loginData.deck, this.battleField.friendlyMode));
	this.battleField.decks.set(1, BattleField.getDeckCards(this.battleField.games[1], this.battleField.games[1].loginData.deck, this.battleField.friendlyMode));
	this.battleField.start(startAt, now);
	TimeManager.instance.setMillis(now);
	TimeManager.instance.setNow(Math.ceil(now / 1000));
	TimeManager.instance.addEventListener(Event.UPDATE, timeManager_updateHandler);
}

protected function timeManager_updateHandler(e:Event):void
{
	this.battleField.update(e.data as int);
}
public function getAlliseDeck():IntCardMap 
{
	return battleField.decks.get(this.battleField.side);
}
public function getAxiseDeck():IntCardMap 
{
	return battleField.decks.get(this.battleField.side == 0 ? 1 : 0);
}
public function getAlliseEllixir():Number
{
	return battleField.elixirUpdater.bars[this.battleField.side];
}

public function getBattleStep() : int
{
	return Math.min(6, AppModel.instance.game.player.get_battleswins()) * 20;
}
}
}