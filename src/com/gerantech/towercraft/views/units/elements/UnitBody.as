package com.gerantech.towercraft.views.units.elements
{
  import com.gerantech.towercraft.views.units.UnitView;
  import starling.core.Starling;
  import starling.display.Sprite;

  public class UnitBody extends Sprite implements IElement
  {
    private var _unit:UnitView;
    public function set unit(value:UnitView):void { this._unit = value; }
    public function get unit():UnitView { return this._unit; }

    public var startFrame:int;
    private var bodyDisplay:UnitMC;
    private var sideDisplay:UnitMC;

    static public  function has_side(t:int) : Boolean { return t == 108 || t == 119; }

    public function UnitBody(unit:UnitView)
    {
      this.unit = unit;
    	var hasSide:Boolean = has_side(unit.card.type);
      var angle:String = unit.side == unit.battleField.side ? "000_" : "180_";

      this.bodyDisplay = new UnitMC(unit.card.type + "/" + (hasSide ? 0 : unit.battleField.getColorIndex(unit.side)) + "/", "m_" + angle);
    	this.bodyDisplay.currentFrame = Math.floor(Math.random() * bodyDisplay.numFrames);
      this.bodyDisplay.pause();
    	Starling.juggler.add(this.bodyDisplay);
      this.addChild(this.bodyDisplay);

      if( hasSide && unit.side != unit.battleField.side )
      {
        this.sideDisplay = new UnitMC(unit.card.type + "/1/", "m_" + angle);
        this.sideDisplay.pause();
        this.sideDisplay.currentFrame = this.bodyDisplay.currentFrame;
        Starling.juggler.add(this.sideDisplay);
        this.addChild(this.sideDisplay);
      }
    }

    override public function get width () : Number
    {
      return this.bodyDisplay.width;
    }
    override public function set width (value:Number) : void
    {
      this.bodyDisplay.width = value;
      if( this.sideDisplay !== null )
        this.sideDisplay.width = value;
      // super.width = value;
    }
    
    override public function get height () : Number
    {
      return this.bodyDisplay.height;
    }
    override public function set height (value:Number) : void
    {
      this.bodyDisplay.height = value;
      if( this.sideDisplay != null )
        this.sideDisplay.height = value;
      // super.height = value;
    }

    override public function get scale () : Number
    {
      return this.bodyDisplay.scale;
    }
    override public function set scale (value:Number) : void
    {
      this.bodyDisplay.scale = value;
      if( this.sideDisplay != null )
        this.sideDisplay.scale = value;
    }
    override public function get scaleX () : Number
    {
      return this.bodyDisplay.scaleX;
    }
    override public function set scaleX (value:Number) : void
    {
      this.bodyDisplay.scaleX = value;
      if( this.sideDisplay != null )
        this.sideDisplay.scaleX = value;
    }
    override public function get scaleY () : Number
    {
      return this.bodyDisplay.scaleY;
    }
    override public function set scaleY (value:Number) : void
    {
      this.bodyDisplay.scaleY = value;
      if( this.sideDisplay != null )
        this.sideDisplay.scaleY = value;
    }

    override public function get pivotX () : Number
    {
      return this.bodyDisplay.pivotX;
    }
    override public function set pivotX (value:Number) : void
    {
      this.bodyDisplay.pivotX = value;
      if( this.sideDisplay != null )
        this.sideDisplay.pivotX = value;
    }
    override public function get pivotY () : Number
    {
      return this.bodyDisplay.pivotY;
    }
    override public function set pivotY (value:Number) : void
    {
      this.bodyDisplay.pivotY = value;
      if( this.sideDisplay != null )
        this.sideDisplay.pivotY = value;
    }

		public function set loop(value:Boolean) : void
		{
			this.bodyDisplay.loop = value;
      if( this.sideDisplay != null )
				this.sideDisplay.loop = value;
		}

		public function set currentFrame(value:int) : void
		{
			this.bodyDisplay.currentFrame = value;
      if( this.sideDisplay != null )
				this.sideDisplay.currentFrame = value;
		}

		public function pause() : void
		{
			this.bodyDisplay.pause();
      if( this.sideDisplay != null )
				this.sideDisplay.pause();
		}

		public function play() : void
		{
			this.bodyDisplay.play();
      if( this.sideDisplay != null )
				this.sideDisplay.play();
		}

		public function updateTexture(anim:String, dir:String):void 
		{
			this.bodyDisplay.updateTexture(anim, dir);
      if( this.sideDisplay != null )
				this.sideDisplay.updateTexture(anim, dir);
		}
		
		override public function dispose() : void
		{
			Starling.juggler.remove(this.bodyDisplay);
      if( this.sideDisplay != null )
				Starling.juggler.remove(this.sideDisplay);
			super.dispose();
		}
	}
}