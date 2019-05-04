package com.gerantech.towercraft.controls.items.challenges 
{
import com.gerantech.towercraft.controls.buttons.IconButton;
import com.gerantech.towercraft.controls.buttons.SimpleLayoutButton;
import com.gerantech.towercraft.controls.items.AbstractListItemRenderer;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.controls.tooltips.BaseTooltip;
import com.gerantech.towercraft.events.GameEvent;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.vo.UserData;
import com.gerantech.towercraft.utils.StrUtils;
import com.gt.towers.constants.PrefsTypes;
import com.gt.towers.socials.Challenge;
import feathers.controls.ButtonState;
import feathers.controls.ImageLoader;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.VerticalLayout;
import flash.geom.Rectangle;
import starling.core.Starling;
import starling.events.Event;

/**
* @author Mansour Djawadi
*/
public class ChallengeIndexItemRenderer extends AbstractListItemRenderer
{
static public var ARENA:int;
static public var IN_HOME:Boolean;
static public var SHOW_INFO:Boolean;
static private const BG_SCALE_GRID:Rectangle = new Rectangle(23, 22, 2, 2);
static private const COLORS:Array = [0x30e465, 0xffa400, 0xff4200, 0xe720ff];

private var state:int;
private var chIndex:int;
private var locked:Boolean;
private var backgroundImage:SimpleLayoutButton;
private var backgroundLayoutData:AnchorLayoutData;
private var iconDisplay:ImageLoader;
private var challenge:Challenge;
private var titleDisplay:RTLLabel;
private var messageDisplay:RTLLabel;
private var bannerDisplay:ImageLoader;
private var infoButton:IconButton;
private var rankButton:IconButton;
private var costIconDisplay:ImageLoader;
private var costLabelDisplay:ShadowLabel;
public function ChallengeIndexItemRenderer() { super(); }
override protected function initialize() : void
{
	super.initialize();
	layout = new AnchorLayout();
	tutorials.addEventListener(GameEvent.TUTORIAL_TASKS_FINISH, tutorials_completeHandler);
}

override protected function commitData() : void 
{
	super.commitData();
	height = VerticalLayout(_owner.layout).typicalItemHeight;

	challenge = player.challenges.get(_data as int);
	state = challenge.getState(timeManager.now);
	chIndex = IN_HOME ? UserData.instance.challengeIndex : index;
	locked = Challenge.getUnlockAt(index) > ARENA;
	challenge.mode = Challenge.getMode(chIndex);
	
	backgroundFactory();
	iconFactory();
	bannerFactory();
	infoFactory();
	rankingFactory();
	titleFactory();
	messageFactory();
	costFactory();
	
	alpha = 0;
	Starling.juggler.tween(this, 0.25, {delay:Math.log(index + 1) * 0.2, alpha:1});
}

private function costFactory() : void 
{
	if( locked )
		return;
	challenge.runRequirements = Challenge.getRunRequiements(chIndex);
	var costType:int = challenge.runRequirements.keys()[0];
	var costValue:int = challenge.runRequirements.get(costType);
	if( costValue <= 0 )
		return;
	
	if( costIconDisplay == null )
	{
		costIconDisplay = new ImageLoader();
		costIconDisplay.touchable = false;
		costIconDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR ? 10 : NaN, 70, appModel.isLTR ? NaN : 56);
		costIconDisplay.width = costIconDisplay.height = 78;
		addChild(costIconDisplay);
	}
	costIconDisplay.source = Assets.getTexture("res-" + costType, "gui");
	
	if( costLabelDisplay == null )
	{
		costLabelDisplay = new ShadowLabel(null, 1, 0, "center", null, false, null, 1.25);
		costLabelDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR ? 80 : NaN, 48, appModel.isLTR ? NaN : 24);
		costLabelDisplay.touchable = false;
		costLabelDisplay.width = 40;
		addChild(costLabelDisplay);
	}
	costLabelDisplay.text = StrUtils.getNumber(costValue);
}

private function infoFactory() : void
{
	if( !SHOW_INFO || locked || infoButton != null )
		return;
	infoButton = new IconButton(Assets.getTexture("events/info"), 0.6, Assets.getTexture("events/badge"));
	infoButton.name = challenge.mode.toString();
	infoButton.width = 96;
	infoButton.height = 103;
	infoButton.layoutData = new AnchorLayoutData(-24, appModel.isLTR? -24 : NaN, NaN, appModel.isLTR? NaN : -24);
	infoButton.addEventListener(Event.TRIGGERED, infoButton_triggeredHandler);
	addChild(infoButton);
}

private function rankingFactory() : void
{
	if( challenge.type != Challenge.TYPE_2_RANKING || locked || rankButton != null )
		return;
	rankButton = new IconButton(Assets.getTexture("home/ranking"), 0.6, Assets.getTexture("events/badge"));
	rankButton.width = 96;
	rankButton.height = 103;
	rankButton.layoutData = new AnchorLayoutData(-24, appModel.isLTR? 100 : NaN, NaN, appModel.isLTR? NaN : 100);
	addChild(rankButton);
}

private function bannerFactory() : void
{
	if( bannerDisplay == null )
	{
		bannerDisplay = new ImageLoader();
		bannerDisplay.touchable = false;
		bannerDisplay.maintainAspectRatio = false;
		bannerDisplay.layoutData = new AnchorLayoutData(150, 11, 60, 11);
		addChild(bannerDisplay);
	}
	bannerDisplay.source = Assets.getTexture(locked ? "events/banner-locked" : "events/banner-" + chIndex, "gui");
}

private function backgroundFactory() : void
{
	if( backgroundImage == null )
	{
		backgroundLayoutData = new AnchorLayoutData(0, 0, 0, 0);
		backgroundImage = new SimpleLayoutButton();
		backgroundImage.layoutData = backgroundLayoutData;
		backgroundImage.backgroundSkin = new ImageLoader();
		backgroundImage.addEventListener(Event.TRIGGERED, backgroundImage_triggerdHandler);
		backgroundImage.addEventListener(FeathersEventType.STATE_CHANGE, backgroundImage_stateChangeHandler);
		ImageLoader(backgroundImage.backgroundSkin).scale9Grid = BG_SCALE_GRID;
		addChild(backgroundImage);
	}
	ImageLoader(backgroundImage.backgroundSkin).source = Assets.getTexture("events/index-bg-" + chIndex + "-up", "gui");
}

private function iconFactory() : void
{
	if( iconDisplay == null )
	{
		iconDisplay = new ImageLoader();
		iconDisplay.touchable = false;
		iconDisplay.width = iconDisplay.height = 150;
		iconDisplay.layoutData = new AnchorLayoutData(10, appModel.isLTR ? NaN : 10, NaN, appModel.isLTR ? 10 : NaN);
		addChild(iconDisplay);
	}
	
	if( locked )
		iconDisplay.source = Assets.getTexture("events/lock", "gui");
	else
		iconDisplay.source = Assets.getTexture("events/type-" + challenge.mode, "gui");
}

private function titleFactory() : void
{
	if( titleDisplay == null )
	{
		titleDisplay = new RTLLabel(null, COLORS[chIndex], null, null, false, null, 0.9);
		titleDisplay.layoutData = new AnchorLayoutData(12, appModel.isLTR ? NaN : 160, NaN, appModel.isLTR ? 160 : NaN);
		titleDisplay.touchable = false;
		addChild(titleDisplay);
	}
	titleDisplay.text = locked ? loc("challenge_label", [loc("num_" + (chIndex + 1))]) : loc("challenge_title_" + challenge.mode);
}

private function messageFactory() : void
{
	if( messageDisplay == null )
	{
		messageDisplay = new RTLLabel(null, 1, null, null, false, null, 0.7);
		messageDisplay.touchable = false;
		messageDisplay.layoutData = new AnchorLayoutData(76, appModel.isLTR ? NaN : 160, NaN, appModel.isLTR ? 160 : NaN);
		addChild(messageDisplay);
	}
	messageDisplay.text = locked ? loc("challenge_locked") : loc("challenge_message_" + challenge.mode);
}

protected function backgroundImage_stateChangeHandler(event:Event) : void
{
	backgroundLayoutData.top = backgroundLayoutData.right = backgroundLayoutData.left = backgroundLayoutData.bottom = event.data == ButtonState.DOWN ? 4 : 0;
}
protected function backgroundImage_triggerdHandler(event:Event) : void
{
	if( locked )
	{
		var point:int = game.arenas.get(Challenge.getUnlockAt(chIndex)).min - 1;
		appModel.navigator.addLog(loc("availableuntil_messeage", [loc("resource_title_2") + " " + point, ""]));
		return;
	}
	
	_owner.dispatchEventWith(Event.TRIGGERED, false, chIndex);
}

protected function infoButton_triggeredHandler(event:Event) : void
{
	appModel.navigator.addChild(new BaseTooltip(loc("challenge_info_" + int(infoButton.name)), infoButton.getBounds(stage)));
}

protected function tutorials_completeHandler(event:Event) : void 
{
	if( event.data.name != "challenge_tutorial" )
		return;
	tutorials.removeEventListener(GameEvent.TUTORIAL_TASKS_FINISH, tutorials_completeHandler);
	if ( (player.getTutorStep() == PrefsTypes.T_72_NAME_SELECTED && index == 0) || (player.getTutorStep() == PrefsTypes.T_73_CHALLENGES_SHOWN && index == 1) )
		backgroundImage.showTutorHint();
}
}
}