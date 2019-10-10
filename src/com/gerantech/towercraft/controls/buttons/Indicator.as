package com.gerantech.towercraft.controls.buttons
{
import com.gerantech.mmory.core.constants.ExchangeType;
import com.gerantech.mmory.core.constants.ResourceType;
import com.gerantech.mmory.core.events.CoreEvent;
import com.gerantech.mmory.core.utils.CoreUtils;
import com.gerantech.towercraft.controls.sliders.LabeledProgressBar;
import com.gerantech.towercraft.controls.tooltips.BaseTooltip;
import com.gerantech.towercraft.events.LoadingEvent;
import com.gerantech.towercraft.managers.SoundManager;
import com.gerantech.towercraft.managers.net.LoadingManager;
import com.gerantech.towercraft.models.vo.RewardData;

import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

import flash.geom.Rectangle;
import flash.utils.setTimeout;

import starling.animation.Transitions;
import starling.core.Starling;
import starling.events.Event;

public class Indicator extends SimpleLayoutButton
{
public var type:int;
public var direction:String;
public var value:Number = -0.1;
public var minimum:Number = 0;
public var maximum:Number = Number.MAX_VALUE;
public var hasProgressbar:Boolean;
public var hasIncreaseButton:Boolean;
public var autoApdate:Boolean;
public var iconDisplay:ImageLoader;
public var labelOffsetX:Number = 0;
public var progressBar:LabeledProgressBar;
public var progressBarFactory:Function;

private var _displayValue:Number = Number.MIN_VALUE;

public function Indicator(direction:String, type:int, hasProgressbar:Boolean = false, hasIncreaseButton:Boolean = true, autoApdate:Boolean = true)
{
	this.direction = direction;
	this.type = type;
	this.hasProgressbar = hasProgressbar;
	this.hasIncreaseButton = hasIncreaseButton;
	this.autoApdate = autoApdate;
	this.width = 180;
	this.height = 64;
	addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
}

override protected function initialize():void
{
	super.initialize();
	this.isQuickHitAreaEnabled = false;
	layout = new AnchorLayout();
	
	if( progressBarFactory == null )
		progressBarFactory = defaultProgressBarFactory;
	progressBar = progressBarFactory();
	addChild(progressBar);
	if( !hasProgressbar )
		progressBar.fillSkin.visible = false;

	iconDisplay = new ImageLoader();
	iconDisplay.pivotX = iconDisplay.pivotY = iconDisplay.width * 0.5;
	iconDisplay.source = appModel.assets.getTexture("res-" + type);
	iconDisplay.width = iconDisplay.height = height + 24;
	iconDisplay.layoutData = new AnchorLayoutData(NaN, direction == "ltr"?NaN: -height, NaN, direction == "ltr"? -height:NaN, NaN, 0);
	addChild(iconDisplay);
	
	if( hasIncreaseButton )
	{
		var increaseButton:IndicatorButton = new IndicatorButton();
		increaseButton.layoutData = new AnchorLayoutData(NaN, direction=="ltr"?-height:NaN, NaN, direction=="ltr"?NaN:-height, NaN, 0); 
		increaseButton.addEventListener(Event.TRIGGERED, addButton_triggerHandler);
		increaseButton.width = increaseButton.height = height + 12;
		increaseButton.label = "+";
		addChild(increaseButton);
	}
	
	if( !autoApdate )
		return;
	
	if( appModel.loadingManager.state >= LoadingManager.STATE_LOADED )
		loadingManager_loadedHandler(null);
	else
		appModel.loadingManager.addEventListener(LoadingEvent.LOADED, loadingManager_loadedHandler);
}

protected function loadingManager_loadedHandler(event:LoadingEvent) : void
{
	appModel.loadingManager.removeEventListener(LoadingEvent.LOADED, loadingManager_loadedHandler);
	appModel.navigator.addEventListener("achieveResource", navigator_achieveResourceHandler);
	player.resources.addEventListener(CoreEvent.CHANGE, playerResources_changeHandler);
	setData(minimum, -1, maximum);
}

protected function navigator_achieveResourceHandler(event:Event) : void 
{
	if( event.data == null )
		return;
	var params:Array = event.data as Array;
	if( !ResourceType.isBook(params[2]) )
		addResourceAnimation(params[0], params[1], params[2], params[3]);
}

protected function addedToStageHandler(event:Event):void 
{
	if( appModel.battleFieldView == null || appModel.battleFieldView.battleData == null || appModel.battleFieldView.battleData.outcomes == null )
		return;
	for( var i:int = 0; i < appModel.battleFieldView.battleData.outcomes.length; i++ )
	{
		var rd:RewardData = appModel.battleFieldView.battleData.outcomes[i];
		if( type == rd.key )
		{
			addResourceAnimation(rd.x, rd.y, rd.key, rd.value, 0.5 * i + 0.1);
			appModel.battleFieldView.battleData.outcomes.removeAt(i);
			return;
		}
	}
}

protected function playerResources_changeHandler(event:CoreEvent):void
{
	if( event.key != type )
		return;
	//trace("CoreEvent.CHANGE:", ResourceType.getName(event.key), event.from, event.to);
	setData(minimum, -1, maximum);
}

public function setData(minimum:Number, value:Number, maximum:Number, changeDuration:Number = 0):void
{
	this.minimum = minimum;
	if( value == -1 )
		value = getValue();
	if( clampValue )
		this.value = CoreUtils.clamp(value, minimum, maximum);
	else
		this.value = value;
	this.maximum = maximum;
	//trace("type:" + type, "this.minimum:" + this.minimum, "value:" + value, "this.maximum:" + this.maximum, "this.value:" + this.value, "changeDuration:" + changeDuration);
	
	if( progressBar != null )
	{
		progressBar.minimum = this.minimum;
		progressBar.maximum = this.maximum;
	}
	
	if( changeDuration <= 0 )
		displayValue = this.value;
	else
		Starling.juggler.tween(this, changeDuration, {displayValue:this.value, transition:Transitions.EASE_IN_OUT})
}

public function get displayValue() : Number 
{
	return _displayValue;
}
public function set displayValue(v:Number) : void 
{
	if( _displayValue == v )
		return;
	_displayValue = v;
	
	if( progressBar != null )
		progressBar.value = v;
}

protected function defaultProgressBarFactory():LabeledProgressBar
{
	var ret:LabeledProgressBar = new LabeledProgressBar();
	ret.clampValue = this._clampValue;
	ret.formatValueFactory = this._formatValueFactory;;
	ret.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	ret.labelOffsetX = labelOffsetX;
	ret.isEnabled = false;
	ret.minimum = minimum;
	ret.maximum = maximum;
	ret.value = value;
//	progressLabel.layoutData = new AnchorLayoutData(NaN, (direction == "rtl" || (direction == "ltr" && hasIncreaseButton)) ? 40 : 0, NaN, direction == "ltr"||(direction == "rtl"&&hasIncreaseButton) ? 40 : 0, NaN, -1);
	return ret;
}

private var _clampValue:Boolean = true;
public function get clampValue():Boolean 
{
	return _clampValue;
}
public function set clampValue(value:Boolean):void 
{
	if( this._clampValue == value )
		return;
	this._clampValue = value;
	if( progressBar != null )
		progressBar.clampValue = this._clampValue;;
}

private var _formatValueFactory:Function;
public function get formatValueFactory():Function 
{
	return _formatValueFactory;
}
public function set formatValueFactory(value:Function):void 
{
	this._formatValueFactory = value;
	if( progressBar != null )
		progressBar.formatValueFactory = this._formatValueFactory;;
}

public function addResourceAnimation(x:Number, y:Number, type:int, count:int, delay:Number = 0):void
{
	if( ResourceType.isCard(type) && this.type == ResourceType.R3_CURRENCY_SOFT )
	{
		appModel.sounds.addAndPlay("card-r-0",null, SoundManager.CATE_SFX, SoundManager.SINGLE_FORCE_THIS);
		appModel.navigator.addAnimation(x, y, 130, appModel.assets.getTexture("res-cards"), count, new Rectangle(320, 1900), delay, null);
		return;
	}
	
	if( this.type != type )
		return;
	
	setData(minimum, getValue() - count, maximum);
	setTimeout(function():void
	{
		var rect:Rectangle;
		if( iconDisplay.stage == null )
			rect = new Rectangle(x, y - 500, 2, 2);
		else
			rect = iconDisplay.getBounds(stage);
		
		appModel.sounds.addAndPlay("res-show-" + type, null, SoundManager.CATE_SFX, SoundManager.SINGLE_FORCE_THIS, 1);
		trace("typetypetype", type);
		appModel.navigator.addAnimation(x, y, 130, appModel.assets.getTexture("res-" + type), count, rect, 0.02, punch);
	}, delay * 1000);
}

private function getValue() : int
{
	return type == ResourceType.R17_STARS ? exchanger.items.get(ExchangeType.C104_STARS).numExchanges : player.getResource(type);
}

override protected function trigger():void
{
	super.trigger();
	if( type == ResourceType.R1_XP || type == ResourceType.R2_POINT || type == ResourceType.R3_CURRENCY_SOFT || type == ResourceType.R4_CURRENCY_HARD || type == ResourceType.R6_TICKET )
		appModel.navigator.addChild(new BaseTooltip(loc("tooltip_indicator_" + type), iconDisplay.getBounds(stage)));
	else
		dispatchEventWith(Event.SELECT);
}	
private function addButton_triggerHandler(event:Event):void
{
	if( type == ResourceType.R3_CURRENCY_SOFT || type == ResourceType.R4_CURRENCY_HARD || type == ResourceType.R6_TICKET )
		appModel.navigator.gotoShop(type);
	dispatchEventWith(Event.SELECT);
}		

public function punch():void
{
	appModel.sounds.addAndPlay("res-hide-" + type, null, SoundManager.CATE_SFX, SoundManager.SINGLE_FORCE_THIS, 1);
	setData(minimum, -1, maximum, 1);
	iconDisplay.scale = 1.5;
	Starling.juggler.tween(iconDisplay, 0.5, {scale:1, transition:Transitions.EASE_OUT_BACK});
}

override public function dispose():void
{
	removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
	appModel.loadingManager.removeEventListener(LoadingEvent.LOADED, loadingManager_loadedHandler);
	appModel.navigator.removeEventListener("achieveResource", navigator_achieveResourceHandler);
	player.resources.removeEventListener(CoreEvent.CHANGE, playerResources_changeHandler);
	super.dispose();
}
}
}