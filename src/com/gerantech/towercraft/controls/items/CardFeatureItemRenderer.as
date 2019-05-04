package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.controls.groups.GradientHilight;
import com.gerantech.towercraft.controls.texts.LTRLable;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.MainTheme;
import com.gerantech.towercraft.utils.StrUtils;
import com.gt.towers.battle.units.Card;
import com.gt.towers.constants.CardFeatureType;
import com.gt.towers.scripts.ScriptEngine;
import starling.display.BlendMode;
import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayoutData;
import feathers.layout.RelativePosition;
import feathers.layout.TiledRowsLayout;
import flash.filters.DropShadowFilter;
import flash.filters.GlowFilter;
import flash.geom.Rectangle;
import starling.display.DisplayObject;
import starling.display.Image;

public class CardFeatureItemRenderer extends FeatureItemRenderer
{
static public var CARD_TYPE:int;
static public var UPGRADABLE:Boolean;
static public var IN_DETAILS:Boolean;
private var feature:int;
private var iconDisplay:ImageLoader;
private var hilight:GradientHilight;
private var diff:Number = 0;
public function CardFeatureItemRenderer() { super(); }
override protected function commitData():void
{
	if( _owner == null || _data == null )
		return;
	
	feature = _data as int;
	var card:Card = player.cards.get(CARD_TYPE);
	var level:int = card == null ? 1 : (card.level - (IN_DETAILS ? 0 : 1));
	var oldValue:Number = ScriptEngine.get(feature, CARD_TYPE, level + 0) * CardFeatureType.getUIFactor(feature);
	if ( UPGRADABLE )
	{
		var newValue:Number = ScriptEngine.get(feature, CARD_TYPE, level + 1) * CardFeatureType.getUIFactor(feature);
		diff = Math.round(Math.abs(newValue - oldValue));
	}
	
	iconFactory();
	super.commitData();
	width = TiledRowsLayout(_owner.layout).typicalItemWidth;
	height = 86;

	valueDisplay.text = "<span><br/>" + StrUtils.getNumber(Math.abs(Math.round(oldValue))) + (diff == 0?"":(' <font color="#00FF00"> + ' + StrUtils.getNumber(diff) + ' </font>')) + "</span>";
	keyDisplay.text = loc("building_feature_" + feature + (oldValue > 0 ? "" : "_1"));
	iconDisplay.source = Assets.getTexture("cards/features/" + feature + (oldValue > 0 ? "" : "_1"), "gui");
}

protected function iconFactory() : ImageLoader 
{
	iconDisplay = new ImageLoader();
	iconDisplay.layoutData = new AnchorLayoutData(0, NaN, 0, 0);
	addChild(iconDisplay);
	return iconDisplay;
}

override protected function backgroundFactory() : DisplayObject
{
	var skin:Image = new Image(appModel.theme.roundSmallInnerSkin);
	skin.scale9Grid = MainTheme.ROUND_SMALL_SCALE9_GRID;
	skin.alpha = IN_DETAILS ? 1 : 0.6;
	backgroundSkin = skin;
	
	if( UPGRADABLE && IN_DETAILS && diff != 0 )
	{
		skin.color = 0xAAFFAA;
		if( hilight == null )
		{
			hilight = new GradientHilight();
			hilight.alpha = 0.5;
			hilight.loopDelay = 0;
			hilight.direction = RelativePosition.RIGHT;
			hilight.layoutData = new AnchorLayoutData(2, 2, 2, 2);
			hilight.loopMode = GradientHilight.LOOP_MODE_DIRECTIONAL;			
		}
		addChild(hilight);
	}
	return backgroundSkin;
}

override protected function keyLabelFactory(scale:Number = 0.62, color:uint = 0):RTLLabel
{
	if( keyDisplay != null )
		return null;
	keyDisplay = new RTLLabel("", 0, null, null, false, null, scale * 0.9);
	keyDisplay.layoutData = new AnchorLayoutData(0, NaN, NaN, 100);
	addChild(keyDisplay);
	return keyDisplay;
}

override protected function valueLabelFactory(scale:Number = 0.75, color:uint = 0):void
{
	if( valueDisplay != null )
		return;
	var l:LTRLable = new LTRLable("", 1, "left", false, scale);
	var fs:Number = appModel.theme.gameFontSize * scale * 0.03;
	l.layoutData = new AnchorLayoutData(NaN, NaN, -10, 100);
	l.isHTML = true;
	l.nativeFilters = [new GlowFilter(0, 1, fs, fs, fs * 3), new DropShadowFilter(fs, 90, 0, 1, 0, 0) ];
	addChild(l);
	valueDisplay = l;
}
}
}