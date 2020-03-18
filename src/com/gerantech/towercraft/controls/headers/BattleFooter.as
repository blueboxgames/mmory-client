package com.gerantech.towercraft.controls.headers
{
import com.gerantech.mmory.core.battle.BattleField;
import com.gerantech.mmory.core.constants.PrefsTypes;
import com.gerantech.mmory.core.constants.SFSCommands;
import com.gerantech.mmory.core.scripts.ScriptEngine;
import com.gerantech.mmory.core.utils.Point2;
import com.gerantech.towercraft.controls.BattleDeckCard;
import com.gerantech.towercraft.controls.CardView;
import com.gerantech.towercraft.controls.TowersLayout;
import com.gerantech.towercraft.controls.buttons.MMOryButton;
import com.gerantech.towercraft.controls.overlays.TutorialSwipeOverlay;
import com.gerantech.towercraft.controls.sliders.ElixirBar;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.tutorials.TutorialTask;
import com.gerantech.towercraft.models.vo.UserData;
import com.gerantech.towercraft.themes.MainTheme;
import com.gerantech.towercraft.views.BattleFieldView;
import com.gerantech.towercraft.views.units.CardPlaceHolder;
import com.smartfoxserver.v2.core.SFSEvent;

import feathers.controls.LayoutGroup;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;

import flash.geom.Point;
import flash.geom.Rectangle;

import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Quad;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

public class BattleFooter extends TowersLayout
{
static public var HEIGHT:int = 360;
public var stickerButton:MMOryButton;
private var padding:int = 16;
private var cards:Vector.<BattleDeckCard>;
private var cardsContainer:LayoutGroup;
private var preparedCard:CardView;
private var placeHolder:CardPlaceHolder;
private var draggableCard:Draggable;
private var touchId:int;
private var summonState:int;
private var summonPoint:Point2;
private var draggedInMap:Boolean;
private var elixirBar:ElixirBar;
private var cardQueue:Vector.<int>;
private var selectedCard:BattleDeckCard;
private var selectedCardPosition:Rectangle;
private var task:TutorialTask;
private var numRounds:int;
private var numCovers:int;

public function BattleFooter() { super(); }

override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout();
	backgroundSkin = new Quad(1, 1, 0);
	backgroundSkin.alpha = 0.7;
	height = HEIGHT;
	summonPoint = new Point2(0,0);
	
	cardsContainer = new LayoutGroup();
	cardsContainer.layoutData = new AnchorLayoutData(0, 0, NaN, 0);
	addChild(cardsContainer);
	
	var hlayout:HorizontalLayout = new HorizontalLayout();
	hlayout.padding = hlayout.gap = 24;
	hlayout.verticalAlign = VerticalAlign.JUSTIFY;
	hlayout.horizontalAlign = HorizontalAlign.RIGHT;
	cardsContainer.layout = hlayout;
	
	cardQueue = fieldView.battleData.getAlliseDeck()._queue;
	cards = new Vector.<BattleDeckCard>();
	var minDeckSize:int = Math.min(4, cardQueue.length);
	for ( var i:int = 0; i < minDeckSize; i++ ) 
		createDeckItem(cardQueue.shift());
	
	preparedCard = new CardView();
	preparedCard.touchable = false;
	preparedCard.width = 160;
	preparedCard.height = preparedCard.width * CardView.VERICAL_SCALE;
	preparedCard.layoutData = new AnchorLayoutData(NaN, NaN, 0, padding);
	preparedCard.type = cardQueue[0];
	addChild(preparedCard);
	
	if( fieldView.battleData.userType == 0 )
	{
		stickerButton = new MMOryButton();
		stickerButton.height = 110;
		stickerButton.width = preparedCard.width;
		stickerButton.styleName = MainTheme.STYLE_BUTTON_SMALL_NEUTRAL;
		stickerButton.iconTexture = appModel.assets.getTexture("tooltip-bg-bot-left");
		stickerButton.layoutData = new AnchorLayoutData(padding, NaN, NaN, padding);
		stickerButton.addEventListener(Event.TRIGGERED, stickerButton_triggeredHandler);
		addChild(stickerButton);
	}
	
	elixirBar = new ElixirBar();
	elixirBar.layoutData = new AnchorLayoutData(NaN, padding * 2, padding, preparedCard.width + padding * 2);
	elixirBar.value = fieldView.battleData.getAlliseEllixir();
	addChild(elixirBar);
	
	draggableCard = new Draggable();
	numCovers = ScriptEngine.getInt(ScriptEngine.T62_BATTLE_NUM_COVERS, battleField.field.mode, player.get_battleswins());
	numRounds = ScriptEngine.getInt(ScriptEngine.T63_BATTLE_NUM_ROUND, battleField.field.mode, player.get_battleswins());
	
	stage.addEventListener(TouchEvent.TOUCH, stage_touchHandler);
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_elixirUpdateHandler);
}

protected function stickerButton_triggeredHandler():void
{
	dispatchEventWith(FeathersEventType.BEGIN_INTERACTION);
}

protected function sfsConnection_elixirUpdateHandler(event:SFSEvent):void
{
	if( event.params.cmd != SFSCommands.BATTLE_ELIXIR_UPDATE )
		return;
	elixirBar.value = fieldView.battleData.getAlliseEllixir();
	for( var i:int=0; i<cards.length; i++ )
		cards[i].updateData();
}

public function updateScore(round:int, winnerSide:int, allise:int, axis:int, unitId:int) : void 
{
	if( allise > 2 || appModel.maxTutorBattles <= player.get_battleswins() || numRounds < round )
		return;
	var summonData:Array = ScriptEngine.get(ScriptEngine.T66_BATTLE_SUMMON_POS, battleField.field.mode, "newround", player.get_battleswins());
	if( summonData != null )
		showSummonTutorial(summonData[0], new Point(summonData[1], summonData[2]), summonData[3], summonData[4]);
}

private function createDeckItem(cardType:int) : void
{
	var card:BattleDeckCard = new BattleDeckCard(cardType);
	card.width = 200;
	cards.push(card);
	cardsContainer.addChild(card);
}

public function transitionInCompleteHandler() : void 
{
	if( appModel.maxTutorBattles <= player.get_battleswins() )
		return;
	var summonData:Array = ScriptEngine.get(ScriptEngine.T66_BATTLE_SUMMON_POS, battleField.field.mode, "start", player.get_battleswins());
	if( summonData != null )
		showSummonTutorial(summonData[0], new Point(summonData[1], summonData[2]), summonData[3], summonData[4]);
}

private function showSummonTutorial(index:Number, point:Point, delay:int, forced:Boolean) : void 
{
	var c:Rectangle = cards[index].getBounds(stage);
	task = new TutorialTask(TutorialTask.TYPE_SWIPE, "", [new Point(c.x + cards[index].width * 0.5, c.y + cards[index].height * 0.5), point], delay, 1500, forced);
	appModel.navigator.addChild(new TutorialSwipeOverlay(task));
}

protected function stage_touchHandler(event:TouchEvent) : void
{
	var touch:Touch = event.getTouch(stage);
	if( touch == null )
		return;
	if( touch.phase == TouchPhase.BEGAN )
	{
		if( touch.target is BattleDeckCard )
			selectedCard = touch.target as BattleDeckCard;
		if( selectedCard == null || !selectedCard.touchable )
		{
			/*if( touch.target is BattleFieldView )
				touchId = touch.id;
			else*/
			touchId = -1;
			return;
		}
		
		touchId = touch.id;
		selectedCard.visible = false;
		placeHolder = new CardPlaceHolder();
		summonState = battleField.getSummonState(battleField.side == 0 ? 1 : 0);
		selectedCardPosition = selectedCard.getBounds(stage);
		summonPoint.x = touch.globalX - fieldView.x + BattleField.WIDTH * 0.5;
		summonPoint.y = touch.globalY - fieldView.y + BattleField.HEIGHT * 0.5;
		placeHolder.x = draggableCard.x = summonPoint.x + fieldView.x - BattleField.WIDTH * 0.5;
		placeHolder.y = draggableCard.y = summonPoint.y + fieldView.y - BattleField.HEIGHT * 0.5;
		Starling.juggler.tween(draggableCard, 0.1, {scale:1});
		draggableCard.visible = true;
		draggableCard.type = placeHolder.type = selectedCard.type;
		stage.addChild(draggableCard);
		stage.addChild(placeHolder);
		
		fieldView.mapBuilder.setSummonAreaEnable(true, summonState);
	}
	else 
	{
		if( touchId != touch.id )
			return;
		if( touch.phase == TouchPhase.MOVED )
		{
			summonPoint.x = touch.globalX - fieldView.x + BattleField.WIDTH * 0.5;
			summonPoint.y = touch.globalY - fieldView.y + BattleField.HEIGHT * 0.5;
			draggableCard.scale = Math.min(1.2, (100 + touch.globalY - y) / 200 * 1.2);
			draggableCard.visible = draggableCard.scale >= 0.6;
			placeHolder.visible = !draggableCard.visible;
			setTouchPosition();
			placeHolder.x = draggableCard.x = summonPoint.x + fieldView.x - BattleField.WIDTH * 0.5;
			placeHolder.y = draggableCard.y = summonPoint.y + fieldView.y - BattleField.HEIGHT * 0.5;
		}
		else if( touch.phase == TouchPhase.ENDED && selectedCard != null )
		{
			draggedInMap = false;
			draggableCard.scale = Math.min(1.2, (100 + touch.globalY - y) / 200 * 1.2);
			draggableCard.visible = draggableCard.scale >= 0.6;
			setTouchPosition();
			fieldView.mapBuilder.setSummonAreaEnable(false, summonState);
			if( battleField.validateSummonPosition(summonPoint) && fieldView.battleData.getAlliseEllixir() >= draggableCard.elixir )
			{
				if( task != null && task.data )
				{
					summonPoint.x = task.points[1].x;
					summonPoint.y = task.points[1].y;	
					placeHolder.x = task.points[1].x;
					placeHolder.y = task.points[1].y;
				}
				
				placeHolder.summon();
				cardQueue.push(selectedCard.type);
				selectedCard.type = cardQueue.shift();
				preparedCard.type = cardQueue[0];
				pushNewCardToDeck(selectedCard);
				
				Starling.juggler.tween(draggableCard, 0.1, {scale:0, onComplete:draggableCard.removeFromParent});
				selectedCard = null;
				
				elixirBar.value -= draggableCard.elixir;
				for( var i:int=0; i < cards.length; i++ )
					cards[i].updateData();
					
				summonPoint.x = battleField.side == 0 ? summonPoint.x : BattleField.WIDTH - summonPoint.x;
				summonPoint.y = battleField.side == 0 ? summonPoint.y : BattleField.HEIGHT - summonPoint.y;
				fieldView.responseSender.summonUnit(draggableCard.type, summonPoint.x, summonPoint.y, battleField.now);
				
				task = null;
				UserData.instance.prefs.setInt(PrefsTypes.TUTOR, fieldView.battleData.getBattleStep() + 2);
				battleField.numSummonedUnits ++;
				coverUnitTutorial();
			}
			else
			{
				placeHolder.removeFromParent();
				draggableCard.x = selectedCardPosition.x;
				draggableCard.y = selectedCardPosition.y;
				draggableCard.scale = 1;
				draggableCard.visible = false;
				selectedCard.visible = true;	
			}
			touchId = -1;			
		}
	}
}

private function coverUnitTutorial():void
{
	if( appModel.maxTutorBattles <= player.get_battleswins() )
		return;
	
	var ptoffset:int = ScriptEngine.getInt(ScriptEngine.T64_BATTLE_PAUSE_TIME, battleField.field.mode, player.get_battleswins(), battleField.numSummonedUnits);
	if( ptoffset > -1 )
	{
		this.battleField.resetTime = battleField.now + ptoffset; // resume
		if( ptoffset > 0 )
			this.battleField.state = BattleField.STATE_3_PAUSED; // pause
	}

	if( numCovers < battleField.numSummonedUnits )
		return;
	var summonData:Array = ScriptEngine.get(ScriptEngine.T66_BATTLE_SUMMON_POS, battleField.field.mode, "cover", player.get_battleswins() * 10 + battleField.numSummonedUnits);
	if( summonData != null )
		showSummonTutorial(summonData[0], new Point(summonData[1], summonData[2]), summonData[3], summonData[4]);
}

private function setTouchPosition() : void 
{
	if( selectedCard == null || draggableCard.visible )
		return;
	battleField.fixSummonPosition(summonPoint, selectedCard.type, summonState);
}

private function pushNewCardToDeck(deckSelected:BattleDeckCard) : void 
{
	var card:CardView = new CardView();
	card.touchable = false;
	card.x = preparedCard.x;
	card.y = preparedCard.y;
	card.width = preparedCard.width;
	card.type = deckSelected.type;
	addChild(card);
	var b:Rectangle = deckSelected.getBounds(this);
	Starling.juggler.tween(card, 0.4, {x:b.x, y:b.y, width:b.width, height:b.height, transition:Transitions.EASE_IN_OUT, onComplete:pushAnimationCompleted});
	function pushAnimationCompleted() : void
	{
		card.removeFromParent(true);
		deckSelected.visible = true;	
	}
}

override public function dispose() : void
{
	super.dispose();
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_elixirUpdateHandler);
	if( draggableCard != null )
		draggableCard.removeFromParent(true);
	if( placeHolder != null )
		placeHolder.removeFromParent(true);
	removeEventListener(TouchEvent.TOUCH, stage_touchHandler);
}
protected function get fieldView():		BattleFieldView {	return appModel.battleFieldView;	}
protected function get battleField() : BattleField { return fieldView.battleData.battleField; }
}
}

import com.gerantech.towercraft.controls.CardView;

import feathers.layout.AnchorLayoutData;

import flash.geom.Rectangle;
class Draggable extends CardView
{
public function Draggable()
{
	super();
	touchable = false;
	// showRarity = false;
	width = 220;
	height = width * CardView.VERICAL_SCALE;
	pivotX = width * 0.5;
	pivotY = height * 0.5;
}
}