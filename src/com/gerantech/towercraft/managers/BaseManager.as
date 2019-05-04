package com.gerantech.towercraft.managers
{
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.utils.StrUtils;
import com.gt.towers.Game;
import com.gt.towers.Player;
import com.gt.towers.exchanges.Exchanger;
import starling.events.EventDispatcher;
public class BaseManager extends EventDispatcher
{
public function BaseManager(){super();}
protected function get timeManager():	TimeManager		{	return TimeManager.instance;		}
protected function get tutorials():		TutorialManager	{	return TutorialManager.instance;	}
protected function get appModel():		AppModel		{	return AppModel.instance;			}
protected function get game():			Game			{	return appModel.game;				}
protected function get player():		Player			{	return game.player;					}
protected function get exchanger():		Exchanger		{	return game.exchanger;				}
protected function loc(resourceName:String, parameters:Array = null) : String
{
	return StrUtils.loc(resourceName, parameters);
}
}
}