package com.gerantech.towercraft.models.vo
{
import com.gerantech.towercraft.managers.ExchangeManager;
import com.gerantech.towercraft.managers.TimeManager;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.AppModel;
import com.gt.towers.Player;
import com.gt.towers.battle.units.Card;
import com.gt.towers.constants.ExchangeType;
import com.gt.towers.exchanges.ExchangeItem;
import com.gt.towers.socials.Challenge;
import flash.events.Event;

public class TabItemData
{
public var index:int;
public var badgeNumber:int;
public var newBadgeNumber:int;
public var icon:String;
public var label:String;
public var width:Number;
private var player:Player;
public function TabItemData(index:int)
{
	this.index = index;
	player = AppModel.instance.game.player;
	update();
}

protected function exchangeManager_endHandler(e:Event):void 
{
	update();
}

public function update() : void 
{
	if( player.inTutorial() )
		return;
	
	if( index == 0 )
	{
		var keys:Vector.<int> = player.game.exchanger.items.keys();
		for each( var k:int in keys )
		{
			var e:ExchangeItem = player.game.exchanger.items.get(k);
			if( (e.category == ExchangeType.C20_SPECIALS && e.type != ExchangeType.C29_DAILY_BATTLES && e.numExchanges == 0 ) || (e.category == ExchangeType.C30_BUNDLES && e.expiredAt > TimeManager.instance.now) )
			{
				newBadgeNumber ++;
				badgeNumber ++;
			}
		}
		
	}
	else if( index == 1 )
	{
		keys = player.cards.keys();
		for each( k in keys )
		{
			var b:Card = player.cards.get(k);
			if( b == null )
				continue;
			
			//trace(b.type, b.upgradable() , player.cards.get(b.type).level);
			if( b.upgradable() )
				badgeNumber ++;
			
			if( player.cards.get(b.type).level == -1 )
				newBadgeNumber ++;
		}
	}
	else if( index == 3 )
	{
		badgeNumber = SFSConnection.instance.lobbyManager.numUnreads();
	}/*
	else if( index == 4 && player.get_arena(0) > 2 )
	{
		if( player.challenges != null )
		{
			keys = player.challenges.keys();
			for each( k in keys )
			{
				var c:Challenge = player.challenges.get(k);
				if( c.getState(TimeManager.instance.now) == Challenge.STATE_1_STARTED )
					newBadgeNumber ++;
				badgeNumber ++;
			}
		}
		else
		{
			badgeNumber ++;
		}
	}*/
}
}
}