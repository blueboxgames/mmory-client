package com.gerantech.towercraft.controls.toasts 
{
	import com.gerantech.towercraft.controls.items.EmoteItemRenderer;
	import com.gerantech.towercraft.controls.segments.lobby.LobbyChatItemSegment;
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.themes.MainTheme;
	import feathers.controls.List;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.data.ListCollection;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.TiledRowsLayout;
	import feathers.layout.VerticalAlign;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.events.Event;
/**
* @author Mansour Djawadi
*/
public class EmoteToast extends BaseToast 
{
	private var list:feathers.controls.List;

public function EmoteToast() 
{
	super();
	//this.closeOnStage = this.closeWithKeyboard = true;
	this.toastHeight = 312;
	this.animationMode = BaseToast.ANIMATION_MODE_BOTTOM;
}
override protected function initialize():void
{
	hasOverlay = true;
	super.initialize();
	this.layout = new AnchorLayout();
	overlay.alpha = 0;

	var background:Image = new Image(appModel.theme.backgroundSkinTexture);
	background.scale9Grid = MainTheme.DEFAULT_BACKGROUND_SCALE9_GRID;
	background.alpha = 0.9;
	backgroundSkin = background;

	var listLayout:TiledRowsLayout = new TiledRowsLayout();
	listLayout.requestedColumnCount = 5;
	listLayout.paddingTop = -20;
	listLayout.padding = -10;
	listLayout.gap = -35;
	listLayout.horizontalAlign = VerticalAlign.JUSTIFY;
	listLayout.typicalItemWidth = (stageWidth - listLayout.padding * 2 - listLayout.gap * (listLayout.requestedColumnCount - 1)) / listLayout.requestedColumnCount;
	listLayout.typicalItemHeight = 180;
	listLayout.verticalAlign = VerticalAlign.JUSTIFY;
	listLayout.useVirtualLayout = true;
	
	list = new List();
	list.layout = listLayout;
	list.layoutData = new AnchorLayoutData(0, 0, NaN, 0);
	list.itemRendererFactory = function () : IListItemRenderer { return new EmoteItemRenderer(); }
	list.dataProvider = new ListCollection([0, 1, 2, 3, 4]);
	list.addEventListener(Event.CHANGE, list_changeHandler);
	addChild(list);
}

protected function list_changeHandler(event:Event) : void 
{
	dispatchEventWith(Event.CHANGE, false, list.selectedIndex);
	close();
}
}
}