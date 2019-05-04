package com.gerantech.towercraft.managers
{
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.managers.oauth.OAuthManager;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.utils.Localizations;
import com.gt.towers.constants.PrefsTypes;
import com.marpies.ane.gameanalytics.GameAnalytics;
import com.smartfoxserver.v2.entities.data.SFSObject;
import starling.events.Event;
import starling.events.EventDispatcher;

public class UserPrefs extends EventDispatcher 
{
public function UserPrefs(){}
public function init() : void
{
	// tutorial first step
    setInt(PrefsTypes.TUTOR, PrefsTypes.T_000_FIRST_RUN);
	authenticateSocial();
	
	// select language with market index
	var loc:String = AppModel.instance.game.player.prefs.exists(PrefsTypes.SETTINGS_4_LOCALE) ? AppModel.instance.game.player.prefs.get(PrefsTypes.SETTINGS_4_LOCALE) : "0";
	if( loc == "0" )
		loc = Localizations.instance.getLocaleByMarket(AppModel.instance.descriptor.market);
	changeLocale(loc, true);
}

public function changeLocale(locale:String, forced:Boolean=false) : void
{
	var prev:String = AppModel.instance.game.player.prefs.get(PrefsTypes.SETTINGS_4_LOCALE);
	if( !forced && prev == locale )
	{
		dispatchEventWith(Event.FATAL_ERROR);
		return;
	}
	
	Localizations.instance.addEventListener(Event.CHANGE, localizations_changeHandler);
	Localizations.instance.changeLocale(locale, AppModel.instance.assets);
}

protected function localizations_changeHandler(event:Event) : void 
{
	Localizations.instance.removeEventListener(Event.CHANGE, localizations_changeHandler);
	
	var locale:String = event.data as String;
	setString(PrefsTypes.SETTINGS_4_LOCALE, locale);
	AppModel.instance.direction = Localizations.instance.getDir(locale);
	AppModel.instance.isLTR = AppModel.instance.direction == "ltr";
	AppModel.instance.align = AppModel.instance.isLTR ? "left" : "right";

	dispatchEventWith(Event.COMPLETE, false, locale);
}

public function setBool(key:int, value:Boolean):void
{
	setString(key, value.toString());
}
public function setInt(key:int, value:int):void
{
    // prevent backward tutor steps
    if( key == PrefsTypes.TUTOR )
        if( AppModel.instance.game.player.getTutorStep() >= value )
            return;
    
	setString(key, value.toString());
    if( key == PrefsTypes.TUTOR )
		GameAnalytics.addDesignEvent("tutorial:step-" + value);

}
public function setFloat(key:int, value:Number):void
{
	setString(key, value.toString());
}
public function setString(key:int, value:String):void
{
	AppModel.instance.game.player.prefs.set(key, value);
	var params:SFSObject = new SFSObject();
	params.putInt("k", key);
	params.putText("v", value);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.PREFS, params);
}


/************************   AUTHENTICATE SOCIAL OR GAME SERVICES   ***************************/
public function authenticateSocial():void
{
    //NativeAbilities.instance.showToast(SocialManager.instance.initialized + " == " + SocialManager.instance.authenticated + " == " + player.prefs.getAsBool(PrefsTypes.AUTH_41_GOOGLE), 2);
    if( OAuthManager.instance.authenticated )
    {
        /*socials.user = new SocialUser();
        socials.user.id = "g01079473321487998344";
        socials.user.name = "ManJav";
        socials.user.imageURL = "content://com.google.android.gms.games.background/images/751cd60e/7927";
        sendSocialData();*/
        return;
    }
    
    //state = STATE_SOCIAL_SIGNIN;            
    OAuthManager.instance.addEventListener(OAuthManager.AUTHENTICATE, socialManager_eventsHandler);
    OAuthManager.instance.addEventListener(OAuthManager.FAILURE, socialManager_eventsHandler);
    OAuthManager.instance.init( PrefsTypes.AUTH_41_GOOGLE , true);
}
protected function socialManager_eventsHandler(event:Event):void
{
    OAuthManager.instance.removeEventListener(OAuthManager.AUTHENTICATE, socialManager_eventsHandler);
    OAuthManager.instance.removeEventListener(OAuthManager.FAILURE, socialManager_eventsHandler);
    //sendSocialData();
}
}
}