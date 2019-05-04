package com.gerantech.towercraft.controls.segments
{
import com.gerantech.towercraft.controls.BuildingCard;
import com.gerantech.towercraft.controls.headers.DeckHeader;
import com.gerantech.towercraft.controls.items.CardItemRenderer;
import com.gerantech.towercraft.controls.overlays.BuildingUpgradeOverlay;
import com.gerantech.towercraft.controls.overlays.TransitionData;
import com.gerantech.towercraft.controls.popups.CardDetailsPopup;
import com.gerantech.towercraft.controls.popups.CardSelectPopup;
import com.gerantech.towercraft.controls.popups.RequirementConfirmPopup;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gt.towers.Player;
import com.gt.towers.battle.units.Card;
import com.gt.towers.constants.ResourceType;
import com.gt.towers.exchanges.Exchanger;
import com.gt.towers.scripts.ScriptEngine;
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
private var padding:int;
private var availableList:List;
private var unavailableList:List;
private var deckHeader:DeckHeader;
private var scroller:ScrollContainer;
private var draggableCard:BuildingCard;
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
	padding = 36;
	
	backgroundSkin = new Quad(1,1);
	backgroundSkin.alpha = 0;
	
	deckHeader = new DeckHeader();
	deckHeader.addEventListener(Event.SELECT, deckHeader_selectHandler);
	deckHeader.layoutData = new AnchorLayoutData(NaN, 0, NaN, 0);
	addChild(deckHeader);
	
	var scrollerLayout:VerticalLayout = new VerticalLayout();
	scrollerLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
	scrollerLayout.padding = scrollerLayout.gap = padding * 0.5;
	scrollerLayout.paddingTop = deckHeader._height + padding;
	
	scroller = new ScrollContainer();
	scroller.layout = scrollerLayout;
	scroller.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	scroller.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
	scroller.addEventListener(Event.SCROLL, scroller_scrollHandler);
	addChildAt(scroller, 0);
	

	//var deckSize:int = player.getSelectedDeck().keys().length;
	//var foundLabel:RTLLabel = new RTLLabel(loc("found_cards", [deckSize+foundCollection.length, deckSize+foundCollection.length ]), 0xBBCCDD, null, null, false, null, 0.8);
	//scroller.addChild(foundLabel);
	
	layout = new AnchorLayout();
	var foundLayout:TiledRowsLayout = new TiledRowsLayout();
	var unavailabledLayout:TiledRowsLayout = new TiledRowsLayout();
	unavailabledLayout.gap = foundLayout.gap = foundLayout.paddingTop = padding * 0.5;
	unavailabledLayout.verticalGap = foundLayout.verticalGap = padding * 2;
	unavailabledLayout.paddingBottom = foundLayout.paddingBottom = padding * 2;
	unavailabledLayout.useSquareTiles = foundLayout.useSquareTiles = false;
	unavailabledLayout.useVirtualLayout = foundLayout.useVirtualLayout = false;
	unavailabledLayout.requestedColumnCount = foundLayout.requestedColumnCount = 4;
	unavailabledLayout.typicalItemWidth = foundLayout.typicalItemWidth = (width - foundLayout.gap * (foundLayout.requestedColumnCount - 1) - padding * 2) / foundLayout.requestedColumnCount;
	unavailabledLayout.typicalItemHeight = foundLayout.typicalItemHeight = foundLayout.typicalItemWidth * BuildingCard.VERICAL_SCALE;

	availableList = new List();
	availableList.verticalScrollPolicy = ScrollPolicy.OFF;
	availableList.layout = foundLayout;
	availableList.itemRendererFactory = function():IListItemRenderer { return new CardItemRenderer(true, true, true, scroller); }
	availableList.dataProvider = availableCollection;
	availableList.addEventListener(FeathersEventType.FOCUS_IN, unlocksList_focusInHandler);
	scroller.addChild(availableList);
	
	if( unavailableCollection.length > 0 )
	{
		var unavailableLabel:RTLLabel = new RTLLabel(loc("unavailable_cards"), 0xBBCCDD, null, null, false, null, 0.8);
		unavailableLabel.layoutData = new AnchorLayoutData(deckHeader._height + availableList.height + padding * 4, padding, NaN, padding);
		scroller.addChild(unavailableLabel);	
		
		unavailableList = new List();
		unavailableList.verticalScrollPolicy = ScrollPolicy.OFF;
		unavailableList.alpha = 0.8;
		unavailableList.layout = unavailabledLayout;
		unavailableList.itemRendererFactory = function():IListItemRenderer { return new CardItemRenderer(false, false, false, scroller); }
		unavailableList.dataProvider = unavailableCollection;
		scroller.addChild(unavailableList);
	}
	
	initializeCompleted = true;
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
	deckHeader.y = Math.max( -deckHeader._height, Math.min(0, deckHeader.y + changes));
	deckHeader.visible = deckHeader.y > -deckHeader._height
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
	selectCard(item.data as int, item.getBounds(this));
}
private function deckHeader_selectHandler(event:Event):void
{
	var item:BuildingCard = event.data as BuildingCard;
	selectCard(item.type, item.getBounds(this));
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

private function touchHandler(event:TouchEvent):void
{
	var touch:Touch = event.getTouch(this);
	if( touch == null )
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
		draggableCard.x = touch.globalX;
		draggableCard.y = touch.globalY;
		deckHeader.getCardIndex(touch);
	}
	else if(touch.phase == TouchPhase.ENDED)
	{
		var cardIndex:int = deckHeader.getCardIndex(touch);
		if( touchId == -1 && cardIndex > -1 )
			Starling.juggler.tween(draggableCard, 0.2, {x:deckHeader.cardsBounds[cardIndex].x+deckHeader.cardsBounds[cardIndex].width*0.5, y:deckHeader.cardsBounds[cardIndex].y+deckHeader.cardsBounds[cardIndex].height*0.5, onComplete:pushToDeck, onCompleteArgs:[cardIndex] });
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
	deckHeader.cards[cardIndex].iconDisplay.setData(draggableCard.type);
	player.getSelectedDeck().set(cardIndex, draggableCard.type);
	
	var params:SFSObject = new SFSObject();
	params.putShort("index", cardIndex);
	params.putShort("type", draggableCard.type);
	params.putShort("deckIndex", player.selectedDeckIndex);
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
		
		draggableCard = new BuildingCard(false, false, false, false);
		draggableCard.width = 240;
		draggableCard.height = draggableCard.width * BuildingCard.VERICAL_SCALE;
		draggableCard.pivotX = draggableCard.width * 0.5;
		draggableCard.pivotY = draggableCard.height * 0.5;
		draggableCard.x = stage.stageWidth * 0.5;
		draggableCard.y = stage.stageHeight * 0.7;
		draggableCard.alpha = 0;
		Starling.juggler.tween(draggableCard, 0.5, {alpha:1, y:stage.stageHeight * 0.6, transition:Transitions.EASE_OUT});
		addChild(draggableCard);
		draggableCard.setData(type);
		
		addEventListener(TouchEvent.TOUCH, touchHandler);
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
	removeEventListener(TouchEvent.TOUCH, touchHandler);
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
	
	var upgradeOverlay:BuildingUpgradeOverlay = new BuildingUpgradeOverlay();
	upgradeOverlay.card = card;
	appModel.navigator.addOverlay(upgradeOverlay);
	
	deckHeader.update();
	updateData();
}		
}
}