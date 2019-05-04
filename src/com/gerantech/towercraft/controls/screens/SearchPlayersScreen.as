package com.gerantech.towercraft.controls.screens
{
import com.gerantech.towercraft.controls.items.PlayersItemRenderer;
import com.gerantech.towercraft.controls.popups.ProfilePopup;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.data.SFSArray;
import com.smartfoxserver.v2.entities.data.SFSObject;
import feathers.controls.renderers.IListItemRenderer;
import feathers.events.FeathersEventType;
import starling.events.Event;

public class SearchPlayersScreen extends SearchScreen
{
public function SearchPlayersScreen(){}
override protected function initialize() : void
{
	title = "Players";
	showTileAnimationn = false;
	super.initialize();
	textInput.prompt = "نام  |  آیدی(!)  |  تگ(#)";
	list.itemRendererFactory = function():IListItemRenderer { return new PlayersItemRenderer(); }
	list.addEventListener(FeathersEventType.FOCUS_IN, list_focusHandler);
}

override protected function searchButton_triggeredHandler(e:Event) : Boolean
{
	if( !super.searchButton_triggeredHandler(e) )
		return false;
	
	var params:SFSObject = new SFSObject();
	if( textInput.text.substr(0, 1) == "#" )
		params.putText("tag", textInput.text.substr(1));
	else if( textInput.text.substr(0, 1) == "!" )
		params.putInt("id", int(textInput.text.substr(1)));
	else
		params.putUtfString("name", textInput.text);
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_issuesResponseHandler);
	SFSConnection.instance.sendExtensionRequest("playersGet", params);
	return true;
}
protected function sfs_issuesResponseHandler(event:SFSEvent):void
{
	if( event.params.cmd != "playersGet" )
		return;
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_issuesResponseHandler);
	result.data = SFSArray(SFSObject(event.params.params).getSFSArray("players")).toArray();
}

protected function list_focusHandler(event:Event):void
{
    appModel.navigator.addPopup(new ProfilePopup(event.data.data));
}
}
}