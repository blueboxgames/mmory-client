package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.buttons.Indicator;
import com.gerantech.towercraft.controls.groups.ColorGroup;
import com.gerantech.towercraft.controls.groups.RewardsPalette;
import com.gerantech.towercraft.controls.sliders.LabeledProgressBar;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.vo.UserData;
import com.gerantech.towercraft.themes.MainTheme;
import com.gerantech.towercraft.utils.StrUtils;
import com.gt.towers.constants.PrefsTypes;
import com.gt.towers.others.Quest;
import feathers.controls.ImageLoader;
import feathers.controls.ProgressBar;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import flash.geom.Rectangle;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;
import starling.events.Event;

public class QuestItemRenderer extends AbstractTouchableListItemRenderer
{
static public var HEIGHT:int = 400;
static private var PADDING:int = 30;
static private var SCALE_GRID:Rectangle = new Rectangle(48, 36, 2, 2);
public var quest:Quest;
private var passed:Boolean;
private var skinLayout:AnchorLayoutData;
private var backgroundDisplay:ImageLoader;
private var iconDisplay:ImageLoader;
private var titleDisplay:ShadowLabel;
private var messageDisplay:RTLLabel;
private var rewardPalette:RewardsPalette;
private var progressBarDisplay:LabeledProgressBar;

public function QuestItemRenderer(){}
override protected function initialize():void
{
	super.initialize();
	this.height = HEIGHT; 
	layout = new AnchorLayout();
	
	skinLayout = new AnchorLayoutData(-10, -10, -10, -10);
	backgroundDisplay = new ImageLoader();
	backgroundDisplay.scale9Grid = SCALE_GRID;
	backgroundDisplay.layoutData = skinLayout;
	addChild(backgroundDisplay);
	
	iconDisplay = new ImageLoader();
	iconDisplay.layoutData = new AnchorLayoutData(NaN, 0);
	iconDisplay.width = 180;
	iconDisplay.height = 120;
	addChild(iconDisplay);
	
	var messageBG:ImageLoader = new ImageLoader();
	messageBG.source = appModel.theme.roundMediumInnerSkin;
	messageBG.scale9Grid = MainTheme.ROUND_MEDIUM_SCALE9_GRID;
	messageBG.layoutData = new AnchorLayoutData(120, appModel.isLTR?300:PADDING, NaN, appModel.isLTR?PADDING:300);
	messageBG.height = 140;
	addChild(messageBG);
	
	rewardPalette = new RewardsPalette();
	rewardPalette.label = loc("quest_rewards");
	rewardPalette.width = 240;
	rewardPalette.height = 140;
	rewardPalette.layoutData = new AnchorLayoutData(120, appModel.isLTR?PADDING:NaN, NaN, appModel.isLTR?NaN:PADDING);
	addChild(rewardPalette);
	
	titleDisplay = new ShadowLabel(null, 1, 0, null, null, false, null, 0.85);
	titleDisplay.layoutData = new AnchorLayoutData(24, 170, NaN, PADDING);
	addChild(titleDisplay);
	
	messageDisplay = new RTLLabel("", 0, "center", null, true, null, 0.65);
	messageDisplay.touchable = false;
	messageDisplay.layoutData = new AnchorLayoutData(140, appModel.isLTR?316:PADDING * 2, NaN, appModel.isLTR?PADDING * 2:316);
	addChild(messageDisplay);
	
	progressBarDisplay = new LabeledProgressBar();
	progressBarDisplay.layoutData = new AnchorLayoutData(NaN, PADDING, PADDING * 2, PADDING);
	progressBarDisplay.height = 54;
	progressBarDisplay.formatValueFactory = function(value:Number, minimum:Number, maximum:Number) : String
	{
		return StrUtils.getNumber(value + "/" + maximum);
	}
	addChild(progressBarDisplay);
}

override protected function commitData():void
{
	super.commitData();
	removeTweens();
	if( _data == null || _owner == null )
		return;
	
	this.height = HEIGHT;
	alpha = 1;
	quest = _data as Quest;
	passed = quest.passed();
	
	backgroundDisplay.source = Assets.getTexture("quest-item-bg-" + (passed ? "hilight" : "neutral"), "gui");
	
	var iconStr:String = QuestItemRenderer.getIcon(quest.type);
	iconDisplay.source = Assets.getTexture(iconStr, "gui");
	iconDisplay.height = iconStr.substr(0,9) == "home/dash-tab-" ? 160 : 120;
	iconDisplay.y = iconStr.substr(0,9) == "home/dash-tab-" ? -PADDING * 2 : 0;
	
	if( quest.type == Quest.TYPE_7_CARD_COLLECT || quest.type == Quest.TYPE_8_CARD_UPGRADE )
		titleDisplay.text = loc("quest_title_" + quest.type, [loc("card_title_" + quest.key), quest.target]);
	else if( quest.type == Quest.TYPE_6_CHALLENGES )
		titleDisplay.text = loc("quest_title_" + quest.type, [quest.target, loc("challenge_title_" + (quest.key - 31))]);
	else if( quest.type == Quest.TYPE_9_BOOK_OPEN )
		titleDisplay.text = loc("quest_title_" + quest.type, [quest.target, loc("resource_title_" + quest.key)]);
	else
		titleDisplay.text = loc("quest_title_" + quest.type, [quest.target]);
	
	messageDisplay.text = loc("quest_message_" + quest.type);
	rewardPalette.setRewards(quest.rewards);
	progressBarDisplay.visible = !passed;
	if( progressBarDisplay.visible )
	{
		progressBarDisplay.maximum = quest.target;
		progressBarDisplay.value = Math.round( quest.current );
		//sliderDisplay.addChild(sliderDisplay.labelDisplay);	
		progressBarDisplay.isEnabled = true;
	}

	if( passed )
		punchscale(-20);

	/*if( player.getTutorStep() == PrefsTypes.T_161_QUEST_FOCUS && quest.type == Quest.TYPE_3_BATTLES && quest.nextStep == 1 )
	{
		UserData.instance.prefs.setInt(PrefsTypes.TUTOR, PrefsTypes.T_162_QUEST_SHOWN);
		actionButton.showTutorHint();
	}*/
}

private function punchscale(p:int) : void 
{
	Starling.juggler.tween(skinLayout, 1, {top:p, left:p, bottom:p, right:p, transition:Transitions.EASE_IN_OUT, onComplete:punchscale, onCompleteArgs:[p == -10 ? -20 : -10]});
}

public function hide():void 
{
	touchable = false;
	removeTweens();
	Starling.juggler.tween(this, 0.8, {delay:0.5, alpha:-0.5, height:20, transition:Transitions.EASE_IN, onComplete:removeMe});
}

private function removeMe():void 
{
	touchable = true;
	owner.dispatchEventWith(Event.UPDATE, false, this);
}

private function removeTweens():void 
{
	//clearTimeout(timeoutId);
	Starling.juggler.removeTweens(this);
	Starling.juggler.removeTweens(skinLayout);
}

override public function set currentState(value:String) : void
{
	if( super.currentState == value )
		return;
	if( !passed )
		skinLayout.top = skinLayout.right = skinLayout.left = skinLayout.bottom = value == STATE_DOWN ? 0 : -10;
	super.currentState = value;
	if( super.currentState == STATE_SELECTED )
		owner.dispatchEventWith(Event.SELECT, false, this);
}

static private function getIcon(type:int) : String
{
	switch( type )
	{
		case 0: return "res-1";
		case 1: return "leagues/" + AppModel.instance.game.player.get_arena(0) + 1;
		case 2:
		case 3:
		case 4: return "home/dash-tab-2";
		case 5: return "home/dash-tab-3";
		case 6: return "home/dash-tab-4";
		case 7:
		case 8: return "home/dash-tab-1";
		case 9: return "books/56";
	}
	return "home/tasks";
}
}
}