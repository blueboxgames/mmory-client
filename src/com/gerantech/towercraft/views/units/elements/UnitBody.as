package com.gerantech.towercraft.views.units.elements
{
  import com.gerantech.mmory.core.battle.BattleField;
  import com.gerantech.mmory.core.battle.units.Card;
  import com.gerantech.mmory.core.constants.CardTypes;
  import com.gerantech.towercraft.models.AppModel;
  import com.gerantech.towercraft.views.ArtRules;
  import com.gerantech.towercraft.views.units.UnitView;

  import starling.core.Starling;
  import starling.display.Image;
  import starling.display.Sprite;

  public class UnitBody extends Sprite implements IElement
  {
    private var _unit:UnitView;
    public function set unit(value:UnitView):void { this._unit = value; }
    public function get unit():UnitView { return this._unit; }

    public var startFrame:int;
    private var baseDisplay:Image;
    private var overlayDisplay:Image;
    private var bodyDisplay:UnitMC;
    private var sideDisplay:UnitMC;

    static public  function has_side(t:int) : Boolean { return t == 108 || t == 118 || t == 119; }

    public function UnitBody(unit:UnitView, card:Card, side:int)
    {
      this.unit = unit;
      var battleField:BattleField = AppModel.instance.battleFieldView.battleData.battleField;

      if( AppModel.instance.artRules.get(card.type, ArtRules.BASE) != "" )
      {
        baseDisplay = new Image(AppModel.instance.assets.getTexture(card.type + "/" + battleField.getColorIndex(side) + "/base"));
        this.addChild(baseDisplay);
      }

    	var hasSide:Boolean = has_side(card.type);
      var angle:String = side == battleField.side ? "000_" : "180_";
      this.bodyDisplay = new UnitMC(card.type + "/" + (hasSide ? 0 : battleField.getColorIndex(side)) + "/", "m_" + angle);
      if( CardTypes.isTroop(card.type) )
      	this.bodyDisplay.currentFrame = Math.floor(Math.random() * bodyDisplay.numFrames);
      this.bodyDisplay.pause();
    	Starling.juggler.add(this.bodyDisplay);
      this.addChild(this.bodyDisplay);

      if( AppModel.instance.artRules.get(card.type, ArtRules.OVERLAY) != "" )
      {
        overlayDisplay = new Image(AppModel.instance.assets.getTexture(card.type + "/" + battleField.getColorIndex(side) + "/overlay"));
        this.addChild(overlayDisplay);
      }


      if( hasSide && side != battleField.side )
      {
        this.sideDisplay = new UnitMC(card.type + "/1/", "m_" + angle);
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
      if( this.baseDisplay !== null )
        this.baseDisplay.width = value;
      if( this.overlayDisplay !== null )
        this.overlayDisplay.width = value;
      if( this.sideDisplay !== null )
        this.sideDisplay.width = value;
    }
    
    override public function get height () : Number
    {
      return this.bodyDisplay.height;
    }
    override public function set height (value:Number) : void
    {
      this.bodyDisplay.height = value;
      if( this.baseDisplay != null )
        this.baseDisplay.height = value;
      if( this.overlayDisplay != null )
        this.overlayDisplay.height = value;
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
      if( this.baseDisplay != null )
        this.baseDisplay.scale = value;
      if( this.overlayDisplay != null )
        this.overlayDisplay.scale = value;
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
      // if( this.baseDisplay != null )
      //   this.baseDisplay.scaleX = value;
      // if( this.overlayDisplay != null )
      //   this.overlayDisplay.scaleX = value;
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
      // if( this.baseDisplay != null )
      //   this.baseDisplay.scaleY = value;
      // if( this.overlayDisplay != null )
      //   this.overlayDisplay.scaleY = value;
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
      if( this.baseDisplay != null )
        this.baseDisplay.pivotX = value;
      if( this.overlayDisplay != null )
        this.overlayDisplay.pivotX = value;
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
      if( this.baseDisplay != null )
        this.baseDisplay.pivotY = value;
      if( this.overlayDisplay != null )
        this.overlayDisplay.pivotY = value;
      if( this.sideDisplay != null )
        this.sideDisplay.pivotY = value;
    }

    public function get color () : uint
    {
      return this.bodyDisplay.color;
    }
    public function set color (value:uint) : void
    {
      this.bodyDisplay.color = value;
      if( this.baseDisplay != null )
        this.baseDisplay.color = value;
      if( this.overlayDisplay != null )
        this.overlayDisplay.color = value;
      if( this.sideDisplay != null )
        this.sideDisplay.color = value;
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