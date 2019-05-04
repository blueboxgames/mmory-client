package com.gerantech.towercraft.controls
{
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.views.effects.UIParticleSystem;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;

public class StarCheck extends Image
{
private var actived:Boolean;
private var size:int = 200;
private var atlas:String;
public function StarCheck(actived:Boolean = false, size:int = 200, atlas:String = "gui")
{
	super( Assets.getTexture("gold-key" + (actived ? "" : "-off"), atlas));
    this.touchable = false;
	this.actived = actived;
	this.atlas = atlas;
	pivotX = this.width * 0.5
	pivotY = this.height * 0.5
	width = height = this.size = size;
}

public function active() : void
{
	if( actived )
		return;
	
	var pd:UIParticleSystem = new UIParticleSystem("explode", 0.1);
	pd.x = x;
	pd.y = y;
	pd.speed *= 5;
	pd.startSize *= 3;
	pd.lifespan *= 0.1;
	//pd.x = pd.y = width * 0.5;
	parent.addChildAt(pd, parent.getChildIndex(this));
	
	texture = Assets.getTexture("gold-key", atlas);
	width = height = size * 2;
	Starling.juggler.tween(this, 0.6, {width:size, height:size, transition:Transitions.EASE_OUT_BACK});
	actived = true;
}
public function deactive() : void
{
	if( !actived )
		return;
	
	texture = Assets.getTexture("gold-key-off", atlas);
	width = height = size * 0.8;
	Starling.juggler.tween(this, 0.6, {width:size, height:size, transition:Transitions.EASE_OUT_BACK});
	actived = false;
}
}
}