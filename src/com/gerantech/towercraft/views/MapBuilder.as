package com.gerantech.towercraft.views
{
  import com.gerantech.mmory.core.battle.fieldes.FieldData;
  import com.gerantech.towercraft.controls.texts.ShadowLabel;
  import com.gerantech.towercraft.models.AppModel;
  import com.gerantech.towercraft.utils.StrUtils;
  import com.gerantech.xdloader.XDLoader;

  import starling.animation.Transitions;
  import starling.core.Starling;
  import starling.display.DisplayObject;
  import starling.display.Image;
  import starling.display.Sprite;
  import starling.events.Event;

  public class MapBuilder extends XDLoader
  {
    static public const SUMMON_AREA_FIRST:int = 0;
    static public const SUMMON_AREA_RIGHT:int = 1;
    static public const SUMMON_AREA_LEFT:int = 2;
    static public const SUMMON_AREA_BOTH:int = 3;

    public var summonHint:Image;
    public var tutorHint:Sprite;
    public var summonAreaMode:int;

    public function MapBuilder()
    {
      super();
      this.addEventListener(Event.ADDED, this.addedHandler);
    }

    private function addedHandler(event:Event):void
    {
      var target:DisplayObject = event.target as DisplayObject;
      if( target.name == "summon-hint" )
      {
        summonHint = target as Image;
        summonHint.visible = false;
      }
      
      if( target.name == "tutor-hint" )
      {
        tutorHint = target as Sprite;
        tutorHint.visible = false;
      }
    }

    public function setSummonAreaEnable(value:Boolean) : void
    {
      if( summonHint == null )
        return;
        
      Starling.juggler.removeTweens(summonHint);
      if( value )
      {
        summonHint.visible = true;
        Starling.juggler.tween(summonHint, 0.2, {alpha:0.5});
      }
      else
      {
        Starling.juggler.tween(summonHint, 0.2, {alpha:0, onComplete:function () : void { summonHint.visible = false; }});
      }
    }

    public function changeSummonArea(isRight:Boolean) : void
    {
      if( summonHint == null )
        return;
      if( AppModel.instance.battleFieldView.battleData.allise.getInt("score") > 1 )
      {
        summonAreaMode = SUMMON_AREA_BOTH;
        summonHint.texture = AppModel.instance.assets.getTexture("summon-2");
        return;
      }
      summonAreaMode = isRight ? SUMMON_AREA_RIGHT : SUMMON_AREA_LEFT;
      summonHint.texture = AppModel.instance.assets.getTexture("summon-1");
      summonHint.scaleX = Math.abs(summonHint.scaleX) * (isRight ? -1 : 1);
    }

    public function showtutorHint(field:FieldData, battleswins:int):void
    {
      if( tutorHint == null )
        return;
      tutorHint.visible = true;
      Starling.juggler.tween(tutorHint, 1.5, {alpha:0, repeatCount:7, onComplete:hideHint});
      
      var tutorHintText:ShadowLabel = new ShadowLabel(StrUtils.loc("tutor_" + field.mode + "_enemy_hint"), field.mode == 0 ? 0xEC3E3E : 0xFFFFFF, 0, "center", null, true, "center", 1.3);
      tutorHintText.width = Starling.current.stage.width * 0.8;
      tutorHintText.pivotX = tutorHintText.width * 0.5;
      tutorHintText.pivotY = tutorHintText.height * 0.5;
      tutorHintText.x = Starling.current.stage.width * 0.45;
      tutorHintText.y = Starling.current.stage.height * (field.mode == 0 ? 0.15 : 0.12);
      tutorHintText.scale = 0;
      tutorHintText.alpha = 0;
      AppModel.instance.battleFieldView.guiTextsContainer.addChild(tutorHintText);
      Starling.juggler.tween(tutorHintText, 0.6, {delay:1, alpha:1, scale:1, transition:Transitions.EASE_OUT_BACK});

      function hideHint() : void
      {
        tutorHintText.visible = true;
        tutorHintText.removeFromParent(true);
      }
    }
  }
}