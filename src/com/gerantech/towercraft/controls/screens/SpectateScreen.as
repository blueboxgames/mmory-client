package com.gerantech.towercraft.controls.screens
{
import com.gerantech.towercraft.controls.items.BattleItemRenderer;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gt.towers.battle.fieldes.FieldData;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.Room;
import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.SFSObject;
import com.smartfoxserver.v2.entities.variables.SFSRoomVariable;
import com.smartfoxserver.v2.requests.LeaveRoomRequest;
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
	var sfsObj:SFSObject = new SFSObject();
	sfsObj.putText("t", cmd);
	
	sfsConnection = SFSConnection.instance;
	sfsConnection.addEventListener(SFSEvent.CONNECTION_LOST,	sfs_connectionLostHandler);
	sfsConnection.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_responseUpdateHandler);
	sfsConnection.addEventListener(SFSEvent.ROOM_VARIABLES_UPDATE, sfs_roomVariablesUpdateHandler);
	sfsConnection.sendExtensionRequest("spectateBattles", sfsObj);
	
	title = loc("button_spectate");
	showTileAnimationn = false;
	super.initialize();
	listLayout.gap = 0;	
	list.itemRendererFactory = function():IListItemRenderer { return new BattleItemRenderer(); }
	list.dataProvider = rooms;
}

protected function sfs_responseUpdateHandler(event:SFSEvent):void
{
	if( event.params.cmd != "spectateBattles" )
		return;
	updateRooms(SFSRoomVariable(sfsConnection.getRoomByName(cmd).getVariable("rooms")).getSFSArrayValue());
}
override protected function list_changeHandler(event:Event):void
{
	super.list_changeHandler(event);
	appModel.navigator.runBattle(SFSObject(list.selectedItem).getInt("id"), false, player.nickName, 0);
}

protected function sfs_roomVariablesUpdateHandler(event:SFSEvent):void
{
	if( cmd != event.params.room.name || event.params.changedVars.indexOf("rooms") == -1 )
		return;
	updateRooms(SFSRoomVariable(event.params.room.getVariable("rooms")).getSFSArrayValue());
}

private function updateRooms(_rooms:ISFSArray):void
{
	var battles:Array = new Array();
	for (var i:int = 0; i < _rooms.size(); i++) 
		battles.push(_rooms.getSFSObject(i));
	
	/*for (var i:int = 0; i < 12; i++) 
	{
		var battle:SFSObject = new SFSObject();
		battle.putInt("id", i);
		battle.putText("name", "name_"+i);
		battle.putInt("startAt", 23423424324);
		var players:SFSArray = new SFSArray();
		for (var j:int = 0; j < 2; j++) 
		{
			var p:SFSObject = new SFSObject();
			p.putText("n", "player-" + i + "-" + j);
			p.putText("ln", "lobby " + i);
			p.putInt("lp", i);
			players.addSFSObject(p);
		}
		battle.putSFSArray("players", players);
		battles.push(battle);
	}*/

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
	sfsConnection.removeEventListener(SFSEvent.ROOM_VARIABLES_UPDATE, sfs_roomVariablesUpdateHandler);
}
override protected function backButtonFunction():void
{
	dispatchEventWith(Event.COMPLETE);
}
override public function dispose():void
{
	var r:Room = sfsConnection.getRoomByName(cmd)
	sfsConnection.send(new LeaveRoomRequest(sfsConnection.getRoomByName(cmd)));
	removeConnectionListeners();
	super.dispose();
}
}
}