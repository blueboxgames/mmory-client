package com.gerantech.towercraft.events
{
	import flash.events.Event;
	
	public class LoadingEvent extends Event
	{
		public static const LOADED:String = "loaded";
		public static const LOGIN_ERROR:String = "loginError";
		public static const LOGIN_USER_EXISTS:String = "loginUserExists";
        public static const LOGIN_USER_BANNED:String = "loginUserBanned";
		public static const UNDER_MAINTENANCE:String = "underMaintenance";
		public static const NOTICE_UPDATE:String = "noticeUpdate";
		public static const FORCE_UPDATE:String = "forceUpdate";
		public static const NETWORK_ERROR:String = "networkError";
		public static const CORE_LOADING_ERROR:String = "coreLoadingError";
		public static const CONNECTION_LOST:String = "connectionLost";
		public static const FORCE_RELOAD:String = "forceReload";
		
		public var data:Object;
		
		public function LoadingEvent(type:String, data:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.data =  data;
			super(type, bubbles, cancelable);
		}
	}
}