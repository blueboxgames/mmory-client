package com.gerantech.towercraft.views
{
import com.gerantech.mmory.core.battle.BattleField;
import com.gerantech.mmory.core.battle.GameObject;
import com.gerantech.mmory.core.battle.bullets.Bullet;
import com.gerantech.mmory.core.battle.units.Card;
import com.gerantech.mmory.core.battle.units.Unit;
import com.gerantech.mmory.core.constants.CardTypes;
import com.gerantech.mmory.core.constants.PrefsTypes;
import com.gerantech.mmory.core.scripts.ScriptEngine;
import com.gerantech.mmory.core.utils.GraphicMetrics;
import com.gerantech.mmory.core.utils.Point2;
import com.gerantech.mmory.core.utils.Point3;
import com.gerantech.towercraft.controls.headers.BattleFooter;
import com.gerantech.towercraft.managers.DropTargets;
import com.gerantech.towercraft.managers.SoundManager;
import com.gerantech.towercraft.managers.TimeManager;
import com.gerantech.towercraft.managers.net.ResponseSender;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.models.vo.BattleData;
import com.gerantech.towercraft.utils.SyncUtil;
import com.gerantech.towercraft.views.units.UnitView;
import com.gerantech.towercraft.views.units.elements.IElement;
import com.gerantech.towercraft.views.units.elements.ImageElement;
import com.gerantech.towercraft.views.weapons.BulletView;
import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSObject;

import flash.utils.setTimeout;

import starling.assets.AssetManager;
import starling.core.Starling;
import starling.display.DisplayObjectContainer;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.EnterFrameEvent;
import starling.events.Event;
import starling.textures.Texture;
public class BattleFieldView extends Sprite
{
private const DEBUG:Boolean = false;
public var mapBuilder:MapBuilder;
public var battleData:BattleData;
public var responseSender:ResponseSender;
public var dropTargets:DropTargets;
public var shadowsContainer:DisplayObjectContainer;
public var unitsContainer:DisplayObjectContainer;
public var guiImagesContainer:DisplayObjectContainer;
public var guiTextsContainer:DisplayObjectContainer;
public var effectsContainer:DisplayObjectContainer;
public var center:Point2;
private var units:Array;

public function BattleFieldView() { super(); }
public function initialize () : void 
{
	units = new Array();
	touchGroup = true;
	alignPivot();

	shadowsContainer = new Sprite();
	unitsContainer = new Sprite();
	effectsContainer = new Sprite();
	guiImagesContainer = new Sprite();
	guiTextsContainer = new Sprite();
	
	if( AppModel.instance.artRules == null )
		AppModel.instance.artRules = new ArtRules(AppModel.instance.assets.getObject("arts-rules"));

	var preAssets:Object = new Object();
	for ( var key:String in SyncUtil.ALL )
		if( SyncUtil.ALL[key]["mode"] == "prev" )
			preAssets[key] = SyncUtil.ALL[key];

	var mode:int = ScriptEngine.get(ScriptEngine.T41_CHALLENGE_MODE, AppModel.instance.game.player.prefs.get(PrefsTypes.CHALLENGE_INDEX), AppModel.instance.game.player.id);
	var deckKeys:Vector.<int> = AppModel.instance.game.player.decks.get(0).keys();
	var deck:Vector.<String> = new Vector.<String>;
	for(var k:int = 0; k < deckKeys.length; k++ )
		deck.push(AppModel.instance.game.player.decks.get(0).get(deckKeys[k]).toString());
	deck.push(ScriptEngine.get(ScriptEngine.T54_CHALLENGE_INITIAL_UNITS, mode, false) + "");
	deck.push(ScriptEngine.get(ScriptEngine.T54_CHALLENGE_INITIAL_UNITS, mode, true) + "");
	fillDeck(deck, preAssets);

	key = "map-" + mode;
	preAssets[key +".json"] = SyncUtil.ALL[key + ".json"];
	preAssets[key + ".atf"] = SyncUtil.ALL[key + ".atf"];
	preAssets[key + ".xml"] = SyncUtil.ALL[key + ".xml"];

	var syncTool:SyncUtil = new SyncUtil();
	syncTool.addEventListener(Event.COMPLETE, syncToolPre_completeHandler);
	syncTool.sync(preAssets);
}

protected function syncToolPre_completeHandler(event:Event):void 
{
	mapBuilder = new MapBuilder();
	dispatchEventWith(Event.COMPLETE);
}

public function createPlaces(battleData:BattleData) : void
{
	this.battleData = battleData	;
	if( mapBuilder == null )
		return;
	var deckKeys:Vector.<int> = battleData.getAxiseDeck().keys();
	var deck:Vector.<String> = new Vector.<String>;
	for(var k:int = 0; k < deckKeys.length; k++ )
		deck.push(battleData.getAxiseDeck().get(deckKeys[k]).type.toString());
	var postAssets:Object = new Object();
	fillDeck(deck, postAssets);

	var syncTool:SyncUtil = new SyncUtil();
	syncTool.addEventListener(Event.COMPLETE, syncToolPost_completeHandler);
	syncTool.sync(postAssets);
}

private function fillDeck(deck:Vector.<String>, assets:Object):void
{
	var type:String;
	for( var i:int=0; i<deck.length; i++ )
	{		
		type = AppModel.instance.artRules.get(int(deck[i]), ArtRules.TEXTURE);
		for( var key:String in SyncUtil.ALL )
		{
			if( SyncUtil.ALL[key].hasOwnProperty("mode") )
				continue;
			if( key.search(type) > -1 )
				assets[key] = SyncUtil.ALL[key];
		}
	}
}

protected function syncToolPost_completeHandler(event:Event):void
{
	pivotX = BattleField.WIDTH * 0.5;
	pivotY = BattleField.HEIGHT * 0.5;
	center = new Point2(Starling.current.stage.stageWidth * 0.5, (Starling.current.stage.stageHeight - BattleFooter.HEIGHT * 0.5 - 100) * 0.5);
	x = center.x;
	y = center.y - 50;

	mapBuilder.init(battleData.battleField.field.json);
	addChild(mapBuilder);

	battleData.battleField.state = BattleField.STATE_2_STARTED;

	responseSender = new ResponseSender(battleData);
	TimeManager.instance.addEventListener(Event.UPDATE, timeManager_updateHandler);
	
	addChild(shadowsContainer);
	addChild(unitsContainer);

	summonUnits(battleData.sfsData.getSFSArray("units"), battleData.sfsData.getDouble("now"));
	scale = 0.85;

	/*for ( i = 0; i < battleData.battleField.tileMap.width; i ++ )
		for ( var j:int = 0; j < battleData.battleField.tileMap.height; j ++ )
			drawTile(i, j, battleData.battleField.tileMap.map[i][j], battleData.battleField.tileMap.tileWidth, battleData.battleField.tileMap.tileHeight);*/
	
	addChild(effectsContainer);
	addChild(guiImagesContainer);
	addChild(guiTextsContainer);
	dispatchEventWith(Event.TRIGGERED);
}

protected function timeManager_updateHandler(e:Event):void
{
	unitsContainer.sortChildren(unitSortMethod);
}

private function unitSortMethod(left:IElement, right:IElement) : Number
{
	if( left.unit == null || right.unit == null )
		return 0;
	return left.unit.y - right.unit.y;
}

public function summonUnits(units:ISFSArray, time:Number):void
{
	for( var i:int = 0; i < units.size(); i++ )
	{
		var u:ISFSObject = units.getSFSObject(i);
		this.summonUnit(u.getInt("i"), u.getInt("t"), u.getInt("l"), u.getInt("s"), u.getDouble("x"), u.getDouble("y"), u.containsKey("h") ? u.getDouble("h") : -1, time);
	}
}

private function summonUnit(id:int, type:int, level:int, side:int, x:Number, y:Number, health:Number, t:Number) : void
{
	var card:Card = getCard(side, type, level);
	if( CardTypes.isSpell(type) )
	{
		var offset:Point3 = GraphicMetrics.getSpellStartPoint(card.type);
		var spell:BulletView = new BulletView(battleData.battleField, id, card, side, x + offset.x, y + offset.y * (side == 0 ? 0.7 : -0.7), offset.z * 0.7, x, y, 0);
		battleData.battleField.bullets.push(spell as Bullet);
		return;
	}

	var u:UnitView = new UnitView(card, id, side, x, y, card.z, t);
	if( health >= 0 )
		u.setHealth(health);
	battleData.battleField.units.push(u as Unit);

	AppModel.instance.sounds.addAndPlayRandom(AppModel.instance.artRules.getArray(type, ArtRules.SUMMON_SFX), SoundManager.CATE_SFX, SoundManager.SINGLE_BYPASS_THIS);
}

private function getCard(side:int, type:int, level:int) : Card
{
	var ret:Card = battleData.battleField.decks.get(side).get(type);
	if( ret == null )
	{
		trace("create new card while battling ==> side:", side, "type:", type, "level:", level);
		ret = new Card(battleData.battleField.games[side], type, level);
	}
	return ret;
}

public function requestKillPioneers(side:int):void 
{
	var color:int = side == battleData.battleField.side ? 1 : 0;
	function carPassing(fromX:int, toX:int, y:int, color:int) : void
	{
		AppModel.instance.sounds.addAndPlay("car-passing-by", null, 1, SoundManager.SINGLE_NONE);
		var txt:Texture = AppModel.instance.assets.getTexture("201/" + color + "/base");
		var a:AssetManager = AppModel.instance.assets;
		var car:ImageElement = new ImageElement(null, txt);
		car.pivotX = car.width * 0.5;
		car.pivotY = car.height * UnitView._PIVOT_Y + AppModel.instance.artRules.getInt(201, "y");
		car.width = UnitView._WIDTH;
		car.height = UnitView._HEIGHT;
		car.x = fromX;
		car.y = y + BattleField.HEIGHT * 0.5;
		unitsContainer.addChild(car);
		Starling.juggler.tween(car, 1, {x:toX, onComplete:car.removeFromParent, onCompleteArgs:[true]});
	}

 	battleData.battleField.requestKillPioneers(side);
	var time:int = battleData.battleField.resetTime - battleData.battleField.now - 500;
	setTimeout(carPassing, time, color == 0 ? -600 : 1100, color == 0 ? 1100 : -600, color == 1 ? -200 : 200, color);
	setTimeout(carPassing, time, color == 0 ? -400 : 1300, color == 0 ? 1300 : -400, color == 1 ? -480 : 420, color);
}

public function updateUnits(unitData:SFSObject) : void
{
	var serverUnitIds:Array = unitData.getIntArray("keys");
	kill(battleData.battleField.units);
	if( !unitData.containsKey("testData") )
		return;

	kill(units);
	var serverUnitTests:Array = unitData.getUtfStringArray("testData");
	for( var i:int = 0; i < serverUnitTests.length; i++ )
	{
		var vars:Array = serverUnitTests[i].split(",");// unit.id + "," + unit.x + "," + unit.y + "," + unit.health + "," + unit.card.type + "," + unit.side + "," + unit.card.level
		var u:UnitView = getUnit(vars[0]);
		if( u == null )
		{
			u = new UnitView(getCard(vars[5], vars[4], vars[6]), vars[0], vars[5], vars[1], vars[2], 0, 0, true);
			u.alpha = 0.3;
			units.push(u);
			continue;
		}
		u.setPosition(vars[1], vars[2], GameObject.NaN);
		u.setHealth(vars[3]);
	}

	function kill(units:Array):void
	{
		for(var i:int = 0; i < units.length; i++)
		if( serverUnitIds.indexOf(units[i].id) == -1 )
		{
			units[i].hit(100);
			units.removeAt(i);
		}
	}
}

private function getUnit(id:int):UnitView
{
	for(var i:int = 0; i < units.length; i++)
		if( units[i].id == id )
			return units[i] as UnitView;
	return null;
}

override public function dispose() : void
{
	TimeManager.instance.removeEventListener(Event.UPDATE, timeManager_updateHandler);
	if( battleData != null )
		battleData.battleField.dispose();
	if( mapBuilder != null )
		mapBuilder.dispose();
	super.dispose();
}

static private var SHAKE_POINTS:Array = [[-3.875 ,-8.75],[5.875 ,7.75],[-8.25 ,-3.875],[-2.875 ,-8.75],[-4 ,7.375],[7.25 ,4.125],[-7.125 ,3.25],[9.125 ,-1.875],[-5.25 ,-0.375],[-7.75 ,-1.5],[7.5 ,-1.625],[6.375 ,3.625],[-6.25 ,2.375],[4 ,-4.125],[-5.625 ,-2],[-4.5 ,-1.125],[2.5 ,-4.5],[0.875 ,5.75],[-3.875 ,-2.5],[2.625 ,-4.375],[-2.25 ,-3.125],[-3.375 ,-1.375],[2.625 ,-3.625],[0.25 ,3.75],[0.25 ,3],[3.875 ,0.5],[-1.875 ,2.25],[-2.25 ,0.125],[-1.875 ,1.5],[-1.375 ,0.25],[1.25 ,2.75],[2.5 ,0.125],[-1 ,1.25],[0.375 ,-0.5],[0.375 ,-0.5],[1.5 ,0.5],[0 ,0]];
private var shakeSpeed:Number;
private var shakePower:Number;
private var shakeIndex:Number;
public function shake(power:Number = 1, speed:Number=0.7) : void
{
	if( power == 0 )
		return;
	this.shakeIndex = 0;
	this.shakePower = power;
	this.shakeSpeed = speed;
	this.addEventListener(Event.ENTER_FRAME, this.enterFrameHandler);
}
private function enterFrameHandler(event:EnterFrameEvent):void
{
	if( shakeIndex >= SHAKE_POINTS.length )
	{
		this.removeEventListener(Event.ENTER_FRAME, this.enterFrameHandler);
		return;
	}
	var index:int = Math.floor(shakeIndex);
	x = center.x + SHAKE_POINTS[index][0] * this.shakePower;
	y = center.y + SHAKE_POINTS[index][1] * this.shakePower;
	shakeIndex += this.shakeSpeed;
}

private function drawTile(x:Number, y:Number, color:int, width:int, height:int, alpha:Number = 0.1):void
{
	var q:Quad = new Quad(width - 2, height - 2, color);
	q.alpha = alpha;
	q.x = x - width * 0.5;
	q.y = y - -height * 0.5;
	guiTextsContainer.addChild(q);
}
}
}