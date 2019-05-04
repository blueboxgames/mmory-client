package com.gerantech.towercraft.controls.segments 
{
import com.gerantech.towercraft.Game;
import com.gerantech.towercraft.controls.FastList;
import com.gerantech.towercraft.controls.items.InboxThreadItemRenderer;
import com.gerantech.towercraft.managers.InboxService;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.models.vo.InboxThread;
import feathers.controls.StackScreenNavigatorItem;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalLayout;
import starling.events.Event;
/**
* @author Mansour Djawadi
*/
public class InboxSegment extends Segment 
{
public var threadsCollection:ListCollection;
public var issueMode:Boolean;
private var listLayout:VerticalLayout;
private var list:FastList;
public function InboxSegment() { super(); }
override public function init():void
{
	if( initializeCompleted )
		return;
	super.init();
	layout = new AnchorLayout();
	
	if( threadsCollection == null )
		threadsCollection = InboxService.instance.threads;
	
	listLayout = new VerticalLayout();
	listLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
	listLayout.gap = listLayout.padding = 10;	
	listLayout.paddingTop = 100;
	listLayout.useVirtualLayout = true;
	listLayout.typicalItemHeight = 164;
	
	list = new FastList();
	list.layout = listLayout;
	list.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	list.addEventListener(Event.CHANGE, list_changeHandler);
	list.itemRendererFactory = function():IListItemRenderer { return new InboxThreadItemRenderer(); }
	list.dataProvider = threadsCollection;
	addChild(list);
}

protected function list_changeHandler(event:Event) : void 
{
	openThread(list.selectedItem, issueMode);
}

static public function openThread(threadData:Object = null, issueMode:Boolean = false) : void 
{
	if( threadData == null )
		threadData = {sender:"Admin", senderId:10000}; 
	var item:StackScreenNavigatorItem = AppModel.instance.navigator.getScreen(Game.INBOX_SCREEN);
	item.properties.thread = new InboxThread(threadData);
	item.properties.myId = issueMode ? 10000 : AppModel.instance.game.player.id;
	InboxService.instance.requestRelations(item.properties.thread.ownerId, issueMode ? 10000 : -1);
	AppModel.instance.navigator.pushScreen(Game.INBOX_SCREEN);}
}
}