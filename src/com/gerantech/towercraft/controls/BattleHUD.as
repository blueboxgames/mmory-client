package com.gerantech.towercraft.controls
{
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.buttons.SimpleLayoutButton;
import com.gerantech.towercraft.controls.headers.AttendeeHeader;
import com.gerantech.towercraft.controls.headers.BattleFooter;
import com.gerantech.towercraft.controls.items.StickerItemRenderer;
import com.gerantech.towercraft.controls.overlays.EndOverlay;
import com.gerantech.towercraft.controls.sliders.battle.BattleCountdown;
import com.gerantech.towercraft.controls.sliders.battle.BattleScoreBoard;
import com.gerantech.towercraft.controls.sliders.battle.BattleTimerSlider;
import com.gerantech.towercraft.controls.sliders.battle.IBattleBoard;
import com.gerantech.towercraft.controls.sliders.battle.IBattleSlider;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.toasts.BattleExtraTimeToast;
import com.gerantech.towercraft.controls.toasts.BattleTurnToast;
import com.gerantech.towercraft.controls.toasts.LastSecondsToast;
import com.gerantech.towercraft.controls.tooltips.StickerBubble;
import com.gerantech.towercraft.managers.SoundManager;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.vo.BattleData;
import com.gerantech.towercraft.models.vo.UserData;
import com.gerantech.towercraft.themes.MainTheme;
import com.gerantech.towercraft.views.units.UnitView;
import com.gt.towers.battle.BattleField;
import com.gt.towers.battle.fieldes.FieldData;
import com.gt.towers.constants.PrefsTypes;
import com.gt.towers.constants.StickerType;
import com.gt.towers.socials.Challenge;
import com.marpies.ane.gameanalytics.GameAnalytics;
import feathers.controls.ImageLoader;
import feathers.controls.List;
import feathers.controls.ScrollPolicy;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.TiledRowsLayout;
import feathers.layout.VerticalAlign;
import flash.geom.Rectangle;
import flash.utils.setTimeout;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;
import starling.display.Quad;
import starling.events.Event;
import starling.utils.Color;

 public class BattleHUD extends TowersLayout
{
private var padding:int;
private var scoreIndex:int = 0;
private var debugMode:Boolean = false;

private var battleData:BattleData;
private var timerSlider:IBattleSlider;
private var stickerList:List;
private var stickerCloserOveraly:SimpleLayoutButton;
private var lastSecondsToast:LastSecondsToast;
private var bubbleAllise:StickerBubble;
private var bubbleAxis:StickerBubble;
private var timeLog:RTLLabel;
private var surrenderButton:CustomButton;
private var scoreBoard:IBattleBoard;
private var deck:BattleFooter;

public function BattleHUD() { super(); }
override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout();
	this.battleData = appModel.battleFieldView.battleData;
	
	var gradient:ImageLoader = new ImageLoader();
	gradient.scale9Grid = MainTheme.SHADOW_SIDE_SCALE9_GRID;
    gradient.color = Color.BLACK;
	gradient.alpha = 0.5;
	gradient.width = 440;
	gradient.height = 140;
	gradient.source = Assets.getTexture("theme/gradeint-left");
	addChild(gradient);
	
	var hasQuit:Boolean = battleData.battleField.field.isOperation() || SFSConnection.instance.mySelf.isSpectator;
	padding = 16;
	var leftPadding:int = (hasQuit ? 150 : 0);
	if( hasQuit )
	{
		var leaveButton:CustomButton = new CustomButton();
		leaveButton.style = "danger";
		leaveButton.label = "X";
		leaveButton.height = leaveButton.width = 120;
		leaveButton.layoutData = new AnchorLayoutData(padding, NaN, NaN, padding);
		leaveButton.addEventListener(Event.TRIGGERED, closeButton_triggeredHandler);
		addChild(leaveButton);			
	}
	
	//var _name:String = battleData.battleField.field.isOperation() ? loc("operation_label") + " " + StrUtils.getNumber(battleData.battleField.field.index + 1) : battleData.axis.getUtfString("name");
	var _name:String = player.get_battleswins() < 4 ? loc("trainer_label") : battleData.axis.getUtfString("name");
	var _point:int = player.admin ? battleData.axis.getInt("point") : 0;
	var opponentHeader:AttendeeHeader = new AttendeeHeader(_name, _point);
	opponentHeader.layoutData = new AnchorLayoutData(0, NaN, NaN, leftPadding );
	addChild(opponentHeader);
	
	if( SFSConnection.instance.mySelf.isSpectator )
	{
		_name = battleData.allise.getUtfString("name");
		_point = battleData.allise.getInt("point");
		var meHeader:AttendeeHeader = new AttendeeHeader(_name, player.admin ? _point : 0);
		meHeader.layoutData = new AnchorLayoutData(NaN, NaN, 0, 0 );
		addChild(meHeader);
	}
	
	if( debugMode )
	{
		timeLog = new RTLLabel("", 0);
		timeLog.layoutData = new AnchorLayoutData(padding * 10, padding * 6);
		addChild(timeLog);
	}

	if( battleData.battleField.field.isOperation() )
	{
		timerSlider = new BattleTimerSlider();
		timerSlider.layoutData = new AnchorLayoutData(padding * 4, padding * 6);
	}
	else
	{
		timerSlider = new BattleCountdown();
		timerSlider.layoutData = new AnchorLayoutData(padding, padding);
	}
	addChild(timerSlider);
	
	addEventListener(FeathersEventType.CREATION_COMPLETE, createCompleteHandler);
	
	if( battleData.battleField.field.isOperation() )
		return;

	/*if( !SFSConnection.instance.mySelf.isSpectator )
	{
		stickerButton = new CustomButton();
		stickerButton.icon = Assets.getTexture("tooltip-bg-bot-right");
		stickerButton.iconLayout = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, -4);
		stickerButton.width = 140;
		stickerButton.layoutData = new AnchorLayoutData(NaN, padding * 2, padding);
		stickerButton.addEventListener(Event.TRIGGERED, stickerButton_triggeredHandler);
		addChild(stickerButton);
	}*/
	
	if( !SFSConnection.instance.mySelf.isSpectator )
	{
		if( player.get_arena(player.get_point()) > 4 )
		{
			surrenderButton = new CustomButton();
			surrenderButton.style = CustomButton.STYLE_DANGER;
			surrenderButton.icon = Assets.getTexture("surrender");
			surrenderButton.iconLayout = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, -4);
			surrenderButton.width = 140;
			surrenderButton.layoutData = new AnchorLayoutData(NaN, NaN, padding, padding);
			surrenderButton.addEventListener(Event.TRIGGERED, closeButton_triggeredHandler);
			addChild(surrenderButton);
		}
	}
	
	bubbleAllise = new StickerBubble();
	bubbleAllise.layoutData = new AnchorLayoutData(NaN, padding, padding);
	
	bubbleAxis = new StickerBubble(true);
	bubbleAxis.layoutData = new AnchorLayoutData(140 + padding, NaN, NaN, padding);
	
	scoreBoard = new BattleScoreBoard();
	scoreBoard.layoutData = new AnchorLayoutData(NaN, -15, NaN, NaN, NaN, -BattleFooter.HEIGHT * 0.2);
	//scoreBoard.y = appModel.battleFieldView.y - scoreBoard.height * 0.5;
	addChild(scoreBoard);
	updateScores(1, 0, battleData.allise.getInt("score"), battleData.axis.getInt("score"), -1);
}

public function showDeck() : void
{
	deck = new BattleFooter();
	deck.layoutData = new AnchorLayoutData(NaN, 0, -500, 0);
	deck.addEventListener(FeathersEventType.BEGIN_INTERACTION, stickerButton_triggeredHandler);
	Starling.juggler.tween(deck.layoutData, 0.4, {delay:0.5, bottom:0, transition:Transitions.EASE_OUT, onComplete:deck.transitionInCompleteHandler});
	addChild(deck);
}

protected function createCompleteHandler(event:Event):void
{
	removeEventListener(FeathersEventType.CREATION_COMPLETE, createCompleteHandler);
	timeManager.addEventListener(Event.CHANGE, timeManager_changeHandler);
	if( !battleData.battleField.field.isOperation() )
		return;
	
	if( battleData.battleField.extraTime > 0 )
		appModel.navigator.addAnimation(stage.stageWidth * 0.5, stage.stageHeight * 0.5, 240, Assets.getTexture("extra-time"), battleData.battleField.extraTime, BattleTimerSlider(timerSlider).iconDisplay.getBounds(this), 0.5, punchTimer, "+ ");
	function punchTimer():void {
		var diff:int = 48;
		timerSlider.y -= diff;
		Starling.juggler.tween(timerSlider, 0.4, {y:y + diff, transition:Transitions.EASE_OUT_ELASTIC});
	}
}

protected function timeManager_changeHandler(event:Event):void
{
	if( battleData.battleField.field.isOperation() )
		return;
	//trace(timeManager.now-battleData.startAt , battleData.battleField.field.times._list)
	
	if( surrenderButton != null )
		surrenderButton.visible = timeManager.now > battleData.battleField.startAt + battleData.battleField.field.times.get(2);
	var time:int = battleData.battleField.startAt + battleData.battleField.field.times.get(2) - timeManager.now;
	if( time < 0 )
		time = battleData.battleField.startAt + battleData.battleField.field.times.get(3) - timeManager.now;
	timerSlider.value = time;
	
	var duration:int = int(battleData.battleField.getDuration() + 1);
	if( duration == 120 || duration == 180 )
	{
		appModel.sounds.stopAll(SoundManager.CATE_THEME);
		appModel.sounds.addAndPlay("battle-" + duration, null, SoundManager.CATE_THEME, SoundManager.SINGLE_BYPASS_THIS, 4);
	}
	if( duration == battleData.battleField.getTime(1) )
	{
		timerSlider.enableStars(0x08899);
		animateShadow(0.5, null, 0x08899);
		appModel.navigator.addPopup(new BattleExtraTimeToast(BattleExtraTimeToast.MODE_ELIXIR_2X));
	}
	
	if( battleData.allise.getInt("score") == battleData.axis.getInt("score") && duration == battleData.battleField.getTime(2) )
	{
		appModel.navigator.addPopup(new BattleExtraTimeToast(BattleExtraTimeToast.MODE_EXTRA_TIME));
		animateShadow(0.4, null, 0xAA0000);
		timerSlider.enableStars(0xFF0000);
	}
	
	if( duration == battleData.battleField.getTime(2) - 10 || duration == battleData.battleField.getTime(3) - 10 )
	{
		lastSecondsToast = new LastSecondsToast();
		lastSecondsToast.x = appModel.battleFieldView.x;
		lastSecondsToast.y = appModel.battleFieldView.y + 20;
		addChild(lastSecondsToast);
	}
}

public function animateShadow(alphaSeed:Number, shadow:Image = null, color:uint = 0) : void
{
	if( shadow == null )
	{
		shadow = new Image(Assets.getTexture("radial-gradient-shadow"));
		shadow.scale9Grid = new Rectangle(2, 2, 12, 12);
		shadow.height = stageHeight;
		shadow.width = stageWidth;
		shadow.touchable = false;
		shadow.alpha = 0.8;
		addChildAt(shadow, 0);
	}
	shadow.color = color;
	Starling.juggler.removeTweens(shadow);
	Starling.juggler.tween(shadow, Math.random() + 0.1, {alpha:Math.random() * alphaSeed + 0.1, onComplete:animateShadow, onCompleteArgs:[alphaSeed==0?0.6:0, shadow, color]});
}

public function updateRoomVars():void{}
public function updateScores(round:int, winnerSide:int, allise:int, axis:int, unitId:int) : void
{
	trace("updateScores:", "round:" + round, "winnerSide:" + winnerSide, "allise:" + allise, "axis:" + axis, "unitId:" + unitId);
	battleData.allise.putInt("score", allise);
	battleData.axis.putInt("score", axis);
	
	if( winnerSide == 0 && allise > 0 )
		UserData.instance.prefs.setInt(PrefsTypes.TUTOR, appModel.battleFieldView.battleData.getBattleStep() + 2 + allise);

	if( deck != null )
		deck.updateScore(round, winnerSide, allise, axis, unitId);
	if( scoreBoard != null )
		scoreBoard.update(allise, axis);
	
	// uniit focus only appeared  in touchdown battles
	if( battleData.battleField.field.mode == Challenge.MODE_1_TOUCHDOWN )
	{	
		var unit:UnitView = battleData.battleField.units.get(unitId) as UnitView;
		if( unit != null )
			unit.showWinnerFocus();
				
		setTimeout(appModel.navigator.addLog, 3000, loc("round_label", [loc("num_" + round)]));
	}

	// prevent end of battle state
	if( allise > 2 || axis > 2 || (battleData.battleField.now * 0.001 - battleData.battleField.startAt) > battleData.battleField.getTime(2) )
		return;
	
	// invalid data
	if( allise <= 0 && axis <= 0 )
		return;
	
	var side:int = winnerSide == battleData.battleField.side ? 0 : 1;
	appModel.navigator.addPopup(new BattleTurnToast(side, winnerSide == battleData.battleField.side ? allise : axis));
}

protected function closeButton_triggeredHandler(event:Event):void
{
	dispatchEventWith(Event.CLOSE);
}

protected function stickerButton_triggeredHandler(event:Event):void
{
	deck.stickerButton.visible = false;
	if( stickerList == null )
	{
		var stickersLayout:TiledRowsLayout = new TiledRowsLayout();
		stickersLayout.padding = stickersLayout.gap = padding * 0.2;
		stickersLayout.tileHorizontalAlign = HorizontalAlign.JUSTIFY;
		stickersLayout.tileVerticalAlign = VerticalAlign.JUSTIFY;
		stickersLayout.useSquareTiles = false;
		stickersLayout.distributeWidths = true;
		stickersLayout.distributeHeights = true;
		stickersLayout.requestedColumnCount = 4;
		
		stickerList = new List();
		stickerList.layout = stickersLayout;
		stickerList.layoutData = new AnchorLayoutData(NaN, padding, NaN, 0);
		stickerList.height = padding * 20;
		stickerList.itemRendererFactory = function ():IListItemRenderer { return new StickerItemRenderer(); }
		stickerList.verticalScrollPolicy = stickerList.horizontalScrollPolicy = ScrollPolicy.OFF;
		stickerList.dataProvider = new ListCollection(StickerType.getAll(battleData.battleField.friendlyMode));
		
		stickerCloserOveraly = new SimpleLayoutButton();
		stickerCloserOveraly.backgroundSkin = new Quad(1, 1, 0);
		stickerCloserOveraly.backgroundSkin.alpha = 0.1;
		stickerCloserOveraly.layoutData = new AnchorLayoutData(0, 0, 0, 0);
		stickerCloserOveraly.addEventListener(Event.TRIGGERED, stickerCloserOveraly_triggeredHandler);
	}
	addChild(stickerCloserOveraly);

	AnchorLayoutData(stickerList.layoutData).bottom = -padding * 20;
	Starling.juggler.tween(stickerList.layoutData, 0.2, {bottom:0, transition:Transitions.EASE_OUT});
	stickerList.addEventListener(Event.CHANGE, stickerList_changeHandler);
	addChild(stickerList);
}
private function hideStickerList():void
{
	stickerList.removeEventListener(Event.CHANGE, stickerList_changeHandler);
	removeChild(stickerCloserOveraly);
	AnchorLayoutData(stickerList.layoutData).bottom = 0;
	Starling.juggler.tween(stickerList.layoutData, 0.2, {bottom: -padding * 20, transition:Transitions.EASE_IN, onComplete:stickerList.removeFromParent});
}

protected function stickerCloserOveraly_triggeredHandler(event:Event):void
{
	hideStickerList();
	deck.stickerButton.visible = true;
}

protected function stickerList_changeHandler(event:Event):void
{
	hideStickerList();
	var sticker:int = stickerList.selectedItem as int
	appModel.battleFieldView.responseSender.sendSticker(sticker);
	showBubble(sticker);
	stickerList.selectedIndex = -1;
	GameAnalytics.addDesignEvent("sticker:st" + sticker);
}

public function showBubble(type:int, itsMe:Boolean=true):void
{
	var bubble:StickerBubble = itsMe ? bubbleAllise : bubbleAxis;
	if( bubble == null )
		return;
	
	Starling.juggler.removeTweens(bubble);
	bubble.type = type;
	bubble.scale = 0.5;
	addChild(bubble);
	Starling.juggler.tween(bubble, 0.2, {scale:1.0, transition:Transitions.EASE_OUT_BACK});
	Starling.juggler.tween(bubble, 0.2, {scale:0.5, transition:Transitions.EASE_IN_BACK, delay:4, onComplete:hideBubble, onCompleteArgs:[bubble]});
	appModel.sounds.addAndPlay("whoosh");
}

private function hideBubble(bubble:StickerBubble):void
{
	bubble.removeFromParent();
	if( SFSConnection.instance.lastJoinedRoom != null && !SFSConnection.instance.mySelf.isSpectator )
		deck.stickerButton.visible = true;
}

public function end(overlay:EndOverlay) : void 
{
	// remove all element except sticker elements
	var numCh:int = numChildren - 1;
	while ( numCh >= 0 )
	{
		if( getChildAt(numCh) != bubbleAllise && getChildAt(numCh) != bubbleAxis && getChildAt(numCh) != scoreBoard )
			getChildAt(numCh).removeFromParent(true);
		numCh --;
	}

	addChildAt(overlay, 0);
	if( scoreBoard != null )
		addChildAt(scoreBoard, 0);
}

public function stopTimers() : void
{
	timeManager.removeEventListener(Event.CHANGE, timeManager_changeHandler);
	Starling.juggler.removeTweens(timerSlider);
}

override public function dispose():void
{
	stopTimers();
	super.dispose();
}
}
}