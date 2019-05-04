package com.gerantech.towercraft.controls.screens
{
import com.gerantech.towercraft.Game;
import com.gerantech.towercraft.controls.popups.BroadcastMessagePopup;
import com.gerantech.towercraft.controls.popups.RestorePopup;
import feathers.controls.StackScreenNavigatorItem;
import feathers.data.ListCollection;
import starling.events.Event;

public class AdminScreen extends ListScreen
{
override protected function initialize():void
{
	title = "Admin Screen";
	showTileAnimationn = false;
	super.initialize();
	
	listLayout.gap = 0;	
//	list.itemRendererFactory = function():IListItemRenderer { return new SettingsItemRenderer(); }
	list.dataProvider = new ListCollection(["Players", "Track Issues", "Offends", "Push Message", "Restore", "Operations", "Battles", "Search Chat"])
}

override protected function list_changeHandler(event:Event):void
{
	super.list_changeHandler(event);
	switch(list.selectedItem)
	{
		case "Players":
			appModel.navigator.pushScreen(Game.PLAYERS_SCREEN);
			break;
		case "Track Issues":
			//appModel.navigator.getScreen(Game.ISSUES_SCREEN).properties.reporter = -1;
			appModel.navigator.pushScreen(Game.ISSUES_SCREEN);
			break;
		case "Offends":
			appModel.navigator.getScreen(Game.OFFENDS_SCREEN).properties.target = 0;
			appModel.navigator.pushScreen(Game.OFFENDS_SCREEN);
			break;
		case "Restore":
			appModel.navigator.addPopup(new RestorePopup());
			break;
		case "Push Message":
			appModel.navigator.addPopup(new BroadcastMessagePopup());
			break;
		case "Operations":
		case "Battles":
			var item:StackScreenNavigatorItem = appModel.navigator.getScreen( Game.SPECTATE_SCREEN );
			item.properties.cmd = String(list.selectedItem).toLowerCase() ;
			appModel.navigator.pushScreen( Game.SPECTATE_SCREEN ) ;
			break;
		case "Search Chat":
			appModel.navigator.pushScreen(Game.SEARCH_CHAT_SCREEN);
			break;
	}
}
}
}