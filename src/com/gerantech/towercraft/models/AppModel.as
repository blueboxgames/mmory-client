package com.gerantech.towercraft.models
{
import com.gerantech.towercraft.controls.StackNavigator;
import com.gerantech.towercraft.managers.NotificationManager;
import com.gerantech.towercraft.managers.SoundManager;
import com.gerantech.towercraft.managers.net.LoadingManager;
import com.gerantech.towercraft.models.vo.Descriptor;
import com.gerantech.towercraft.themes.MainTheme;
import com.gerantech.towercraft.views.ArtRules;
import com.gerantech.towercraft.views.BattleFieldView;
import com.gt.towers.Game;
import flash.desktop.NativeApplication;
import flash.system.Capabilities;
import starling.utils.AssetManager;

public class AppModel
{
private static var _instance:AppModel;
public static const PLATFORM_WINDOWS:int = 0;
public static const PLATFORM_MAC:int = 1;
public static const PLATFORM_ANDROID:int = 2;
public static const PLATFORM_IOS:int = 3;

public var platform:int;
public var game:Game;
public var descriptor:Descriptor;
public var aspectratio:Number;
public var theme:MainTheme;
public var navigator:StackNavigator;
public var loadingManager:LoadingManager;
public var battleFieldView:BattleFieldView;
public var align:String = "right";
public var direction:String = "rtl";
public var isLTR:Boolean = false;
public var locale:String = "fa_IR";
public var assets:AssetManager;
public var sounds:SoundManager;
public var notifier:NotificationManager;
public var invokes:Array;
public var artRules:ArtRules;

public function AppModel()
{
	descriptor = new Descriptor(NativeApplication.nativeApplication.applicationDescriptor);
	assets = new AssetManager(1);
	assets.verbose = false;
	
	sounds = new SoundManager();
	notifier = new NotificationManager();
	notifier.init();
	
	switch( Capabilities.os.substr(0, 5) )
	{
		case "Mac O": platform = PLATFORM_MAC; break;
		case "Linux": platform = PLATFORM_ANDROID; break;
		case "iPhon": platform = PLATFORM_IOS; break;
	}
	//locale = StrUtils.getLocaleByMarket(AppModel.instance.descriptor.market);
}

public static function get instance():AppModel
{
	if( _instance == null )
		_instance = new AppModel();
	return _instance;
}
}
}