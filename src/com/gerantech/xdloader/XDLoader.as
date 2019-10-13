package com.gerantech.xdloader
{
  import com.gerantech.towercraft.models.AppModel;

  import flash.geom.Matrix;

  import starling.display.Canvas;
  import starling.display.DisplayObject;
  import starling.display.DisplayObjectContainer;
  import starling.display.Image;
  import starling.display.Sprite;
  import starling.geom.Polygon;

  public class XDLoader extends Sprite
  {
    static public const TYPE_SHAPE:String = "shape";
    static public const TYPE_GROUP:String = "group";
    static public const TYPE_ARTBOARD:String = "artboard";
    
    static public const TYPE_STYLE_SOLID:String = "solid";
    static public const TYPE_STYLE_PATTERN:String = "pattern";

    static public const TYPE_SHAPE_RECT:String = "rect";
		static public const TYPE_SHAPE_CIRCLE:String = "circle";

    public var version:String;
    
    public function XDLoader() {}
    public function init(artboard:Object):void
    {
      version = artboard["version"];
      var children:Array = artboard["children"];
      for(var i:int = 0; i < children.length; i++)
        createByType(this, children[i]);
    }

    static public function createByType(root:DisplayObjectContainer, node:Object):void
    {
      if( node.hasOwnProperty("visible") && !node.visible )
        return;
      
      switch( node.type )
      {
        case TYPE_SHAPE:    performShape(root, node);  break;
        case TYPE_GROUP:    
        case TYPE_ARTBOARD: performGroup(root, node);  break;
      }
    }

    static public function performGroup(root:DisplayObjectContainer, node:Object):void
    {
      var child:Sprite = new Sprite();
      child.name = node.name;
      performTransform(child, node);
      root.addChild(child)

      var children:Array = node[node.type]["children"];
      var len:int = children.length
      for(var i:int = 0; i < len; i++)
        createByType(child, children[i]);
    }

    static public function performShape(root:DisplayObjectContainer, node:Object):void
    {
      var shape:Object = node.shape;
      var fill:Object = node["style"]["fill"];
      var child:DisplayObject;

			if( fill.type == TYPE_STYLE_PATTERN )
			{
				child = new Image(AppModel.instance.assets.getTexture(fill.pattern.meta.ux.uid));
        child.x = shape.x;
        child.y = shape.y;
        performTransform(child, node);
				child.width = shape.width;
				child.height = shape.height;
			}
      else
      {
        child = new Canvas();
        performTransform(child, node);
        Canvas(child).beginFill(getColor(fill));

        if( shape.type == TYPE_SHAPE_RECT )
        {
          if( shape.hasOwnProperty("r") )
          {
            if( shape.r is Array )
              drawRoundRectangle(Canvas(child), shape.x, shape.y, shape.width, shape.height, shape.r[0], shape.r[1], shape.r[2], shape.r[3]);
            else
              drawRoundRectangle(Canvas(child), shape.x, shape.y, shape.width, shape.height, shape.r, shape.r, shape.r, shape.r);
          }
          else
          {
            Canvas(child).drawRectangle(shape.x, shape.y, shape.width, shape.height);
          }
        }
        else if( shape.type == TYPE_SHAPE_CIRCLE )
        {
          Canvas(child).drawCircle(shape.cx, shape.cy, shape.r);
        }
      }

			// opacity
			if( node.style.hasOwnProperty("opacity") )
				child.alpha = node.style.opacity;

      child.name = node.name;
      root.addChild(child);
    }

    static public function performTransform(root:DisplayObject, node:Object):void
    {
      if( !node.hasOwnProperty("transform") )
        return;
      var t:Object = node.transform;
      root.transformationMatrix = new Matrix(t.a, t.b, t.c, t.d, t.tx, t.ty);
    }

		static public function drawRoundRectangle(canvas:Canvas, x:Number, y:Number, width:Number, height:Number, r0:Number, r1:Number, r2:Number, r3:Number):void
		{
			canvas.drawPolygon(Polygon.createCircle(x + r0, y + r0, r0));
			canvas.drawPolygon(Polygon.createCircle(x + width - r1, y + r1, r1));
			canvas.drawPolygon(Polygon.createCircle(x + r2, y + height - r2, r2));
			canvas.drawPolygon(Polygon.createCircle(x + + width - r3, y + height - r3, r3));
			canvas.drawPolygon(new Polygon([
				x+r0,				y,
				x+width-r1, y,
			  x+width, 		y+r1,
				x+width, 		y+height-r2,
				x+width-r2, y+height,
				x+r3, 			y+height,
				x,					y+height-r3,
				x,					y-r0,
			]));
		}

    static public function getColor(style:Object):uint
    {
      if( style["type"] == TYPE_STYLE_SOLID )
      {
        var c:Object = style["color"]["value"];
        return toRgb(c["r"], c["g"], c["b"]);
      }
      return Math.random() * 0xFFFFFF;
    }
    static public function toRgb(r:Number, g:Number, b:Number):uint
    {
      return r << 16 | g << 8 | b;
    }
  }
}