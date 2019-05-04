package com.gerantech.towercraft.models.vo
{
	import com.gerantech.towercraft.utils.Utils;

	public class Descriptor
	{
		public var name:String;
		public var id:String;
		public var copyright:String;
		public var versionLabel:String;
		public var versionNumber:String;
		public var versionCode:int;
		
		public var description:String;
		public var market:String;
		public var marketIndex:int;
		public var platform:String;
		public var server:String;
		
		private var markets:Array = ["google", "appstore", "cafebazaar", "myket", "cando", "vitrin", "ario", "iranapps"]
		
		public function Descriptor(xml:XML)
		{
			name = getNodesByName(xml, "name");
			id = getNodesByName(xml, "id");
			copyright = getNodesByName(xml, "copyright");
			description = getNodesByName(xml, "description");
			versionLabel = getNodesByName(xml, "versionLabel");
			versionNumber = getNodesByName(xml, "versionNumber");
			versionCode = Utils.getVersionCode(versionNumber)
			
			var descriptJson:Object = JSON.parse(description);
			for(var n:String in descriptJson)
				this[n] = descriptJson[n];
			marketIndex = markets.indexOf(market);
		}
		
		private function getNodesByName(xml:XML, nodeName:String) : String 
		{
			var list:XMLList = xml.children();
			
			for each(var node:XML in  list)
			{
				var name:String = node.localName().toString();
				if (name == nodeName)
					return node.valueOf();
			}
			return null;
		}
	}
}
