package com.gerantech.towercraft.views.units 
{
import com.gerantech.mmory.core.battle.BattleField;
import com.gerantech.mmory.core.battle.units.Card;
import com.gerantech.mmory.core.constants.CardTypes;
import com.gerantech.mmory.core.scripts.ScriptEngine;
import com.gerantech.mmory.core.utils.CoreUtils;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.utils.StrUtils;
import com.gerantech.towercraft.views.units.elements.UnitBody;

import starling.core.Starling;
import starling.display.Image;
import starling.display.Sprite;

/**
* ...
* @author Mansour Djawadi
*/
public class CardPlaceHolder extends Sprite 
{
private var _type:int;
private var unitDisplay:Image;
private var titleDisplay:ShadowLabel;
private var levelDisplay:ShadowLabel;
private var unitsContainer:Sprite;
private var zoneDisplay:Image;
public function CardPlaceHolder() 
{
	super();
	
	pivotX = width * 0.5;
	pivotY = height * 0.5;

	zoneDisplay = new Image(null);
	zoneDisplay.pivotX = zoneDisplay.width * 0.5;
	zoneDisplay.pivotY = zoneDisplay.height * 0.5;
	zoneDisplay.alpha = 0.5;
	addChild(zoneDisplay);
	
	unitsContainer = new Sprite();
	unitsContainer.x = 
	unitsContainer.alpha = 0.3;
	addChild(unitsContainer);
	
	titleDisplay = new ShadowLabel("", 1, 0, "center");
	titleDisplay.width = 500;
	titleDisplay.pivotX = titleDisplay.width * 0.5;
	titleDisplay.y = -250;
	addChild(titleDisplay);
	
	levelDisplay = new ShadowLabel("", 1, 0, "center", null, false, null, 0.8);
	levelDisplay.width = 500;
	levelDisplay.height = 100;
	levelDisplay.pivotX = levelDisplay.width * 0.5;
	levelDisplay.y = -180;
	addChild(levelDisplay);
}

public function set type(value:int) : void
{
	if( _type == value )
		return;
	
	_type = value;
	var isSpell:Boolean = CardTypes.isSpell(_type);
	var card:Card = AppModel.instance.game.player.cards.get(_type);

	if( isSpell || card.speed == 0 )
	{
		var w:Number = isSpell ? card.bulletDamageArea : card.bulletRangeMax;
		zoneDisplay.width = w * 2;
		zoneDisplay.height = w * 2 * BattleField.CAMERA_ANGLE;
		zoneDisplay.texture = AppModel.instance.assets.getTexture("map/damage-range");
	}
	else
	{
		zoneDisplay.width = zoneDisplay.height = 48;
		zoneDisplay.texture = AppModel.instance.assets.getTexture("theme/radio-selected-disabled-icon");
	}
	
	
	titleDisplay.text = StrUtils.loc("card_title_" + _type);
	levelDisplay.text = StrUtils.loc("level_label", [card.level]);
	
	unitsContainer.removeChildren();
	if( isSpell )
		return;
	var nums:int = AppModel.instance.game.player.cards.get(_type).quantity;
	for (var i:int = 0; i < card.quantity; i++)
	{
		var unitDisplay:UnitBody = new UnitBody(null, card, 0);
		unitDisplay.pivotX = unitDisplay.width * 0.5;
		unitDisplay.pivotY = unitDisplay.height * UnitView._PIVOT_Y;
		unitDisplay.width = UnitView._WIDTH;
		unitDisplay.height = UnitView._HEIGHT;
		unitDisplay.scale *= UnitView._SCALE;

		unitDisplay.x = CoreUtils.getXPosition(nums, i, 0);
		unitDisplay.y = CoreUtils.getYPosition(nums, i, 0);
		unitsContainer.addChild(unitDisplay);
	}
}
public function get type() : int
{
	return _type;
}

public function summon() : void
{
	zoneDisplay.visible = false;
	titleDisplay.visible = false;
	levelDisplay.visible = false;
	var dely:Number = ScriptEngine.getInt(ScriptEngine.T04_SUMMON_TIME, this._type, AppModel.instance.game.player.cards.get(_type).level) * 0.001;
	Starling.juggler.tween(unitsContainer, 0.2, {alpha:0, delay:Math.max(0, dely - 0.5), onComplete:removeFromParent, onCompleteArgs:[true]});
}
}
}