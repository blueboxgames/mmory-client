package com.gerantech.towercraft.controls.sliders
{
import com.gerantech.towercraft.controls.TowersLayout;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.MainTheme;
import com.gerantech.towercraft.utils.StrUtils;
import com.gerantech.mmory.core.battle.BattleField;
import com.gerantech.mmory.core.battle.ElixirUpdater;

import feathers.controls.ImageLoader;
import feathers.controls.LayoutGroup;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;

public class ElixirBar extends TowersLayout
{
private var elixirIconDisplay:LayoutGroup;
private var fillDisplay:ImageLoader;
private var realtimeDisplay:ImageLoader;
private var elixirCountDisplay:ShadowLabel;
private var _value:Number;

public function ElixirBar()
{
	super();
	this.touchable = false;
	this.pivotX = this.width * 0.5;
	this.layout = new AnchorLayout();
	this.value = appModel.battleFieldView.battleData.getAlliseEllixir();
}

override protected function initialize():void
{
	super.initialize();
	
	layout = new AnchorLayout();
	//width = 280;
	height = 48;
	var padding:int = 12;
	
	backgroundSkin = new Image(appModel.theme.backgroundSliderSkin);
	Image(backgroundSkin).scale9Grid = MainTheme.SLIDER_SCALE9_GRID;
	
	fillDisplay = new ImageLoader();
	fillDisplay.scale9Grid = MainTheme.SLIDER_SCALE9_GRID;
	fillDisplay.layoutData = new AnchorLayoutData(0, NaN, 0, 0);
	fillDisplay.source = Assets.getTexture("theme/slider-fill-danger-skin", "gui");
	addChild(fillDisplay);
	
	realtimeDisplay = new ImageLoader();
	realtimeDisplay.alpha = 0.4;
	//realtimeDisplay.blendMode = BlendMode.ADD;
	realtimeDisplay.scale9Grid = MainTheme.SLIDER_SCALE9_GRID;
	realtimeDisplay.layoutData = new AnchorLayoutData(0, NaN, 0, 0);
	realtimeDisplay.source = Assets.getTexture("theme/slider-fill-danger-skin", "gui");
	addChild(realtimeDisplay);
	
	
	for (var i:int = 1; i < 10; i++ )
	{
		var slot:ImageLoader = new ImageLoader();
		slot.layoutData = new AnchorLayoutData(0, NaN, 0);
		slot.scale9Grid = MainTheme.QUAD_SCALE9_GRID;
		slot.source = appModel.theme.quadSkin;
		slot.x = i * 90;
		slot.width = 3;
		slot.color = 0;
		addChild(slot);
	}
	
	elixirIconDisplay = new LayoutGroup();
	elixirIconDisplay.touchable = false;
	elixirIconDisplay.width = 90;
	elixirIconDisplay.height = 96;
	elixirIconDisplay.y = height * 0.5;
	elixirIconDisplay.pivotX = elixirIconDisplay.width * 0.5;
	elixirIconDisplay.pivotY = elixirIconDisplay.height * 0.7;
	elixirIconDisplay.layout = new AnchorLayout();
	elixirIconDisplay.backgroundSkin = new Image (Assets.getTexture("cards/elixir", "gui"));
	addChild(elixirIconDisplay);
	
	elixirCountDisplay = new ShadowLabel(null, 1, 0, null, null, false, null, 0.9);
	elixirCountDisplay.pixelSnapping = false;
	elixirCountDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, 15);
	elixirIconDisplay.addChild(elixirCountDisplay);
}

public function get value():Number
{
	return _value;
}
public function set value(newValue:Number):void
{
	var __v:Number = Math.max(0, Math.min( newValue, ElixirUpdater.MAX_VALUE ));
	if( _value == __v )
		return;
	_value = __v;

	var last:Number = (_value + 0) / ElixirUpdater.MAX_VALUE * this.width;
	var next:Number = (_value + 1) / ElixirUpdater.MAX_VALUE * this.width;
	var time:Number = 1 / (battleField.getDuration() > battleField.getTime(1) ? battleField.elixirUpdater.finalSpeeds[battleField.side] : battleField.elixirUpdater.normalSpeeds[battleField.side]) / 1000;

	if( elixirIconDisplay != null )
	{
		elixirCountDisplay.text = StrUtils.getNumber(_value);
		Starling.juggler.tween(elixirIconDisplay, 0.8, {x:last, transition:Transitions.EASE_OUT_ELASTIC});
	}
	
	if( fillDisplay != null )
	{
		Starling.juggler.removeTweens(fillDisplay);
		Starling.juggler.tween(fillDisplay, 0.8, {width:last, transition:Transitions.EASE_OUT_ELASTIC});
	}

	if( realtimeDisplay != null )
	{
		realtimeDisplay.width = last;
		Starling.juggler.removeTweens(realtimeDisplay);
		Starling.juggler.tween(realtimeDisplay, time, {width:next, transition:Transitions.LINEAR});
	}
}

private function get battleField() : BattleField
{
	return appModel.battleFieldView.battleData.battleField;
}

override public function dispose():void
{
	Starling.juggler.removeTweens(fillDisplay);
	Starling.juggler.removeTweens(elixirIconDisplay);
	super.dispose();
}
}
}