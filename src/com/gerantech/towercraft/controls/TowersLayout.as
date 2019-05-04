package com.gerantech.towercraft.controls
{
import com.gerantech.towercraft.managers.ExchangeManager;
import com.gerantech.towercraft.managers.TimeManager;
import com.gerantech.towercraft.managers.TutorialManager;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.utils.StrUtils;
import com.gt.towers.Game;
import com.gt.towers.Player;
import com.gt.towers.exchanges.Exchanger;
import feathers.controls.LayoutGroup;
import starling.core.Starling;
public class TowersLayout extends LayoutGroup
{
public function TowersLayout(){	super();}
protected function get timeManager():		TimeManager		{	return TimeManager.instance;				}
protected function get tutorials():			TutorialManager	{	return TutorialManager.instance;			}
protected function get appModel():			AppModel		{	return AppModel.instance;					}
protected function get game():				Game			{	return appModel.game;						}
protected function get player():			Player			{	return game.player;							}
protected function get exchanger():			Exchanger		{	return game.exchanger;						}
protected function get exchangeManager():	ExchangeManager	{	return ExchangeManager.instance;			}
protected function get stageWidth():		Number			{	return Starling.current.stage.stageWidth;	}
protected function get stageHeight():		Number			{	return Starling.current.stage.stageHeight;	}
protected function loc(resourceName:String, parameters:Array = null):String
{
	return StrUtils.loc(resourceName, parameters);
}
}
}