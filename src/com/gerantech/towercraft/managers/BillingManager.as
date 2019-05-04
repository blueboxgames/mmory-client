package com.gerantech.towercraft.managers
{
import com.gerantech.extensions.NativeAbilities;
import com.gerantech.extensions.iab.Iab;
import com.gerantech.extensions.iab.Purchase;
import com.gerantech.extensions.iab.events.IabEvent;
import com.gerantech.towercraft.controls.popups.MessagePopup;
import com.gerantech.towercraft.events.LoadingEvent;
import com.gerantech.towercraft.managers.net.LoadingManager;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gt.towers.constants.ExchangeType;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.data.SFSObject;
import feathers.events.FeathersEventType;
import flash.net.URLRequest;
import flash.net.navigateToURL;

public class BillingManager extends BaseManager
{
private var items:Array;
private static var _instance:BillingManager;
public static function get instance():BillingManager
{
	if( _instance == null )
		_instance = new BillingManager();
	return (_instance);
}

public function BillingManager(){}
protected function loadingManager_loadedHandler(event:LoadingEvent):void
{
	appModel.loadingManager.removeEventListener(LoadingEvent.LOADED, loadingManager_loadedHandler);
	init();
}		
public function init():void
{
	if( appModel.loadingManager.state < LoadingManager.STATE_LOADED )
	{
		appModel.loadingManager.addEventListener(LoadingEvent.LOADED, loadingManager_loadedHandler);
		return;
	}
	
	// provide all sku items
	items = new Array("k2k.item_0");
	var keys:Vector.<int> = exchanger.items.keys();
	for each(var k:int in keys)
		if( ExchangeType.getCategory(k) == ExchangeType.C0_HARD )
			items.push("k2k.item_" + k);
		else if( ExchangeType.getCategory(k) == ExchangeType.C30_BUNDLES )
			items.push("k2k.bundle_" + k);

	var base64Key:String, bindURL:String, packageURL:String;
	switch( appModel.descriptor.market )
	{
		case "google":
			base64Key = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA1FccxhKFO5uuTqOy+KG/q3dddZ69FQ9a/XIrJ6rGjrAf8lG4wBzbgropt6T2+NEQOsN8lsqpvLEp/JprowBS8ANsM9E3D6nGGnsT649kceEKktImiilbEMfqmFjXqgGMbdfGV9VFuk40Vi/yPoHAV3SWP0P7XjtXFyi1rX8xV9IaUMvO+bOjLH4fuNJWhQbH7IxATA3OgCaBnGJ2FhjR0puv3401mlpkCpYxTeKYZ2TWE204QxalkTdY1BL+bFoxn8K9dCo8eNBmWDqizA3TDXHRvVCEOSURqoxB11q2LbL66bTgmwj6y46xEukLkeOFdCHLUS5EHMQYkyjk4RdBXwIDAQAB";
			bindURL = "com.android.vending.billing.InAppBillingService.BIND";
			packageURL = "com.android.vending";
			break;
		
		case "myket":
			base64Key = "";
			bindURL = "ir.mservices.market.InAppBillingService.BIND";
			packageURL = "ir.mservices.market";
			break;
		
		case "cando":
			base64Key = "";
			bindURL = "com.ada.market.service.payment.BIND";
			packageURL = "com.ada.market";
			break;
		
		case "ario":
			base64Key = "";
			bindURL = "com.arioclub.android.sdk.iab.InAppBillingService.BIND";
			packageURL = "com.arioclub.android";
			break;
		
		default://cafebazaar
			base64Key = "MIHNMA0GCSqGSIb3DQEBAQUAA4G7ADCBtwKBrwCoKU7EhXq5BhXRVJPe1JvmuPyJhHpsg6Ei9XM6dF0T1a4B4Czca8awJAzaSgx8/NEVYX8pBoP36/GqZ6XRi7yBORtoMHnVzL6qbGtPrGvLww1RwlPRnwVqkIxWhCFqa1U4J/WnskeL/K7SBjHoJlIoc2Mb1xeOWOZZQM1bU10LpkblO6lzSdMnTw9Jgs+UptXC6lLy/+sdfwcUjBfgBfJplPxS2Gtvk5yHkCacfkUCAwEAAQ==";
			bindURL = "ir.cafebazaar.pardakht.InAppBillingService.BIND";
			packageURL = "com.farsitel.bazaar";
			break;
	}			

	Iab.instance.addEventListener(IabEvent.SETUP_FINISHED, iab_setupFinishedHandler);
	Iab.instance.startSetup(base64Key, bindURL, packageURL);
}
protected function iab_setupFinishedHandler(event:IabEvent):void
{
	log("setup: " + event.result.response);
	Iab.instance.removeEventListener(IabEvent.SETUP_FINISHED, iab_setupFinishedHandler);
	dispatchEventWith(FeathersEventType.INITIALIZE);
	if( event.result.succeed )
		queryInventory();
}

// -_-_-_-_-_-_-_-_-_-_-_-_-_-_- QUERY INVENTORY -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
/**Getting purchased product details, _iap should be initialized first</br>
 * if put items args getting purchased and not purchased product details
 */
public function queryInventory():void
{
	Iab.instance.addEventListener(IabEvent.QUERY_INVENTORY_FINISHED, iab_queryInventoryFinishedHandler);
	Iab.instance.queryInventory(); //restoring purchased in-app items and subscriptions
}

protected function iab_queryInventoryFinishedHandler(event:IabEvent):void
{
	log("queryInventory: " + event.result.response);
	if( !event.result.succeed )
	{
		dispatchEventWith(FeathersEventType.END_INTERACTION, false, event.result);
		return;
	}
	Iab.instance.removeEventListener(IabEvent.QUERY_INVENTORY_FINISHED, iab_queryInventoryFinishedHandler);
	
	// verify and consume all remaining items
	for each( var k:String in items )
	{
		var purchase:Purchase = Iab.instance.getPurchase(k);
		if( purchase == null || purchase.itemType == Iab.ITEM_TYPE_SUBS )
			continue;
		verify(purchase);
	}
}

// -_-_-_-_-_-_-_-_-_-_-_-_-_-_- PURCHASE -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
public function purchase(sku:String):void
{
	Iab.instance.addEventListener(IabEvent.PURCHASE_FINISHED, iab_purchaseFinishedHandler);
	Iab.instance.purchase(sku);
}

protected function iab_purchaseFinishedHandler(event:IabEvent):void
{
	log("purchase: " + event.result.response);
	Iab.instance.removeEventListener(IabEvent.PURCHASE_FINISHED, iab_purchaseFinishedHandler);
	if( !event.result.succeed )
	{
		explain(event.result.response);
		dispatchEventWith(FeathersEventType.END_INTERACTION, false, event.result);
		return;
	}
	var purchase:Purchase = Iab.instance.getPurchase(event.result.purchase.sku);
	if( purchase != null )
		verify(purchase);
	else
		queryInventory();
}

// -_-_-_-_-_-_-_-_-_-_-_-_-_-_- PURCHASE VERIFICATION AND CONSUMPTION -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
private function verify(purchase:Purchase):void
{
	appModel.navigator.addLog(loc("waiting_message"));
	var param:SFSObject = new SFSObject();
	param.putText("productID", purchase.sku);
	param.putText("purchaseToken", purchase.token);
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_purchaseVerifyHandler);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.VERIFY_PURCHASE, param);
	function sfsConnection_purchaseVerifyHandler(event:SFSEvent):void
	{
		if( event.params.cmd != SFSCommands.VERIFY_PURCHASE )
			return;
		SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_purchaseVerifyHandler);
		var result:SFSObject = event.params.params;
		if( result.getBool("success") )
		{
			if( appModel.descriptor.market == "cafebazaar" || appModel.descriptor.market == "ario" )
			{
				if(  result.getInt("consumptionState") == 1 )
					consume(purchase.sku);
			}
			else
			{
				if(  result.getInt("consumptionState") == 0 )
					consume(purchase.sku);
			}
		}
		else
		{
			log("purchase verify=>invalid: " + purchase.sku);
			explain(Iab.IABHELPER_VERIFICATION_FAILED);
		}
	}	
}

// -_-_-_-_-_-_-_-_-_-_-_-_-_-_- CONSUMING PURCHASED ITEM -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
public function consume(sku:String):void
{
	Iab.instance.addEventListener(IabEvent.CONSUME_FINISHED, iab_consumeFinishedHandler);
	Iab.instance.consume(sku);
}
protected function iab_consumeFinishedHandler(event:IabEvent):void
{			
	log("queryInventory: " + event.result.response);
	Iab.instance.removeEventListener(IabEvent.CONSUME_FINISHED, iab_consumeFinishedHandler);
	if( !event.result.succeed )
	{
		explain(Iab.IABHELPER_INVALID_CONSUMPTION);
		dispatchEventWith(FeathersEventType.END_INTERACTION, false, event.result);
		return;
	}
	
	/*var priceList:Array = skuDetails._price.split(" ");
	var price:String = priceList[0];
	var currency:String = priceList[1];
	price = price.split('٬').join('');
	if( currency == "ریال" )
		currency = "IRR";;
	price = StrUtils.getLatinNumber(price);
	trace(int(price), currency)
	GameAnalytics.addBusinessEvent("USD", 1000, "item", "id", "cart", "[receipt]", "[signature]");*/
	
	var params:SFSObject = new SFSObject();
	params.putText("productID", event.result.purchase.sku);
	params.putText("purchaseToken", event.result.purchase.token);
	params.putBool("consume", true);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.VERIFY_PURCHASE, params);
	
	dispatchEventWith(FeathersEventType.END_INTERACTION, false, event.result);
}

private function explain( response:int ) : void
{
	var res : int = Iab.IABHELPER_UNKNOWN_ERROR;
	switch( response )
	{
		case Iab.IABHELPER_NOT_SUPPORTED :
		case Iab.IABHELPER_USER_CANCELLED :
		case Iab.IABHELPER_NOT_INITIALIZED :
		case Iab.IABHELPER_VERIFICATION_FAILED :
		case Iab.IABHELPER_INVALID_CONSUMPTION :
			res = response;
			break;
	}
	appModel.navigator.addPopup(new MessagePopup(loc("popup_purchase_" + res, [appModel.descriptor.market])));
}

// -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_- RATING -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
public function rate():void
{
	switch(appModel.descriptor.market )
	{
		case "google":
			navigateToURL(new URLRequest("https://play.google.com/store/apps/details?id=air." + appModel.descriptor.id));
			break;
		
		case "cafebazaar":
			NativeAbilities.instance.runIntent("android.intent.action.EDIT", "bazaar://details?id=air." + appModel.descriptor.id);
			break;
		
		case "myket":
			navigateToURL(new URLRequest("http://myket.ir/App/air." + appModel.descriptor.id));
			break;
		
		case "cando":
			navigateToURL(new URLRequest("cando://leave-review?id=air." + appModel.descriptor.id));
			break;
	}			
}

// -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_- GET DOWNLOAD URL -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
public function getDownloadURL():String
{
	switch(appModel.descriptor.market )
	{
		case "google":		return 'https://play.google.com/store/apps/details?id=air.' + appModel.descriptor.id;			
		case "cafebazaar":	return 'https://cafebazaar.ir/app/air.' + appModel.descriptor.id;			
		case "myket":		return 'http://myket.ir/App/air.' + appModel.descriptor.id;
		case "cando":		return 'cando://details?id=air.' + appModel.descriptor.id;			
	}
	return "http://towers.grantech.ir/get/towerstory.apk";
}

// -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_- SHARING -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
public function share():void
{
	NativeAbilities.instance.shareText(loc("app_title"), loc("app_brief") + "\n" + getDownloadURL());
}
private function log(message:String):void 
{
	//NativeAbilities.instance.showToast("iab_" + message, 2);
}
}
}