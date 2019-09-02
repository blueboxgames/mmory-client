package com.gerantech.towercraft.views.units.elements
{
  import com.gerantech.mmory.core.battle.units.Unit;
  import starling.display.Image;
  import starling.textures.Texture;
  import com.gerantech.towercraft.views.units.UnitView;
  public class ImageElement extends Image implements IElement
  {
    public var _unit:UnitView;
    public function set unit(value:UnitView):void { this._unit = value; }
    public function get unit():UnitView { return this._unit; }
    public function ImageElement(unit:UnitView, texture:Texture) 
    {
      super(texture);
      this.unit = unit;
    }
  } 
}