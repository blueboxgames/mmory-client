package com.gerantech.towercraft.views.hb
{
  public interface IHealthBar
  {
    function setPosition(x:Number, y:Number) : void;

    function get value() : Number;
    function set value(v:Number) : void

    function get maximum() : Number;
    function set maximum(value:Number) : void

    function get alpha() : Number;
    function set alpha(value:Number) : void

    function get side():int;
    function set side(value:int):void;

    function dispose() : void 
  }
}