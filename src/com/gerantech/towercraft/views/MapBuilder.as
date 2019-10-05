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
  import com.gerantech.mmory.core.battle.BattleField;

  public class MapBuilder extends XDLoader
  {
    private var summonImage:Image;
    private var summonThird:Image;
    private var summonHalf:Image;
    private var summonRight:Image;
    private var summonLeft:Image;
    private var summonBot:Image;
    private var tutorHint:Sprite;

    public function MapBuilder()
    {
      super();
      this.addEventListener(Event.ADDED, this.addedHandler);
    }

    private function addedHandler(event:Event):void
    {
      var target:DisplayObject = event.target as DisplayObject;
      if( target.name == null )
        return;
      if( target.name.length > 7 && target.name.substring(0, 7) == "summon-" )
      {
        if( target.name == "summon-third" )
          summonThird = target as Image;
        else if( target.name == "summon-half" )
          summonHalf = target as Image;
        else if( target.name == "summon-right" )
          summonRight = target as Image;
        else if( target.name == "summon-left" )
          summonLeft = target as Image;
        else if( target.name == "summon-bot" )
          summonBot = target as Image;
        
        Image(target).color = 0x220000;
        Image(target).visible = false;
      }
      
      if( target.name == "tutor-hint" )
      {
        tutorHint = target as Sprite;
        tutorHint.visible = false;
      }
    }

    public function setSummonAreaEnable(value:Boolean, summonState:int) : void
    {
      if( summonImage != null )
        summonImage.visible = false;
      summonImage = getSummonImage(summonState)
      Starling.juggler.removeTweens(summonImage);
      if( value )
      {
        summonImage.visible = true;
        Starling.juggler.tween(summonImage, 0.2, {alpha:0.5});
      }
      else
      {
        Starling.juggler.tween(summonImage, 0.2, {alpha:0, onComplete:function () : void { summonImage.visible = false; }});
      }
    }

    private function getSummonImage(summonState:int):Image
    {
      switch( summonState )
      {
        case BattleField.SUMMON_AREA_HALF: return summonHalf;
        case BattleField.SUMMON_AREA_RIGHT: return summonRight;
        case BattleField.SUMMON_AREA_LEFT: return summonLeft;
        case BattleField.SUMMON_AREA_BOTH: return summonBot;
      }
      return summonThird;
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