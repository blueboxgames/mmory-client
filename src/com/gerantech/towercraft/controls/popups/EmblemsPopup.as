package com.gerantech.towercraft.controls.popups
{
import com.gerantech.towercraft.controls.items.EmblemItemRenderer;
import feathers.controls.List;
import feathers.controls.ScrollBarDisplayMode;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.layout.AnchorLayoutData;
import feathers.layout.TiledRowsLayout;
import flash.geom.Rectangle;
import starling.events.Event;

public class EmblemsPopup extends SimplePopup
{
private var list:List;

public function EmblemsPopup(){}
override protected function initialize():void
{
	super.initialize();
	
	transitionOut.destinationBound = transitionIn.sourceBound = new Rectangle(stage.stageWidth*0.15, stage.stageHeight*0.15, stage.stageWidth*0.7, stage.stageHeight*0.7);
	transitionOut.sourceBound = transitionIn.destinationBound = new Rectangle(stage.stageWidth*0.10, stage.stageHeight*0.10, stage.stageWidth*0.8, stage.stageHeight*0.8);
	rejustLayoutByTransitionData();

	var listLayout:TiledRowsLayout = new TiledRowsLayout();
	listLayout.gap = padding;
	listLayout.useSquareTiles = false;
	listLayout.requestedColumnCount = 5;
	listLayout.typicalItemWidth = (transitionIn.destinationBound.width-listLayout.gap*(listLayout.requestedColumnCount+1)) / listLayout.requestedColumnCount;
	listLayout.typicalItemHeight = listLayout.typicalItemWidth * 1.06;
	
	list = new List();
	list.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
	list.layout = listLayout;
	list.layoutData = new AnchorLayoutData(padding, padding, padding, padding);
	list.itemRendererFactory = function():IListItemRenderer { return new EmblemItemRenderer(); }
	list.addEventListener(Event.CHANGE, list_changeHandler);
	addChild(list);
}
override protected function transitionInCompleted():void
{
	super.transitionInCompleted();
	var collection:ListCollection = new ListCollection();
	for (var i:int = 0; i < 110; i++) 
		collection.addItem(i);
	list.dataProvider = collection;
}
protected override function transitionOutStarted():void
{
	list.removeFromParent();
	super.transitionOutStarted();
}

private function list_changeHandler(event:Event):void
{
	dispatchEventWith(Event.SELECT, false, list.selectedIndex);
	close();
}
}
}