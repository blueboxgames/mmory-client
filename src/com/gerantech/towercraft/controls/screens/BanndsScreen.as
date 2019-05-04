package com.gerantech.towercraft.controls.screens
{
import com.gerantech.towercraft.controls.items.BanMessageItemRenderer;
import com.gerantech.towercraft.controls.items.InfractionItemRenderer;
import com.gerantech.towercraft.controls.popups.AdminBanPopup;
import com.gerantech.towercraft.controls.popups.ProfilePopup;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSArray;
import com.smartfoxserver.v2.entities.data.SFSObject;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import starling.events.Event;

public class BanndsScreen extends ListScreen
{
public var target:int;
public function BanndsScreen(){}
override protected function initialize() : void
{
	title = "Ban messages of " + target ;
	super.initialize();
	
	listLayout.paddingRight = listLayout.paddingLeft = listLayout.gap = 2;	
	list.itemRendererFactory = function():IListItemRenderer { return new BanMessageItemRenderer(); }

	// send request
	var params:SFSObject = new SFSObject();
	params.putInt("id", target);
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_issuesResponseHandler);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.BANNED_DATA_GET, params);
}

protected function sfs_issuesResponseHandler(event:SFSEvent) : void
{
	if( event.params.cmd != SFSCommands.BANNED_DATA_GET )
		return;
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_issuesResponseHandler);
	var bannes:SFSArray = SFSArray(SFSObject(event.params.params).getSFSArray("data"));
	var bannesArray:Array = new Array();
	for (var i:int = 0; i < bannes.size(); i++)
		bannesArray.push(bannes.getSFSObject(i));
	list.dataProvider = new ListCollection(bannesArray);
}

override protected function list_changeHandler(event:Event) : void
{
	if( list.selectedItem == null )
		return;
	var msg:SFSObject = list.selectedItem as SFSObject;
	appModel.navigator.addPopup( new ProfilePopup({name:msg.getUtfString("name"), id:msg.getInt("id")}) );
}
}
}