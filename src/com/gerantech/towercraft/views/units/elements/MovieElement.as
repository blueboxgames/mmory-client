package com.gerantech.towercraft.views.units.elements
{
  import com.gerantech.mmory.core.battle.units.Unit;

  import starling.display.MovieClip;
  import starling.textures.Texture;

  public class MovieElement extends MovieClip implements IElement
  {
    public var _unit:Unit;
    public function set unit(value:Unit):void { this._unit = value; }
    public function get unit():Unit { return this._unit; }
    public function MovieElement(unit:Unit, textures:Vector.<Texture>, fps:Number = 12) 
    {
      super(textures, fps);
      this.unit = unit;
    }
  } 
}