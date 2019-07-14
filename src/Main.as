package
{
import com.gerantech.mmory.core.constants.ResourceType;
import com.gerantech.towercraft.Game;
import com.gerantech.towercraft.controls.screens.BattleScreen;
import com.gerantech.towercraft.controls.screens.SplashScreen;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.utils.Localizations;
import com.marpies.ane.gameanalytics.GameAnalytics;
import com.marpies.ane.gameanalytics.data.GAErrorSeverity;

import feathers.events.FeathersEventType;

import flash.desktop.NativeApplication;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.display3D.Context3DProfile;
import flash.display3D.Context3DRenderMode;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.InvokeEvent;
import flash.events.UncaughtErrorEvent;
import flash.utils.getTimer;

import haxe.Log;

import starling.core.Starling;

public class Main extends Sprite
{
public static var t:int;
private var starling:Starling;
private var splash:SplashScreen;

public function Main()
{
	Log.trace = function(v : * , p : * = null) : void {trace(p.fileName.substr(0,p.fileName.length-3) + "|" + p.methodName+":" + p.lineNumber + " =>  " + v); }
	Localizations.instance.changeLocale(Localizations.instance.getLocaleByMarket(AppModel.instance.descriptor.market));
	/*var str:String = "";
	var ret:Number = -0.05;
	for( var level:int=1; level<=13; level++ )
		str += level + "[" + ((			ret + (Math.log(level) * 0.585) * (ret/Math.abs(ret))			)).toFixed(3) + "]   " ;
	trace(str);
	NativeApplication.nativeApplication.exit();
	return;*/
    
	// GameAnalytic Configurations
	var currencies:Vector.<String> = new Vector.<String>();
	// var bt:Array = CardTypes.getAll();
	// for each( var r:int in bt )
	// 	currencies.push(r.toString());
	currencies.push(ResourceType.R1_XP.toString());
	currencies.push(ResourceType.R2_POINT.toString());
	currencies.push(ResourceType.R4_CURRENCY_HARD.toString());
	currencies.push(ResourceType.R3_CURRENCY_SOFT.toString());
	
	GameAnalytics.config/*.setUserId("test_id").setResourceCurrencies(new <String>["gems", "coins"]).setResourceItemTypes(new <String>["boost", "lives"]).setCustomDimensions01(new <String>["ninja", "samurai"])*/
		.setBuildAndroid(AppModel.instance.descriptor.versionNumber).setGameKeyAndroid("df4b20d8b9a4b0ec2fdf5ac49471d5b2").setGameSecretAndroid("972a1c900218b46f42d8a93e2f69710545903307")
		.setResourceCurrencies(currencies)
		.setResourceItemTypes(new <String>["outcome", "special", "book", "purchase", "exchange", "upgrade", "donate"])
	/*.setBuildiOS(AppModel.instance.descriptor.versionNumber).setGameKeyiOS("[ios_game_key]").setGameSecretiOS("[ios_secret_key]")*/
	GameAnalytics.init();
	
	t = getTimer();
	stage.scaleMode = StageScaleMode.NO_SCALE;
	stage.align = StageAlign.TOP_LEFT;
	AppModel.instance.aspectratio = this.stage.fullScreenWidth / this.stage.fullScreenHeight;

	this.mouseEnabled = this.mouseChildren = false;
	splash = new SplashScreen(stage);
	splash.addEventListener(FeathersEventType.TRANSITION_IN_COMPLETE, loaderInfo_completeHandler);

	loaderInfo.addEventListener(Event.COMPLETE, loaderInfo_completeHandler);
	loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, loaderInfo_uncaughtErrorHandler);
	NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, nativeApplication_invokeHandler);
}

private function loaderInfo_completeHandler(event:Event):void
{
	if( event.currentTarget == this.loaderInfo )
		this.loaderInfo.removeEventListener(Event.COMPLETE, loaderInfo_completeHandler);
	else
		this.splash.removeEventListener(FeathersEventType.TRANSITION_IN_COMPLETE, loaderInfo_completeHandler);
	
	if( this.loaderInfo.bytesLoaded == this.loaderInfo.bytesTotal && this.splash.transitionInCompleted )
		starStarling();
}

private function starStarling():void
{
	//var _ratio:Number = 1080 / stage.fullScreenWidth;
	//var _height:Number = Math.min(stage.fullScreenWidth * 2, stage.fullScreenHeight);
	this.starling = new Starling(Game, stage, null, null, Context3DRenderMode.AUTO, Context3DProfile.BASELINE_EXTENDED);
	this.starling.addEventListener("rootCreated", starling_rootCreatedHandler);
	this.starling.supportHighResolutions = true;
	this.starling.skipUnchangedFrames = true;
	this.starling.start();
	this.starling.stage.stageWidth  = 1080;
	this.starling.stage.stageHeight = 1080 * (stage.fullScreenHeight / stage.fullScreenWidth);
	//NativeAbilities.instance.showToast(stage.fullScreenWidth + "," + stage.fullScreenHeight + "," + this.starling.stage.stageWidth + "," + this.starling.stage.stageHeight + "," + this.starling.contentScaleFactor, 2);
	//this.starling.showStatsAt("right", "top", 1 / this.starling.contentScaleFactor);
	trace(stage.fullScreenWidth, stage.fullScreenHeight, this.starling.stage.stageWidth, this.starling.stage.stageHeight, this.starling.contentScaleFactor);
}

private function starling_rootCreatedHandler(event:Object):void
{
	this.stage.addEventListener(Event.DEACTIVATE, stage_deactivateHandler, false, 0, true);
}

protected function stage_deactivateHandler(event:Event):void
{
	if( !BattleScreen.IN_BATTLE )
	{
		this.starling.stop(true);
		this.stage.frameRate = 0;
	}
	this.stage.addEventListener(Event.ACTIVATE, stage_activateHandler, false, 0, true);
	AppModel.instance.sounds.muteAll(true);
	AppModel.instance.notifier.reset();
}
protected function stage_activateHandler(event:Event):void
{
	this.stage.removeEventListener(Event.ACTIVATE, stage_activateHandler);
	this.stage.frameRate = 60;
	this.starling.start();
	AppModel.instance.sounds.muteAll(false);
	AppModel.instance.notifier.clear();
}

protected function nativeApplication_invokeHandler(event:InvokeEvent):void
{
	NativeApplication.nativeApplication.removeEventListener(InvokeEvent.INVOKE, nativeApplication_invokeHandler);
	AppModel.instance.invokes = event.arguments;
}

protected function loaderInfo_uncaughtErrorHandler(event:UncaughtErrorEvent):void 
{
	var text:String;
	var severity:int;

	if( event.error is Error )
	{
		text =  event.error.getStackTrace();
		severity = GAErrorSeverity.CRITICAL;
	}
	else if( event.error is ErrorEvent )
	{
		text = event.error.text;
		severity = GAErrorSeverity.ERROR;
	}
	else
	{
		text = event.error.toString();
		severity = GAErrorSeverity.WARNING;
	}
	GameAnalytics.addErrorEvent(severity, text);
	//navigateToURL(new URLRequest("http://127.0.0.1:8080/towerslet/towers?" + severity + "--" + text));
}
}
}