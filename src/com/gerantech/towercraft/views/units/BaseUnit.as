package com.gerantech.towercraft.views.units 
{
import com.gerantech.towercraft.managers.TutorialManager;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.views.BattleFieldView;
import com.gt.towers.Game;
import com.gt.towers.Player;
import com.gt.towers.battle.units.Card;
import com.gt.towers.battle.units.Unit;

/**
* ...
* @author Mansour Djawadi
*/
public class BaseUnit extends Unit
{
public function BaseUnit(card:Card, id:int, side:int, x:Number, y:Number, z:Number)
{
	super(id, AppModel.instance.battleFieldView.battleData.battleField, card, side, x, y, z);
}
protected function get appModel():		AppModel		{	return AppModel.instance;			}
protected function get game():			Game			{	return appModel.game;				}
protected function get player():		Player			{	return game.player;					}
protected function get fieldView():		BattleFieldView {	return appModel.battleFieldView;	}
protected function get tutorials():		TutorialManager	{	return TutorialManager.instance;	}
}
}