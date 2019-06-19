package com.gerantech.towercraft.controls.headers
{
import com.gerantech.towercraft.controls.BattleDeckCard;
import com.gerantech.towercraft.controls.CardView;
import com.gerantech.towercraft.controls.TowersLayout;
import com.gerantech.towercraft.controls.buttons.MMOryButton;
import com.gerantech.towercraft.controls.overlays.TutorialSwipeOverlay;
import com.gerantech.towercraft.controls.sliders.ElixirBar;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.tutorials.TutorialTask;
import com.gerantech.towercraft.models.vo.UserData;
import com.gerantech.towercraft.themes.MainTheme;
import com.gerantech.towercraft.views.MapBuilder;
import com.gerantech.towercraft.views.units.CardPlaceHolder;
import com.gerantech.mmory.core.battle.BattleField;
import com.gerantech.mmory.core.battle.ElixirUpdater;
import com.gerantech.mmory.core.constants.CardTypes;
import com.gerantech.mmory.core.constants.PrefsTypes;
import com.gerantech.mmory.core.socials.Challenge;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.data.SFSObject;

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
private var padding:int;
private var cardsContainer:LayoutGroup;
private var draggableCard:Draggable;
private var preparedCard:CardView;
private var placeHolder:CardPlaceHolder;
private var cards:Vector.<BattleDeckCard>;
private var touchId:int;
private var elixirBar:ElixirBar;
private var cardQueue:Vector.<int>;
private var touchPosition:Point = new Point();
private var selectedCard:BattleDeckCard;
private var selectedCardPosition:Rectangle;
private var task:TutorialTask;

public function BattleFooter()
{
	super();
	padding = 12;
}

override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout();
	backgroundSkin = new Quad(1, 1, 0);
	backgroundSkin.alpha = 0.7;
	height = HEIGHT;
	
	cardsContainer = new LayoutGroup();
	cardsContainer.layoutData = new AnchorLayoutData(0, 0, NaN, 0);
	addChild(cardsContainer);
	
	var hlayout:HorizontalLayout = new HorizontalLayout();
	hlayout.padding = hlayout.gap = 24;
	hlayout.verticalAlign = VerticalAlign.JUSTIFY;
	hlayout.horizontalAlign = HorizontalAlign.RIGHT;
	cardsContainer.layout = hlayout;
	
	cardQueue = appModel.battleFieldView.battleData.getAlliseDeck()._queue;
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
	
	if( appModel.battleFieldView.battleData.userType == 0 )
	{
		stickerButton = new MMOryButton();
		stickerButton.height = 110;
		// stickerButton.iconSize = MMOryButton.DEFAULT_ICON_SIZE
		stickerButton.width = preparedCard.width;
		stickerButton.styleName = MainTheme.STYLE_BUTTON_SMALL_NEUTRAL;
		stickerButton.iconTexture = Assets.getTexture("tooltip-bg-bot-left");
		stickerButton.layoutData = new AnchorLayoutData(padding, NaN, NaN, padding);
		stickerButton.addEventListener(Event.TRIGGERED, stickerButton_triggeredHandler);
		addChild(stickerButton);
	}
	
	elixirBar = new ElixirBar();
	elixirBar.value = ElixirUpdater.INIT_VALUE;
	elixirBar.layoutData = new AnchorLayoutData(NaN, padding * 2, padding, preparedCard.width + padding * 2);
	addChild(elixirBar);
	
	draggableCard = new Draggable();
	
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

	var params:SFSObject = event.params.params as SFSObject;
	if( params.containsKey(battleField.side.toString()) )
	{
		battleField.elixirUpdater.updateAt(battleField.side, params.getInt(battleField.side.toString()));
		elixirBar.value = appModel.battleFieldView.battleData.getAlliseEllixir();
		for( var i:int=0; i<cards.length; i++ )
			cards[i].updateData();
	}
	else
	{
		var outside:int = 1 - battleField.side;
		battleField.elixirUpdater.updateAt(outside, params.getInt(outside.toString()));
	}
}

public function updateScore(round:int, winnerSide:int, allise:int, axis:int, unitId:int) : void 
{
	if( player.get_battleswins() == 0 && battleField.numSummonedUnits < 4 && allise == 1)
		showSummonTutorial(0, new Point(450, 900), 200);
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
	if( player.get_battleswins() < 3 )
		//showSummonTutorial(1, new Point(200, 1250), 500);
		showSummonTutorial(1, new Point(200, 1300), 500);
}

private function showSummonTutorial(index:Number, point:Point, delay:int) : void 
{
	var c:Rectangle = cards[index].getBounds(stage);
	task = new TutorialTask(TutorialTask.TYPE_SWIPE, "", [new Point(c.x + cards[index].width * 0.5, c.y + cards[index].height * 0.5), point], delay, 1500);
	var swipeoverlay:TutorialSwipeOverlay = new TutorialSwipeOverlay(task);
	appModel.navigator.addChild(swipeoverlay);
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
		selectedCardPosition = selectedCard.getBounds(stage);
		draggableCard.x = placeHolder.x = selectedCardPosition.x += selectedCard.width * 0.50;
		draggableCard.y = placeHolder.y = selectedCardPosition.y += selectedCard.height * 0.44;
		Starling.juggler.tween(draggableCard, 0.1, {scale:1});
		draggableCard.visible = true;
		draggableCard.type = placeHolder.type = selectedCard.type;
		stage.addChild(draggableCard);
		stage.addChild(placeHolder);
		
		appModel.battleFieldView.mapBuilder.setSummonAreaEnable(true);
	}
	else 
	{
		if( touchId != touch.id )
			return;
		if( touch.phase == TouchPhase.MOVED )
		{
			setTouchPosition(touch);
			placeHolder.x = draggableCard.x = touchPosition.x;
			placeHolder.y = draggableCard.y = touchPosition.y;
			draggableCard.scale = Math.min(1.2, (100 + touch.globalY - y) / 200 * 1.2);
			draggableCard.visible = draggableCard.scale >= 0.6;
			placeHolder.visible = !draggableCard.visible;
		}
		else if( touch.phase == TouchPhase.ENDED && selectedCard != null )
		{
			appModel.battleFieldView.mapBuilder.setSummonAreaEnable(false);
			setTouchPosition(touch);
			touchPosition.x -= (appModel.battleFieldView.x - BattleField.WIDTH * 0.5);
			touchPosition.y -= (appModel.battleFieldView.y - BattleField.HEIGHT * 0.5);
			if( validateSummonPosition() && appModel.battleFieldView.battleData.getAlliseEllixir() >= draggableCard.elixir )
			{
				if( task != null )
				{
					touchPosition.x = task.points[1].x - (appModel.battleFieldView.x - BattleField.WIDTH * 0.5);
					touchPosition.y = task.points[1].y - (appModel.battleFieldView.y - BattleField.HEIGHT * 0.5);	
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
					
				touchPosition.x = battleField.side == 0 ? touchPosition.x : BattleField.WIDTH - touchPosition.x;
				touchPosition.y = battleField.side == 0 ? touchPosition.y : BattleField.HEIGHT - touchPosition.y;
				appModel.battleFieldView.responseSender.summonUnit(draggableCard.type, touchPosition.x, touchPosition.y);
				
				task = null;
				UserData.instance.prefs.setInt(PrefsTypes.TUTOR, appModel.battleFieldView.battleData.getBattleStep() + 2);
				if( player.get_battleswins() < 2 )
				{
					battleField.numSummonedUnits ++;
					
					if( battleField.numSummonedUnits == 1 ) // pause battle
					{
						battleField.pauseTime = battleField.now + 2500;
						showSummonTutorial(1, new Point(300, 1200), 2000);
					}
					else if( battleField.numSummonedUnits == 2 ) // resume battle
					{
						battleField.pauseTime = (battleField.startAt + 2000) * 1000;
					}
				}
			}
			else
			{
				placeHolder.removeFromParent();
				draggableCard.x = selectedCardPosition.x;
				draggableCard.y = selectedCardPosition.y;
				draggableCard.scale = 1;
				selectedCard.visible = true;	
			}
			touchId = -1;			
		}
	}
}

private function validateSummonPosition() : Boolean
{
	if( touchPosition.y < 0 || touchPosition.y > BattleField.HEIGHT )
		return false;
	if( CardTypes.isSpell(selectedCard.type) )
		return true;
	return true;
/*	if( touchPosition.y 
	touchPosition.y < BattleField.HEIGHT && touchPosition.y > BattleField.HEIGHT * (CardTypes.isSpell(selectedCard.cardType)?0.0:0.5) &&*/
}

private function setTouchPosition(touch:Touch) : void 
{
	touchPosition.x = Math.max(BattleField.PADDING, Math.min(stageWidth - BattleField.PADDING, touch.globalX));
	
	if( selectedCard == null )
		return;
	
	var limitY:Number = -0.5;
	if( !CardTypes.isSpell(selectedCard.type) )
	{
		if( battleField.field.mode == Challenge.MODE_1_TOUCHDOWN )
		{
			limitY = 0.15;
		}
		else if( appModel.battleFieldView.mapBuilder != null )
		{
			if( appModel.battleFieldView.mapBuilder.summonAreaMode >= MapBuilder.SUMMON_AREA_BOTH )
				limitY = -0.24;
			else if( touch.globalX > stageWidth * 0.5 )
				limitY = appModel.battleFieldView.mapBuilder.summonAreaMode == MapBuilder.SUMMON_AREA_RIFGT ? -0.24 : 0.01;
			else
				limitY = appModel.battleFieldView.mapBuilder.summonAreaMode == MapBuilder.SUMMON_AREA_LEFT ? -0.24 : 0.01;
		}
	}
	touchPosition.y = Math.max(BattleField.HEIGHT * limitY + appModel.battleFieldView.y, touch.globalY);
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
	draggableCard.removeFromParent(true);
	placeHolder.removeFromParent(true);
	removeEventListener(TouchEvent.TOUCH, stage_touchHandler);
}
private function get battleField() : BattleField
{
	return appModel.battleFieldView.battleData.battleField;
}
}
}

import com.gerantech.towercraft.controls.CardView;
import com.gerantech.towercraft.models.Assets;

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
/* override protected function createCompleteHandler():void
{
	super.createCompleteHandler();
	
	var hilight:ImageLoader = new ImageLoader();
	hilight.touchable = false;
	hilight.scale9Grid = new Rectangle(39, 39, 4, 4);
	hilight.layoutData = new AnchorLayoutData(-2, -2, -2, -2);
	hilight.source = Assets.getTexture("cards/hilight", "gui");
	addChild(hilight);
}
 */}