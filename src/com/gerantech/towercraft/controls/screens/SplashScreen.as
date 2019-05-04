package com.gerantech.towercraft.controls.screens
{
import com.gerantech.towercraft.controls.popups.BanPopup;
import com.gerantech.towercraft.controls.popups.ConfirmPopup;
import com.gerantech.towercraft.controls.popups.MessagePopup;
import com.gerantech.towercraft.controls.popups.UnderMaintenancePopup;
import com.gerantech.towercraft.events.LoadingEvent;
import com.gerantech.towercraft.managers.BillingManager;
import com.gerantech.towercraft.managers.net.LoadingManager;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.models.vo.UserData;
import com.gerantech.towercraft.utils.StrUtils;
import com.gt.SplashMovie;
import com.smartfoxserver.v2.entities.data.SFSObject;
import feathers.events.FeathersEventType;
import flash.desktop.NativeApplication;
import flash.display.Stage;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.net.URLRequest;
import flash.net.navigateToURL;
import flash.utils.getTimer;

public class SplashScreen extends EventDispatcher
{
private var stage:Stage;
private var logo:SplashMovie;
public var transitionInCompleted:Boolean;
public function SplashScreen(stage:Stage)
{
	this.stage = stage;
	this.stage.addEventListener("resize", stage_resizeHandler);
	
	logo = new SplashMovie();
	logo.addEventListener("clear", logo_clearHandler);
	this.stage.addChild(logo);
}
protected function stage_resizeHandler(event:*):void
{
	AppModel.instance.aspectratio = stage.fullScreenWidth / stage.fullScreenHeight;
	logo.graphics.clear();
	logo.graphics.beginFill(0);
	logo.graphics.drawRect(-stage.fullScreenWidth, -stage.fullScreenHeight, stage.fullScreenWidth * 4, stage.fullScreenHeight * 4);
	logo.scaleY = logo.scaleX = stage.fullScreenWidth / 1080;
	//trace(stage.fullScreenWidth, stage.fullScreenHeight, logo.width, logo.height, logo.scaleY, 'sssssssssssssssssss')
	logo.y = (stage.fullScreenHeight - (2160 * logo.scaleY)) * 0.5;
}
protected function logo_clearHandler(event:*):void
{
	transitionInCompleted = true;
	dispatchEvent(new Event(FeathersEventType.TRANSITION_IN_COMPLETE));
	logo.removeEventListener("clear", logo_clearHandler);
	
	if(	AppModel.instance.loadingManager == null )
		AppModel.instance.loadingManager = new LoadingManager();
	AppModel.instance.loadingManager.addEventListener(LoadingEvent.NETWORK_ERROR,		loadingManager_eventsHandler);
	AppModel.instance.loadingManager.addEventListener(LoadingEvent.LOGIN_ERROR, 		loadingManager_eventsHandler);
	AppModel.instance.loadingManager.addEventListener(LoadingEvent.LOGIN_USER_EXISTS, 	loadingManager_eventsHandler);
	AppModel.instance.loadingManager.addEventListener(LoadingEvent.LOGIN_USER_BANNED,   loadingManager_eventsHandler);
	AppModel.instance.loadingManager.addEventListener(LoadingEvent.UNDER_MAINTENANCE, 	loadingManager_eventsHandler);
	AppModel.instance.loadingManager.addEventListener(LoadingEvent.NOTICE_UPDATE,		loadingManager_eventsHandler);
	AppModel.instance.loadingManager.addEventListener(LoadingEvent.FORCE_UPDATE,		loadingManager_eventsHandler);
	AppModel.instance.loadingManager.addEventListener(LoadingEvent.CORE_LOADING_ERROR,	loadingManager_eventsHandler);
	AppModel.instance.loadingManager.addEventListener(LoadingEvent.LOADED,				loadingManager_eventsHandler);
	AppModel.instance.loadingManager.addEventListener(LoadingEvent.CONNECTION_LOST,		loadingManager_eventsHandler);
	AppModel.instance.loadingManager.addEventListener(LoadingEvent.FORCE_RELOAD,		loadingManager_eventsHandler);
	AppModel.instance.loadingManager.load();
}

protected function loadingManager_eventsHandler(event:LoadingEvent):void
{
	AppModel.instance.loadingManager.removeEventListener(LoadingEvent.NETWORK_ERROR,		loadingManager_eventsHandler);
	AppModel.instance.loadingManager.removeEventListener(LoadingEvent.LOGIN_ERROR, 			loadingManager_eventsHandler);
	AppModel.instance.loadingManager.removeEventListener(LoadingEvent.LOGIN_USER_EXISTS, 	loadingManager_eventsHandler);
	AppModel.instance.loadingManager.removeEventListener(LoadingEvent.LOGIN_USER_BANNED,    loadingManager_eventsHandler);
	AppModel.instance.loadingManager.removeEventListener(LoadingEvent.UNDER_MAINTENANCE, 	loadingManager_eventsHandler);
	AppModel.instance.loadingManager.removeEventListener(LoadingEvent.NOTICE_UPDATE,		loadingManager_eventsHandler);
	AppModel.instance.loadingManager.removeEventListener(LoadingEvent.FORCE_UPDATE,			loadingManager_eventsHandler);
	AppModel.instance.loadingManager.removeEventListener(LoadingEvent.CORE_LOADING_ERROR,	loadingManager_eventsHandler);
	AppModel.instance.loadingManager.removeEventListener(LoadingEvent.LOADED,				loadingManager_eventsHandler);

	var confirmData:SFSObject = new SFSObject();
	confirmData.putText("type", event.type);
	
	switch( event.type )
	{
		case LoadingEvent.LOADED:
			trace(AppModel.instance.game.player.id, "loaded", "t[" + (getTimer() - Main.t) + "," + (getTimer() - AppModel.instance.loadingManager.loadStartAt) + "]");
			logo.addEventListener("cancel", logo_cancelHandler);
			logo.play();
			break;
		case LoadingEvent.CONNECTION_LOST:
			var reloadpopup:MessagePopup = new MessagePopup(loc("popup_" + event.type + "_message"), loc("reconnect_button"));
			reloadpopup.data = confirmData;
			reloadpopup.closeOnOverlay = false;
			reloadpopup.addEventListener("select", confirm_eventsHandler);
			AppModel.instance.navigator.addPopup(reloadpopup);
			removeLogo();
			break;
		
		case LoadingEvent.FORCE_RELOAD:
			reload();
			break;
		
		case LoadingEvent.UNDER_MAINTENANCE:
			removeLogo();
			AppModel.instance.navigator.addPopup(new UnderMaintenancePopup(event.data.getInt("umt")));
			break;
		
		case LoadingEvent.LOGIN_USER_BANNED:
			removeLogo();
			AppModel.instance.navigator.addPopup(new BanPopup(event.data.getSFSObject("ban")));
			return;
			
		case LoadingEvent.FORCE_UPDATE:
			var updatepopup:MessagePopup = new MessagePopup(loc("popup_"+event.type+"_message"), loc("popup_update_label"));
			updatepopup.data = confirmData;
			updatepopup.closeOnStage = updatepopup.closeWithKeyboard = updatepopup.closeOnOverlay = false;
			updatepopup.addEventListener("select", confirm_eventsHandler);
			AppModel.instance.navigator.addPopup(updatepopup);
			removeLogo();
			return;
			
		default:
			var message:String = loc("popup_" + event.type + "_message");
			if( event.type == LoadingEvent.LOGIN_ERROR )
			{
				if( event.data == 2 || event.data == 3 || event.data == 6 )
					message = loc("popup_loginError_" + event.data + "_message");
			}
			else if( event.type == LoadingEvent.LOGIN_USER_EXISTS )
			{
				message = loc("popup_reload_authenticated_label", [event.data.getText("name")]);
			}
			
			var acceptLabel:String = "popup_reload_label";
			if( event.type == LoadingEvent.NOTICE_UPDATE )
				acceptLabel = "popup_update_label";
			else if( event.type == LoadingEvent.LOGIN_USER_EXISTS )
				acceptLabel = "popup_accept_label";
			
			if( event.type == LoadingEvent.LOGIN_USER_EXISTS )
				confirmData.putSFSObject("serverData", event.data as SFSObject);
			
			var confirm:ConfirmPopup = new ConfirmPopup(message, loc(acceptLabel));
			confirm.closeOnOverlay = false;
			confirm.data = confirmData;
			confirm.addEventListener("select", confirm_eventsHandler);
			confirm.addEventListener("cancel", confirm_eventsHandler);
			AppModel.instance.navigator.addPopup(confirm);
			removeLogo();
			/*break;
			// complain !!!!! ..............
			trace("LoadingEvent:", event.type, "t["+(getTimer()-Towers.t)+"]");*/
			break;
	}
}

private function confirm_eventsHandler(event:*):void
{
	var confirm:ConfirmPopup = event.currentTarget as ConfirmPopup;
	confirm.closeOnOverlay = false;
	confirm.removeEventListener("select", confirm_eventsHandler);
	confirm.removeEventListener("cancel", confirm_eventsHandler);
	
	var confirmData:SFSObject = confirm.data as SFSObject;
	if( event.type == "select" )
	{
		switch( confirmData.getText("type") )
		{
			case LoadingEvent.FORCE_UPDATE:
				navigateToURL(new URLRequest(BillingManager.instance.getDownloadURL()));
				NativeApplication.nativeApplication.exit();
				return;
			
			case LoadingEvent.NOTICE_UPDATE:
				navigateToURL(new URLRequest(BillingManager.instance.getDownloadURL()));
			case LoadingEvent.CORE_LOADING_ERROR:
				AppModel.instance.loadingManager.addEventListener(LoadingEvent.LOADED,				loadingManager_eventsHandler);
				AppModel.instance.loadingManager.addEventListener(LoadingEvent.CORE_LOADING_ERROR,	loadingManager_eventsHandler);
				AppModel.instance.loadingManager.loadCore();
				break;
			
			case LoadingEvent.LOGIN_USER_EXISTS:
				UserData.instance.id = confirmData.getSFSObject("serverData").getLong("id");
				UserData.instance.password = confirmData.getSFSObject("serverData").getText("password");
				UserData.instance.save();
				reload();
				break;
			
			default:
				reload();
		}
		return;
	}
	
	switch( confirmData.getText("type") )
	{
		case LoadingEvent.NOTICE_UPDATE:
			AppModel.instance.loadingManager.addEventListener(LoadingEvent.LOADED,				loadingManager_eventsHandler);
			AppModel.instance.loadingManager.addEventListener(LoadingEvent.CORE_LOADING_ERROR,	loadingManager_eventsHandler);
			AppModel.instance.loadingManager.loadCore();
			return;
			
		case LoadingEvent.LOGIN_USER_EXISTS:
			UserData.instance.id = -2;
			UserData.instance.save();
			reload();
			return;
	}
	NativeApplication.nativeApplication.exit();
}

private function reload():void
{
	AppModel.instance.loadingManager.removeEventListener(LoadingEvent.CONNECTION_LOST,	loadingManager_eventsHandler);
	AppModel.instance.loadingManager.removeEventListener(LoadingEvent.FORCE_RELOAD,		loadingManager_eventsHandler);

	this.stage.addChild(logo);
	logo.gotoAndPlay(1);
	logo.addEventListener("clear", logo_clearHandler);
	logo.removeEventListener("cancel", logo_cancelHandler);
}
protected function logo_cancelHandler(event:*):void
{
	removeLogo();
}
private function removeLogo():void 
{
	logo.removeEventListener("cancel", logo_cancelHandler);
	if( logo.parent == stage )
		stage.removeChild(logo);

}

protected function loc(resourceName:String, parameters:Array=null, locale:String=null):String
{
	return StrUtils.loc(resourceName, parameters);
}
}
}