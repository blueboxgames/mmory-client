package com.gerantech.towercraft.views.effects 
{
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.views.units.elements.IElement;
import com.gerantech.mmory.core.battle.units.Unit;
/**
* ...
* @author Mansour Djawadi
*/
public class BattleParticleSystem extends MortalParticleSystem implements IElement
{
public var _unit:Unit;
public function set unit(value:Unit):void { this._unit = value; }
public function get unit():Unit { return this._unit; }
public function BattleParticleSystem(unit:Unit, config:String, texture:String, duration:Number = 0.1, autoStart:Boolean = true, autoDispose:Boolean = true)
{
	super(AppModel.instance.assets.getObject(config), AppModel.instance.assets.getTexture(texture), duration, autoStart, autoDispose);
	this.unit = unit;
}
}
}