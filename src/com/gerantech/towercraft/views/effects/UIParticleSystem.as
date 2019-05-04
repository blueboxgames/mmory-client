package com.gerantech.towercraft.views.effects 
{
	import com.gerantech.towercraft.managers.ParticleManager;
/**
* @author Mansour Djawadi
*/
public class UIParticleSystem extends MortalParticleSystem 
{
public function UIParticleSystem(name:String, duration:Number = 0.1, autoStart:Boolean = true, autoDispose:Boolean = true)
{
	super(ParticleManager.getParticleData(name), ParticleManager.getTextureByBitmap(name), duration, autoStart, autoDispose);
}
}
}