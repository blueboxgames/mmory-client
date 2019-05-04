package com.gerantech.towercraft.models.vo
{
import com.gerantech.towercraft.managers.TimeManager;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.AppModel;
import com.gt.towers.Game;
import com.gt.towers.InitData;
import com.gt.towers.battle.BattleField;
import com.gt.towers.battle.fieldes.FieldData;
import com.gt.towers.constants.MessageTypes;
import com.gt.towers.constants.ResourceType;
import com.gt.towers.exchanges.ExchangeItem;
import com.gt.towers.socials.Challenge;
import com.gt.towers.utils.maps.IntCardMap;
import com.gt.towers.utils.maps.IntIntCardMap;
import com.gt.towers.utils.maps.IntIntMap;
import com.smartfoxserver.v2.entities.Room;
import com.smartfoxserver.v2.entities.data.ISFSObject;

public class BattleData
{
public var room:Room;
public var singleMode:Boolean;
public var battleField:BattleField;
public var isLeft:Boolean;
public var allise:ISFSObject;
public var axis:ISFSObject;
public var outcomes:Vector.<RewardData>;
public var stars:Vector.<int>;
public var sfsData:ISFSObject;

public function BattleData(data:ISFSObject)
{
	this.sfsData = data;
	this.room = SFSConnection.instance.getRoomById(data.getInt("roomId"));
	this.singleMode = data.getBool("singleMode");
	this.allise = data.getSFSObject("p" + data.getInt("side"));
	this.axis = data.getSFSObject(data.getInt("side") == 0 ? "p1" : "p0");
	
	var alliseGame:Game =	instantiateGame(allise);
	var axisGame:Game =		instantiateGame(axis);
	function instantiateGame(gameSFS:ISFSObject) : Game
	{
		var game:Game = new Game();
		var initData:InitData = new InitData();
		initData.resources.set(ResourceType.R1_XP,	 	gameSFS.getInt("xp"));
		initData.resources.set(ResourceType.R2_POINT,	gameSFS.getInt("point"));
		initData.cardsLevel = new IntIntMap(			gameSFS.getText("deck"));
		game.init(initData);
		
		var cards:Array = gameSFS.getText("deck").split(",");
		game.loginData.deck = new Array();
		var deck:Array = new Array();
		var i:int = 0;
		while ( i < cards.length )
		{
			game.loginData.deck.push(int(cards[i].split(":")[0]));
			i++;
		}
		return game;
	}

	// reduce battle cost
	var game:Game = AppModel.instance.game;
	var cost:IntIntMap = Challenge.getRunRequiements(data.getInt("mode"));
	var exItem:ExchangeItem = Challenge.getExchangeItem(data.getInt("mode"), cost, game.player.get_arena(0));
	var response:int = game.exchanger.exchange(exItem, data.getInt("startAt"), 0);
	if( response != MessageTypes.RESPONSE_SUCCEED )
		trace("battle cost data from server server is invalid!");
	
	var f:FieldData = new FieldData(data.getInt("mode"), data.getText("map"), "60,120,180,240");
	this.battleField = new BattleField();
	this.battleField.initialize(this.battleField.side == 0 ? alliseGame : axisGame, this.battleField.side == 0 ? axisGame : alliseGame, f, data.getInt("side"), data.getInt("startAt"), data.getDouble("now"), false, data.getInt("friendlyMode"));
	this.battleField.state = BattleField.STATE_1_CREATED;
	this.battleField.decks = new IntIntCardMap();
	this.battleField.decks.set(0, BattleField.getDeckCards(this.battleField.games[0], this.battleField.games[0].loginData.deck, this.battleField.friendlyMode));
	this.battleField.decks.set(1, BattleField.getDeckCards(this.battleField.games[1], this.battleField.games[1].loginData.deck, this.battleField.friendlyMode));
	TimeManager.instance.setNow(Math.ceil(data.getDouble("now") / 1000));
}

public function getAlliseDeck():IntCardMap 
{
	return battleField.decks.get(battleField.side);
}
public function getAlliseEllixir():Number
{
	return battleField.elixirBar.get(battleField.side);
}

public function getBattleStep() : int
{
	return Math.min(6, AppModel.instance.game.player.get_battleswins()) * 20;
}
}
}