package com.gerantech.towercraft.managers 
{
import com.gameanalytics.sdk.GameAnalytics;
import com.gerantech.mmory.core.constants.ExchangeType;
import com.gerantech.mmory.core.constants.MessageTypes;
import com.gerantech.mmory.core.constants.PrefsTypes;
import com.gerantech.mmory.core.constants.ResourceType;
import com.gerantech.mmory.core.exchanges.ExchangeItem;
import com.gerantech.mmory.core.exchanges.Exchanger;
import com.gerantech.mmory.core.utils.maps.IntIntMap;
import com.gerantech.towercraft.Game;
import com.gerantech.towercraft.controls.overlays.EarnOverlay;
import com.gerantech.towercraft.controls.overlays.FortuneOverlay;
import com.gerantech.towercraft.controls.overlays.OpenBookOverlay;
import com.gerantech.towercraft.controls.popups.AdConfirmPopup;
import com.gerantech.towercraft.controls.popups.BookDetailsPopup;
import com.gerantech.towercraft.controls.popups.ConfirmPopup;
import com.gerantech.towercraft.controls.popups.EmoteDetailsPopup;
import com.gerantech.towercraft.controls.popups.SimpleHeaderPopup;
import com.gerantech.towercraft.controls.screens.DashboardScreen;
import com.gerantech.towercraft.controls.segments.ExchangeSegment;
import com.gerantech.towercraft.events.GameEvent;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.vo.UserData;
import com.gerantech.towercraft.models.vo.VideoAd;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.data.SFSObject;

import feathers.events.FeathersEventType;

import starling.events.Event;
/**
* @author Mansour Djawadi
*/
public class ExchangeManager extends BaseManager
{
private static var _instance:ExchangeManager;
private var earnOverlay:EarnOverlay;
public static function get instance() : ExchangeManager
{
	if( _instance == null )
		_instance = new ExchangeManager();
	return (_instance);
}
public function ExchangeManager() {	super(); }
public function process(item : ExchangeItem) : void 
{
	if( player.get_battleswins() < 1 )
	{
		dispatchCustomEvent(FeathersEventType.ERROR, item);
		return;// disalble all items in tutorial
	}

	var params:SFSObject = new SFSObject();
	params.putInt("type", item.type);

	//     _-_-_-_-_-_- all books -_-_-_-_-_-_
	if( item.isBook() )
	{
		item.enabled = true;
		var _state:int = item.getState(timeManager.now);
		if( item.category == ExchangeType.C110_BATTLES && _state == ExchangeItem.CHEST_STATE_EMPTY )
			return;
		
		if( ( item.category == ExchangeType.C100_FREES || item.category == ExchangeType.C110_BATTLES ) && _state == ExchangeItem.CHEST_STATE_READY  )
		{
			item.outcomes = new IntIntMap();
			exchange(item, params);
			return;
		}
		else if( item.category == ExchangeType.C100_FREES && _state != ExchangeItem.CHEST_STATE_READY )
		{
			if( item.type == ExchangeType.C104_STARS )
			{
				if( _state == ExchangeItem.CHEST_STATE_BUSY )
					appModel.navigator.addLog(loc("popup_chest_message_110", [""]));
				else
					appModel.navigator.addLog(loc("exchange_hint_104", [10]));
				return;
			}
		}

		var detailsPopup:SimpleHeaderPopup = new BookDetailsPopup(item);
		detailsPopup.addEventListener(Event.SELECT, detailsPopup_selectHandler);
		appModel.navigator.addPopup(detailsPopup);
		return;
	}
	
	//     _-_-_-_-_-_- all emotes -_-_-_-_-_-_
	if( item.isEmote() )
	{
		item.enabled = true;
		detailsPopup = new EmoteDetailsPopup(item);
		detailsPopup.addEventListener(Event.SELECT, detailsPopup_selectHandler);
		appModel.navigator.addPopup(detailsPopup);
		return;
	}

	function detailsPopup_selectHandler(event:Event):void
	{
		detailsPopup.removeEventListener(Event.SELECT, detailsPopup_selectHandler);
		if( item.isBook() )
		{
			_state = item.getState(timeManager.now);
			if( _state == ExchangeItem.CHEST_STATE_WAIT )
			{
				if( exchanger.isBattleBookReady(item.type, timeManager.now) == MessageTypes.RESPONSE_ALREADY_SENT )
					params.putInt("hards", Exchanger.timeToHard(ExchangeType.getCooldown(item.outcome)));
				else
					detailsPopup.addEventListener(Event.SELECT, detailsPopup_selectHandler);
			}
		}
		exchange(item, params);
	}

	var reqs:Vector.<int> = item.requirements.keys();
	if( reqs == null || reqs.length == 0 )
	{
		exchange(item, params);
		return;
	}

	//     _-_-_-_-_-_- special offers -_-_-_-_-_-_
	if( item.category == ExchangeType.C20_SPECIALS )
	{
		if( item.numExchanges > 0 )
			return;
		if( !player.has(item.requirements) )
		{
			appModel.navigator.addLog(loc("log_not_enough", [loc("resource_title_" + reqs[0])]));
			dispatchCustomEvent(FeathersEventType.ERROR, item);
			return;
		}
		exchange(item, params);
		return;
	}

	//     _-_-_-_-_-_- purchase automation -_-_-_-_-_-_
	if( reqs[0] == ResourceType.R5_CURRENCY_REAL )
	{
		BillingManager.instance.addEventListener(FeathersEventType.END_INTERACTION, billinManager_endInteractionHandler);
		BillingManager.instance.purchase((item.category == ExchangeType.C30_BUNDLES ? "k2k.bundle_" : "k2k.item_") + item.type);
		function billinManager_endInteractionHandler ( event:Event ) : void {
			BillingManager.instance.removeEventListener(FeathersEventType.END_INTERACTION, billinManager_endInteractionHandler);
			var result:Object = event.data;
			if( event.data.succeed )
			{
				exchange(item, params);
				if( item.category == ExchangeType.C0_HARD )
				{
					sendAnalyticsEvent(item);
					dispatchCustomEvent(FeathersEventType.END_INTERACTION, item);
				}
				return;
			}
			
			dispatchCustomEvent(FeathersEventType.ERROR , item);
			return;
		}
		return;
	}
	
	//     _-_-_-_-_-_- other gem consumption -_-_-_-_-_-_
	if( reqs[0] == ResourceType.R4_CURRENCY_HARD )
	{
		if( !player.has(item.requirements) )
		{
			appModel.navigator.addLog(loc("log_not_enough", [loc("resource_title_" + ResourceType.R4_CURRENCY_HARD)]));
			dispatchCustomEvent(FeathersEventType.ERROR, item);
			return;
		}
		var confirm1:ConfirmPopup = new ConfirmPopup(loc("popup_sure_label"));
		//confirm1.acceptStyle = "danger";
		confirm1.addEventListener(Event.SELECT, confirm1_selectHandler);
		confirm1.addEventListener(Event.CLOSE, confirm1_closeHandler);
		appModel.navigator.addPopup(confirm1);
		function confirm1_selectHandler ( event:Event ):void {
			confirm1.removeEventListener(Event.SELECT, confirm1_selectHandler);
			confirm1.removeEventListener(Event.CLOSE, confirm1_closeHandler);
			exchange(item, params);
		}
		function confirm1_closeHandler ( event:Event ):void {
			confirm1.removeEventListener(Event.SELECT, confirm1_selectHandler);
			confirm1.removeEventListener(Event.CLOSE, confirm1_closeHandler);
			dispatchCustomEvent(FeathersEventType.ERROR, item);
		}
		return;
	}
	
	exchange(item, params);
}

private function exchange( item:ExchangeItem, params:SFSObject ) : int
{
	if( item.category == ExchangeType.C100_FREES )
		exchanger.findRandomOutcome(item, timeManager.now);
	var bookType:int = -1;
	if( item.category == ExchangeType.C30_BUNDLES )
		bookType = item.containBook(); // reterive a book from bundle. if not found show golden book
	else
		bookType = item.category == ExchangeType.BOOKS_50 ? item.type : item.outcome; // reserved because outcome changed after exchange

	var response:int = exchanger.exchange(item, timeManager.now, params.containsKey("hards") ? params.getInt("hards") : 0);
	if( response == MessageTypes.RESPONSE_SUCCEED )
	{
		if( ( item.isBook() && ( item.getState(timeManager.now) != ExchangeItem.CHEST_STATE_BUSY || item.category == ExchangeType.C100_FREES ) ) || ( item.category == ExchangeType.C30_BUNDLES && ExchangeType.getCategory(bookType) == ExchangeType.BOOKS_50 ) )
		{
			if( item.category == ExchangeType.C110_BATTLES )
				UserData.instance.prefs.setInt(PrefsTypes.TUTOR, PrefsTypes.T_013_BOOK_OPENED);
			
			earnOverlay = EarnOverlay(item.category == ExchangeType.C100_FREES ? new FortuneOverlay(bookType) : new OpenBookOverlay(bookType));
			appModel.navigator.addOverlay(earnOverlay);
		}
	}
	else if( response == MessageTypes.RESPONSE_NOT_ENOUGH_REQS )
	{
		appModel.navigator.addLog(loc("log_not_enough", [loc("resource_title_" + item.requirements.keys()[0])]));
		ExchangeSegment.SELECTED_CATEGORY = 3;
		if( appModel.navigator.activeScreenID == Game.DASHBOARD_SCREEN )
		{
			DashboardScreen(appModel.navigator.activeScreen).gotoPage(0);
		}
		else
		{
			DashboardScreen.TAB_INDEX = 0;
			appModel.navigator.popScreen();
		}
	}
	
	if( !item.requirements.exists(ResourceType.R5_CURRENCY_REAL) )
	{
		dispatchCustomEvent(FeathersEventType.BEGIN_INTERACTION, item);
		SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_extensionResponseHandler);
		SFSConnection.instance.sendExtensionRequest(SFSCommands.EXCHANGE, params);
	}
	return response;
}

protected function sfsConnection_extensionResponseHandler(event:SFSEvent):void
{
	if( event.params.cmd != SFSCommands.EXCHANGE )
		return;
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_extensionResponseHandler);
	var data:SFSObject = event.params.params;
	var item:ExchangeItem = exchanger.items.get(data.getInt("type"));
	if( data.getInt("response") != MessageTypes.RESPONSE_SUCCEED )
	{
		dispatchCustomEvent(FeathersEventType.ERROR, item);
		return;
	}
	
	if( item.isBook() || item.containBook() > -1 )
	{
		if( !data.containsKey("rewards") )
		{
			dispatchCustomEvent(FeathersEventType.END_INTERACTION, item);
			return;
		}
		
		var outcomes:IntIntMap = EarnOverlay.getOutcomse(data.getSFSArray("rewards"))		
		player.addResources(outcomes);
		earnOverlay.outcomes = outcomes;
		earnOverlay.addEventListener(Event.CLOSE, openChestOverlay_closeHandler);
		function openChestOverlay_closeHandler(event:Event):void {
			earnOverlay.removeEventListener(Event.CLOSE, openChestOverlay_closeHandler);
			if( item.category != ExchangeType.C43_ADS )
				showAd();
			earnOverlay = null;
			gotoDeckTutorial();
		}
	}
	dispatchCustomEvent(FeathersEventType.END_INTERACTION, item);
}

private function gotoDeckTutorial():void
{
	if( !player.inSlotTutorial() )
		return;
	/*
	var tutorialData:TutorialData = new TutorialData("open_book_end");
	tutorialData.addTask(new TutorialTask(TutorialTask.TYPE_MESSAGE, "tutor_cards_2", null, 500, 1500, 4));
	tutorials.show(tutorialData);*/
	UserData.instance.prefs.setInt(PrefsTypes.TUTOR, PrefsTypes.T_015_DECK_FOCUS);
	tutorials.dispatchEventWith(GameEvent.TUTORIAL_TASKS_FINISH, false, {name:"open_book_end"});
}

private function showAd():void
{
	return;
	if( player.inTutorial() || player.prefs.getAsBool(PrefsTypes.SETTINGS_5_REMOVE_ADS) || !VideoAdsManager.instance.getAdByType(VideoAdsManager.TYPE_CHESTS).available )
		return;
	
	var adConfirmPopup:AdConfirmPopup = new AdConfirmPopup();
	adConfirmPopup.addEventListener(Event.SELECT, adConfirmPopup_selectHandler);
	appModel.navigator.addPopup(adConfirmPopup);
	function adConfirmPopup_selectHandler(event:Event):void {
		adConfirmPopup.removeEventListener(Event.SELECT, adConfirmPopup_selectHandler);
		VideoAdsManager.instance.showAd(VideoAdsManager.TYPE_CHESTS);
		VideoAdsManager.instance.addEventListener(Event.COMPLETE, videoIdsManager_completeHandler);
	}
}
private function videoIdsManager_completeHandler(event:Event):void
{
	VideoAdsManager.instance.removeEventListener(Event.COMPLETE, videoIdsManager_completeHandler);
	VideoAdsManager.instance.requestAd(VideoAdsManager.TYPE_CHESTS, true);
	var ad:VideoAd = event.data as VideoAd;
	if( !ad.rewarded )
		return;
	
	var params:SFSObject = new SFSObject();
	params.putInt("type", ExchangeType.C43_ADS );
	exchange(exchanger.items.get(ExchangeType.C43_ADS), params);
}
private function dispatchCustomEvent( type:String, item:ExchangeItem ) : void 
{
	item.enabled = true;
	dispatchEventWith(type, false, item);
}

public function sendAnalyticsEvent( item:ExchangeItem ) : void
{
	// send analytics events
	var outs:Vector.<int> = item.outcomes.keys();
	var itemID:String = (item.category == ExchangeType.C30_BUNDLES ? "k2k.bundle_" : "k2k.item_") + item.type;
	if( GameAnalytics.isInitialized )
	{
		// GameAnalytics.addResourceEvent(GAResourceFlowType.SOURCE, ResourceType.getName(outs[0]), item.outcomes.get(outs[0]), "IAP", itemID);
		var currency:String = appModel.descriptor.marketIndex <= 1 ? "USD" : "IRR";
		var amount:int = item.requirements.get(outs[0]) * (appModel.descriptor.market == "google" ? 1 : 10);
		GameAnalytics.addBusinessEvent(currency, amount, ResourceType.getName(outs[0]), itemID , "IAP");
		// Might need this:
		// GameAnalytics.addBusinessEvent(currency, amount, item.type.toString(), result.purchase.sku, outs[0].toString(), result.purchase != null?result.purchase.json:null, result.purchase != null?result.purchase.signature:null);  
	}
}
}
}