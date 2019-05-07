package com.gerantech.towercraft.utils
{
	import flash.geom.Point;
	import flash.net.registerClassAlias;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import starling.geom.Polygon;
	
	public class Utils 
	{
		
		public static function getVersionCode(version : String):int
		{
			var vs:Array = version.split(".");
			return (int(vs[0])*1000000) + (int(vs[1])*1000) + int(vs[2]);
		}
		//private static var _images:Vector.<Image> = new Vector.<Image>();
		
		public static function clonePointVector(vec:Vector.<Point>):Vector.<Point> {
			registerClassAlias("flash.geom.Point", Point);
			var clone:Vector.<Point>;
			var ba:ByteArray = new ByteArray();
			ba.writeObject(vec);
			ba.position = 0;
			clone = ba.readObject() as Vector.<Point>;
			return clone;
		}
		
		public static function cloneNumberVector(vec:Vector.<Number>):Vector.<Number> {
			var clone:Vector.<Number>;
			var ba:ByteArray = new ByteArray();
			ba.writeObject(vec);
			ba.position = 0;
			clone = ba.readObject() as Vector.<Number>;
			return clone;
		}
		
		public static function getDistance(x1:Number, y1:Number, x2:Number, y2:Number):Number {
			return Math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2));
		}
		
		public static function getAngle(x1:Number, y1:Number, x2:Number, y2:Number):Number {
			var dx:Number = x2 - x1;
			var dy:Number = y2 - y1;
			return Math.atan2(dy, dx);
		}
		
		public static function sign(x:Number):int {
			if(x >= 0)
				return 1;
			return -1;
		}
		
		public static function intToBool(x:int):Boolean {
			if(x > 0)
				return true;
			return false;
		}
		
		public static function boolToInt(b:Boolean):int {
			if(b)
				return 1;
			return 0;
		}
		
		public static function vectorToObject(vec:Vector.<Number>):Object {
			var ob:Object = new Object();
			ob.v0 = vec[0];
			ob.v1 = vec[1];
			ob.v2 = vec[2];
			ob.v3 = vec[3];
			ob.v4 = vec[4];
			return ob;
		}
		
		public static function objectToVector(ob:Object):Vector.<Number> {
			var vec:Vector.<Number> = new Vector.<Number>();
			vec.push(ob.v0);
			vec.push(ob.v1);
			vec.push(ob.v2);
			vec.push(ob.v3);
			vec.push(ob.v4);
			return vec;
		}
		
		/*public static function drawDot(container:Sprite, x1:Number, y1:Number, color:uint, scale:Number):void {
		// refresh the line
		var dot:Image = new Image(TanksGame.ASSET_MANAGER.getTexture("dot_5_0000"));
		dot.alignPivot();
		dot.x = x1;
		dot.y = y1;
		// adjust color
		dot.color = color;
		dot.scale = scale;
		// draw line on RenderTexture
		container.addChild(dot);
		_images.push(dot);
		}
		
		public static function drawLine(container:Sprite, x1:Number, y1:Number, angle:Number, thickness:Number, color:uint):void {
		// refresh the line
		// adjust thickness
		var line1:Image;
		if(thickness <= .3)
		line1 = new Image(TanksGame.ASSET_MANAGER.getTexture("line_03_0000"));
		else if(thickness <= .5)
		line1 = new Image(TanksGame.ASSET_MANAGER.getTexture("line_05_0000"));
		else if(thickness <= 1)
		line1 = new Image(TanksGame.ASSET_MANAGER.getTexture("line_10_0000"));
		else if(thickness <= 2)
		line1 = new Image(TanksGame.ASSET_MANAGER.getTexture("line_20_0000"));
		else if(thickness <= 4)
		line1 = new Image(TanksGame.ASSET_MANAGER.getTexture("line_40_0000"));
		else
		line1 = new Image(TanksGame.ASSET_MANAGER.getTexture("line_40_0000"));
		line1.alignPivot();
		line1.scaleX = 3;
		// adjust length and position
		line1.x = x1;
		line1.y = y1;
		line1.rotation = angle;
		// adjust color
		line1.color = color;
		// draw line on RenderTexture
		container.addChild(line1);
		_images.push(line1);
		}
		
		public static function drawLineSegment(container:Sprite, x1:Number, y1:Number, x2:Number, y2:Number, thickness:Number, color:uint):void {
		// refresh the line
		var line1:Image = new Image(TanksGame.ASSET_MANAGER.getTexture("line_03_0000"));
		line1.color = 0xFFFFFF;
		// adjust thickness
		if(thickness <= .3)
		line1.texture = TanksGame.ASSET_MANAGER.getTexture("line_03_0000");
		else if(thickness <= .5)
		line1.texture = TanksGame.ASSET_MANAGER.getTexture("line_05_0000");
		else if(thickness <= 1)
		line1.texture = TanksGame.ASSET_MANAGER.getTexture("line_10_0000");
		else if(thickness <= 2)
		line1.texture = TanksGame.ASSET_MANAGER.getTexture("line_20_0000");
		else
		line1.texture = TanksGame.ASSET_MANAGER.getTexture("line_10_0000");
		line1.readjustSize();
		// adjust length and position
		var dist:Number = MyUtils.getDistance(x1, y1, x2, y2);
		line1.scaleX = dist / line1.width;
		line1.x = x1;
		line1.y = y1;
		line1.rotation = MyUtils.getAngle(x1, y1, x2, y2);
		// adjust color
		line1.color = color;
		// draw line on RenderTexture
		container.addChild(line1);
		_images.push(line1);
		}
		
		public static function clearDrawings():void {
		for(var i:int = 0; i < _images.length; i++) {
		_images[i].removeFromParent();
		}
		}
		*/
		public static function getClosestPoint(A:Point, B:Point, C:Point):Point {
			var x1:Number = A.x;
			var y1:Number = A.y;
			var x2:Number = B.x;
			var y2:Number = B.y;
			var x3:Number = C.x;
			var y3:Number = C.y;
			
			var px:Number = x2 - x1;
			var py:Number = y2 - y1;
			var dAB:Number = px * px + py * py;
			
			var u:Number = ((x3 - x1) * px + (y3 - y1) * py) / dAB;
			var _x:Number = x1 + u * px;
			var _y:Number = y1 + u * py;
			return new Point(_x, _y);
		}
		
		public static function distanceToLine(p:Point, p1:Point, p2:Point):Number {
			var x:Number = p.x;
			var y:Number = p.y;
			var x1:Number = p1.x;
			var y1:Number = p1.y;
			var x2:Number = p2.x;
			var y2:Number = p2.y;
			
			var A:Number = x - x1;
			var B:Number = y - y1;
			var C:Number = x2 - x1;
			var D:Number = y2 - y1;
			
			var dot:Number = A * C + B * D;
			var len_sq:Number = C * C + D * D;
			var param:Number = -1;
			//in case of 0 length line
			if(len_sq != 0)
				param = dot / len_sq;
			
			var xx:Number, yy:Number;
			
			if(param < 0) {
				xx = x1;
				yy = y1;
			} else if(param > 1) {
				xx = x2;
				yy = y2;
			} else {
				xx = x1 + param * C;
				yy = y1 + param * D;
			}
			
			var dx:Number = x - xx;
			var dy:Number = y - yy;
			return Math.sqrt(dx * dx + dy * dy);
		}
		
		// gets the dot product between 2 points
		public static function dot(a:Point, b:Point):Number {
			return (a.x * b.x) + (a.y * b.y);
		}
		
		// reflects a point
		public static function reflectVector(vector:Point, normal:Point):Point {
			// using the formula [R = V - (2 * V.N) * N] or [V -= 2 * N * (N.V)]
			var vn2:Number = 2.0 * dot(vector, normal);
			return new Point(vector.x - (normal.x * vn2), vector.y = vector.y - (normal.y * vn2));
		}
		
		public static function dictionaryToString(dictionary:Dictionary):String {
			var str:String = "";
			var tot:int;
			for(var key:String in dictionary) {
				str += "[" + key + "]:";
				str += String(dictionary[key]) + ", ";
				tot += dictionary[key];
			}
			return "total = " + tot + " | " + str;
		}
		
		public static function polygonToArray(poly:Polygon):Array {
			var arr:Array = new Array();
			for(var i:int = 0; i < poly.numVertices; i++) {
				arr.push(poly.getVertex(i).x);
				arr.push(poly.getVertex(i).y);
			}
			return arr;
		}
		
		public static function arrayToPolygon(arr:Array):Polygon {
			var vertexArr:Array = new Array();
			for(var i:int = 0; i < arr.length; i += 2) {
				vertexArr.push(new Point(arr[i], arr[i + 1]));
			}
			var poly:Polygon = new Polygon(vertexArr);
			return poly;
		}
		
		/**
		 *	ax + by + cz = j ;
		 *	dx + ey + fz = k ;
		 *	gx + hy + iz = l ;
		 */
		public static function solveThreeUnknownEquation(a:Number, b:Number, c:Number, d:Number, e:Number, f:Number, g:Number, h:Number, i:Number, j:Number, k:Number, l:Number):Array {
			var dn:Number;
			var x:Number;
			var y:Number;
			var z:Number;
			dn = a * e * i + b * f * g + c * d * h - g * e * c - h * f * a - i * d * b;
			x = (j * e * i + b * f * l + c * k * h - l * e * c - h * f * j - i * k * b) / dn;
			y = (a * k * i + j * f * g + c * d * l - g * k * c - l * f * a - i * d * j) / dn;
			z = (a * e * l + b * k * g + j * d * h - g * e * j - h * k * a - l * d * b) / dn;
			var xyz:Array = [x, y, z];
			return xyz;
		}
		
		public static function random(min:int = 0, max:int = int.MAX_VALUE):int {
			if(min == max)
				return min;
			if(min < max)
				return min + (Math.random() * (max - min + 1));
			else
				return max + (Math.random() * (min - max + 1));
		}
		
		public static function getPCUniqueCode():String
		{
			return Capabilities.serverString.substr(0, 256);// Capabilities.screenDPI + "-" + Capabilities.screenResolutionX + "-" + Capabilities.screenResolutionY;
		}
	}
}
