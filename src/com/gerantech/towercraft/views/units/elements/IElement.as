package com.gerantech.towercraft.views.units.elements
{
  import com.gerantech.mmory.core.battle.units.Unit;

  public interface IElement
  {
    function set unit(value:Unit) : void;
    function get unit():Unit;
  } 
}