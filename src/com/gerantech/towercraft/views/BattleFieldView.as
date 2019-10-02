package com.gerantech.towercraft.views
{
import com.gerantech.mmory.core.battle.BattleField;
import com.gerantech.mmory.core.battle.GameObject;
import com.gerantech.mmory.core.battle.bullets.Bullet;
import com.gerantech.mmory.core.battle.units.Card;
import com.gerantech.mmory.core.battle.units.Unit;
import com.gerantech.mmory.core.constants.CardTypes;
import com.gerantech.mmory.core.events.BattleEvent;
import com.gerantech.mmory.core.utils.GraphicMetrics;
import com.gerantech.mmory.core.utils.Point2;
import com.gerantech.mmory.core.utils.Point3;
import com.gerantech.mmory.core.utils.maps.IntUnitMap;
import com.gerantech.towercraft.controls.headers.BattleFooter;
import com.gerantech.towercraft.managers.DropTargets;
import com.gerantech.towercraft.managers.SoundManager;
import com.gerantech.towercraft.managers.TimeManager;
import com.gerantech.towercraft.managers.net.ResponseSender;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.models.vo.BattleData;
import com.gerantech.towercraft.views.units.UnitView;
import com.gerantech.towercraft.views.units.elements.IElement;
import com.gerantech.towercraft.views.units.elements.ImageElement;
import com.gerantech.towercraft.views.weapons.BulletView;
import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSObject;

import flash.filesystem.File;
import flash.utils.setTimeout;

import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.DisplayObjectContainer;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;

public class BattleFieldView extends Sprite
{
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
private var units:IntUnitMap;

public function BattleFieldView() { super(); }
public function initialize () : void 
{
	units = new IntUnitMap();
	touchGroup = true;
	alignPivot();
	scale = 0.8;

	shadowsContainer = new Sprite();
	unitsContainer = new Sprite();
	effectsContainer = new Sprite();
	guiImagesContainer = new Sprite();
	guiTextsContainer = new Sprite();
	
	if( AppModel.instance.assets.getObject("arts-rules") != null )
	{
		Starling.juggler.delayCall(assetManagerLoaded, 0.1, 1);
		return;
	}
	AppModel.instance.assets.enqueue(File.applicationDirectory.resolvePath("assets/images/battle"));
	AppModel.instance.assets.loadQueue(assetManagerLoaded);
}

private function assetManagerLoaded(ratio:Number):void 
{
	trace("assetManagerLoaded" , ratio)
	if( ratio < 1 )
		return;
	if( AppModel.instance.artRules == null )
		AppModel.instance.artRules = new ArtRules(AppModel.instance.assets.getObject("arts-rules"));
	mapBuilder = new MapBuilder();
	dispatchEventWith(Event.COMPLETE);
}

public function createPlaces(battleData:BattleData) : void
{
	this.battleData = battleData;
	if( mapBuilder == null )
		return;
	
	pivotX = BattleField.WIDTH * 0.5;
	pivotY = BattleField.HEIGHT * 0.5;
	center = new Point2(Starling.current.stage.stageWidth * 0.5, (Starling.current.stage.stageHeight - BattleFooter.HEIGHT * 0.5 - 500) * 0.5);
	x = center.x;
	y = center.y;

	mapBuilder.init(AppModel.instance.assets.getObject("graphicContent"));
	mapBuilder.pivotX = mapBuilder.width * 0.5;
	mapBuilder.pivotY = mapBuilder.height * 0.5;
	mapBuilder.x = pivotX//width * 0.5;
	mapBuilder.y = pivotY + 250//height * 0.5;
	addChild(mapBuilder);

	battleData.battleField.state = BattleField.STATE_2_STARTED;

	responseSender = new ResponseSender(battleData);
	TimeManager.instance.addEventListener(Event.UPDATE, timeManager_updateHandler);
	
	addChild(shadowsContainer);
	addChild(unitsContainer);

	summonUnits(battleData.sfsData.getSFSArray("units"), battleData.sfsData.getDouble("now"));

	/*for ( i = 0; i < battleData.battleField.tileMap.width; i ++ )
		for ( var j:int = 0; j < battleData.battleField.tileMap.height; j ++ )
			drawTile(i, j, battleData.battleField.tileMap.map[i][j], battleData.battleField.tileMap.tileWidth, battleData.battleField.tileMap.tileHeight);*/
	
	addChild(effectsContainer);
	addChild(guiImagesContainer);
	addChild(guiTextsContainer);
}

protected function timeManager_updateHandler(e:Event):void 
{
	battleData.battleField.update(e.data as int);
	unitsContainer.sortChildren(unitSortMethod);
}

private function unitSortMethod(left:IElement, right:IElement) : Number
{
	if( left.unit == null || right.unit == null )
		return 0;
	return left.unit.y - right.unit.y;
}

public function summonUnits(units:ISFSArray, summonTime:Number):void
{
	if( mapBuilder == null )
	{
		trace("not able to summon units:\n" + units.getDump(), "\nsummonTime: " + summonTime)
		return;
	}

	TimeManager.instance.forceUpdate();
	this.battleData.battleField.forceUpdate(summonTime - this.battleData.battleField.now);
	for( var i:int = 0; i < units.size(); i++ )
	{
		var u:ISFSObject = units.getSFSObject(i);
		this.summonUnit(u.getInt("i"), u.getInt("t"), u.getInt("l"), u.getInt("s"), u.getDouble("x"), u.getDouble("y"), u.containsKey("h") ? u.getDouble("h") : -1);
	}
	var diff:Number = TimeManager.instance.millis - this.battleData.battleField.now;
	this.battleData.battleField.update(diff);
}

private function summonUnit(id:int, type:int, level:int, side:int, x:Number, y:Number, health:Number) : void
{
	var card:Card = getCard(side, type, level);
	if( CardTypes.isSpell(type) )
	{
		var offset:Point3 = GraphicMetrics.getSpellStartPoint(card.type);
		var spell:BulletView = new BulletView(battleData.battleField, id, card, side, x + offset.x, y + offset.y * (side == 0 ? 0.7 : -0.7), offset.z * 0.7, x, y, 0);
		battleData.battleField.bullets.set(id, spell as Bullet);
		//trace("summon spell", " side:" + side, " x:" + x, " y:" + y, " offset:" + offset);
		return;
	}

	var u:UnitView = new UnitView(card, id, side, x, y, card.z);
	u.addEventListener("findPath", findPathHandler);
	if( health >= 0 )
		u.health = health;
	battleData.battleField.units.set(id, u as Unit);
	
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

private function findPathHandler(e:BattleEvent):void 
{
	guiTextsContainer.removeChildren();
	var u:UnitView = e.currentTarget as UnitView;
	if( u.path == null )
		return;
	var c:uint = Math.random() * 0xFFFFFF;
	for (var i:int = 0; i < u.path.length; i ++)
		drawTile(u.path[i].x, u.path[i].y, c, battleData.battleField.field.tileMap.tileWidth, battleData.battleField.field.tileMap.tileHeight, 0.3);
}

public function requestKillPioneers(side:int):void 
{
	var color:int = side == battleData.battleField.side ? 1 : 0;
	function crazyDriving(fromX:int, toX:int, y:int, color:int) : void
	{
		AppModel.instance.sounds.addAndPlay("car-passing-by", null, 1, SoundManager.SINGLE_NONE);
		var txt:Texture = AppModel.instance.assets.getTexture("201/" + color + "/base");
		var car:ImageElement = new ImageElement(null, txt);
		car.width = txt.frameWidth * 2.4;
		car.height = txt.frameHeight * 2.4;
		// car.scaleX *= fromX < toX ? 1 : -1;
		car.x = fromX;
		car.y = y + BattleField.HEIGHT * 0.5 - car.height * 0.7;
		unitsContainer.addChild(car);
		Starling.juggler.tween(car, 1, {x:toX, onComplete:car.removeFromParent, onCompleteArgs:[true]});
	}

 	battleData.battleField.requestKillPioneers(side);
	var time:int = battleData.battleField.resetTime - battleData.battleField.now - 500;
	setTimeout(crazyDriving, time, color == 0 ? -600 : 1160, color == 0 ? 1160 : -600, color == 1 ? -140 : 140, color);
	setTimeout(crazyDriving, time, color == 0 ? -400 : 1360, color == 0 ? 1360 : -400, color == 1 ? -420 : 420, color);
}

public function hitUnits(buletId:int, targets:ISFSArray) : void
{
	for ( var i:int = 0; i < targets.size(); i ++ )
	{
		var id:int = targets.getSFSObject(i).getInt("i");
		if( battleData.battleField.units.exists(id) )
			battleData.battleField.units.get(id).setHealth(targets.getSFSObject(i).getDouble("h"));
		else
			trace("unit " + id + " not found.");
	}
}

public function updateUnits(unitData:SFSObject) : void
{
	var serverUnitIds:Array = unitData.getIntArray("keys");
	var clientUnitIds:Vector.<int> = battleData.battleField.units.keys();
	
	// force remove units from server
	for( var i:int = 0; i < clientUnitIds.length; i++ )
		if( serverUnitIds.indexOf(clientUnitIds[i]) == -1 )
			battleData.battleField.units.get(clientUnitIds[i]).hit(100);
	
	if( !unitData.containsKey("testData") )
		return;
	
	var serverUnitTests:Array = unitData.getUtfStringArray("testData");
	for( i = 0; i < serverUnitTests.length; i++ )
	{
		var vars:Array = serverUnitTests[i].split(",");// unit.id + "," + unit.x + "," + unit.y + "," + unit.health + "," + unit.card.type + "," + unit.side + "," + unit.card.level
		if( units.exists(vars[0]) )
		{
			units.get(vars[0]).setPosition(vars[1], vars[2], GameObject.NaN);
		}
		else
		{
			var u:UnitView = new UnitView(getCard(vars[5], vars[4], vars[6]), vars[0], vars[5], vars[1], vars[2], 0);
			u.alpha = 0.3;
			u.isDump = true;
			units.set(vars[0], u as Unit);
		}
	}

	clientUnitIds = units.keys();
	for( i = 0; i < clientUnitIds.length; i++ )
	{
		if( serverUnitIds.indexOf(clientUnitIds[i]) == -1 )
		{
			units.get(clientUnitIds[i]).dispose();
			units.remove(clientUnitIds[i]);
		}
	}
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

public function shake() : void
{return;
	x = center.x + 5;
	y = center.y + 5;
	Starling.juggler.tween(this, 0.4, {x:center.x, y:center.y, transition:Transitions.EASE_IN_ELASTIC});
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