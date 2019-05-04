package com.gerantech.towercraft.controls.popups 
{
import com.gerantech.towercraft.controls.items.challenges.ChallengeIndexItemRenderer;
import com.gerantech.towercraft.controls.overlays.TransitionData;
import com.gerantech.towercraft.themes.MainTheme;
import feathers.controls.List;
import feathers.controls.ScrollBarDisplayMode;
import feathers.controls.ScrollPolicy;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalLayout;
import flash.geom.Rectangle;
import starling.display.Image;
import starling.events.Event;
/**
* @author Mansour Djawadi
*/
public class FriendlyBattleModePopup extends AbstractPopup 
{
public function FriendlyBattleModePopup() { super(); }
override protected function initialize():void
{
	// create transition in data
	var _h:int = 700;
	var _p:int = 180;
	transitionIn = new TransitionData();
	transitionOut = new TransitionData();
	transitionOut.destinationAlpha = 0;
	transitionIn.sourceBound = transitionOut.destinationBound = new Rectangle(_p,	stageHeight - 600 - _h * 0.4,	stageWidth - _p * 2,	_h * 0.8);
	transitionOut.sourceBound = transitionIn.destinationBound = new Rectangle(_p,	stageHeight - 600 - _h * 0.5,	stageWidth - _p * 2,	_h * 1.0);

	super.initialize();
	layout = new AnchorLayout();
	ChallengeIndexItemRenderer.IN_HOME = false;
	ChallengeIndexItemRenderer.SHOW_INFO = false;
	
	var skin:Image = new Image(appModel.theme.roundMediumInnerSkin);
	skin.scale9Grid = MainTheme.ROUND_MEDIUM_SCALE9_GRID;
	skin.alpha = 0.6;
	skin.color = 0;
	backgroundSkin = skin;

	var listLayout:VerticalLayout = new VerticalLayout();
	listLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
	listLayout.useVirtualLayout = false;
	listLayout.typicalItemHeight = 340;
	listLayout.paddingTop = 10;
	listLayout.padding = 30;
	listLayout.gap = -10;

	var list:List = new List();
	list.layout = listLayout;
	list.verticalScrollPolicy	= ScrollPolicy.OFF;
	list.scrollBarDisplayMode	= ScrollBarDisplayMode.NONE;
	list.dataProvider			= new ListCollection([0,1]);
	list.layoutData				= new AnchorLayoutData(0, 0, 0, 0);
	list.itemRendererFactory	= function () : IListItemRenderer { return new ChallengeIndexItemRenderer(); };
	list.addEventListener(Event.TRIGGERED, list_triggeredHandler);
	addChild(list);
}

private function list_triggeredHandler(event:Event) : void 
{
	this.dispatchEventWith(Event.SELECT, false, event.data);
	close();
}
}
}