package com.gerantech.towercraft.models.vo
{
	public class VideoAd
	{
		public var type:int;
		public var zoneId:String;
		public var adId:String;
		public var completed:Boolean;
		public var rewarded:Boolean;
		public var autoPlay:Boolean;
		
		public function VideoAd(type:int, zoneId:String, adId:String=null)
		{
			this.type = type;
			this.zoneId = zoneId;
			this.adId = adId;
		}
		public function get available():Boolean
		{
			return adId != null;
		}
	}
}