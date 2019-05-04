package com.gerantech.towercraft.controls.overlays
{
import com.gerantech.towercraft.controls.items.RatingItemRenderer;
import com.gerantech.towercraft.controls.tooltips.ConfirmTooltip;
import com.gerantech.towercraft.models.tutorials.TutorialTask;
import dragonBones.events.EventObject;
import dragonBones.starling.StarlingArmatureDisplay;
import dragonBones.starling.StarlingEvent;
import feathers.controls.List;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalLayout;
import flash.geom.Rectangle;
import starling.events.Event;

public class RatingMessageOverlay extends TutorialMessageOverlay
{
private var list:List;
public function RatingMessageOverlay(task:TutorialTask):void { super(task); }
override protected function characterArmature_completeHandler(event:StarlingEvent) : void
{
	var position:Rectangle = new Rectangle(characterArmature.x, stageHeight - 900, 1, 1);
	var tootlip:ConfirmTooltip = new ConfirmTooltip( loc(task.message) + "\n\n\n\n", position, 1, 0.75, false);
	tootlip.valign = "bot";
	tootlip.addEventListener(FeathersEventType.CREATION_COMPLETE, tootlip_createCompleteHandler);
	tootlip.addEventListener(Event.SELECT, tootlip_eventsHandler); 
	tootlip.addEventListener(Event.CANCEL, tootlip_eventsHandler); 
	addChild(tootlip);
}

protected function tootlip_createCompleteHandler(event:Event):void 
{
	var tootlip:ConfirmTooltip = event.currentTarget as ConfirmTooltip;
	tootlip.removeEventListener(FeathersEventType.CREATION_COMPLETE, tootlip_createCompleteHandler);
	
	var numItems:int = tootlip.numChildren - 1;
	/*for( var i:int = numItems; i >= 0 ; i-- )
		if( tootlip.getChildAt(i) is CustomButton )
			tootlip.removeChildAt(i);*/
	
	var listLayout:HorizontalLayout = new HorizontalLayout();
	list = new List();
	list.layoutData = new AnchorLayoutData(NaN, NaN, 220, NaN, 0);
	list.layout = listLayout;
	list.dataProvider = new ListCollection([{i:0,s:false}, {i:1,s:false}, {i:2,s:false}, {i:3,s:false}, {i:4,s:false}]);
	list.itemRendererFactory = function () : IListItemRenderer { return new RatingItemRenderer(); }
	list.addEventListener(Event.CHANGE, list_changeHander);
	tootlip.addChild(list);
}

private function list_changeHander(event:Event) : void 
{
	var selectedIndex:int = list.selectedIndex;
	list.removeEventListener(Event.CHANGE, list_changeHander);
	for( var j:int = 0; j < 5; j++ )
		list.dataProvider.setItemAt({i:j, s: j <= selectedIndex}, j);
	list.selectedIndex = selectedIndex;
	list.addEventListener(Event.CHANGE, list_changeHander);
}

override protected function tootlip_eventsHandler(event:Event):void
{
	if( list.selectedIndex == -1 )
	{
		appModel.navigator.addLog(loc("popup_offer_30_error"), 200);
		return;
	}
	
	dispatchEventWith(list.selectedIndex > 2 ? Event.SELECT : Event.CANCEL);
	ConfirmTooltip(event.currentTarget).close();
	close();
}
}
}