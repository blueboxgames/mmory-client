package com.gerantech.towercraft.managers
{
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
		
		private var adIds:Dictionary;
		private var tapsell:Tapsell;
		private static var _intance:VideoAdsManager;
		
		public static function get instance():VideoAdsManager
		{
			if( _intance == null )
				_intance = new VideoAdsManager();
			return _intance;
		}
		
		public function VideoAdsManager()
		{
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
		}
		
		public function requestAll():void
		{
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
			for (var k:String in adIds) 
				if( VideoAd(adIds[k]).type == type )
					return adIds[k];
			return null;
		}

		public function requestAd(type:int, isCached:Boolean):void
		{
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
		public function getVersion():String
		{
			return tapsell.getVersion();
		}
	}
}