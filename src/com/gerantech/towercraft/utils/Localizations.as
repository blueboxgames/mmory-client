package com.gerantech.towercraft.utils
{
import flash.filesystem.File;
import flash.system.Capabilities;
import starling.events.Event;
import starling.events.EventDispatcher;
import starling.utils.AssetManager;

/**
 * ...
 * @author Mansour Djawadi
 */

[Event(name="change", type="starling.events.Event")]
public class Localizations extends EventDispatcher
{
    static private var _instance:Localizations;
    public var locale:String;
    public var localeDictionary:Object;
    public var assetManager:AssetManager;
    static public function get instance() : Localizations
    {
        if( _instance == null )
            _instance = new Localizations();
        return _instance;
    }

    public function changeLocale(locale:String = "en_US", assetManager:AssetManager = null) : void
    {
        if( assetManager != null )
            this.assetManager = assetManager;
        this.locale = locale;
		
        this.assetManager.enqueue(File.applicationDirectory.resolvePath("locale/" + locale + ".json"));
        this.assetManager.loadQueue(assetManager_localeCallback);
    }

    protected function assetManager_localeCallback(ratio:Number) : void 
    {
        if( ratio < 1 )
            return;
        localeDictionary = this.assetManager.getObject(locale);
        dispatchEventWith(Event.CHANGE, false, locale);
    }

    public function get(key:String, parameters:Array = null) : String
    {
        var loc:String = localeDictionary[key];
        if( loc == null )
            return key;
        if( parameters != null && parameters.length > 0 )
        {
            var slices:Array = loc.split("#");
            if( slices.length <= parameters.length )
                return loc;
            
            var ret:String = "";
            for( var i:int = 0; i < parameters.length; i++ )
                ret += slices[i] + parameters[i];
            if( slices[i] != "" )
                ret += slices[i];
            return ret;
        }
        
        return loc;
    }
	
	public function getLocaleByMarket(market:String = null) : String
	{
		switch( market )
		{
			case "google":
			case "appstore":
				return getLocal("en");
		}
		return getLocal("fa");
	}

	public function getLocalesByMarket(market:String = null) : Array
	{
		switch( market )
		{
			case "google":
			case "appstore":
				return ["en_US"];
		}
		return ["fa_IR", "en_US"];
	}

	public function getLocal(local:String = null) : String
	{
		var ret:String = "en_US";
		//if( local == null )
		//	local = Capabilities.languages[0].split("-")[0];
		
		switch( local )
		{
			//case "ar":	return "ar_SA";
			case "en":	return "en_US";
			//case "es":	return "es_ES";
			case "fa":	return "fa_IR";
			//case "fr":	return "fr_FR";
			//case "id":	return "id_ID";
			//case "ru":	return "ru_RU";
			//case "tr":	return "tr_TR";
			//case "ur":	return "ur_PK";
		}
		return ret;
	}

	public function getDir(local:String = null) : String
	{		
		if( local == null )
			local = Capabilities.languages[0].split("-")[0];
		
		switch( local )
		{
			case "ar":
			case "ar_SA":
			case "fa":
			case "fa_IR":
			case "ur":
			case "ur_PK":
				return "rtl";
		}
		return "ltr";
	}

}
}