package com.gerantech.towercraft.controls.groups 
{
import com.gerantech.towercraft.controls.TowersLayout;
import com.gerantech.towercraft.models.Assets;
import feathers.layout.RelativePosition;
import flash.geom.Rectangle;
import starling.core.Starling;
import starling.display.BlendMode;
import starling.display.MovieClip;
import starling.events.Event;

/**
* @author Mansour Djawadi
*/
public class GradientHilight extends TowersLayout 
{
static public const LOOP_MODE_ONE:int = 0;
static public const LOOP_MODE_DIRECTIONAL:int = 1;
static public const LOOP_MODE_BIDIRECTIONAL:int = 2;
static private const SCALE_GRID_H:Rectangle = new Rectangle(2, 1, 56, 1);
static private const SCALE_GRID_V:Rectangle = new Rectangle(1, 2, 1, 56);
private var skin:MovieClip;
public var color:uint = 0xFFFFFF;
public var loopMode:int = 2;
public var loopDelay:Number = 1;
public var autoplay:Boolean = true;
public var direction:String = RelativePosition.TOP;
public function GradientHilight() { super(); }
protected function backroundAnimationFactory() : void 
{
	if( this.skin == null )
	{
		this.skin = new MovieClip(Assets.getTextures(this.direction == RelativePosition.TOP || this.direction == RelativePosition.BOTTOM ? "animations/light-v/" : "animations/light-h/", "gui"), 40);
		this.skin.color = this.color;
		this.skin.blendMode = BlendMode.ADD;
		this.skin.scale9Grid = this.direction == RelativePosition.TOP || this.direction == RelativePosition.BOTTOM ? SCALE_GRID_V : SCALE_GRID_H;
	}
	this.addChild(this.skin);
}

override protected function draw() : void
{
	if( this.isInvalid(INVALIDATION_FLAG_SIZE) )
	{
		this.skin.x		= this.direction == RelativePosition.LEFT ? this.actualWidth : 0;
		this.skin.y		= this.direction == RelativePosition.BOTTOM ? this.actualHeight : 0;
		this.skin.width = this.actualWidth * (this.direction == RelativePosition.LEFT ? -1 : 1);
		this.skin.height= this.actualHeight * (this.direction == RelativePosition.BOTTOM ? -1 : 1);
	}
	super.draw();
}

public function play() : void
{
	if( this.skin == null )
		return;
	this.visible = true;
	this.skin.play();
	this.skin.addEventListener(Event.COMPLETE, skin_completeHandler);
	Starling.juggler.add(this.skin);
}

public function stop() : void
{
	this.visible = false;
	this.skin.addEventListener(Event.COMPLETE, skin_completeHandler);
	this.skin.stop();
	Starling.juggler.remove(this.skin);
}

protected function skin_completeHandler(event:Event) : void
{
	this.stop();
	if( this.loopMode == LOOP_MODE_ONE )
		return;
	
	if( this.loopMode == LOOP_MODE_BIDIRECTIONAL )
	{
		switch( this.direction )
		{
			case RelativePosition.RIGHT	: this.direction = RelativePosition.LEFT;	break;
			case RelativePosition.LEFT	: this.direction = RelativePosition.RIGHT;	break;
			case RelativePosition.TOP	: this.direction = RelativePosition.BOTTOM;	break;
			case RelativePosition.BOTTOM: this.direction = RelativePosition.TOP;	break;
		}
		this.invalidate(INVALIDATION_FLAG_SIZE);
	}
	
	Starling.juggler.delayCall(this.play, this.loopDelay);
}

override protected function feathersControl_addedToStageHandler (event:Event) : void
{
	backroundAnimationFactory();
	
	if( this.autoplay )
		this.play();
	super.feathersControl_addedToStageHandler (event);
}

override protected function feathersControl_removedFromStageHandler (event:Event) : void
{
	this.stop();
	super.feathersControl_removedFromStageHandler (event);
}

override public function dispose() : void
{
	this.stop();
	super.dispose();
}
}
}