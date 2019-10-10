package com.gerantech.towercraft.managers
{
import com.gerantech.extensions.NativeAbilities;
import com.gerantech.mmory.core.constants.ExchangeType;
import com.gerantech.mmory.core.constants.PrefsTypes;
import com.gerantech.mmory.core.exchanges.ExchangeItem;
import com.gerantech.mmory.core.exchanges.Exchanger;
import com.gerantech.towercraft.managers.net.LoadingManager;
import com.gerantech.towercraft.models.AppModel;

import flash.filesystem.File;

public class NotificationManager extends BaseManager
{
private var iconFile:File;
private var soundFile:File;
public function NotificationManager(){}
public function init():void
{
	soundFile = File.applicationStorageDirectory.resolvePath("assets/whoosh.mp3");
	if( !soundFile.exists )
		File.applicationDirectory.resolvePath("assets/whoosh.mp3").copyTo(soundFile, true);

	iconFile = File.applicationStorageDirectory.resolvePath("assets/ic_notifications.png");
	if( !iconFile.exists )
		File.applicationDirectory.resolvePath("assets/ic_notifications.png").copyTo(iconFile, true);
}

public function reset():void
{
	if( appModel.loadingManager.state < LoadingManager.STATE_LOADED )
		return;

	clear();
	if( !appModel.game.player.prefs.getAsBool(PrefsTypes.SETTINGS_3_NOTIFICATION) )
		return;
	
	var date:Date = new Date();
	var secondsInDay:int = 24 * 3600000;
	
	// remember after a day, 3 days and a week ...
	notify("notify_remember_day",	date.time + secondsInDay * 1);
	notify("notify_remember_3days", date.time + secondsInDay * 3);
	notify("notify_remember_week",	date.time + secondsInDay * 7);

	// notify exchanger items ...
	var time:int = date.time / 1000;
	var exchanger:Exchanger = AppModel.instance.game.exchanger;
	var numReadiesForgot:int = 0;
	var numWaitsForgot:int = 0;
	var itemsKey:Vector.<int> = exchanger.items.keys();
	var i:int = 0;
	var existsBusy:Boolean = false;
	while( i < itemsKey.length )
	{
		var cate:int = ExchangeType.getCategory(itemsKey[i]);
		var state:int = exchanger.items.get(itemsKey[i]).getState(TimeManager.instance.now);
		if( cate == ExchangeType.C110_BATTLES )
		{
			existsBusy = existsBusy || state == ExchangeItem.CHEST_STATE_BUSY;
			if( existsBusy )
				numWaitsForgot = 0;
			if( state == ExchangeItem.CHEST_STATE_READY )
				numReadiesForgot ++;
			else if( state == ExchangeItem.CHEST_STATE_WAIT && !existsBusy )
				numWaitsForgot ++;
		}
		/*else if( cate == ExchangeType.C100_FREES )
		{
			notify("notify_exchange_wait_" + cate, (exchanger.items.get(itemsKey[i]).expiredAt + 15 + Math.random() * 10) * 1000);
		}*/
		i++;
	}
	
	if( Math.random() > 0.4 )
		return;
	
	var later:int = 1000 + Math.random() * 10000;
	if( numReadiesForgot > 0 )
		notify("notify_exchange_ready_forgot_" + Math.min(2, numReadiesForgot),	date.time + later);
	else if( numWaitsForgot > 0 )
		notify("notify_exchange_wait_forgot",	date.time + later);
}

private function notify(message:String, time:Number):void
{
	var title:String = AppModel.instance.descriptor.name;
	//trace(title, loc(message))
	NativeAbilities.instance.scheduleLocalNotification(title, title, loc(message), time, 0, "", "", iconFile.exists?iconFile.nativePath:"", soundFile.exists?soundFile.nativePath:"");
	//var d:Date = new Date();d.time=time;trace(title, message, d)
}

public function clear():void
{
	NativeAbilities.instance.cancelLocalNotifications();
}	
}
}