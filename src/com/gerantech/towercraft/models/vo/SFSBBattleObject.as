package com.gerantech.towercraft.models.vo
{
	import com.smartfoxserver.v2.entities.data.SFSObject;

	public class SFSBBattleObject
	{
		public var source:Vector.<int> = new Vector.<int>();
		public var destination:int;
		
		public function SFSBBattleObject(source:Vector.<int>, destination:int)
		{
			this.source = source;
			this.destination = destination;
		}
		
		public function toSFS():SFSObject
		{
			var _sfs:SFSObject = new SFSObject();
			var _src:Array = new Array();
			for each(var s:int in source)
				_src.push(s);
			_sfs.putIntArray("s", _src);
			_sfs.putInt("d", this.destination);
			return _sfs;
		}

		public function update(sfs:SFSObject):void
		{
			this.source = new Vector.<int>();
			var src:Array = sfs.getIntArray("s");
			for (var i:int=0; i<src.length; i++)
				this.source.push(src[i]);
			
			this.destination = sfs.getInt("d");
		}
		
		public function toString():Object
		{
			return "from : " + source + " ,  to " + destination;
		}
	}
}