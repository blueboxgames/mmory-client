package com.gerantech.towercraft.controls.toasts 
{
import com.gerantech.towercraft.controls.BattleHUD;
import com.gerantech.towercraft.controls.screens.BattleScreen;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import feathers.controls.ImageLoader;
import feathers.controls.LayoutGroup;
import feathers.controls.Screen;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;
import flash.geom.Rectangle;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Quad;
/**
* ...
* @author Mansour Djawadi
*/
public class BattleExtraTimeToast extends BaseToast
{
static public const MODE_ELIXIR_2X:int = 0;
static public const MODE_EXTRA_TIME:int = 1;
private var mode:int;
private var elixirLine:LayoutGroup;
public function BattleExtraTimeToast(mode:int) 
{
	this.mode = mode;
	closeAfter = 3000;
	toastHeight = 340;
}

override protected function initialize():void
{
	super.initialize();

	touchable = false;
	backgroundSkin = new Quad (1, 1, 0);
	backgroundSkin.alpha = 0.5;
	
	transitionIn.time = 0.7;
	transitionOut.destinationBound.y = transitionIn.sourceBound.y = 350;
	transitionIn.destinationBound.y = transitionOut.sourceBound.y = 400;
	rejustLayoutByTransitionData();
	
	layout = new AnchorLayout();
	
	// time
	var timeLine:LayoutGroup = new LayoutGroup();
	timeLine.layout = new HorizontalLayout();
	HorizontalLayout(timeLine.layout).verticalAlign = VerticalAlign.MIDDLE;
	timeLine.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, mode == MODE_ELIXIR_2X ? -56 : 0);
	addChild(timeLine);
	
	var extraIcon:ImageLoader = new ImageLoader();
	extraIcon.width = 200;
	extraIcon.source = Assets.getTexture("extra-time");
	extraIcon.pixelSnapping = false;
	
	var extraLabel:ShadowLabel = new ShadowLabel(loc(mode == MODE_ELIXIR_2X ? "battle_remaining" : "battle_extratime"), 1, 0, null, null, false, null, 1.4);
	
	timeLine.addChild(!appModel.isLTR ? extraLabel : extraIcon);
	timeLine.addChild( appModel.isLTR ? extraLabel : extraIcon);
	
	timeLine.scale = 0;
	Starling.juggler.tween(timeLine, 0.3, {delay:0.0, scale:1, transition:Transitions.EASE_OUT_BACK });
	Starling.juggler.tween(timeLine, 0.3, {delay:3.0, scale:0, transition:Transitions.EASE_IN_BACK });
	
	appModel.sounds.addAndPlay("whoosh");
	if( mode != MODE_ELIXIR_2X )
		return;
	
	// elixir
	elixirLine = new LayoutGroup();
	elixirLine.layout = new HorizontalLayout();
	HorizontalLayout(elixirLine.layout).verticalAlign = VerticalAlign.MIDDLE;
	elixirLine.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, 100);
	addChild(elixirLine);
	
	var elixirIcon:ImageLoader = new ImageLoader();
	elixirIcon.width = 200;
	elixirIcon.source = Assets.getTexture("elixir");
	elixirIcon.pixelSnapping = false;
	
	var elixirLabel:ShadowLabel = new ShadowLabel("2x", 0x27E0DC, 0, null, null, false, null, 2.2);
	elixirLine.addChild( appModel.isLTR ? elixirLabel : elixirIcon);
	elixirLine.addChild(!appModel.isLTR ? elixirLabel : elixirIcon)
	
	elixirLine.scale = 0;
	Starling.juggler.tween(elixirLine, 0.3, {delay:0.2, scale:1, transition:Transitions.EASE_OUT_BACK });
}

override public function dispose() : void
{
	if( elixirLine != null )
	{
		var battleScreen:BattleScreen = appModel.navigator.activeScreen as BattleScreen;
		if( battleScreen == null )
			return;
		var hud:BattleHUD = battleScreen.hud;
		var mapped:Rectangle = elixirLine.getBounds(stage);
		elixirLine.includeInLayout = false;
		elixirLine.x = mapped.x;
		elixirLine.y = mapped.y;
		hud.addChild(elixirLine);
		Starling.juggler.tween(elixirLine, 0.8, {x:860, y:150, scale:0.6, transition:Transitions.EASE_IN_OUT_BACK });
	}
	
	super.dispose();
}
}
}