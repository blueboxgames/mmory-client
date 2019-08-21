package com.gerantech.towercraft.managers
{
	import com.chartboost.plugin.air.Chartboost;
	import com.chartboost.plugin.air.ChartboostEvent;
	import com.chartboost.plugin.air.model.CBLocation;
	import com.gerantech.towercraft.models.AppModel;
	import com.gerantech.towercraft.models.vo.VideoAd;

	import flash.utils.Dictionary;

	import ir.tapsell.sdk.air.Tapsell;
	import ir.tapsell.sdk.air.TapsellAdRequestListener;
	import ir.tapsell.sdk.air.TapsellAdShowFinishedListener;

	import starling.events.Event;
	import starling.events.EventDispatcher;

	public class VideoAdsManager extends EventDispatcher implements TapsellAdRequestListener, TapsellAdShowFinishedListener
	{
		public static const TYPE_OPERATIONS:int = 0;
		public static const TYPE_CHESTS:int = 1;

		public static const AD_PROVIDER_TAPSELL:int = 0;
		public static const AD_PROVIDER_CHARTBOOST:int = 1;
		
		private var _hasAd:Boolean;
		private var adIds:Dictionary;
		private var tapsell:Tapsell;
		private var chartboost:Chartboost;
		private static var _instance:VideoAdsManager;
		
		public static function get instance():VideoAdsManager
		{
			if( _instance == null )
				_instance = new VideoAdsManager();
			return _instance;
		}

		private var _adProvider:int;
		
		public function get adProvider():int
		{
			return _adProvider;
		}
		
		public function set adProvider(value:int):void
		{
			_adProvider = value;
		}

		public function get hasAd():Boolean
		{
			return this._hasAd;
		}
		
		public function VideoAdsManager()
		{
			/**
			 * ---------------------------------------------------------------
			 * Initialize Tapsell.
			 * ---------------------------------------------------------------
			 */
			tapsell = Tapsell.getInstance()
			tapsell.initialize("iafbrgahcrlntbpstnondthtsofkpibkcniodogbcgqtetlddnrphbphfbopganmnbtghq");
			tapsell.setDebugMode(true);
			tapsell.setAdRequestListener(this);
			tapsell.setAdShowFinishedListener(this);

			adIds = new Dictionary();
			adIds["59c921884684653f2563a9f2"] = new VideoAd(TYPE_CHESTS, "59c921884684653f2563a9f2") ;
			adIds["59d5f6814684650cb96b01ec"] = new VideoAd(TYPE_OPERATIONS, "59d5f6814684650cb96b01ec") ;
			//adIds["59c925d44684653f256499bc"] = new VideoAd(ExchangeType.C32_CHEST, "59c925d44684653f256499bc") ;
			//adIds["59c8e6114684656c505cb957"] = new VideoAd(ExchangeType.C33_CHEST, "59c8e6114684656c505cb957") ;

			/**
			 * ---------------------------------------------------------------
			 * Initialize Chartboost.
			 * ---------------------------------------------------------------
			 */
			if( Chartboost.isAndroid() )
				Chartboost.startWith(AppModel.instance.navigator.stage.starling.nativeStage, "5d5a9cc80c7ec60cc5b67c06", "fc3d771153452cbc1fd0e83891b30d8aa096e50a");
			else if( Chartboost.isIOS() )
				Chartboost.startWith(AppModel.instance.navigator.stage.starling.nativeStage, "IOS_APP_ID", "IOS_APP_SIGN");

			this._hasAd = false;
		}
		
		public function requestAll():void
		{
			if( adProvider == AD_PROVIDER_CHARTBOOST )
				return;
			for (var k:String in adIds) 
				tapsell.requestAd( k, true );
		}
		
		public function onAdAvailable(zoneId:String, adId:String):void
		{
			var vid:VideoAd = adIds[zoneId] as VideoAd;
			if( vid == null )
			{
				trace("onAdAvailable::Zone", zoneId, "not found.")
				return;
			}
			vid.adId = adId;
			if( vid.autoPlay )
				showAd(vid.type);
			dispatchEventWith(Event.ADDED, false, vid);
			trace("onAdAvailable::Zone:", zoneId, "vid:", vid.type)
		}
		
		public function getAdByType(type:int):VideoAd
		{
			if( adProvider == AD_PROVIDER_CHARTBOOST )
				return null;
			for (var k:String in adIds) 
				if( VideoAd(adIds[k]).type == type )
					return adIds[k];
			return null;
		}

		public function requestAd(type:int, isCached:Boolean):void
		{
			requestAdIn(type, isCached, CBLocation.DEFAULT);
		}

		public function requestAdIn(type:int, isCached:Boolean, location:String):void
		{
			if( adProvider == AD_PROVIDER_CHARTBOOST && ( Chartboost.isAndroid() || Chartboost.isIOS() ) )
			{
				// Test:
				// -----------------------------------
				// trace("Start chaching ad.");
				// dispatchEventWith(Event.READY);
				//------------------------------------
				// Real:
				//------------------------------------
				Chartboost.cacheRewardedVideo(location);
				Chartboost.addDelegateEvent(ChartboostEvent.DID_CACHE_REWARDED_VIDEO, chartboost_didCacheRewardedVideoHandler);
				//------------------------------------
				return;
			}
			var vid:VideoAd = getAdByType(type);
			if( vid == null )
			{
				trace("Type", type, "not found.")
				return;
			}
			vid.autoPlay = !isCached;
			tapsell.requestAd( vid.zoneId, isCached);
		}

		public function showAd( type:int ):void
		{
			showAdIn(type, CBLocation.DEFAULT);
		}

		public function showAdIn( type:int, location:String ):void
		{
			if( adProvider == AD_PROVIDER_CHARTBOOST )
			{
				// Test Show reward:
				// chartboost_didCompleteRewardedVideoHandler("Default", 1);
				// return;
				if( Chartboost.hasRewardedVideo(location) )
				{
					Chartboost.showRewardedVideo(location);
					Chartboost.addDelegateEvent(ChartboostEvent.DID_COMPLETE_REWARDED_VIDEO, chartboost_didCompleteRewardedVideoHandler);
				}
				else 
				{
					requestAdIn(type, true, location);
					dispatchEventWith(ChartboostEvent.DID_FAIL_TO_LOAD_REWARDED_VIDEO);
				}
				return;
			}
			var vid:VideoAd = getAdByType(type);
			if( vid == null )
			{
				trace("Type", type, "not found.")
				return;
			}
			if( !vid.available )
			{
				trace("Zone", vid.zoneId, "has not any ad.")
				return;
			}
			tapsell.showAd(vid.adId, false, true, Tapsell.ORIENTATION_UNLOCKED, true);
			vid.adId = null;
		}

		protected function chartboost_didCompleteRewardedVideoHandler(location:String, reward:int):void
		{
			this._hasAd = false;
			dispatchEventWith(Event.COMPLETE, false, {zone: location, reward: reward});
			requestAdIn(TYPE_CHESTS, true, location);
		}
		protected function chartboost_didCacheRewardedVideoHandler(location:String):void
		{
			dispatchEventWith(Event.READY);
			this._hasAd = true;
		}
		public function onNoAdAvailable(zoneId:String):void{
			trace("No ad available.");
			VideoAd(adIds[zoneId]).adId = null;
		}
		public function onNoNetwork(zoneId:String):void{
			trace("No Network.");
			VideoAd(adIds[zoneId]).adId = null;
		}
		public function onExpiring(zoneId:String,adId:String):void{
			trace("Expiring, I should retry? :-?.");
			VideoAd(adIds[zoneId]).adId = null;
		}
		public function onOpened(zoneId:String,adId:String):void{
			trace("Ad is opened");
		}
		public function onClosed(zoneId:String,adId:String):void{
			trace("Ad is closed");
		}
		public function onError(zoneId:String,error:String):void{
			trace("Error...");
		}
		public function onAdShowFinished(zoneId:String, adId:String, completed:Boolean, rewarded:Boolean):void
		{
			var vid:VideoAd = adIds[zoneId] as VideoAd;
			if( vid == null )
			{
				trace("onAdShowFinished::Zone", zoneId, "not found.")
				return;
			}
			vid.completed = completed;
			vid.rewarded = rewarded;
			dispatchEventWith(Event.COMPLETE, false, vid);
			trace("Ad show was finished, zoneId: "+zoneId+", completed? "+(completed)+", rewarded? "+(rewarded));
		}
		public function getTapsellVersion():String
		{
			return tapsell.getVersion();
		}
	}
}