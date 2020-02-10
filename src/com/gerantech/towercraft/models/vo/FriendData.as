package com.gerantech.towercraft.models.vo
{
  import com.smartfoxserver.v2.entities.data.SFSObject;
  import com.smartfoxserver.v2.entities.data.ISFSObject;

  public class FriendData extends SFSObject 
  {
    public function init(id:int, name:String, point:int, status:int, step:int, start:int) :FriendData
    {
      this.id = id;
      this.point = point;
      this.step = step;
      this.start = start;
      this.status = status;
      this.name = name;
      return this;
    }

    public function update(data:ISFSObject) : FriendData
    {
			if( data.containsKey("name") )
				this.name = data.getUtfString("name");
			if( data.containsKey("id") )
				this.id = data.getInt("id");
			if( data.containsKey("point") )
				this.point = data.getInt("point");
			if( data.containsKey("step") )
				this.step = data.getInt("step");
			if( data.containsKey("start") )
				this.start = data.getInt("start");
			if( data.containsKey("status") )
				this.status = data.getInt("status");
      return this;
    }
    public function set id(value:int):void
    {
      if( getInt("id") == value )
        return;
      putInt("id", value);
    }
    public function get id():int
    {
      return getInt("id");
    }

    public function set point(value:int):void
    {
      if( getInt("point") == value )
        return;
      putInt("point", value);
    }
    public function get point():int
    {
      return getInt("point");
    }

    public function set step(value:int):void
    {
      if( getInt("step") == value )
        return;
      putInt("step", value);
    }
    public function get step():int
    {
      return getInt("step");
    }

    public function set start(value:int):void
    {
      if( getInt("start") == value )
        return;
      putInt("start", value);
    }
    public function get start():int
    {
      return getInt("start");
    }

    public function set status(value:int):void
    {
      if( getInt("status") == value )
        return;
      putInt("status", value);
    }
    public function get status():int
    {
      return getInt("status");
    }

    public function set name(value:String):void
    {
      if( getUtfString("name") == value )
        return;
      putUtfString("name", value);
    }
    public function get name():String
    {
      return getUtfString("name");
    }
  }
}