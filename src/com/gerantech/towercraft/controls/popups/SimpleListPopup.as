package com.gerantech.towercraft.controls.popups
{
import com.gerantech.towercraft.controls.buttons.SimpleLayoutButton;
import com.gerantech.towercraft.controls.items.FloatingListItemRenderer;
import com.gerantech.towercraft.controls.overlays.TransitionData;
import com.gerantech.towercraft.themes.MainTheme;

import feathers.controls.List;
import feathers.controls.ScrollPolicy;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

import flash.geom.Rectangle;

import starling.animation.Transitions;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.display.Quad;
import starling.events.Event;


public class SimpleListPopup extends AbstractPopup
{
public var buttons:Array;
public var padding:int = 12;
public var buttonsWidth:int = 24;
public var buttonHeight:int = 24;

private var list:List;


public function SimpleListPopup(... buttons)
{
	super();
	this.buttons = new Array();
	for each(var button:String in buttons)
	{
		if( button != null )
			this.buttons.push(button);
	}
}

override protected function initialize():void
{
	if( transitionIn == null )
	{
		var _h:int = buttons.length * buttonHeight + padding * 2;
		var _p:int = (stageWidth - buttonsWidth ) * 0.5;
		transitionIn = new TransitionData();
		transitionIn.transition = Transitions.EASE_OUT_BACK;
		transitionIn.sourceBound = new Rectangle(_p,	stageHeight* 0.5 - _h * 0.4,	stageWidth - _p * 2,	_h * 0.8);
		transitionIn.destinationBound = new Rectangle(_p,	stageHeight* 0.5 - _h * 0.5,	stageWidth - _p * 2,	_h * 1.0);
	}

	super.initialize();
	layout = new AnchorLayout();
	
	var skin:Image = new Image(appModel.theme.roundMediumInnerSkin);
	skin.scale9Grid = MainTheme.ROUND_MEDIUM_SCALE9_GRID;
	skin.color = 0;
	skin.alpha = 0.6;
	backgroundSkin = skin;
	
	list = new List();
	list.verticalScrollPolicy = ScrollPolicy.OFF;
	list.dataProvider = new ListCollection(buttons);
	list.itemRendererFactory = function ():IListItemRenderer { return new FloatingListItemRenderer(buttonHeight);};
	list.layoutData = new AnchorLayoutData(padding, padding, padding, padding);
	list.addEventListener(Event.CHANGE, list_changeHandler);
	addChild(list);
}

private function list_changeHandler(event:Event):void
{
	dispatchEventWith(Event.SELECT, false, list.selectedItem);
	close();
}

override protected function defaultOverlayFactory(color:uint = 0, alpha:Number = 0.4):DisplayObject
{
	var overlay:SimpleLayoutButton = new SimpleLayoutButton();
	overlay.backgroundSkin = new Quad(1, 1, 0);
	overlay.alpha = 0;
	overlay.width = stage.width * 3;
	overlay.height = stage.height * 3;
	overlay.x = -overlay.width * 0.5;
	overlay.y = -overlay.height * 0.5;
	overlay.addEventListener(Event.TRIGGERED, overlay_triggeredHandler);
	return overlay;
}

private function overlay_triggeredHandler(event:Event):void
{
	close();
}		
}
}