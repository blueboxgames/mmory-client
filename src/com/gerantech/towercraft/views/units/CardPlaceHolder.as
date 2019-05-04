package com.gerantech.towercraft.views.units 
{
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.utils.StrUtils;
import com.gt.towers.battle.BattleField;
import com.gt.towers.battle.units.Card;
import com.gt.towers.constants.CardTypes;
import com.gt.towers.utils.CoreUtils;
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
private var labelDisplay:ShadowLabel;
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
	unitsContainer.alpha = 0.3;
	addChild(unitsContainer);
	
	titleDisplay = new ShadowLabel("", 1, 0, "center");
	titleDisplay.width = 500;
	titleDisplay.pivotX = titleDisplay.width * 0.5;
	titleDisplay.y = -250;
	addChild(titleDisplay);
	
	labelDisplay = new ShadowLabel("", 1, 0, "center", null, false, null, 0.8);
	labelDisplay.width = 500;
	labelDisplay.height = 100;
	labelDisplay.pivotX = labelDisplay.width * 0.5;
	labelDisplay.y = -180;
	addChild(labelDisplay);
}

public function set type(value:int) : void
{
	if( _type == value )
		return;
	
	_type = value;
	var isSpell:Boolean = CardTypes.isSpell(_type);
	var card:Card = AppModel.instance.game.player.cards.get(_type);

	if( isSpell )
	{
		zoneDisplay.width = card.bulletDamageArea * 2;
		zoneDisplay.height = card.bulletDamageArea * 2 * BattleField.CAMERA_ANGLE;
		zoneDisplay.texture = AppModel.instance.assets.getTexture("damage-range");
	}
	else
	{
		zoneDisplay.width = zoneDisplay.height = 48;
		zoneDisplay.texture = Assets.getTexture("theme/radio-selected-disabled-icon");
	}
	
	
	titleDisplay.text = StrUtils.loc("card_title_" + _type);
	labelDisplay.text = StrUtils.loc("level_label", [card.level]);
	
	unitsContainer.removeChildren();
	if( isSpell )
		return;
	var nums:int = AppModel.instance.game.player.cards.get(_type).quantity;
	for (var i:int = 0; i < card.quantity; i++)
	{
		var unitDisplay:Image = new Image(AppModel.instance.assets.getTexture(_type + "/0/m_000_001"));
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
}
}