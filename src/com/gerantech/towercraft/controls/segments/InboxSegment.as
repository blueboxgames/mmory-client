package com.gerantech.towercraft.controls.segments 
{
import com.gerantech.towercraft.Game;
import com.gerantech.towercraft.controls.items.InboxThreadItemRenderer;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.managers.InboxService;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.vo.InboxThread;

import feathers.controls.ImageLoader;
import feathers.controls.List;
import feathers.controls.StackScreenNavigatorItem;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalLayout;

import flash.geom.Rectangle;

import starling.events.Event;
/**
* @author Mansour Djawadi
*/
public class InboxSegment extends Segment 
{
public var threadsCollection:ListCollection;
public var issueMode:Boolean;
private var listLayout:VerticalLayout;
private var list:List;
public function InboxSegment() { super(); }
override public function init():void
{
	if( initializeCompleted )
		return;
	super.init();
	layout = new AnchorLayout();
	
	if( threadsCollection == null )
		threadsCollection = InboxService.instance.threads;
	
	if( threadsCollection.length == 0 )
	{
		var emptyDisplay:ShadowLabel = new ShadowLabel(loc("inbox_empty_label"));
		emptyDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, 0);
		addChild(emptyDisplay);
		return;
	}

	var headerDisplay:ImageLoader = new ImageLoader();
	headerDisplay.source = Assets.getTexture("socials/header", "gui");
	headerDisplay.layoutData = new AnchorLayoutData(-10, -10, NaN, -10);
	headerDisplay.scale9Grid = new Rectangle(1, 1, 1, 1);
	headerDisplay.height = 180;
	addChild(headerDisplay);

	var titleDisplay:ShadowLabel = new ShadowLabel(loc("tab-4"));
	titleDisplay.layoutData = new AnchorLayoutData(44, NaN, NaN, NaN, 0);
	addChild(titleDisplay);

	listLayout = new VerticalLayout();
	listLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
	listLayout.gap = 10;
	listLayout.padding = 20;	
	listLayout.paddingTop = 200;
	listLayout.useVirtualLayout = true;
	listLayout.typicalItemHeight = 164;
	
	list = new List();
	list.layout = listLayout;
	list.dataProvider = threadsCollection;
	list.addEventListener(Event.CHANGE, list_changeHandler);
	list.layoutData = new AnchorLayoutData(0, paddingH, 0, paddingH);
	list.itemRendererFactory = function():IListItemRenderer { return new InboxThreadItemRenderer(); }
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