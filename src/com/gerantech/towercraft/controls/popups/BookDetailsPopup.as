package com.gerantech.towercraft.controls.popups
{
import com.gerantech.towercraft.controls.buttons.MMOryButton;
import com.gerantech.towercraft.controls.groups.Devider;
import com.gerantech.towercraft.controls.groups.GradientHilight;
import com.gerantech.towercraft.controls.groups.HomeBooksLine;
import com.gerantech.towercraft.controls.groups.IconGroup;
import com.gerantech.towercraft.controls.overlays.OpenBookOverlay;
import com.gerantech.towercraft.controls.overlays.TransitionData;
import com.gerantech.towercraft.controls.screens.DashboardScreen;
import com.gerantech.towercraft.controls.texts.CountdownLabel;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.vo.UserData;
import com.gerantech.towercraft.themes.MainTheme;
import com.gerantech.towercraft.utils.StrUtils;
import com.gt.towers.constants.ExchangeType;
import com.gt.towers.constants.MessageTypes;
import com.gt.towers.constants.PrefsTypes;
import com.gt.towers.constants.ResourceType;
import com.gt.towers.exchanges.ExchangeItem;
import com.gt.towers.exchanges.Exchanger;
import dragonBones.events.EventObject;
import dragonBones.starling.StarlingArmatureDisplay;
import dragonBones.starling.StarlingEvent;
import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayoutData;
import feathers.layout.RelativePosition;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.setTimeout;
import starling.display.Image;
import starling.events.Event;

public class BookDetailsPopup extends SimpleHeaderPopup
{
private var item:ExchangeItem;
private var hilight:GradientHilight;
private var showButton:Boolean;
private var messageDisplay:RTLLabel;
private var actionButton:MMOryButton;
private var footerDisplay:ImageLoader;
private var countdownDisplay:CountdownLabel;
private var bookArmature:StarlingArmatureDisplay;
public function BookDetailsPopup(item:ExchangeItem, showButton:Boolean = true)
{
	super();
	this.item = item;
	this.hasCloseButton = false;
	this.showButton = showButton;
	this.title = loc("exchange_title_" + item.outcome);
}

override protected function initialize():void
{
	var _h:int = showButton ? 680 : 480;
	var _p:int = 32;
	var _b:int = stageHeight - DashboardScreen.FOOTER_SIZE - HomeBooksLine.HEIGHT - 54;
	transitionIn = new TransitionData();
	transitionOut = new TransitionData();
	transitionOut.destinationAlpha = 0;
	transitionIn.sourceBound = transitionOut.destinationBound = new Rectangle(_p,	_b - _h * 0.4,	stageWidth - _p * 2,	_h * 0.6);
	transitionOut.sourceBound = transitionIn.destinationBound = new Rectangle(_p,	_b - _h,		stageWidth - _p * 2,	_h * 1.0);
	
	super.initialize();

	var insideBG:Devider = new Devider(0x1E66C2);
	insideBG.height = 120;
	insideBG.layoutData = new AnchorLayoutData(80, 0, NaN, 0);
	addChild(insideBG);
	
	var arena:int = item.outcomes.get(item.outcome);
	var leagueDisplay:ShadowLabel = new ShadowLabel(loc("arena_text") + " " + loc("num_" + (arena + 1)), 0xBBDDFF, 0, null, null, false, null, 0.8);
	leagueDisplay.layoutData = new AnchorLayoutData(26, NaN, NaN, NaN, 220);
	addChild(leagueDisplay);
	
	titleDisplay.layoutData = new AnchorLayoutData(85, NaN, NaN, NaN, 220);

	var numCards:int = ExchangeType.getNumTotalCards(item.outcome, arena, player.splitTestCoef, 0);
	var cardsPalette:IconGroup = new IconGroup(Assets.getTexture("cards"), int(numCards * 0.9) + " - " + int(numCards * 1.1));
	cardsPalette.width = transitionIn.destinationBound.width * 0.42;
	cardsPalette.layoutData = new AnchorLayoutData(290, NaN, NaN, 50);
	addChild(cardsPalette);
	
	var numSofts:int = ExchangeType.getNumSofts(item.outcome, arena, player.splitTestCoef);
	var softsPalette:IconGroup = new IconGroup(Assets.getTexture("res-" + ResourceType.R3_CURRENCY_SOFT, "gui"), int(numSofts * 0.9) + " - " + int(numSofts * 1.1));
	softsPalette.textColor = 0xFFFF99;
	softsPalette.width = transitionIn.destinationBound.width * 0.42;
	softsPalette.layoutData = new AnchorLayoutData(290, 40);
	addChild(softsPalette);
		
	if( !showButton )
		return;
		
	update(state);
}

override protected function transitionInCompleted():void
{
	super.transitionInCompleted();
	
	// arrow
	var itemWidth:int = stageWidth * 0.25 - 12;
	var bottomArrowSkin:Image = new Image(appModel.theme.calloutBottomArrowSkinTexture);
	bottomArrowSkin.x = itemWidth * (item.type - 110.5) - bottomArrowSkin.width * 0.5 - transitionIn.destinationBound.x + 20;
	bottomArrowSkin.y = transitionIn.destinationBound.height - 2;
	bottomArrowSkin.color = 0xE3E3E3;
	addChild(bottomArrowSkin);
	
	OpenBookOverlay.createFactory();
	bookArmature = OpenBookOverlay.factory.buildArmatureDisplay(item.outcome.toString());
	bookArmature.addEventListener(EventObject.SOUND_EVENT, bookArmature_soundEventHandler);
	bookArmature.scale = OpenBookOverlay.getBookScale(item.outcome) * 1.4;
	bookArmature.animation.gotoAndPlayByTime("appear", 0, 1);
	bookArmature.x = 260;
	bookArmature.y = 50;
	addChildAt(bookArmature, 0);
	function bookArmature_soundEventHandler(event:StarlingEvent):void
	{
		bookArmature.removeEventListener(EventObject.SOUND_EVENT, bookArmature_soundEventHandler);
		addChild(bookArmature);
		appModel.sounds.addAndPlay(event.eventObject.name);
	}
	
	if( player.get_battleswins() < 4 )
	{
		UserData.instance.prefs.setInt(PrefsTypes.TUTOR, PrefsTypes.T_012_SLOT_OPENED);
		actionButton.showTutorHint();
	}
}

private function update(state:int):void 
{
	closeOnOverlay = closeWithKeyboard = player.getResource(ResourceType.R21_BOOK_OPENED_BATTLE) > 0;
	footerFactory(state);
}

//           -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- Factories -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
private function footerFactory(state:int):void 
{
	if( footerDisplay == null )
	{
		footerDisplay = new ImageLoader();
		footerDisplay.source = appModel.theme.roundMediumInnerSkin;
		footerDisplay.layoutData = new AnchorLayoutData(NaN, 12, 12, 12);
		footerDisplay.scale9Grid = MainTheme.ROUND_MEDIUM_SCALE9_GRID;
		footerDisplay.height = 200;
		addChild(footerDisplay);
	}
	footerDisplay.color = 0x87a8d0;
	
	if( actionButton == null )
	{
		actionButton = new MMOryButton();
		actionButton.width = 300;
		actionButton.height = 176;
		actionButton.iconSize = MMOryButton.DEFAULT_ICON_SIZE;
		actionButton.paddingBottom = 30;
		actionButton.paddingTop = 10;
		actionButton.addEventListener(Event.TRIGGERED, batton_triggeredHandler);
		addChild(actionButton);
	}
	actionButton.layoutData = new AnchorLayoutData(NaN, NaN, 20, NaN, 0);
	actionButton.styleName = MainTheme.STYLE_BUTTON_HILIGHT;
	
	var message:String = "";
	if( item.category == ExchangeType.C110_BATTLES )
	{
		if( state == ExchangeItem.CHEST_STATE_BUSY )
		{
			if( hilight == null )
			{
				hilight = new GradientHilight();
				hilight.direction = RelativePosition.RIGHT;
				hilight.loopMode = GradientHilight.LOOP_MODE_DIRECTIONAL;
				hilight.layoutData = footerDisplay.layoutData;
				hilight.height = footerDisplay.height;
				hilight.alpha = 0.5;
			}
			addChildAt(hilight, getChildIndex(footerDisplay) + 1);
			
			footerDisplay.color = 0x437a50;
			actionButton.styleName = MainTheme.STYLE_BUTTON_NORMAL;
			actionButton.layoutData = new AnchorLayoutData(NaN, 30, 20, NaN);
			actionButton.message = loc("skip_label");
			timeManager.addEventListener(Event.CHANGE, timeManager_changeHandler);
			updateButton(ResourceType.R4_CURRENCY_HARD, Exchanger.timeToHard(item.expiredAt - timeManager.now));
			message = loc("popup_chest_message_skip", [Exchanger.timeToHard(item.expiredAt - timeManager.now)]);
			countdownFactory(state);
		}
		else if( state == ExchangeItem.CHEST_STATE_WAIT )
		{
			var free:Boolean = exchanger.isBattleBookReady(item.type, timeManager.now) == MessageTypes.RESPONSE_SUCCEED;
			actionButton.layoutData = new AnchorLayoutData(NaN, free ? NaN : 30, 20, NaN, free ? 0 : NaN);
			actionButton.styleName = free ? MainTheme.STYLE_BUTTON_HILIGHT : MainTheme.STYLE_BUTTON_NORMAL;
			actionButton.iconPosition = RelativePosition.LEFT;
			if( free )
				updateButton( -2, StrUtils.getSimpleTimeFormat(ExchangeType.getCooldown(item.outcome))); 
			else
				updateButton(ResourceType.R4_CURRENCY_HARD, Exchanger.timeToHard(ExchangeType.getCooldown(item.outcome)));
			
			// message ......
			if( !free && messageDisplay == null )
			{
				messageDisplay = new ShadowLabel(loc("popup_chest_error_exists"), free ? 1 : 0xFF1144, 0, null, null, false, null, 0.85);
				messageDisplay.layoutData = new AnchorLayoutData(NaN, NaN, 80, NaN, -160);
				addChild(messageDisplay);
			}
			
			actionButton.message = loc(free ? "start_open_label" : "skip_label");
			actionButton.messagePosition = free ? RelativePosition.TOP : RelativePosition.BOTTOM;
		}
		else if( state == ExchangeItem.CHEST_STATE_READY )
		{
			actionButton.message = null;
			updateButton(-1, -2);
		}
	}
	else
	{
		footerDisplay.color = 0x437a50;
		actionButton.styleName = MainTheme.STYLE_BUTTON_NORMAL;
		updateButton(ResourceType.R4_CURRENCY_HARD, item.requirements.get(ResourceType.R4_CURRENCY_HARD));
	}
}

private function countdownFactory(state:int):void
{
	if( state != ExchangeItem.CHEST_STATE_BUSY )
	{
		if( countdownDisplay != null )
		{
			countdownDisplay.removeFromParent();
			countdownDisplay = null;
		}
		return;
	}
	if( countdownDisplay == null )
	{
		countdownDisplay = new CountdownLabel();
		countdownDisplay.width = 400;
		countdownDisplay.height = 120;
		countdownDisplay.layoutData = new AnchorLayoutData(NaN, NaN, 45, NaN, -150);
		addChild(countdownDisplay);
	}
	var t:uint = uint(item.expiredAt - timeManager.now);
	countdownDisplay.time = t;
	//updateButton(ResourceType.R4_CURRENCY_HARD , Exchanger.timeToHard(t));
	//buttonDisplay.count = Exchanger.timeToHard(t);
	//messageDisplay.text = loc("popup_chest_message_skip", [Exchanger.timeToHard(t)])
}

private function updateButton(type:int, count:*):void
{
	actionButton.iconTexture = MMOryButton.getIcon(type, count);
	actionButton.label = MMOryButton.getLabel(type, count);
}

//           -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- Handlers -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
protected function timeManager_changeHandler(event:Event):void
{
	updateButton(ResourceType.R4_CURRENCY_HARD, Exchanger.timeToHard(item.expiredAt - timeManager.now));
	var _state:int = state;
	countdownFactory(_state);
	if( _state == ExchangeItem.CHEST_STATE_READY )
	{
		timeManager.removeEventListener(Event.CHANGE, timeManager_changeHandler);
		update(_state);
	}
}

protected function batton_selectHandler(event:Event):void
{
	var res:int = exchanger.isBattleBookReady(item.type, timeManager.now);
	if( res == MessageTypes.RESPONSE_ALREADY_SENT )
		appModel.navigator.addLog(loc("popup_chest_error_exists"));
	else
		appModel.navigator.addLog(loc("popup_chest_error_resource"));
}

protected function batton_triggeredHandler(event:Event) : void
{
	dispatchEventWith(Event.SELECT, false, item);
	if( state == ExchangeItem.CHEST_STATE_BUSY )
	{
		update(state);
		if( player.get_battleswins() < 4 )
			setTimeout(actionButton.showTutorHint, 100);
		return;
	}
	close();
}

//           -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- Properties -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
public function get state() : int 
{
	if( item == null )
		return ExchangeItem.CHEST_STATE_EMPTY;
	return item.getState(timeManager.now);
}

override public function dispose():void
{
	if( actionButton != null )
		actionButton.removeEventListener(Event.TRIGGERED, batton_triggeredHandler);
	timeManager.removeEventListener(Event.CHANGE, timeManager_changeHandler);
	super.dispose();
}
}
}