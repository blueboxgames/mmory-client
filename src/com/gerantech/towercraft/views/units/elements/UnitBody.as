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
  import starling.events.Event;

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

    public function UnitBody(unit:UnitView, card:Card, side:int)
    {
      this.unit = unit;
      var artRules:ArtRules = AppModel.instance.artRules;
      var battleField:BattleField = AppModel.instance.battleFieldView.battleData.battleField;

      // base
      var base:String = artRules.get(card.type, ArtRules.BASE);
      if( base != "" )
      {
        this.baseDisplay = new Image(AppModel.instance.assets.getTexture(texture + "/" + battleField.getColorIndex(side) + "/" + base));
        this.addChild(this.baseDisplay);
      }

      // body and side
      var texture:String = artRules.get(card.type, ArtRules.TEXTURE);
      if( texture != "" )
      {
        var hasSide:Boolean = artRules.getInt(card.type, ArtRules.SIDE) == 1;
        var angle:String = side == battleField.side ? "000_" : "180_";
        this.bodyDisplay = new UnitMC(texture + "/" + (hasSide ? 0 : battleField.getColorIndex(side)) + "/", "i_" + angle);
        if( CardTypes.isTroop(card.type) )
          this.bodyDisplay.currentFrame = Math.floor(Math.random() * bodyDisplay.numFrames);
        this.bodyDisplay.pause();
        Starling.juggler.add(this.bodyDisplay);
        this.addChild(this.bodyDisplay);

        if( hasSide && side != battleField.side )
        {
          this.sideDisplay = new UnitMC(texture + "/1/", "i_" + angle);
          this.sideDisplay.pause();
          this.sideDisplay.currentFrame = this.bodyDisplay.currentFrame;
          Starling.juggler.add(this.sideDisplay);
          this.addChild(this.sideDisplay);
        }
      }

      // overlay
      var overlay:String = artRules.get(card.type, ArtRules.OVERLAY);
      if( overlay != "" )
      {
        this.overlayDisplay = new Image(AppModel.instance.assets.getTexture(texture + "/" + battleField.getColorIndex(side) + "/" + overlay));
        this.addChild(this.overlayDisplay);
      }
    }

    public function get color () : uint
    {
      if( this.bodyDisplay != null )
        return this.bodyDisplay.color;
      return 0xFFFFFF;
    }
    public function set color (value:uint) : void
    {
      if( this.bodyDisplay != null )
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
      if( this.bodyDisplay != null )
  			this.bodyDisplay.loop = value;
      if( this.sideDisplay != null )
				this.sideDisplay.loop = value;
		}

		public function set currentFrame(value:int) : void
		{
      if( this.bodyDisplay != null )
  			this.bodyDisplay.currentFrame = value;
      if( this.sideDisplay != null )
				this.sideDisplay.currentFrame = value;
		}

		public function pause() : void
		{
      if( this.bodyDisplay != null )
  			this.bodyDisplay.pause();
      if( this.sideDisplay != null )
				this.sideDisplay.pause();
		}

		public function play() : void
		{
      if( this.bodyDisplay != null )
  			this.bodyDisplay.play();
      if( this.sideDisplay != null )
				this.sideDisplay.play();
		}

		public function updateTexture(anim:String, dir:String):void 
		{
      if( this.bodyDisplay != null )
      {
        this.bodyDisplay.removeEventListener(Event.COMPLETE, this.bodyDisplay_completeHandler);
        if( anim == "s_" )
          this.bodyDisplay.addEventListener(Event.COMPLETE, this.bodyDisplay_completeHandler);
  			this.bodyDisplay.updateTexture(anim, dir);
      }
      if( this.sideDisplay != null )
				this.sideDisplay.updateTexture(anim, dir);
		}

		protected function bodyDisplay_completeHandler(event:Event):void
		{
      this.bodyDisplay.removeEventListener(Event.COMPLETE, this.bodyDisplay_completeHandler);
      this.dispatchEventWith(event.type, false, this.bodyDisplay.direction);
		}
		
		override public function dispose() : void
		{
      if( this.bodyDisplay != null )
  			Starling.juggler.remove(this.bodyDisplay);
      if( this.sideDisplay != null )
				Starling.juggler.remove(this.sideDisplay);
			super.dispose();
		}
	}
}