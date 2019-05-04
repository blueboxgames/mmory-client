package com.gerantech.towercraft.controls.buttons 
{
import com.gerantech.towercraft.models.Assets;
import com.gt.towers.constants.PrefsTypes;
import com.gt.towers.events.CoreEvent;
import com.gt.towers.exchanges.ExchangeItem;
import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import flash.geom.Rectangle;
import starling.animation.Transitions;
import starling.core.Starling;

/**
* @author Mansour Djawadi
*/
public class CollectableLeaguesButton extends CollectableButton 
{
	private var leagueIndex:int;
public function CollectableLeaguesButton()
{
	super();
	width = 180;
	height = 198;
}
override protected function initialize() : void
{
	super.initialize();
	player.resources.addEventListener(CoreEvent.CHANGE, playerResources_changeHandler);
}

protected function playerResources_changeHandler(event:CoreEvent):void 
{
	checkLeagueRewardAchieved();
}

private function checkLeagueRewardAchieved() : void
{
	var availabledCards:Array = player.availabledCards(leagueIndex, 1);
	for each( var c:int in availabledCards )
		if( !player.cards.exists(c) )
			state = ExchangeItem.CHEST_STATE_READY;
	
	backgroundFactory();
}
override public function update() : void
{
	super.update();
	leagueIndex = player.get_arena(0);
	checkLeagueRewardAchieved();
	iconFactory("leagues/" + Math.floor(leagueIndex * 0.5));
	
	if( state == ExchangeItem.CHEST_STATE_READY )
	{
		function repeatPunch(isUp:Boolean):void {
			var s:Number = isUp ? 1.0 : 1.1;
			var t:Number = isUp ? 0.2 : 0.3;
			var d:Number = isUp ? 0.0 : 2.2;
			var e:String = isUp ? Transitions.LINEAR : Transitions.EASE_OUT_BACK;
			Starling.juggler.tween(backgroundDisplay,	t, {delay:d, scale:s, transition:e, onComplete:repeatPunch, onCompleteArgs:[!isUp]});
			Starling.juggler.tween(iconDisplay,			t, {delay:d, scale:s, transition:e});
		}
		repeatPunch(true);
	}

}

override protected function iconFactory(image:String) : ImageLoader 
{
	var _ret:ImageLoader = super.iconFactory(image);
	if( _ret == null )
		return null;
	_ret.pixelSnapping = false;
	_ret.layoutData = null;// new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, -15);
	_ret.x = width * 0.5;
	_ret.y = height * 0.5 - 15;
	_ret.width = width * 0.75;
	_ret.height = width * 0.75;
	_ret.pivotX = _ret.width * 0.5;
	_ret.pivotY = _ret.height * 0.5;
	return _ret;
}

override protected function backgroundFactory() : ImageLoader
{
	if( backgroundDisplay != null )
	{
		backgroundDisplay.source = Assets.getTexture("leagues/circle-" + (leagueIndex % 2) + "-" + state, "gui");
		return null;
	}

	backgroundDisplay = new ImageLoader();
	backgroundDisplay.source = Assets.getTexture("leagues/circle-" + (leagueIndex % 2) + "-" + state, "gui");
	backgroundDisplay.pixelSnapping = false;
	backgroundDisplay.height = height;
	backgroundDisplay.width = width;
	backgroundDisplay.y = height * 0.5;
	backgroundDisplay.x = width * 0.5;
	backgroundDisplay.pivotX = backgroundDisplay.width * 0.5;
	backgroundDisplay.pivotY = backgroundDisplay.height * 0.5;
	addChild(backgroundDisplay);
	return backgroundDisplay;
}

override protected function trigger() : void
{
	if( player.getTutorStep() > 47 )
		super.trigger();
}

override protected function reset() : void
{
	Starling.juggler.removeTweens(backgroundDisplay);
	Starling.juggler.removeTweens(iconDisplay);
	super.reset();
}

override public function dispose() : void
{
	player.resources.removeEventListener(CoreEvent.CHANGE, playerResources_changeHandler);
	super.dispose();
}
}
}