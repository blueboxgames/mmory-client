package com.gerantech.towercraft.controls.buttons 
{
import com.gt.towers.events.CoreEvent;
import com.gt.towers.exchanges.ExchangeItem;
import com.gt.towers.others.Quest;
import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayoutData;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

/**
* @author Mansour Djawadi
*/
public class CollectableQuestsButton extends CollectableButton 
{
private var timeoutId:uint;
public function CollectableQuestsButton(){ super(); }
override protected function initialize() : void
{
	super.initialize();
	player.resources.addEventListener(CoreEvent.CHANGE, playerResources_changeHandler);
}

private function playerResources_changeHandler(e:CoreEvent):void 
{
	clearTimeout(timeoutId);
	timeoutId = setTimeout( updateQuests, 10);
}

private function updateQuests():void 
{
	for each( var q:Quest in player.quests )
	{
		q.current = Quest.getCurrent(player, q.type, q.key);
		if( q.passed() )
			state = ExchangeItem.CHEST_STATE_READY;
	}
	backgroundFactory();
}
override public function update() : void
{
	reset();
	updateQuests();
	iconFactory("home/tasks");
}
override protected function iconFactory(image:String) : ImageLoader 
{
	var _ret:ImageLoader = super.iconFactory(image);
	if( _ret == null )
		return null;
	AnchorLayoutData(_ret.layoutData).left = 8;
	return _ret;
}
override public function dispose() : void
{
	clearTimeout(timeoutId);
	player.resources.removeEventListener(CoreEvent.CHANGE, playerResources_changeHandler);
	super.dispose();
}
}
}