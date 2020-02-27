package com.gerantech.towercraft.controls.screens
{
import com.gerantech.mmory.core.constants.PrefsTypes;
import com.gerantech.towercraft.Game;
import com.gerantech.towercraft.controls.popups.BroadcastMessagePopup;
import com.gerantech.towercraft.controls.popups.RestorePopup;

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
	list.dataProvider = new ListCollection(["Players", "Track Issues", "Offends", "Push Message", "Debug Battle", "Restore", "Spectate Battles", "Search Chat"])
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
		case "Spectate Battles":
			appModel.navigator.getScreen(Game.SPECTATE_SCREEN).properties.cmd = String(list.selectedItem).toLowerCase() ;
			appModel.navigator.pushScreen(Game.SPECTATE_SCREEN) ;
			break;
		case "Search Chat":
			appModel.navigator.pushScreen(Game.SEARCH_CHAT_SCREEN);
			break;
		case "Debug Battle":
			appModel.navigator.runBattle(player.prefs.getAsInt(PrefsTypes.CHALLENGE_INDEX) == -1 ? 0 : player.prefs.getAsInt(PrefsTypes.CHALLENGE_INDEX),true, null, 0, true);
			break;
	}
}
}
}