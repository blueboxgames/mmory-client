package com.gerantech.towercraft.views.effects 
{
import com.gerantech.towercraft.managers.ParticleManager;
import com.gerantech.towercraft.models.AppModel;
import flash.utils.setTimeout;
import starling.events.Event;
import starling.animation.Tween;
import starling.core.Starling;
import starling.extensions.PDParticleSystem;
import starling.textures.Texture;

/**
* ...
* @author Mansour Djawadi
*/
public class MortalParticleSystem extends PDParticleSystem 
{
public var autoDispose:Boolean;
public function MortalParticleSystem(config:Object, texture:Texture, duration:Number = 0.1, autoStart:Boolean = true, autoDispose:Boolean = true) 
{
	super(config, texture);
	this.touchable = false;
	this.autoDispose = autoDispose;
	if( autoStart )
		start(duration);
}

override public function start(duration:Number = -1):void 
{
	if( duration == -1 )
		duration = defaultDuration;
	addEventListener(Event.COMPLETE, completeHandler);
	super.start(duration);
	Starling.juggler.add(this);
}

protected function completeHandler(e:Event):void 
{
	stop();
	removeEventListener(Event.COMPLETE, completeHandler);
	remove(autoDispose);
}

public function remove(dispose:Boolean):void 
{
	removeEventListener(Event.COMPLETE, completeHandler);
	stop(true);
	Starling.juggler.remove(this);
	removeFromParent(dispose);
}
}
}