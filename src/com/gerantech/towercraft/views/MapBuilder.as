package com.gerantech.towercraft.views 
{
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.utils.StrUtils;
import com.gt.towers.battle.fieldes.FieldData;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.display.Image;
import starling.display.MovieClip;
import starling.display.Sprite;
import starlingbuilder.engine.IAssetMediator;
import starlingbuilder.engine.UIBuilder;
import starlingbuilder.engine.localization.ILocalization;
import starlingbuilder.engine.tween.ITweenBuilder;

/**
* ...
* @author Mansour Djawadi
*/
public class MapBuilder extends UIBuilder 
{
static public const linkers:Array = [MovieClip];
static public const SUMMON_AREA_FIRST:int = 0;
static public const SUMMON_AREA_RIFGT:int = 1;
static public const SUMMON_AREA_LEFT:int = 2;
static public const SUMMON_AREA_BOTH:int = 3;

public var mainMap:Sprite;
public var summonAreaMode:int;
private var enemyHint:Sprite;
private var summonHint:Image;
private var movieClips:Vector.<MovieClip>;
public function MapBuilder(assetMediator:IAssetMediator, forEditor:Boolean=false, template:Object=null, localization:ILocalization=null, tweenBuilder:ITweenBuilder=null) 
{
    movieClips = new Vector.<MovieClip>();
	super(assetMediator, forEditor, template, localization, tweenBuilder);
}

override public function create(data:Object, trimLeadingSpace:Boolean = true, binder:Object = null) : Object
{
	var root:Sprite = super.create(data, trimLeadingSpace, binder) as Sprite;
	mainMap = root.getChildByName("main") as Sprite;
	activeMovieClips(mainMap);
	return root;
}

private function activeMovieClips(container:DisplayObjectContainer) : void
{
	for ( var i:int = 0; i < container.numChildren; i ++ )
	{
		if( container.getChildAt(i) is MovieClip )
		{
			var m:MovieClip = container.getChildAt(i) as MovieClip;
			Starling.current.juggler.add(m);
			m.play();
			movieClips.push(m);
		}
		if( container.getChildAt(i) is DisplayObjectContainer )
			activeMovieClips(container.getChildAt(i) as DisplayObjectContainer );
		
		if( container.getChildAt(i).name == "summon-area" )
		{
			summonHint = container.getChildAt(i) as Image;
			summonHint.visible = false;
		}
		
		if( container.getChildAt(i).name == "focus-rects" )
		{
			enemyHint = container.getChildAt(i) as Sprite;
			enemyHint.visible = false;
		}
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
	summonAreaMode = isRight ? SUMMON_AREA_RIFGT : SUMMON_AREA_LEFT;
	summonHint.texture = AppModel.instance.assets.getTexture("summon-1");
	summonHint.scaleX = Math.abs(summonHint.scaleX) * (isRight ? -1 : 1);
}

public function showEnemyHint(field:FieldData, battleswins:int):void
{
	if( enemyHint == null )
		return;
	enemyHint.visible = true;
	Starling.juggler.tween(enemyHint, 1.5, {alpha:0, repeatCount:10, onComplete:hideHint});
	
	var enemyHintText:ShadowLabel = new ShadowLabel(StrUtils.loc("tutor_" + field.mode + "_enemy_hint"), 0xEC3E3E, 0, "center", null, true, "center", 1.4);
	enemyHintText.width = Starling.current.stage.width * 0.8;
	enemyHintText.pivotX = enemyHintText.width * 0.5;
	enemyHintText.pivotY = enemyHintText.height * 0.5;
	enemyHintText.x = Starling.current.stage.width * 0.45;
	enemyHintText.y = Starling.current.stage.height * 0.15;
	enemyHintText.scale = 0;
	enemyHintText.alpha = 0;
	AppModel.instance.battleFieldView.guiTextsContainer.addChild(enemyHintText);
	Starling.juggler.tween(enemyHintText, 0.6, {delay:1, alpha:1, scale:1, transition:Transitions.EASE_OUT_BACK});

	function hideHint() : void
	{
		enemyHintText.visible = true;
		enemyHintText.removeFromParent(true);
	}
}

public function dispose() : void 
{
	for each( var m:MovieClip in movieClips )
		Starling.current.juggler.remove(m);
}
}
}