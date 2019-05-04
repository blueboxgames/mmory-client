package com.gerantech.towercraft.managers.net
{
import com.gerantech.extensions.NativeAbilities;
import com.gerantech.towercraft.Game;
import com.gerantech.towercraft.controls.screens.DashboardScreen;
import com.gerantech.towercraft.events.LoadingEvent;
import com.gerantech.towercraft.managers.BillingManager;
import com.gerantech.towercraft.managers.InboxService;
import com.gerantech.towercraft.managers.TimeManager;
import com.gerantech.towercraft.managers.UserPrefs;
import com.gerantech.towercraft.managers.VideoAdsManager;
import com.gerantech.towercraft.managers.net.sfs.LobbyManager;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.models.vo.UserData;
import com.gerantech.towercraft.utils.StrUtils;
import com.gerantech.towercraft.utils.Utils;
import com.gt.towers.constants.PrefsTypes;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSObject;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.system.Capabilities;
import flash.utils.getTimer;

[Event(name="loaded",				type="com.gerantech.towercraft.events.LoadingEvent")]
[Event(name="loginError",			type="com.gerantech.towercraft.events.LoadingEvent")]
[Event(name="noticeUpdate",			type="com.gerantech.towercraft.events.LoadingEvent")]
[Event(name="forceUpdate",			type="com.gerantech.towercraft.events.LoadingEvent")]
[Event(name="networkError",			type="com.gerantech.towercraft.events.LoadingEvent")]
[Event(name="coreLoadingError",		type="com.gerantech.towercraft.events.LoadingEvent")]
[Event(name="connectionLost",		type="com.gerantech.towercraft.events.LoadingEvent")]
[Event(name="forceReload",			type="com.gerantech.towercraft.events.LoadingEvent")]

public class LoadingManager extends EventDispatcher
{
public var state:int = -1;
public static const STATE_DISCONNECTED:int = -1;
public static const STATE_CONNECT:int = 0;
public static const STATE_LOGIN:int = 1;
public static const STATE_CORE_LOADING:int = 2;
public static const STATE_LOADED:int = 3;
public var loadStartAt:int;
public var serverData:SFSObject;

private var sfsConnection:SFSConnection;

public function LoadingManager(){}
public function load():void
{
	loadStartAt = getTimer();
	SFSConnection.dispose();
	sfsConnection = SFSConnection.instance;
	sfsConnection.addEventListener(SFSConnection.SUCCEED, sfsConnection_connectionHandler);
	sfsConnection.addEventListener(SFSConnection.FAILURE, sfsConnection_connectionHandler);
	state = STATE_CONNECT;
	
    DashboardScreen.TAB_INDEX = 2;
	if( appModel.navigator != null )
	{
		appModel.navigator.popAll();
		appModel.navigator.removeAllPopups();
        appModel.navigator.rootScreenID = Game.DASHBOARD_SCREEN;
	}
	if( UserData.instance.prefs == null )
		UserData.instance.prefs = new UserPrefs();
}

protected function sfsConnection_connectionHandler(event:SFSEvent):void
{
	sfsConnection.removeEventListener(SFSConnection.FAILURE, sfsConnection_connectionHandler);
	sfsConnection.removeEventListener(SFSConnection.SUCCEED, sfsConnection_connectionHandler);
	if( event.type == SFSConnection.SUCCEED )
	{				
		login();
	}
	else
	{
		dispatchEvent(new LoadingEvent(LoadingEvent.NETWORK_ERROR));
		state = STATE_DISCONNECTED;
	}
}

/**************************************   LOGIN   ****************************************/
private function login():void 
{
	state = STATE_LOGIN;
	UserData.instance.load();
	sfsConnection.addEventListener(SFSEvent.LOGIN,			sfsConnection_loginHandler);
	sfsConnection.addEventListener(SFSEvent.LOGIN_ERROR,	sfsConnection_loginErrorHandler);
	
	var loginParams:ISFSObject = new SFSObject();
	loginParams.putInt("id", UserData.instance.id);

	// new player
	var __id:int = UserData.instance.id;
	if( __id < 0 )
	{
		if( __id == -1 )
			__id = - Math.random() * int.MAX_VALUE;
		//else if( __id == -2 )
		//	__id = - int.MAX_VALUE/2 - Math.random()*(int.MAX_VALUE/2);
		
		//if( __id > - int.MAX_VALUE/2 )
		//{
		//}
	}
	loginParams.putText("udid", appModel.platform == AppModel.PLATFORM_ANDROID ? NativeAbilities.instance.deviceInfo.id : Utils.getPCUniqueCode());
	loginParams.putText("device", appModel.platform == AppModel.PLATFORM_ANDROID ? StrUtils.truncateText(NativeAbilities.instance.deviceInfo.manufacturer+"-"+NativeAbilities.instance.deviceInfo.model, 32, "") : Capabilities.manufacturer);
	loginParams.putInt("appver", appModel.descriptor.versionCode);
	loginParams.putText("market", appModel.descriptor.market);

	sfsConnection.login(__id.toString(), UserData.instance.password, "", loginParams);
}		

protected function sfsConnection_loginErrorHandler(event:SFSEvent):void
{
	sfsConnection.removeEventListener(SFSEvent.LOGIN,		sfsConnection_loginHandler);
	sfsConnection.removeEventListener(SFSEvent.LOGIN_ERROR,	sfsConnection_loginErrorHandler);
	
	if( event.params.errorCode == 110 )
		dispatchEvent(new LoadingEvent(LoadingEvent.FORCE_UPDATE));
	else
		dispatchEvent(new LoadingEvent(LoadingEvent.LOGIN_ERROR, event.params["errorCode"]));
}
protected function sfsConnection_loginHandler(event:SFSEvent):void
{
	sfsConnection.removeEventListener(SFSEvent.LOGIN,		sfsConnection_loginHandler);
	sfsConnection.removeEventListener(SFSEvent.LOGIN_ERROR, sfsConnection_loginErrorHandler);
	
	sfsConnection.addEventListener(SFSEvent.CONNECTION_LOST, sfsConnection_connectionLostHandler);
	serverData = event.params.data;
	
	if( serverData.containsKey("umt") ) // under maintenance mode
	{
		dispatchEvent(new LoadingEvent(LoadingEvent.UNDER_MAINTENANCE, serverData));
		return;
	}			
    if( serverData.containsKey("exists") )// duplicate user
	{
		dispatchEvent(new LoadingEvent(LoadingEvent.LOGIN_USER_EXISTS, serverData));
		return;
	}
    if( serverData.containsKey("ban") && serverData.getSFSObject("ban").getInt("mode") > 2 )// banned user
    {
        dispatchEvent(new LoadingEvent(LoadingEvent.LOGIN_USER_BANNED, serverData));
        return;
    }

    if( serverData.containsKey("password") )// in registering case
	{
		UserData.instance.id = serverData.getLong("id");
		UserData.instance.password = serverData.getText("password");
		UserData.instance.save();
	}
	
	if( TimeManager.instance != null )// start time manager;
		TimeManager.instance.dispose();
	new TimeManager(serverData.getLong("serverTime"));
	
	var noticeVersion:int = serverData.getInt("noticeVersion");
	var forceVersion:int = serverData.getInt("forceVersion");
	trace(appModel.descriptor.versionCode, "noticeVersion:" + noticeVersion, "forceVersion:" + forceVersion)
	if( appModel.descriptor.versionCode < serverData.getInt("forceVersion") )
		dispatchEvent(new LoadingEvent(LoadingEvent.FORCE_UPDATE));
	else if( appModel.descriptor.versionCode < serverData.getInt("noticeVersion") )
		dispatchEvent(new LoadingEvent(LoadingEvent.NOTICE_UPDATE));
	else
		loadCore();
}

public function loadCore():void
{
	var coreLoader:CoreLoader = new CoreLoader(serverData);
	UserData.instance.prefs.addEventListener(Event.COMPLETE, prefs_completeHandler);
	UserData.instance.prefs.init();

	state = STATE_CORE_LOADING;			
}

protected function prefs_completeHandler(e:*):void 
{
	UserData.instance.prefs.removeEventListener("complete", prefs_completeHandler);
	//trace(appModel.descriptor.versionCode, Game.loginData.noticeVersion, Game.loginData.forceVersion)

	state = STATE_LOADED;
	BillingManager.instance.init();			
	sfsConnection.lobbyManager = new LobbyManager();
	InboxService.instance.requestThreads();
	dispatchEvent(new LoadingEvent(LoadingEvent.LOADED));
	
	//registerPushManager();
	
	// prevent ADs for new users
	if( appModel.game.player.get_arena(0) == 0 || appModel.game.player.prefs.getAsBool(PrefsTypes.SETTINGS_5_REMOVE_ADS) )
        return;

	// catch video ads
/*	VideoAdsManager.instance.requestAd(VideoAdsManager.TYPE_CHESTS, true);
	if( appModel.game.player.getLastOperation() < appModel.game.fieldProvider.operations.keys().length )
		VideoAdsManager.instance.requestAd(VideoAdsManager.TYPE_OPERATIONS, true);*/
}

protected function sfsConnection_connectionLostHandler(event:SFSEvent):void
{
	sfsConnection.logout();
	dispatchEvent(new LoadingEvent(LoadingEvent.CONNECTION_LOST));
}

private function registerPushManager():void
{
    /*OneSignal.settings.setAutoRegister( true ).setEnableInAppAlerts( false ).setShowLogs( false );
    OneSignal.idsAvailable( onOneSignalIdsAvailable );
    function onOneSignalIdsAvailable( oneSignalUserId:String, oneSignalPushToken:String ):void {
        var pushParams:ISFSObject = new SFSObject();
        if( UserData.instance.oneSignalUserId != oneSignalUserId )
        {
            pushParams.putText("oneSignalUserId", oneSignalUserId);
            UserData.instance.oneSignalUserId = oneSignalUserId;
        }
        if( UserData.instance.oneSignalPushToken != oneSignalPushToken )
        {
            pushParams.putText("oneSignalPushToken", oneSignalPushToken);
            UserData.instance.oneSignalPushToken = oneSignalPushToken;// 'pushToken' may be null if there's a server or connection error
        }
        if( pushParams.containsKey("oneSignalUserId") )
        {
            UserData.instance.save();
            sfsConnection.sendExtensionRequest(SFSCommands.REGISTER_PUSH, pushParams);
        }
    }
    if( OneSignal.init( "83cdb330-900e-4494-82a8-068b5a358c18" ) ) {
        //NativeAbilities.instance.showToast("OneSignal.init", 2);
    }*/
	
    /*OneSignal.addNotificationReceivedCallback( onNotificationReceived );
    function onNotificationReceived( notification:OneSignalNotification ):void {
    NativeAbilities.instance.showToast(notification.message, 2);
    }*/            
}
protected function get appModel():		AppModel		{	return AppModel.instance;			}
}
}