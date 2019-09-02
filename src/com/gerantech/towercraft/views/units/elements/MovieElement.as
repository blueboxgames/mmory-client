package com.gerantech.towercraft.views.units.elements
{

  import starling.display.MovieClip;
  import starling.textures.Texture;
  import com.gerantech.towercraft.views.units.UnitView;

  public class MovieElement extends MovieClip implements IElement
  {
    public var _unit:UnitView;
    public function set unit(value:UnitView):void { this._unit = value; }
    public function get unit():UnitView { return this._unit; }
    public function MovieElement(unit:UnitView, textures:Vector.<Texture>, fps:Number = 12) 
    {
      super(textures, fps);
      this.unit = unit;
    }
  } 
}