package com.gerantech.towercraft.controls.segments
{
import com.gerantech.mmory.core.Player;
import com.gerantech.mmory.core.battle.units.Card;
import com.gerantech.mmory.core.constants.ResourceType;
import com.gerantech.mmory.core.exchanges.Exchanger;
import com.gerantech.mmory.core.scripts.ScriptEngine;
import com.gerantech.towercraft.controls.CardView;
import com.gerantech.towercraft.controls.headers.DeckHeader;
import com.gerantech.towercraft.controls.items.CardItemRenderer;
import com.gerantech.towercraft.controls.overlays.CardUpgradeOverlay;
import com.gerantech.towercraft.controls.overlays.TransitionData;
import com.gerantech.towercraft.controls.popups.CardDetailsPopup;
import com.gerantech.towercraft.controls.popups.CardSelectPopup;
import com.gerantech.towercraft.controls.popups.RequirementConfirmPopup;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.smartfoxserver.v2.entities.data.SFSObject;

import feathers.controls.List;
import feathers.controls.ScrollBarDisplayMode;
import feathers.controls.ScrollContainer;
import feathers.controls.ScrollPolicy;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.TiledRowsLayout;
import feathers.layout.VerticalLayout;

import flash.geom.Rectangle;
import flash.utils.setTimeout;

import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Quad;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

public class CardsSegment extends Segment
{
private var availableList:List;
private var unavailableList:List;
private var deckHeader:DeckHeader;
private var scroller:ScrollContainer;
private var draggableCard:CardView;
private var selectPopup:CardSelectPopup;
private var detailsPopup:CardDetailsPopup;
private var availableCollection:ListCollection;
private var unavailableCollection:ListCollection;
private var startScrollBarIndicator:Number = 0;
private var touchId:int = -1;
private var _editMode:Boolean;

public function CardsSegment(){}
override public function init():void
{
	super.init();
	updateData();

	backgroundSkin = new Quad(1, 1);
	backgroundSkin.alpha = 0;
	
	deckHeader = new DeckHeader();
	deckHeader.addEventListener(Event.SELECT, deckHeader_selectHandler);
	deckHeader.layoutData = new AnchorLayoutData(NaN, paddingH, NaN, paddingH);
	deckHeader.alpha = 0;
	addChild(deckHeader);
	
	var scrollerLayout:VerticalLayout = new VerticalLayout();
	scrollerLayout.gap = 32;
	scrollerLayout.padding = 16; 
	scrollerLayout.paddingTop = DeckHeader.HEIGHT + 16;
	scrollerLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
	
	scroller = new ScrollContainer();
	scroller.alpha = 0;
	scroller.touchable = false;
	scroller.layout = scrollerLayout;
	scroller.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
	scroller.layoutData = new AnchorLayoutData(0, paddingH, 0, paddingH);
	addChildAt(scroller, 0);

	initializeCompleted = true;
	layout = new AnchorLayout();
	var availableLayout:TiledRowsLayout = new TiledRowsLayout();
	var unavailableLayout:TiledRowsLayout = new TiledRowsLayout();
	unavailableLayout.gap = availableLayout.gap = 16;
	unavailableLayout.verticalGap = availableLayout.verticalGap = 52;
	unavailableLayout.paddingTop = availableLayout.paddingTop = 52;
	unavailableLayout.paddingBottom = availableLayout.paddingBottom = 52;
	unavailableLayout.useSquareTiles = availableLayout.useSquareTiles = false;
	unavailableLayout.useVirtualLayout = availableLayout.useVirtualLayout = false;
	unavailableLayout.requestedColumnCount = availableLayout.requestedColumnCount = 4;
	unavailableLayout.typicalItemWidth = availableLayout.typicalItemWidth = (stageWidth - availableLayout.gap * (availableLayout.requestedColumnCount - 1) - 64) / availableLayout.requestedColumnCount;
	unavailableLayout.typicalItemHeight = availableLayout.typicalItemHeight = availableLayout.typicalItemWidth * CardView.VERICAL_SCALE;

	availableList = new List();
	availableList.layout = availableLayout;
	availableList.verticalScrollPolicy = ScrollPolicy.OFF;
	availableList.itemRendererFactory = function():IListItemRenderer { return new CardItemRenderer(true, true, true, scroller); }
	availableList.dataProvider = availableCollection;
	scroller.addChild(availableList);
	
	if( unavailableCollection.length > 0 )
	{
		scroller.addChild(new ShadowLabel(loc("unavailable_cards"), 0xCCEEFF, 0, "center", null, false, null, 0.8));	
		
		unavailableList = new List();
		unavailableList.verticalScrollPolicy = ScrollPolicy.OFF;
		unavailableList.layout = unavailableLayout;
		unavailableList.itemRendererFactory = function():IListItemRenderer { return new CardItemRenderer(false, false, false, scroller); }
		unavailableList.dataProvider = unavailableCollection;
		scroller.addChild(unavailableList);
	}

	if( !player.inDeckTutorial() )
	{
		Starling.juggler.tween(scroller, 0.1, {alpha:1});
		Starling.juggler.tween(deckHeader, 0.2, {alpha:1, onComplete:finalizeSegment});
		return;
	}

	//tutorial appearance
	scroller.scrollToPosition(NaN, 2900, 0.5);
	scroller.addEventListener(FeathersEventType.SCROLL_COMPLETE, scroller_fscrollCompleteHandler);
	function scroller_fscrollCompleteHandler(event:Event) : void
	{
		scroller.removeEventListener(FeathersEventType.SCROLL_COMPLETE, scroller_fscrollCompleteHandler);
		Starling.juggler.tween(scroller, 0.2, {alpha:1, onComplete:appearPage});
	}
	function appearPage() : void
	{
		scroller.addEventListener(FeathersEventType.SCROLL_COMPLETE, scroller_lscrollCompleteHandler);
		Starling.juggler.delayCall(scroller.scrollToPosition, 1, NaN, 0, 2);
	}
	function scroller_lscrollCompleteHandler(event:Event) : void
	{
		scroller.removeEventListener(FeathersEventType.SCROLL_COMPLETE, scroller_lscrollCompleteHandler);
		Starling.juggler.tween(deckHeader, 0.3, {alpha:1, onComplete:finalizeSegment});
	}
}

private function finalizeSegment() : void
{
	scroller.touchable = true;
	scroller.addEventListener(Event.SCROLL, scroller_scrollHandler);
	availableList.addEventListener(FeathersEventType.FOCUS_IN, unlocksList_focusInHandler);
	exchangeManager.addEventListener(FeathersEventType.END_INTERACTION, exchangeManager_endHandler);
}
	
protected function exchangeManager_endHandler(event:Event):void
{
	deckHeader.update();
	updateData();
}

protected function scroller_scrollHandler(event:Event):void
{
	var scrollPos:Number = Math.max(0, scroller.verticalScrollPosition);
	var changes:Number = startScrollBarIndicator - scrollPos;
	deckHeader.y = Math.max( -DeckHeader.HEIGHT, Math.min(0, deckHeader.y + changes));
	deckHeader.visible = deckHeader.y > -DeckHeader.HEIGHT
	startScrollBarIndicator = scrollPos;
}

override public function updateData():void
{
	var all:Array = ScriptEngine.get(1, -1);
	var unavailables:Array = all.splice(player.get_arena(0) + Player.FIRST_CARDS);
	if( availableCollection == null )
		availableCollection = new ListCollection();
	var unused:Array = new Array();
	var c:int = 0;
	while( c < all.length )
	{
		if( !player.getSelectedDeck().existsValue(all[c]) && player.cards.exists(all[c]) )
			unused.push(all[c]);
		c ++;
	}
	availableCollection.data = unused;
	
	// unavailabled cards
	if( unavailableCollection == null )
		unavailableCollection = new ListCollection();
	unavailableCollection.data = unavailables;
}

private function unlocksList_focusInHandler(event:Event):void
{
	var item:CardItemRenderer = event.data as CardItemRenderer;
	selectCard(item.data as int, item.getBounds(stage));
}
private function deckHeader_selectHandler(event:Event):void
{
	var item:CardView = event.data as CardView;
	selectCard(item.type, item.getBounds(stage));
}
private function selectCard(cardType:int, cardBounds:Rectangle):void
{
	var inDeck:Boolean = player.getSelectedDeck().existsValue(cardType);
	
	// create transition data
	var ti:TransitionData = new TransitionData(0.1);
	var to:TransitionData = new TransitionData(0.1);
	ti.transition = Transitions.EASE_IN;
	to.destinationBound = ti.sourceBound = cardBounds;
	ti.destinationBound = to.sourceBound = new Rectangle(cardBounds.x - 16, cardBounds.y - 16, cardBounds.width + 32, cardBounds.height + (inDeck?170:300));
	to.destinationConstrain = ti.destinationConstrain = this.getBounds(stage);
	
	selectPopup = new CardSelectPopup();
	selectPopup.cardType = cardType;
	selectPopup.data = inDeck;
	selectPopup.transitionIn = ti;
	selectPopup.transitionOut = to;
	selectPopup.addEventListener(Event.CLOSE, selectPopup_closeHandler);
	appModel.navigator.addPopup(selectPopup);
	selectPopup.addEventListener(Event.OPEN, selectPopup_openHandler);
	selectPopup.addEventListener(Event.SELECT, selectPopup_selectHandler);
	function selectPopup_closeHandler(event:Event):void { availableList.selectedIndex = -1; }
	function selectPopup_openHandler(event:Event):void { showCardDetails(cardType); }	
}

private function availabledList_focusInHandler(event:Event):void
{
	showCardDetails(CardItemRenderer(event.data).data as int);
}

private function showCardDetails(cardType:int):void
{
	detailsPopup = new CardDetailsPopup();
	detailsPopup.cardType = cardType;
	detailsPopup.addEventListener(Event.SELECT, selectPopup_selectHandler);
	detailsPopup.addEventListener(Event.UPDATE, details_updateHandler);
	appModel.navigator.addPopup(detailsPopup);	
}
private function selectPopup_selectHandler(event:Event):void
{
	var type:int = -1;
	if( event.currentTarget is CardDetailsPopup )
		type = detailsPopup.cardType;
	else
		type = selectPopup.cardType;
	setTimeout(setEditMode, 10, true, type);
}

private function stage_touchHandler(event:TouchEvent):void
{
	var touch:Touch = event.getTouch(this);
	if( touch == null || draggableCard == null )
		return;
	
	if( touch.phase == TouchPhase.BEGAN)
	{
		if( touch.target.parent == draggableCard )
			touchId = touch.id;
		dispatchEventWith(Event.READY, true, false);
	}
	else if( touch.phase == TouchPhase.MOVED )
	{
		if( touchId != touch.id )
			return;
		draggableCard.x = touch.globalX + paddingH;
		draggableCard.y = touch.globalY;
		deckHeader.getCardIndex(touch.globalX, touch.globalY);
	}
	else if( touch.phase == TouchPhase.ENDED)
	{
		var cardIndex:int = deckHeader.getCardIndex(touch.globalX, touch.globalY);
		if( touchId == -1 && cardIndex > -1 )
			Starling.juggler.tween(draggableCard, 0.2, {x:paddingH+deckHeader.cardsBounds[cardIndex].x+deckHeader.cardsBounds[cardIndex].width*0.5, y:deckHeader.cardsBounds[cardIndex].y+deckHeader.cardsBounds[cardIndex].height*0.5, onComplete:pushToDeck, onCompleteArgs:[cardIndex] });
		else
			pushToDeck(cardIndex);
	}
}
private function pushToDeck(cardIndex:int):void
{
	if( cardIndex == -1 )
	{
		setEditMode(false, -1);
		return;
	}
	deckHeader.cards[cardIndex].iconDisplay.type = draggableCard.type;
	player.getSelectedDeck().set(cardIndex, draggableCard.type);
	
	var params:SFSObject = new SFSObject();
	params.putInt("index", cardIndex);
	params.putInt("type", draggableCard.type);
	params.putInt("deckIndex", player.selectedDeckIndex);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.CHANGE_DECK, params);
	
	setEditMode(false, -1);
}

private function setEditMode(value:Boolean, type:int):void
{
	if( _editMode == value )
		return;
	
	_editMode = value;
	if( value )
	{
		scroller.scrollToPosition(0, 0);
		scroller.visible = false;
		deckHeader.removeEventListener(Event.SELECT, deckHeader_selectHandler);
		deckHeader.startHanging();
		
		draggableCard = new CardView();
		draggableCard.width = 240;
		draggableCard.showElixir = true;
		draggableCard.height = draggableCard.width * CardView.VERICAL_SCALE;
		draggableCard.pivotX = draggableCard.width * 0.5;
		draggableCard.pivotY = draggableCard.height * 0.5;
		draggableCard.x = width * 0.5;
		draggableCard.y = height * 0.7;
		draggableCard.alpha = 0;
		Starling.juggler.tween(draggableCard, 0.5, {alpha:1, y:stage.stageHeight * 0.6, transition:Transitions.EASE_OUT});
		addChild(draggableCard);
		draggableCard.type = type;
		
		addEventListener(TouchEvent.TOUCH, stage_touchHandler);
		return;
	}

	deckHeader.addEventListener(Event.SELECT, deckHeader_selectHandler);
	deckHeader.fix();
	draggableCard.removeFromParent(true);
	draggableCard = null;	
	touchId = -1;
	updateData();
	scroller.visible = true;
	scroller.alpha = 0;
	Starling.juggler.tween(scroller, 0.3, {alpha:1});
	removeEventListener(TouchEvent.TOUCH, stage_touchHandler);
	dispatchEventWith(Event.READY, true, true);
}

private function details_updateHandler(event:Event):void
{
	var cardType:int = event.data as int;
	if( !player.cards.exists(cardType) )
		return;
	
	var card:Card = player.cards.get(cardType);
	var confirmedHards:int = 0;
	if( !player.has(card.get_upgradeRequirements()) )
	{
		var confirm:RequirementConfirmPopup = new RequirementConfirmPopup(loc("popup_cardtogem_message"), card.get_upgradeRequirements());
		confirm.data = card;
		confirm.addEventListener(FeathersEventType.ERROR, upgradeConfirm_errorHandler);
		confirm.addEventListener(Event.SELECT, upgradeConfirm_selectHandler);
		appModel.navigator.addPopup(confirm);
		return;
	}
	
	seudUpgradeRequest(card, 0);
}
private function upgradeConfirm_errorHandler(event:Event):void
{
    appModel.navigator.gotoShop(ResourceType.R3_CURRENCY_SOFT);
    appModel.navigator.addLog(loc("log_not_enough", [loc("resource_title_" + ResourceType.R3_CURRENCY_SOFT)]));
    detailsPopup.close();
}
private function upgradeConfirm_selectHandler(event:Event):void
{
	var confirm:RequirementConfirmPopup = event.currentTarget as RequirementConfirmPopup;
	seudUpgradeRequest( confirm.data as Card, Exchanger.toHard(player.deductions(confirm.requirements)) );
}

private function seudUpgradeRequest(card:Card, confirmedHards:int):void
{
	if( selectPopup != null )
	{
		selectPopup.close();
		selectPopup = null;
	}
	
	if( !card.upgrade(confirmedHards) )
		return;
	
	var sfs:SFSObject = new SFSObject();
	sfs.putInt("type", card.type);
	sfs.putInt("confirmedHards", confirmedHards);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.CARD_UPGRADE, sfs);
	
	var upgradeOverlay:CardUpgradeOverlay = new CardUpgradeOverlay();
	upgradeOverlay.card = card;
	appModel.navigator.addOverlay(upgradeOverlay);
	
	deckHeader.update();
	updateData();
}		
}
}