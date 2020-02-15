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

    static public  function has_side(t:int) : Boolean { return t == 102 || t == 104 || t == 108 || t == 117 || t == 118 || t == 119 || t == 120 || t == 224; }

    public function UnitBody(unit:UnitView, card:Card, side:int)
    {
      this.unit = unit;
      var battleField:BattleField = AppModel.instance.battleFieldView.battleData.battleField;

      var texture:String = AppModel.instance.artRules.get(card.type, ArtRules.TEXTURE);
      if( AppModel.instance.artRules.get(card.type, ArtRules.BASE) != "" )
      {
        this.baseDisplay = new Image(AppModel.instance.assets.getTexture(texture + "/" + battleField.getColorIndex(side) + "/base"));
        this.addChild(this.baseDisplay);
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
        this.overlayDisplay = new Image(AppModel.instance.assets.getTexture(texture + "/" + battleField.getColorIndex(side) + "/overlay"));
        this.addChild(this.overlayDisplay);
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