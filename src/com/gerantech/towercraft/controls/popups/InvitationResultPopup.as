package com.gerantech.towercraft.controls.popups
{
	import com.smartfoxserver.v2.entities.data.SFSObject;

	import flash.geom.Rectangle;

	import starling.events.Event;
	
	public class InvitationResultPopup extends MessagePopup
	{
		private var responseCode:int;
		private var params:SFSObject;
		public function InvitationResultPopup(params:SFSObject)
		{
			this.params = params;
			responseCode = params.getInt("response");
			var array:Array = responseCode == 0 || responseCode == -3 ? [params.getText("inviter")] : null;
			var msg:String = loc("popup_invitation_" + responseCode, array);
			if( params.containsKey("rewardType") )
				msg += "\n" + loc("popup_invitation_reward", [params.getInt("rewardCount"), loc("resource_title_" + params.getInt("rewardType"))]);
			
			super(msg, acceptLabel);
		}
		
		override protected function acceptButton_triggeredHandler(event:Event):void
		{
			super.acceptButton_triggeredHandler(event);
			if( responseCode == 0 )
			{
				if( params.containsKey("rewardType") )
				{
					player.resources.increase(params.getInt("rewardType"), params.getInt("rewardCount") );
					var rec:Rectangle = acceptButton.getBounds(stage);
					appModel.navigator.dispatchEventWith("achieveResource", false, [rec.x + rec.width * 0.5, rec.y, params.getInt("rewardType"), params.getInt("rewardCount")]);
				}
			}
		}
	}
}