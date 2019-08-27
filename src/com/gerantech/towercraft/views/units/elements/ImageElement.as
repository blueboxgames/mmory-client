package com.gerantech.towercraft.views.units.elements
{
  import com.gerantech.mmory.core.battle.units.Unit;
  import starling.display.Image;
  import starling.textures.Texture;
  public class ImageElement extends Image implements IElement
  {
    public var _unit:Unit;
    public function set unit(value:Unit):void { this._unit = value; }
    public function get unit():Unit { return this._unit; }
    public function ImageElement(unit:Unit, texture:Texture) 
    {
      super(texture);
      this.unit = unit;
    }
  } 
}