package
{
import com.gameanalytics.sdk.GAErrorSeverity;
import com.gameanalytics.sdk.GameAnalytics;
import com.gerantech.mmory.core.constants.ExchangeType;
import com.gerantech.mmory.core.constants.ResourceType;
import com.gerantech.towercraft.Game;
import com.gerantech.towercraft.controls.screens.BattleScreen;
import com.gerantech.towercraft.controls.screens.SplashScreen;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.models.vo.Descriptor;
import com.gerantech.towercraft.utils.Localizations;
import com.tuarua.FirebaseANE;
import com.tuarua.fre.ANEError;

import feathers.events.FeathersEventType;

import flash.desktop.NativeApplication;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.InvokeEvent;
import flash.events.UncaughtErrorEvent;
import flash.filesystem.File;
import flash.geom.Rectangle;
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
	var desc:Descriptor = AppModel.instance.descriptor;

	forceCopy("gui.atf", "gui.atf");
	forceCopy("gui.xml", "gui.xml");
	forceCopy(Localizations.instance.getLocaleByMarket(desc.market) + ".json", Localizations.instance.getLocaleByMarket(desc.market) + ".json");
	// change locale based on market
	Localizations.instance.changeLocale(Localizations.instance.getLocaleByMarket(desc.market));

	// GameAnalytic Configurations
	GameAnalytics.config/*.setUserId("test_id").setResourceCurrencies(new <String>["gems", "coins"]).setResourceItemTypes(new <String>["boost", "lives"]).setCustomDimensions01(new <String>["ninja", "samurai"])*/
		.setBuildAndroid(desc.versionNumber).setGameKeyAndroid(desc.analyticskey).setGameSecretAndroid(desc.analyticssec)
		.setResourceCurrencies(new <String>[ResourceType.getName(ResourceType.R1_XP), ResourceType.getName(ResourceType.R2_POINT), ResourceType.getName(ResourceType.R3_CURRENCY_SOFT), ResourceType.getName(ResourceType.R4_CURRENCY_HARD), ResourceType.getName(ResourceType.R6_TICKET)])
		.setResourceItemTypes(new <String>["Initial", ExchangeType.getName(ExchangeType.C0_HARD), ExchangeType.getName(ExchangeType.C10_SOFT), ExchangeType.getName(ExchangeType.C20_SPECIALS), ExchangeType.getName(ExchangeType.C30_BUNDLES), ExchangeType.getName(ExchangeType.C40_OTHERS), ExchangeType.getName(ExchangeType.BOOKS_50), ExchangeType.getName(ExchangeType.C70_TICKETS), ExchangeType.getName(ExchangeType.C80_EMOTES), ExchangeType.getName(ExchangeType.C100_FREES), ExchangeType.getName(ExchangeType.C110_BATTLES), ExchangeType.getName(ExchangeType.C120_MAGICS)]);
	try {
	if( GameAnalytics.isSupported )
		GameAnalytics.init();
	} catch (error:Error) { trace(error.message);	}
	
	t = getTimer();
	stage.scaleMode = StageScaleMode.NO_SCALE;
	stage.align = StageAlign.TOP_LEFT;

	this.mouseEnabled = this.mouseChildren = false;
	splash = new SplashScreen(stage);
	splash.addEventListener(FeathersEventType.TRANSITION_IN_COMPLETE, loaderInfo_completeHandler);

	loaderInfo.addEventListener(Event.COMPLETE, loaderInfo_completeHandler);
	loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, loaderInfo_uncaughtErrorHandler);
	NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, nativeApplication_invokeHandler);

	// Here we will initalize firebase native extension, required for Firebase Cloud Messaging.
	if( AppModel.instance.platform == AppModel.PLATFORM_ANDROID )
	{
		try
		{
			FirebaseANE.init();
			if( !FirebaseANE.isGooglePlayServicesAvailable )
				trace("Google Play Service is not installed on device");
			if( FirebaseANE.options )
				trace("apiKey", FirebaseANE.options.apiKey, "googleAppId", FirebaseANE.options.googleAppId);
		} catch (e:ANEError) { trace(e.errorID, e.message, e.getStackTrace(), e.source); }
	}
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
private function forceCopy(src:String, dst:String):void
{
	var file:File = File.applicationStorageDirectory.resolvePath("assets/" + dst);
	if( !file.exists )
		File.applicationDirectory.resolvePath("assets/" + src).copyTo(file, true);
}

private function starStarling():void
{
	this.starling = new Starling(Game, stage, new Rectangle(0,0,stage.stageWidth,stage.stageHeight));
	this.starling.addEventListener("rootCreated", starling_rootCreatedHandler);
	this.starling.supportHighResolutions = true;
	this.starling.skipUnchangedFrames = true;
	this.starling.start();
	this.starling.stage.stageWidth  = 1080;
	this.starling.stage.stageHeight = 1080 * (stage.stageHeight / stage.stageWidth);
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
	AppModel.instance.invokes = event.arguments;
	if(AppModel.instance.navigator)
		AppModel.instance.navigator.handleInvokes();
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
	if(GameAnalytics.isInitialized)
		GameAnalytics.addErrorEvent(severity, text);
	// new GTStreamer(File.applicationStorageDirectory.resolvePath("log.txt"), null, null, null, false, false).save(text);
}
}
}