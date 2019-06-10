package com.gerantech.towercraft.controls.segments
{
import feathers.core.IFeathersControl;

public interface ISegment extends IFeathersControl
{
	function init():void;
	function focus():void;
	function updateData():void;
    function get paddingH():Number;
    function set paddingH(value:Number):void;
    function get initializeStarted():Boolean;
    function set initializeStarted(value:Boolean):void;
    function get initializeCompleted():Boolean;
    function set initializeCompleted(value:Boolean):void;
}
}