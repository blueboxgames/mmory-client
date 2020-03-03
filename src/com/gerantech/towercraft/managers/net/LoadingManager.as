package com.gerantech.towercraft.managers.net
{
import com.chartboost.plugin.air.model.CBLocation;
import com.gerantech.extensions.DeviceInfo;
import com.gerantech.extensions.NativeAbilities;
import com.gerantech.mmory.core.constants.ExchangeType;
import com.gerantech.mmory.core.constants.PrefsTypes;
import com.gerantech.towercraft.Game;
import com.gerantech.towercraft.controls.items.EmoteItemRenderer;
import com.gerantech.towercraft.controls.items.exchange.ExCategoryItemRenderer;
import com.gerantech.towercraft.controls.overlays.OpenBookOverlay;
import com.gerantech.towercraft.controls.overlays.TutorialMessageOverlay;
import com.gerantech.towercraft.controls.screens.DashboardScreen;
import com.gerantech.towercraft.events.LoadingEvent;
import com.gerantech.towercraft.managers.BillingManager;
import com.gerantech.towercraft.managers.InboxService;
import com.gerantech.towercraft.managers.TimeManager;
import com.gerantech.towercraft.managers.UserPrefs;
import com.gerantech.towercraft.managers.VideoAdsManager;
import com.gerantech.towercraft.managers.net.sfs.LobbyManager;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.models.vo.UserData;
import com.gerantech.towercraft.utils.StrUtils;
import com.gerantech.towercraft.utils.SyncUtil;
import com.gerantech.towercraft.utils.Utils;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSObject;
import com.tuarua.firebase.MessagingANE;
import com.tuarua.firebase.messaging.events.MessagingEvent;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.system.Capabilities;
import flash.utils.getTimer;
import flash.utils.setTimeout;

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
		OpenBookOverlay.factory = null;
		EmoteItemRenderer.factory = null;
		TutorialMessageOverlay.factory = null;
		ExCategoryItemRenderer.placeholders = null;
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
		state = STATE_DISCONNECTED;
		setTimeout( dispatchEvent, 100, new LoadingEvent(LoadingEvent.NETWORK_ERROR));
	}
}

/**************************************   LOGIN   ****************************************/
private function login():void 
{
	state = STATE_LOGIN;
	dispatchEvent(new LoadingEvent(LoadingEvent.PROGRESS, 0.3));
	UserData.instance.load();
	sfsConnection.addEventListener(SFSEvent.LOGIN,			sfsConnection_loginHandler);
	sfsConnection.addEventListener(SFSEvent.LOGIN_ERROR,	sfsConnection_loginErrorHandler);
	sfsConnection.addEventListener(SFSEvent.CONFIG_LOAD_SUCCESS,	sfsConnection_configLoadHandler);
	
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
	var device:DeviceInfo = NativeAbilities.instance.deviceInfo;
	loginParams.putText("imei", appModel.platform == AppModel.PLATFORM_ANDROID ? device.imei : "");
	loginParams.putText("udid", appModel.platform == AppModel.PLATFORM_ANDROID ? device.id : Utils.getPCUniqueCode());
	loginParams.putText("device", appModel.platform == AppModel.PLATFORM_ANDROID ? StrUtils.truncateText(device.manufacturer+"-"+device.model, 32, "") : Capabilities.manufacturer);
	loginParams.putText("market", appModel.descriptor.market);
	loginParams.putInt("appver", appModel.descriptor.versionCode);

	sfsConnection.login(__id.toString(), UserData.instance.password, "", loginParams);
}		

protected function sfsConnection_configLoadHandler(event:SFSEvent):void
{
	dispatchEvent(new LoadingEvent(LoadingEvent.PROGRESS, 0.4));
}		

protected function sfsConnection_loginErrorHandler(event:SFSEvent):void
{
	sfsConnection.removeEventListener(SFSEvent.LOGIN,		sfsConnection_loginHandler);
	sfsConnection.removeEventListener(SFSEvent.LOGIN_ERROR,	sfsConnection_loginErrorHandler);
	sfsConnection.removeEventListener(SFSEvent.CONFIG_LOAD_SUCCESS,	sfsConnection_configLoadHandler);
	
	if( event.params.errorCode == 110 )
		dispatchEvent(new LoadingEvent(LoadingEvent.FORCE_UPDATE));
	else
		dispatchEvent(new LoadingEvent(LoadingEvent.LOGIN_ERROR, event.params["errorCode"]));
}
protected function sfsConnection_loginHandler(event:SFSEvent):void
{
	dispatchEvent(new LoadingEvent(LoadingEvent.PROGRESS, 0.4));
	sfsConnection.removeEventListener(SFSEvent.LOGIN,		sfsConnection_loginHandler);
	sfsConnection.removeEventListener(SFSEvent.LOGIN_ERROR, sfsConnection_loginErrorHandler);
	sfsConnection.removeEventListener(SFSEvent.CONFIG_LOAD_SUCCESS,	sfsConnection_configLoadHandler);
	
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
	
	trace(appModel.descriptor.versionCode, "noticeVersion:" + serverData.getInt("noticeVersion"), "forceVersion:" + serverData.getInt("forceVersion"));
	if( appModel.descriptor.versionCode < serverData.getInt("forceVersion") )
		dispatchEvent(new LoadingEvent(LoadingEvent.FORCE_UPDATE));
	else if( appModel.descriptor.versionCode < serverData.getInt("noticeVersion") )
		dispatchEvent(new LoadingEvent(LoadingEvent.NOTICE_UPDATE));
	else
	{
		SyncUtil.ALL = serverData.getSFSObject("assets").toObject();
		SyncUtil.BASE_URL = serverData.getText("assetsBaseURL");trace(serverData.getText("assetsBaseURL"));
		var syncTool:SyncUtil = new SyncUtil();
		syncTool.addEventListener(Event.COMPLETE, syncTool_completeHandler);
		syncTool.sync("init");
	}
}

private function syncTool_completeHandler(event:*):void
{
	loadCore();
}

public function loadCore():void
{
	state = STATE_CORE_LOADING;
	var coreLoader:CoreLoader = new CoreLoader(serverData);
	
	UserData.instance.prefs.addEventListener(Event.COMPLETE, prefs_completeHandler);
	UserData.instance.prefs.init();
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
	
	registerFCMPushManager();
	
	// prevent ADs for new users
	if( appModel.game.player.get_arena(0) == 0 || !appModel.game.player.prefs.getAsBool(PrefsTypes.SETTINGS_5_ADS) )
		return;

	// catch video ads
	VideoAdsManager.instance.adProvider = VideoAdsManager.AD_PROVIDER_CHARTBOOST;
	if( VideoAdsManager.instance.adProvider == VideoAdsManager.AD_PROVIDER_CHARTBOOST )
	{
		// VideoAdsManager.instance.requestAd(VideoAdsManager.TYPE_CHESTS, true);
		VideoAdsManager.instance.requestAdIn(ExchangeType.C43_ADS, false, CBLocation.DEFAULT);
	}
	/* if( appModel.game.player.getLastOperation() < appModel.game.fieldProvider.operations.keys().length )
		VideoAdsManager.instance.requestAd(VideoAdsManager.TYPE_OPERATIONS, true);*/
}

protected function sfsConnection_connectionLostHandler(event:SFSEvent):void
{
	sfsConnection.logout();
	dispatchEvent(new LoadingEvent(event.params.reason == "idle" ? LoadingEvent.CONNECTION_TIMEOUT : LoadingEvent.CONNECTION_LOST));
}

private function registerOneSignalPushManager():void
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

/**
 * Firebase Messaging
 * we need to receive a token and send it to server.
 * 
 * If token is null wait for listener to recieve the token.
 */
private function registerFCMPushManager():void
{
	if (AppModel.instance.platform != AppModel.PLATFORM_ANDROID)
		return;
	var messaging:MessagingANE = MessagingANE.messaging;
	var fcmToken:String;
	var pushParams:ISFSObject = new SFSObject();
	
	/* messaging.addEventListener(MessagingEvent.ON_MESSAGE_RECEIVED, onMessageReceived); */
	messaging.addEventListener(MessagingEvent.ON_TOKEN_REFRESHED, onTokenRefreshed);

	fcmToken = messaging.token;
	if (fcmToken != null)
	{
		trace("FCM Token: " + fcmToken);
		pushParams.putText("fcmToken", fcmToken);
		sfsConnection.sendExtensionRequest(SFSCommands.REGISTER_PUSH, pushParams);
	}
	/**
	 * This function is used to receive data from message.
	 * It is not required for showing messages.
	 */
	/* function onMessageReceived(event:MessagingEvent):void
	{
		var remoteMessage:RemoteMessage = event.remoteMessage;
	} */

	function onTokenRefreshed(event:MessagingEvent):void
	{
		fcmToken = event.token;
		trace("FCM Token: " + fcmToken);
		pushParams.putText("fcmToken", fcmToken);
		sfsConnection.sendExtensionRequest(SFSCommands.REGISTER_PUSH, pushParams);
	}
}

protected function get appModel():		AppModel		{	return AppModel.instance;			}

}
}