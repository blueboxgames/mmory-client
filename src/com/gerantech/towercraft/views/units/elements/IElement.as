package com.gerantech.towercraft.views.units.elements
{
  import com.gerantech.towercraft.views.units.UnitView;
  public interface IElement
  {
    function set unit(value:UnitView) : void;
    function get unit():UnitView;
  } 
}