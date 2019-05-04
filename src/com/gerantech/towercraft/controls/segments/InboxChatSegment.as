package com.gerantech.towercraft.controls.segments 
{
import com.gerantech.towercraft.controls.items.InboxChatItemRenderer;
import com.gerantech.towercraft.controls.items.lobby.LobbyChatItemRenderer;
import com.gerantech.towercraft.controls.popups.ConfirmPopup;
import com.gerantech.towercraft.controls.popups.ProfilePopup;
import com.gerantech.towercraft.controls.popups.SimpleListPopup;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.vo.InboxThread;
import com.gerantech.towercraft.models.vo.UserData;
import com.gerantech.towercraft.utils.StrUtils;
import com.gt.towers.constants.MessageTypes;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSArray;
import com.smartfoxserver.v2.entities.data.SFSObject;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.layout.AnchorLayout;
import flash.utils.setTimeout;
import starling.core.Starling;
import starling.events.Event;
/**
* @author Mansour Djawadi
*/
public class InboxChatSegment extends ChatSegment 
{
private var preText:String = "";
private var sfsData:ISFSArray;
private var thread:InboxThread;
private var threadCollection:ListCollection;
private var myId:int;

public function InboxChatSegment(myId:int){ this.myId = myId; }
public function setData(sfsData:ISFSArray, thread:InboxThread):void 
{
	this.sfsData = sfsData;
	this.thread = thread;
	layout = new AnchorLayout();

	threadCollection = new ListCollection();
	for( var i:int = 0; i < sfsData.size(); i++ )
		threadCollection.addItem(sfsData.getSFSObject(i));
	showElements();
}


override protected function showElements() : void
{
	super.showElements();
	chatLayout.gap = -10;
	chatList.itemRendererFactory = function ():IListItemRenderer { return new InboxChatItemRenderer(myId)};
	chatList.dataProvider = threadCollection;
	//manager.addEventListener(Event.UPDATE, manager_updateHandler);
}

override protected function chatList_focusInHandler(event:Event):void
{
    if( !_buttonsEnabled )
        return;
	trace("chatList_focusInHandler");
	/*var selectedItem:LobbyChatItemRenderer = event.data as LobbyChatItemRenderer;
	if( selectedItem == null )
		return;
	
	var msgPack:ISFSObject = selectedItem.data as ISFSObject;
	// prevent hints for my messages
	if( msgPack.getInt("i") != player.id && msgPack.getShort("m") == MessageTypes.M0_TEXT )
		showSimpleListPopup(msgPack, selectedItem, buttonsPopup_selectHandler, buttonsPopup_selectHandler, "lobby_report", "lobby_profile", "lobby_reply");
}

override protected function buttonsPopup_selectHandler(event:Event):void
{
	var buttonsPopup:SimpleListPopup = event.currentTarget as SimpleListPopup;
	buttonsPopup.removeEventListener(Event.SELECT, buttonsPopup_selectHandler);
	buttonsPopup.removeEventListener(Event.CLOSE, buttonsPopup_selectHandler);
	
	if( event.type == Event.CLOSE )
		return;
	
	var msgPack:ISFSObject = buttonsPopup.data as ISFSObject;
	switch( event.data )
	{
		case "lobby_profile":
            var user:Object = {name:msgPack.getUtfString("s"), id:int(msgPack.getInt("i"))};
            if( !manager.isPublic )
            {
                user.ln = manager.lobby.name;
                user.lp = manager.emblem;
            }
            appModel.navigator.addPopup( new ProfilePopup(user) );
			break;
		
		case "lobby_report":
			var confirm:ConfirmPopup = new ConfirmPopup(loc("popup_sure_label"), loc("popup_yes_label"));
			confirm.acceptStyle = "danger";
			confirm.addEventListener(Event.SELECT, confirm_selectHandler);
			appModel.navigator.addPopup(confirm);
			break;
		
		case "lobby_reply":
			chatButton_triggeredHandler(null);
			var msg:String = msgPack.getUtfString("t");
			preText = "@" + msgPack.getUtfString("s") + ": " + msg.substr(msg.lastIndexOf("\n") + 1, 20) + "... :\n";
			break;
	}
	function confirm_selectHandler(evet:Event):void
	{
		var sfsReport:ISFSObject = new SFSObject();
		sfsReport.putUtfString("t", msgPack.getUtfString("t"));
		sfsReport.putInt("i", msgPack.getInt("i"));
		sfsReport.putInt("u", msgPack.getInt("u"));
		SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_reportResponseHandler);
		SFSConnection.instance.sendExtensionRequest(SFSCommands.LOBBY_REPORT, sfsReport, manager.lobby);
	}
	function sfs_reportResponseHandler(e:SFSEvent):void
	{
		if( e.params.cmd != SFSCommands.LOBBY_REPORT )
			return;
		SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_reportResponseHandler);
		appModel.navigator.addLog(loc("lobby_report_response_" + e.params.params.getInt("response")) );
	}*/
}

/*protected function manager_updateHandler(event:Event):void
{
	if( Starling.current.nativeStage.frameRate < 1 )
		return;
	UserData.instance.lastLobbeyMessageTime = timeManager.now;
	buttonsEnabled = manager.getMyRequestBattleIndex() == -1;
	chatList.validate();
    if( autoScroll )
        scrollToEnd();
}*/

override protected function chatButton_triggeredHandler(event:Event):void
{
	super.chatButton_triggeredHandler(event);
	preText = "";
}

override protected function sendButton_triggeredHandler(event:Event):void
{
	if( chatTextInput.text == "" )
		return;
	trace(chatTextInput.text);
	if( checkVerbos() )
	{
		appModel.navigator.addLog(loc("lobby_message_limit"));
		return;
	}
	
	var params:SFSObject = new SFSObject();
	params.putShort("type", 0);
	params.putInt("senderId", myId);
    params.putUtfString("text", preText + StrUtils.getSimpleString(chatTextInput.text));
	params.putIntArray("receiverIds", [thread.ownerId]);
	//params.putText("data", dataInput.text );
	//params.putBool("isPush", isPushSwitcher.value == 1 );
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsInstance_extensionResponseHandler);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.INBOX_BROADCAST, params);
	chatTextInput.text = preText = "";
	
	// temp message
    params.putLong("timestamp", new Date().time);
	threadCollection.addItem(params);
}

private function sfsInstance_extensionResponseHandler(event:SFSEvent) : void 
{
	if( event.params.cmd != SFSCommands.INBOX_BROADCAST )
		return;
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfsInstance_extensionResponseHandler);
	threadCollection.getItemAt(threadCollection.length - 1).putInt("status", 0);
	setTimeout(threadCollection.updateItemAt, 500, threadCollection.length - 1);
}

private function checkVerbos() : Boolean 
{
	var myMessages:int = 0;
	for( var i:int = threadCollection.length - 1; i >= 0; i-- )
	{
		if( threadCollection.getItemAt(i).getInt("senderId") != myId )
		{
			myMessages = 0;
			continue;
		}
		myMessages ++;
		if ( myMessages >= 3 )
			return true;
	}
	return false;
}

/*override public function dispose():void
{
	if( manager != null )
		manager.removeEventListener(Event.UPDATE, manager_updateHandler);
	super.dispose();
}*/
}
}