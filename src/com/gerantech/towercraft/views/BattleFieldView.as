package com.gerantech.towercraft.views
{
import com.gerantech.mmory.core.battle.BattleField;
import com.gerantech.mmory.core.battle.GameObject;
import com.gerantech.mmory.core.battle.bullets.Bullet;
import com.gerantech.mmory.core.battle.units.Card;
import com.gerantech.mmory.core.battle.units.Unit;
import com.gerantech.mmory.core.constants.CardTypes;
import com.gerantech.mmory.core.scripts.ScriptEngine;
import com.gerantech.mmory.core.utils.GraphicMetrics;
import com.gerantech.mmory.core.utils.Point2;
import com.gerantech.mmory.core.utils.Point3;
import com.gerantech.towercraft.controls.headers.BattleFooter;
import com.gerantech.towercraft.controls.screens.BattleScreen;
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

public function init():void
{
	units = new Array();
	touchGroup = true;
	alignPivot();

	shadowsContainer = new Sprite();
	unitsContainer = new Sprite();
	effectsContainer = new Sprite();
	guiImagesContainer = new Sprite();
	guiTextsContainer = new Sprite();
	mapBuilder = new MapBuilder();
	
	if( AppModel.instance.artRules == null )
		AppModel.instance.artRules = new ArtRules(AppModel.instance.assets.getObject("arts-rules"));
	
	if( BattleScreen.FRIENDLY_MODE > 0 )
	{
		dispatchEventWith(Event.OPEN);
		return;
	}

	var preAssets:Object = new Object();
	addAssets(preAssets);
	var syncTool:SyncUtil = new SyncUtil();
	syncTool.addEventListener(Event.COMPLETE, syncToolPre_completeHandler);
	syncTool.sync(preAssets);
}

protected function syncToolPre_completeHandler(event:Event):void 
{
	dispatchEventWith(Event.OPEN);
}

public function load(battleData:BattleData) : void
{
	this.battleData = battleData;
	responseSender = new ResponseSender(battleData);
	if( mapBuilder == null )
		return;
	var deck:Vector.<String> = new Vector.<String>;
	for(var k:int = 0; k < battleData.axisGame.loginData.deck.length; k++ )
		deck.push(battleData.axisGame.loginData.deck[k].toString());
	var postAssets:Object = new Object();
	if( BattleScreen.FRIENDLY_MODE > 0 )
		addAssets(postAssets);
	addInitialUnit(ScriptEngine.get(ScriptEngine.T54_CHALLENGE_INITIAL_UNITS, battleData.sfsData.getInt("mode"), 0)[0]);
	addInitialUnit(ScriptEngine.get(ScriptEngine.T54_CHALLENGE_INITIAL_UNITS, battleData.sfsData.getInt("mode"), 2)[0]);
	function addInitialUnit(type:int):void {
		if( type > -1 )
			deck.push(type.toString());
	}
	fillDeck(deck, postAssets);

	var key:String = "map-" + battleData.sfsData.getInt("mode");
	postAssets[key +".json"] = SyncUtil.ALL[key + ".json"];
	postAssets[key + ".atf"] = SyncUtil.ALL[key + ".atf"];
	postAssets[key + ".xml"] = SyncUtil.ALL[key + ".xml"];

	var syncTool:SyncUtil = new SyncUtil();
	syncTool.addEventListener(Event.COMPLETE, syncToolPost_completeHandler);
	syncTool.sync(postAssets);
}

private function addAssets(assets:Object):void
{
	for ( var key:String in SyncUtil.ALL )
		if( SyncUtil.ALL[key]["mode"] == "prev" )
			assets[key] = SyncUtil.ALL[key];

	var deckKeys:Vector.<int> = AppModel.instance.game.player.decks.get(0).keys();
	var deck:Vector.<String> = new Vector.<String>;
	for(var k:int = 0; k < deckKeys.length; k++ )
		deck.push(AppModel.instance.game.player.decks.get(0).get(deckKeys[k]).toString());
	fillDeck(deck, assets);
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
	event.currentTarget.removeEventListener(Event.COMPLETE, syncToolPost_completeHandler);
	dispatchEventWith(Event.READY);
}

public function start(units:ISFSArray):void
{
	pivotX = BattleField.WIDTH * 0.5;
	pivotY = BattleField.HEIGHT * 0.5;
	center = new Point2(Starling.current.stage.stageWidth * 0.5, (Starling.current.stage.stageHeight - BattleFooter.HEIGHT * 0.5 - 100) * 0.5);
	x = center.x;
	y = center.y - 50;

	mapBuilder.init(battleData.battleField.field.json);
	addChild(mapBuilder);

	TimeManager.instance.addEventListener(Event.UPDATE, timeManager_updateHandler);
	
	addChild(shadowsContainer);
	addChild(unitsContainer);

	summonUnits(battleData.battleField.now, units);
	scale = 0.85;

	/*for ( i = 0; i < battleData.battleField.tileMap.width; i ++ )
		for ( var j:int = 0; j < battleData.battleField.tileMap.height; j ++ )
			drawTile(i, j, battleData.battleField.tileMap.map[i][j], battleData.battleField.tileMap.tileWidth, battleData.battleField.tileMap.tileHeight);*/
	
	addChild(effectsContainer);
	addChild(guiImagesContainer);
	addChild(guiTextsContainer);
	dispatchEventWith(Event.COMPLETE);
}

protected function timeManager_updateHandler(e:Event):void
{
	unitsContainer.sortChildren(unitSortMethod);
}

private function unitSortMethod(left:IElement, right:IElement) : Number
{
	if( left.unit == null || right.unit == null )
		return 0;
	return battleData.battleField.side == 0 ? left.unit.y - right.unit.y : right.unit.y - left.unit.y;
}

public function summonUnits(time:Number, units:ISFSArray):void
{
	for( var i:int = 0; i < units.size(); i++ )
	{
		var u:ISFSObject = units.getSFSObject(i);
		this.summonUnit(u.getInt("i"), u.getInt("t"), u.getInt("l"), u.getInt("s"), u.getDouble("x"), u.getDouble("y"), u.containsKey("h") ? u.getDouble("h") : -1, time);
	}
}

private function summonUnit(id:int, type:int, level:int, side:int, x:Number, y:Number, health:Number, t:Number) : void
{
	var card:Card = battleData.battleField.getCard(side, type, level);
	if( CardTypes.isSpell(type) )
	{
		var offset:Point3 = GraphicMetrics.getSpellStartPoint(card.type);
		var spell:BulletView = new BulletView(battleData.battleField, null, null, id, card, side, x + offset.x, y + offset.y * (side == 0 ? 0.7 : -0.7), offset.z * 0.7, x, y, 0);
		battleData.battleField.bullets.push(spell as Bullet);
		return;
	}

	var u:UnitView = new UnitView(card, id, side, x, y, card.z, t);
	if( health >= 0 )
		u.setHealth(health);
	battleData.battleField.units.push(u as Unit);

	AppModel.instance.sounds.addAndPlayRandom(AppModel.instance.artRules.getArray(type, ArtRules.SUMMON_SFX), SoundManager.CATE_SFX, SoundManager.SINGLE_BYPASS_THIS);
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

public function updateUnits(data:SFSObject) : void
{
	kill(battleData.battleField.units, data.getIntArray("k"), false);
	if( data.containsKey("d") )
	{
		var vars:Array;
		var u:UnitView;
		var unitsData:Array = data.getUtfStringArray("d");
		for( var i:int = 0; i < unitsData.length; i++ )
		{
			vars = unitsData[i].split(",");// unit.id + "," + unit.x + "," + unit.y + "," + unit.health + "," + unit.card.type + "," + unit.side + "," + unit.card.level
			u = battleData.battleField.getUnit(vars[0]) as UnitView;
			u.setPosition(vars[1], vars[2], GameObject.NaN);
			u.setHealth(vars[3]);
		}
		return;
	}
	
	if( !data.containsKey("g") )
		return;
	unitsData = data.getUtfStringArray("g");
	var serverUnitIds:Array = new Array();
	for( i = 0; i < unitsData.length; i++ )
	{
		vars = unitsData[i].split(",");// unit.id + "," + unit.x + "," + unit.y + "," + unit.health + "," + unit.card.type + "," + unit.side + "," + unit.card.level
		serverUnitIds.push(int(vars[0]));
		u = getUnit(vars[0]);
		if( u == null )
		{
			u = new UnitView(battleData.battleField.getCard(vars[5], vars[4], vars[6]), vars[0], vars[5], vars[1], vars[2], 0, 0, true);
			u.alpha = 0.2;
			units.push(u);
			continue;
		}
		u.setPosition(vars[1], vars[2], GameObject.NaN);
		u.setHealth(vars[3]);
	}
	kill(units, serverUnitIds, true);

	function kill(units:Array, keys:Array, exists:Boolean):void
	{
		if( keys == null || keys.length == 0 )
			return;
		for(var i:int = units.length - 1; i >= 0; i-- )
		{
			var ki:int = keys.indexOf(units[i].id);
			if( (exists && ki == -1) || (!exists && ki > -1) )
			{
				units[i].dispose();
				units.removeAt(i);
			}
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