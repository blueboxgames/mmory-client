package com.gerantech.towercraft.controls.overlays
{
import com.gerantech.towercraft.controls.tooltips.ConfirmTooltip;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.models.tutorials.TutorialTask;

import dragonBones.events.EventObject;
import dragonBones.objects.DragonBonesData;
import dragonBones.starling.StarlingArmatureDisplay;
import dragonBones.starling.StarlingEvent;
import dragonBones.starling.StarlingFactory;

import flash.geom.Rectangle;

import starling.display.DisplayObject;
import starling.events.Event;
import starling.events.TouchEvent;

public class TutorialMessageOverlay extends TutorialOverlay
{
	
public static var factory: StarlingFactory;
public static var dragonBonesData:DragonBonesData;

protected var side:int;
protected var characterArmature:StarlingArmatureDisplay;
public function TutorialMessageOverlay(task:TutorialTask):void
{
	super(task);
	side = int(task.data) % 2;
	createFactory();
}

public static function createFactory():void
{
	if( factory != null )
		return;
	factory = new StarlingFactory();
	dragonBonesData = factory.parseDragonBonesData(AppModel.instance.assets.getObject("characters_ske"));
	factory.parseTextureAtlasData(AppModel.instance.assets.getObject("characters_tex"), AppModel.instance.assets.getTexture("characters_tex"));
}

override protected function transitionInCompleted():void
{
	super.transitionInCompleted();
	
	appModel.sounds.addAndPlay("whoosh");
	overlay.touchable = true;
	
	transitionOut.delay = 0.5;
	characterArmature = factory.buildArmatureDisplay("103");
	characterArmature.touchable = false;
	characterArmature.x = 170; //side == 0 ? 220 : stageWidth - 220;
	characterArmature.y = stageHeight;
	characterArmature.scale = 1 / 0.6;
	characterArmature.addEventListener(EventObject.COMPLETE, characterArmature_completeHandler);
	characterArmature.animation.gotoAndPlayByTime("appear", 0, 1);
	addChild(characterArmature as DisplayObject);
	//Starling.juggler.tween(characterArmature, 0.4, {delay:0.2, x:(side == 0 ? 220 : stageWidth - 220), transition:Transitions.EASE_OUT_BACK, onComplete:characterArmature_completeHandler});
}

protected function characterArmature_completeHandler(event:StarlingEvent) : void 
{

	if( event.eventObject.animationState.name != "appear" )
		return;
	
	characterArmature.removeEventListener(EventObject.COMPLETE, characterArmature_completeHandler);
	characterArmature.animation.gotoAndPlayByTime("idle", 0, -1);

	var position:Rectangle = new Rectangle(characterArmature.x + 200, stageHeight - 800, 1, 1);
	var tootlip:ConfirmTooltip = new ConfirmTooltip( loc(task.message), position, 0.8, 0.56, task.type == TutorialTask.TYPE_CONFIRM, false);
	tootlip.valign = "bot";
	tootlip.addEventListener(Event.SELECT, tootlip_eventsHandler); 
	tootlip.addEventListener(Event.CANCEL, tootlip_eventsHandler); 
	addChild(tootlip);
}

protected function tootlip_eventsHandler(event:Event):void
{
	dispatchEventWith(event.type);
	ConfirmTooltip(event.currentTarget).close();
	close();
}
override protected function stage_touchHandler(event:TouchEvent):void
{
	//if( !_isEnabled || task.type == TutorialTask.TYPE_CONFIRM )
		return;
	super.stage_touchHandler(event);
}

override public function close(dispose:Boolean = true):void
{
	characterArmature.animation.gotoAndPlayByTime("disappear", 0, 1);
	super.close(dispose);
}
}
}