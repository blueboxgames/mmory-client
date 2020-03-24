package com.gerantech.towercraft.views.hb
{
  import com.gerantech.towercraft.models.AppModel;
  import com.gerantech.towercraft.views.ArtRules;
  import com.gerantech.towercraft.views.BattleFieldView;
  import com.gerantech.towercraft.views.units.UnitView;

  import starling.animation.Transitions;
  import starling.core.Starling;
  import starling.display.Image;
  import starling.display.Sprite;

  public class HealthBarZone implements IHealthBar
  {
    protected var _side:int = -1;
    protected var _value:Number = 0.0;
    protected var _alpha:Number = 1.0;
    protected var _maximum:Number = 1.0;
    protected var unit:UnitView;
    protected var centerDisplay:Image;
    protected var filedView:BattleFieldView;
    protected var backgroundZone:ZoneBorder;
    protected var sideZone:ZoneBorder;

    public function HealthBarZone(filedView:BattleFieldView, unit:UnitView)
    {
      super();

      this.unit = unit;
      this.filedView = filedView;

      this.centerDisplay = new Image(AppModel.instance.assets.getTexture(unit.card.type + "/center"));
      this.centerDisplay.pivotX = this.centerDisplay.width * 0.5;
      this.centerDisplay.pivotY = this.centerDisplay.height * 0.5;
      this.centerDisplay.x = this.unit.getSideX();
      this.centerDisplay.y = this.unit.getSideY();
      filedView.shadowsContainer.addChildAt(this.centerDisplay, 0);

      this.sideZone = new ZoneBorder(unit);
      this.sideZone.x = this.unit.getSideX();
      this.sideZone.y = this.unit.getSideY();
      filedView.shadowsContainer.addChildAt(this.sideZone, 0);

      this.backgroundZone = new ZoneBorder(unit);
      this.backgroundZone.x = this.unit.getSideX();
      this.backgroundZone.y = this.unit.getSideY();
      // this.backgroundZone.blendMode = BlendMode.ADD;
      this.backgroundZone.alpha = 0.5;
      filedView.shadowsContainer.addChildAt(this.backgroundZone, 0);

      this.maximum = unit.cardHealth;
      this.side = side;
    }

    public function setPosition(x:Number, y:Number):void
    {
    }

    public function get value():Number
    {
    	return this._value;
    }
    public function set value(v:Number):void
    {
      if( this._value == v )
        return;
      this._value = v;
      if( this.sideZone != null )
        this.sideZone.value = v;
    }

    public function get maximum():Number
    {
      return this._maximum;
    }
    public function set maximum(value:Number):void
    {
      this._maximum = value;
    }

    public function get alpha():Number
    {
    	return _alpha;
    }
    public function set alpha(value:Number):void
    {
      if( this._alpha == value )
        return;
      this.sideZone.alpha = value;
      this.centerDisplay.alpha = value;
      this.backgroundZone.alpha = value;
    }

    public function get width():Number
    {
      return 0;
    }
    public function set width(value:Number):void
    {
    }

    public function get height():Number
    {
      return 0;
    }
    public function set height(value:Number):void
    {}

    public function get side():int
    {
      return this._side;
    }
    public function set side(value:int):void
    {
      if( this._side == value )
        return;
      this._side = value;

      if( this.centerDisplay != null )
      {
        this.centerDisplay.color = ArtRules.getSideColor(value);
        this.centerDisplay.scale = 0;
        Starling.juggler.tween(this.centerDisplay, 0.3, {scale:1, transition:Transitions.EASE_OUT_ELASTIC});
      }

      if( this.sideZone != null )
        this.sideZone.side = value;
    }

    public function dispose():void
    {
      if( this.sideZone != null )
        this.sideZone.removeFromParent(true);
      if( this.backgroundZone != null )
        this.backgroundZone.removeFromParent(true);
    }
  }
}

import com.gerantech.mmory.core.battle.BattleField;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.views.ArtRules;
import com.gerantech.towercraft.views.units.UnitView;

import starling.core.Starling;
import starling.display.BlendMode;
import starling.display.Image;
import starling.display.Sprite;
class ZoneBorder extends Sprite
{
  private var _side:int;
  private var _value:int;
  private var _maximum:Number;
  private var unit:UnitView;
  private var background:Image;
  private var candles:Vector.<Image>;
  public function ZoneBorder(unit:UnitView, count:int = 64)
  {
    super();
    this.unit = unit;
    this.maximum = unit.cardHealth;
    this.candles = new Vector.<Image>();
    this.scaleY = BattleField.CAMERA_ANGLE;

    this.background = new Image(AppModel.instance.assets.getTexture(unit.card.type + "/light"));
    this.background.pivotX = this.background.width * 0.5;
    this.background.pivotY = this.background.height * 0.5;
    this.background.width = this.unit.card.focusRange * 2 + 10;
    this.background.height = this.unit.card.focusRange * 2 + 10;
    this.background.blendMode = BlendMode.AUTO;
    this.addChild(this.background);

    for(var i:int = 0; i < count; i++)
    {
      var candle:Image = new Image(AppModel.instance.assets.getTexture(unit.card.type + "/candle"));
      candle.pivotX = candle.width * 0.5;
      candle..pivotY = unit.card.focusRange;
      candle.rotation = Math.PI * 2 * i / count;
      this.addChild(candle);
      this.candles[i] = candle;
    }
  }

  public function get side():int
  {
    return this._side;
  }
  public function set side(value:int):void
  {
    if( this._side == value )
      return;
    this._side = value;
    var c:uint = ArtRules.getSideColor(value);
    for(var i:int = 0; i < this.candles.length; i++)
      this.candles[i].color = c;
    
    this.background.visible = value < -1;
    if( value < -1 )
    {
      this.background.scale = 0;
      this.background.color = c;
      Starling.juggler.tween(this.background, 0.3, {width:this.unit.card.focusRange * 2 + 10, height:this.unit.card.focusRange * 2 + 10});
    }
  }

  public function get value():Number
  {
    return this._value;
  }
  public function set value(value:Number):void
  {
    if( this._value == value )
      return;
    this._value = value;
    var ratio:int = Math.round(value / this._maximum * this.candles.length);
    for(var i:int = 0; i < this.candles.length; i++)
      this.candles[i].visible = i < ratio;
  }

  public function get maximum():Number
  {
    return this._maximum;
  }
  public function set maximum(value:Number):void
  {
    this._maximum = value;
  }
}