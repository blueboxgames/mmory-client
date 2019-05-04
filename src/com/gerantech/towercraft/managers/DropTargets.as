package com.gerantech.towercraft.managers
{
	import starling.display.DisplayObject;
	import starling.display.Stage;
	
	public class DropTargets
	{
		private var rectangles:Vector.<RectPlay>;
		private var stage:Stage;
		
		public function DropTargets(stage:Stage)
		{
			this.stage = stage;
			rectangles = new Vector.<RectPlay>();
		}
		
		public function add(drop:DisplayObject):void
		{
			rectangles.push(new RectPlay(drop, drop.getBounds(stage)));
		}
		
		public function contain(x:Number, y:Number):DisplayObject
		{
			for each(var r:RectPlay in rectangles)
				if(r.bounds.contains(x, y))
					return r.drop;
			return null;
		}
	}
	
}

import flash.geom.Rectangle;
import starling.display.DisplayObject;

class RectPlay
{
	public var drop:DisplayObject;
	public var bounds:Rectangle;
	
	public function RectPlay(drop:DisplayObject, bounds:Rectangle)
	{
		this.drop = drop;
		this.bounds = bounds;
	}
}