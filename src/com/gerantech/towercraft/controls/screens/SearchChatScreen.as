package com.gerantech.towercraft.controls.screens
{
import com.gerantech.towercraft.controls.items.PlayersItemRenderer;
import com.gerantech.towercraft.controls.items.SearchChatItemRenderer;
import com.gerantech.towercraft.controls.popups.ProfilePopup;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.data.SFSArray;
import com.smartfoxserver.v2.entities.data.SFSObject;
import feathers.controls.renderers.IListItemRenderer;
import feathers.events.FeathersEventType;
import starling.events.Event;

public class SearchChatScreen extends SearchScreen
{
public function SearchChatScreen(){}
override protected function initialize() : void
{
	patternLimit = 2;
	title = "Search in lobby cha";
	showTileAnimationn = false;
	super.initialize();
	textInput.prompt = "insert word";
	listLayout.paddingLeft = listLayout.paddingRight = 10;
	list.itemRendererFactory = function():IListItemRenderer { return new SearchChatItemRenderer(); }
	list.addEventListener(FeathersEventType.FOCUS_IN, list_focusHandler);
}

override protected function searchButton_triggeredHandler(e:Event) : Boolean
{
	if( !super.searchButton_triggeredHandler(e) )
		return false;
	
	var params:SFSObject = new SFSObject();
	params.putUtfString("p", textInput.text);
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_issuesResponseHandler);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.SEARCH_IN_CHATS, params);
	return true;
}
protected function sfs_issuesResponseHandler(event:SFSEvent):void
{
	if( event.params.cmd != SFSCommands.SEARCH_IN_CHATS )
		return;
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_issuesResponseHandler);
	result.removeAll();
	var chats:SFSArray = SFSArray(SFSObject(event.params.params).getSFSArray("result"));
	for (var i:int = 0; i < chats.size(); i++)
		result.addItem(chats.getSFSObject(i));
//	trace(event.params.params.getDump())
}

protected function list_focusHandler(event:Event) : void
{
}
}
}