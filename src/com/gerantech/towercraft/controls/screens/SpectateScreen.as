package com.gerantech.towercraft.controls.screens
{
import com.gerantech.mmory.core.constants.SFSCommands;
import com.gerantech.towercraft.controls.items.BattleItemRenderer;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.SFSObject;

import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;

import starling.events.Event;

public class SpectateScreen extends ListScreen
{
public var cmd:String;
private var sfsConnection:SFSConnection;
private var rooms:ListCollection = new ListCollection();

public function SpectateScreen(){}
override protected function initialize():void
{
	var params:SFSObject = new SFSObject();
	params.putText("t", cmd);
	
	sfsConnection = SFSConnection.instance;
	sfsConnection.addEventListener(SFSEvent.CONNECTION_LOST,	sfs_connectionLostHandler);
	sfsConnection.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_responseUpdateHandler);
	sfsConnection.sendExtensionRequest(SFSCommands.SPECTATE_JOIN, params);
	
	title = loc("button_spectate");
	showTileAnimationn = false;
	super.initialize();
	listLayout.gap = 0;	
	list.itemRendererFactory = function():IListItemRenderer { return new BattleItemRenderer(); }
	list.dataProvider = rooms;
}

protected function sfs_responseUpdateHandler(event:SFSEvent):void
{
	if( event.params.cmd == SFSCommands.SPECTATE_UPDATE )
		updateRooms(SFSObject(event.params.params).getSFSArray("rooms"));
}
override protected function list_changeHandler(event:Event):void
{
	super.list_changeHandler(event);
	var sfs:SFSObject = list.selectedItem as SFSObject;
	appModel.navigator.runBattle(sfs.getInt("id"), false, sfs.getSFSArray("players").getSFSObject(0).getInt("i"));
}


private function updateRooms(_rooms:ISFSArray):void
{
	var battles:Array = new Array();
	for (var i:int = 0; i < _rooms.size(); i++) 
		battles.push(_rooms.getSFSObject(i));
	rooms.data = battles;
}

protected function sfs_connectionLostHandler(event:SFSEvent):void
{
	removeConnectionListeners();
}
protected function removeConnectionListeners():void
{
	sfsConnection.removeEventListener(SFSEvent.CONNECTION_LOST,	sfs_connectionLostHandler);
	sfsConnection.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_responseUpdateHandler);
}
// override protected function backButtonFunction():void
// {
// 	dispatchEventWith(Event.COMPLETE);
// }
override public function dispose():void
{
	var params:SFSObject = new SFSObject();
	params.putText("t", cmd);
	sfsConnection.sendExtensionRequest(SFSCommands.SPECTATE_LEAVE, params);
	removeConnectionListeners();
	super.dispose();
}
}
}