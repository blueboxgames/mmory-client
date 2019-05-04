package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.managers.ExchangeManager;
import com.gerantech.towercraft.managers.TimeManager;
import com.gerantech.towercraft.managers.TutorialManager;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.utils.StrUtils;
import com.gt.towers.Game;
import com.gt.towers.Player;
import com.gt.towers.exchanges.Exchanger;
import feathers.controls.renderers.LayoutGroupListItemRenderer;
import feathers.skins.ImageSkin;
import flash.geom.Rectangle;
import flash.utils.clearInterval;
import flash.utils.setInterval;
import starling.core.Starling;
import starling.events.Event;

public class AbstractListItemRenderer extends LayoutGroupListItemRenderer
{
public var deleyCommit:Boolean = false;
public static var FAST_COMMIT_TIMEOUT:uint = 0;
public static var SLOW_COMMIT_TIMEOUT:uint = 400;

protected var skin:ImageSkin;
protected var ownerBounds:Rectangle;

private var intevalId:uint;
private var tempY:Number;
private var screenRect:Rectangle;
private var commitPhase:uint;

public function AbstractListItemRenderer(){}
override protected function initialize():void
{
	addEventListener( Event.REMOVED_FROM_STAGE, removedFromStageHandler );
}

override protected function commitData():void
{
	super.commitData();
	if( ownerBounds == null && _owner != null )
		ownerBounds = _owner.getBounds(stage);
	
	if( deleyCommit )
	{
		clearInterval(intevalId);
		intevalId = setInterval(checkScrolling, SLOW_COMMIT_TIMEOUT);
		commitPhase = 0;
	}
}

protected function onScreen (itemBounds:Rectangle) : Boolean
{
	if( ownerBounds == null )
		return true;
	return ownerBounds.contains(itemBounds.x + 1, itemBounds.y + 1) || ownerBounds.contains(itemBounds.x + itemBounds.width - 1, itemBounds.y + itemBounds.height - 1);
}
private function checkScrolling():void
{
	var itemBounds:Rectangle = getBounds(_owner);
	if( !onScreen(itemBounds) )
		return;
	
	var speed:Number = Math.abs(tempY - itemBounds.y);
	if( commitPhase == 0 && speed < 500 )
	{
		commitPhase = 1;
		commitBeforeStopScrolling();
	}
	else if( commitPhase == 1 && speed < 100 )
	{
		commitPhase = 2;
		clearInterval(intevalId);
		commitAfterStopScrolling();
	}
	tempY = itemBounds.y;
}		

protected function commitBeforeStopScrolling():void{}
protected function commitAfterStopScrolling():void{}
protected function removedFromStageHandler( event:Event ) : void { clearInterval(intevalId); }
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