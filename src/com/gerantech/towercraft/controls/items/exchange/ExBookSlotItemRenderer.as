package com.gerantech.towercraft.controls.items.exchange
{
import com.gerantech.towercraft.controls.buttons.ExchangeButton;
import com.gerantech.towercraft.controls.groups.GradientHilight;
import com.gerantech.towercraft.controls.overlays.HandPoint;
import com.gerantech.towercraft.controls.overlays.OpenBookOverlay;
import com.gerantech.towercraft.controls.texts.CountdownLabel;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.vo.RewardData;
import com.gerantech.towercraft.utils.StrUtils;
import com.gt.towers.constants.ExchangeType;
import com.gt.towers.constants.PrefsTypes;
import com.gt.towers.constants.ResourceType;
import com.gt.towers.exchanges.ExchangeItem;
import com.gt.towers.exchanges.Exchanger;
import dragonBones.events.EventObject;
import dragonBones.starling.StarlingArmatureDisplay;
import dragonBones.starling.StarlingEvent;
import feathers.controls.ImageLoader;
import feathers.controls.LayoutGroup;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import flash.geom.Rectangle;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.events.Event;

public class ExBookSlotItemRenderer extends ExBookBaseItemRenderer
{
private var state:int = -2;
private var countdownDisplay:CountdownLabel;
private var backgroundDisplay:ImageLoader;
private var emptyLabel:RTLLabel;
private var waitGroup:LayoutGroup;
private var busyGroup:LayoutGroup;
private var readyLabel:ShadowLabel;
private var timeoutId:uint;
private var hardLabel:ShadowLabel;
private var handPoint:HandPoint;
private var ribbonImage:ImageLoader;
private var hilight:GradientHilight;

public function ExBookSlotItemRenderer(){}
override protected function initialize():void
{
	super.initialize();
	padding = 16;
	backgroundSkin = skin = null;
}
override protected function commitData():void
{
	if( index < 0 || _data == null )
		return;
	reset();
	
	if( firstCommit )
		exchangeManager.addEventListener(FeathersEventType.BEGIN_INTERACTION, exchangeManager_beginInteractionHandler);
	exchange = exchanger.items.get(_data as int);
	if( exchange == null )
		return;
	state = exchange.getState(timeManager.now);
	backgroundFactory();
	super.commitData();
	emptyGroupFactory();
	waitGroupFactory();
	busyGroupFactory();
	readyGroupFactory();
	
	if( state == ExchangeItem.CHEST_STATE_BUSY )
	{
		timeManager.addEventListener(Event.CHANGE, timeManager_changeHandler);
		timeManager_changeHandler(null);
	}
	else if( state == ExchangeItem.CHEST_STATE_READY && player.getTutorStep() == PrefsTypes.T_012_SLOT_OPENED )
	{
		showTutorArrow();
	}
	else if( state == ExchangeItem.CHEST_STATE_WAIT && player.getResource(ResourceType.R21_BOOK_OPENED_BATTLE) == 0 )
	{
		showTutorArrow();
	}
	
	// show book falling
	owner.addEventListener(FeathersEventType.CREATION_COMPLETE, createComplteHandler);
}

private function createComplteHandler(event:Event):void 
{
	event.currentTarget.removeEventListener(FeathersEventType.CREATION_COMPLETE, createComplteHandler);
	setTimeout(achieve, 10);
}

/**
 * add, remove or update armature depends on type and state
 */
override protected function bookFactory() : StarlingArmatureDisplay
{
	clearTimeout(timeoutId);
	if( state != ExchangeItem.CHEST_STATE_EMPTY ) 
	{
		bookArmature = OpenBookOverlay.factory.buildArmatureDisplay( exchange.outcome.toString() );
		bookArmature.scale = OpenBookOverlay.getBookScale(exchange.outcome) * 0.68;
		bookArmature.x = width * 0.53;
		bookArmature.y = height * 0.70;
		if( state == ExchangeItem.CHEST_STATE_READY )
		{
			timeoutId = setTimeout(bookArmature.animation.gotoAndPlayByTime, Math.random() * 2000, "wait", 0, 100);
		}
		else
		{
			bookArmature.animation.gotoAndStopByProgress("appear", 1);
			bookArmature.animation.timeScale = 0;
		}
		addChild(bookArmature);
	}
	return bookArmature;
}

override protected function buttonFactory() : ExchangeButton
{
	return null;
}

protected function backgroundFactory() : ImageLoader
{
	var st:int = Math.max(0, state);
	if( backgroundDisplay == null )
	{
		backgroundDisplay = new ImageLoader();
		backgroundDisplay.layoutData = new AnchorLayoutData(0, 0, 0, 0);
		backgroundDisplay.scale9Grid = new Rectangle(39, 43, 6, 34);
	}
	addChild(backgroundDisplay);
	backgroundDisplay.source = Assets.getTexture("home/slot-" + st, "gui");
	
	if( state != ExchangeItem.CHEST_STATE_BUSY )
		return backgroundDisplay;
	if( hilight == null )
	{
		hilight = new GradientHilight();
		hilight.layoutData = new AnchorLayoutData(10, 12, 10, 12);
		hilight.alpha = 0.5;
		/*var mask:ImageLoader = new ImageLoader();
		mask.source = backgroundDisplay.source;
		mask.layoutData = backgroundDisplay.layoutData;
		mask.scale9Grid = backgroundDisplay.scale9Grid;
		mask.maskInverted = true
		hilight.mask = mask;
		addChild(mask);*/
	}
	addChild(hilight);
	return backgroundDisplay;
}
protected function emptyGroupFactory() : RTLLabel 
{
	if( state != ExchangeItem.CHEST_STATE_EMPTY )
		return null;
	if( emptyLabel == null )
	{
		emptyLabel = new RTLLabel(loc("empty_label"), 0xFFFFFF);
		emptyLabel.alpha = 0.4;
		emptyLabel.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, 0);
	}
	addChild(emptyLabel);
	return emptyLabel;
}
protected function waitGroupFactory() : LayoutGroup 
{
	if( state != ExchangeItem.CHEST_STATE_WAIT )
		return null;
	if( waitGroup == null )
	{
		waitGroup = new LayoutGroup();
		waitGroup.layout = new AnchorLayout();
		waitGroup.layoutData = new AnchorLayoutData(0, 0, 0, 0);
		
		showOpenWarn();
		
		var timeLabel:ShadowLabel = new ShadowLabel(StrUtils.getSimpleTimeFormat(ExchangeType.getCooldown(exchange.outcome)), 1, 0, null, null, false, null, 0.9);
		timeLabel.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, -height * 0.13);
		waitGroup.addChild(timeLabel);
	}
	addChild(waitGroup);
	return waitGroup;
}

private function showOpenWarn() : void 
{
	if( state != ExchangeItem.CHEST_STATE_WAIT || waitGroup == null )
		return;
	var busySlot:ExchangeItem = exchanger.findItem(ExchangeType.C110_BATTLES, ExchangeItem.CHEST_STATE_BUSY, timeManager.now);
	if( busySlot != null )
	{
		
		if( ribbonImage != null )
		{
			Starling.juggler.removeTweens(ribbonImage);
			ribbonImage.removeFromParent(true);
		}
		return;
	}
	
	ribbonImage = new ImageLoader();
	ribbonImage.width = 180;
	ribbonImage.pixelSnapping = false;
	ribbonImage.scale9Grid = new Rectangle(24, 0, 3, 0)
	ribbonImage.source = Assets.getTexture("home/open-ribbon");
	ribbonImage.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0);
	waitGroup.addChild(ribbonImage);
	
	var openLabel:ShadowLabel = new ShadowLabel(loc("tap_label"), 1, 0, "center", null, false, null, 0.65);
	openLabel.layoutData = new AnchorLayoutData(10, NaN, NaN, NaN, 0);
	waitGroup.addChild(openLabel);

	Starling.juggler.removeTweens(ribbonImage);
	ribbonImage.y = -4;
	ribbonImage.scaleY = 1;
	up();
	function up()	: void { Starling.juggler.tween(ribbonImage, 1.5, {scaleY:0.95, y:-4,	transition:Transitions.EASE_OUT,onComplete:down,	delay:0}); }
	function down() : void { Starling.juggler.tween(ribbonImage, 0.3, {scaleY:1.10, y:4,	transition:Transitions.EASE_IN,	onComplete:up,		delay:Math.random() * 3}); }
}

protected function busyGroupFactory() : LayoutGroup
{
	if( state != ExchangeItem.CHEST_STATE_BUSY )
		return null;
	
	if( busyGroup == null )
	{
		busyGroup = new LayoutGroup();
		busyGroup.layout = new AnchorLayout();
		busyGroup.layoutData = new AnchorLayoutData(0, 0, 0, 0);
		
		var hardImage:ImageLoader = new ImageLoader();
		hardImage.source = Assets.getTexture("res-" + ResourceType.R4_CURRENCY_HARD, "gui");
		hardImage.width = height * 0.2;
		hardImage.layoutData = new AnchorLayoutData(padding * 5, NaN, NaN, NaN, -padding * 2.2);
		busyGroup.addChild(hardImage);
		
		countdownDisplay = new CountdownLabel();
		countdownDisplay.layoutData = new AnchorLayoutData(padding * 0.6, padding, NaN, padding * 0.4);
		busyGroup.addChild(countdownDisplay);
		
		hardLabel = new ShadowLabel("", 1, 0, null, null, false, null, 0.9);
		hardLabel.layoutData = new AnchorLayoutData(padding * 5, NaN, NaN, NaN, padding * 2);
		busyGroup.addChild(hardLabel);
	}

	addChild(busyGroup);
	return busyGroup;
}

protected function readyGroupFactory() : ShadowLabel 
{
	if( state != ExchangeItem.CHEST_STATE_READY )
		return null;
	if( readyLabel == null )
	{
		readyLabel = new  ShadowLabel(loc("open_label"));
		readyLabel.shadowDistance = padding * 0.25;
		readyLabel.layoutData = new AnchorLayoutData(padding * 2, NaN, NaN, NaN, 0);
	}
	addChild(readyLabel);
	return readyLabel;
}

protected function timeManager_changeHandler(event:Event):void
{
	if(	exchange.getState(timeManager.now) != ExchangeItem.CHEST_STATE_BUSY )
	{
		commitData();
		exchangeManager.dispatchEventWith(FeathersEventType.BEGIN_INTERACTION, false, exchange);
		return;
	}
	
	var t:uint = uint(exchange.expiredAt - timeManager.now);//trace(index, t)
	
	if( hardLabel != null )
		hardLabel.text = StrUtils.getNumber(Exchanger.timeToHard(t));
	
	if( countdownDisplay != null )
		countdownDisplay.time = t;
}

private function achieve():void 
{
	if( appModel.battleFieldView == null || appModel.battleFieldView.battleData == null || appModel.battleFieldView.battleData.outcomes == null )
		return;
	
	var achieved:int =-1;
	var rd:RewardData;
	for ( var i:int = 0; i < appModel.battleFieldView.battleData.outcomes.length; i++ )
	{
		rd = appModel.battleFieldView.battleData.outcomes[i];
		if ( rd.value == exchange.type )
		{
			achieved = i;
			break;
		}
	}

	if( achieved == -1 )
		return;

	if( emptyLabel != null )
		emptyLabel.removeFromParent();
	var bookAnimation:StarlingArmatureDisplay = OpenBookOverlay.factory.buildArmatureDisplay( rd.key.toString() );
	bookAnimation.scale = OpenBookOverlay.getBookScale(exchange.outcome) * 1.9;
	bookAnimation.animation.gotoAndPlayByFrame("appear", 0, 1);
	bookAnimation.animation.timeScale = 0.5;
	bookAnimation.x = rd.x;
	bookAnimation.y = rd.y;
	bookAnimation.addEventListener(EventObject.COMPLETE, bookAnimation_completeHandler);
	appModel.navigator.addChild(bookAnimation);
	var globalPos:Rectangle = this.getBounds(stage);
	Starling.juggler.tween(bookAnimation, 0.5, {delay:0.5, x:globalPos.x + width * 0.53, scale:OpenBookOverlay.getBookScale(exchange.outcome) * 0.68, transition:Transitions.EASE_IN_OUT});
	Starling.juggler.tween(bookAnimation, 0.5, {delay:0.5, y:globalPos.y + height * 0.65, transition:Transitions.EASE_IN_BACK});
	function bookAnimation_completeHandler(event:StarlingEvent):void
	{
		bookAnimation.removeFromParent(true);
		exchange.expiredAt = 0;
		exchange.outcome = rd.key;
		exchange.outcomes.set(rd.key, player.get_arena(0));
		commitData();
	}
	
	appModel.battleFieldView.battleData.outcomes.removeAt(achieved);
}

private function showTutorArrow () : void
{
	if( handPoint != null )
		handPoint.removeFromParent(true);
	
	handPoint = new HandPoint(width * 0.5, 0);
//	handPoint.layoutData = new AnchorLayoutData(isUp ? NaN : 0, NaN, isUp ? -handPoint._height : NaN, NaN, 0);
	setTimeout(addChild, 200, handPoint);
}
override public function set isSelected(value:Boolean):void
{
	if( value == super.isSelected )
		return;
	super.isSelected = value;
	if( handPoint != null )
		handPoint.removeFromParent(true);
}

private function reset() : void
{
	//tutorials.removeEventListener(GameEvent.TUTORIAL_TASKS_FINISH, tutorialManager_finishHandler);
	timeManager.removeEventListener(Event.CHANGE, timeManager_changeHandler);
	removeChildren(0, -1);
	backgroundDisplay = null;
	bookArmature = null;
	buttonDisplay = null;
	countdownDisplay = null;
	waitGroup = null;
	readyLabel = null;
	clearTimeout(timeoutId);
}


override protected function resetData(item:ExchangeItem):void 
{
	showOpenWarn();
	super.resetData(item);
}

override protected function showAchieveAnimation(item:ExchangeItem):void {}
override protected function exchangeManager_endInteractionHandler(event:Event):void {}
protected function exchangeManager_beginInteractionHandler(event:Event):void 
{
	resetData(event.data as ExchangeItem);
}
override public function dispose():void
{
	reset();
	super.dispose();
}
}
}