package com.gerantech.towercraft.views.effects 
{
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.views.units.UnitView;
import com.gerantech.towercraft.views.units.elements.IElement;
/**
* ...
* @author Mansour Djawadi
*/
public class BattleParticleSystem extends MortalParticleSystem implements IElement
{
public var _unit:UnitView;
public function set unit(value:UnitView):void { this._unit = value; }
public function get unit():UnitView { return this._unit; }
public function BattleParticleSystem(unit:UnitView, config:String, texture:String, duration:Number = 0.1, autoStart:Boolean = true, autoDispose:Boolean = true)
{
	super(AppModel.instance.assets.getObject(config), AppModel.instance.assets.getTexture(texture), duration, autoStart, autoDispose);
	this.unit = unit;
}
}
}