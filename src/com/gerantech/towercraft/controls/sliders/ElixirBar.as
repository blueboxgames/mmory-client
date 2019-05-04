package com.gerantech.towercraft.controls.sliders
{
import com.gerantech.towercraft.controls.TowersLayout;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.MainTheme;
import com.gt.towers.battle.BattleField;
import feathers.controls.ImageLoader;
import feathers.controls.LayoutGroup;
import feathers.controls.text.BitmapFontTextRenderer;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.text.BitmapFontTextFormat;
import starling.events.Event;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.BlendMode;
import starling.display.Image;

public class ElixirBar extends TowersLayout
{
private var elixirBottle:LayoutGroup;
private var fillDisplay:ImageLoader;
private var realtimeDisplay:ImageLoader;
private var elixirCountDisplay:BitmapFontTextRenderer;
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
	height = 72;
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
	
	elixirBottle = new LayoutGroup();
	elixirBottle.touchable = false;
	elixirBottle.pivotX = elixirBottle.width * 0.5;
	elixirBottle.pivotY = elixirBottle.height * 0.5;
	elixirBottle.layout = new AnchorLayout();
	//elixirBottle.backgroundSkin = new Image (Assets.getTexture("elixir"));
	elixirBottle.layoutData = new AnchorLayoutData(NaN, NaN, padding, padding);
	addChild(elixirBottle);
	
	elixirCountDisplay = new BitmapFontTextRenderer();
	elixirCountDisplay.textFormat = new BitmapFontTextFormat(Assets.getFont(), 110)
	elixirCountDisplay.pixelSnapping = elixirCountDisplay.touchable = false;
	elixirCountDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, 0);
	elixirBottle.addChild(elixirCountDisplay);
}

public function get value():Number
{
	return _value;
}
public function set value(newValue:Number):void
{
	var __v:Number = Math.max(0, Math.min( newValue, BattleField.POPULATION_MAX ));
	if( _value == __v )
		return;
	_value = __v;

	if( elixirCountDisplay != null )
	{
		elixirCountDisplay.text = _value.toString();
		elixirBottle.scale = 1.4;
		Starling.juggler.tween(elixirBottle, 0.8, {scale:1, transition:Transitions.EASE_OUT_ELASTIC});
	}
	
	var last:Number = (_value + 0) / BattleField.POPULATION_MAX * this.width;
	var next:Number = (_value + 1) / BattleField.POPULATION_MAX * this.width;
	var time:Number = 1 / appModel.battleFieldView.battleData.battleField.getElixirIncreaseSpeed() / 1000;
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

override public function dispose():void
{
	Starling.juggler.removeTweens(fillDisplay);
	Starling.juggler.removeTweens(elixirBottle);
	super.dispose();
}
}
}