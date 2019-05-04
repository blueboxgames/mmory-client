package com.gerantech.towercraft.views.effects 
{
import com.gerantech.towercraft.models.AppModel;
/**
* ...
* @author Mansour Djawadi
*/
public class BattleParticleSystem extends MortalParticleSystem
{

public function BattleParticleSystem(config:String, texture:String, duration:Number = 0.1, autoStart:Boolean = true, autoDispose:Boolean = true)
{
	super(AppModel.instance.assets.getObject(config), AppModel.instance.assets.getTexture(texture), duration, autoStart, autoDispose);
}
}
}