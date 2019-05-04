package com.gerantech.towercraft.controls.popups
{
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.utils.StrUtils;
	
	import flash.desktop.NativeApplication;
	import flash.geom.Rectangle;
	import flash.utils.setInterval;
	
	import feathers.controls.ImageLoader;
	import feathers.layout.AnchorLayoutData;

	public class UnderMaintenancePopup extends ConfirmPopup
	{
		private var waitTime:int;
		private var forceClose:Boolean;
		public function UnderMaintenancePopup(waitTime:int, forceClose:Boolean = true)
		{
			super(loc("popup_under_maintenance", [StrUtils.uintToTime(waitTime)]), null, loc("popup_accept_label"));
			this.waitTime = waitTime;
			this.forceClose = forceClose;
			closeOnOverlay = false;
			declineStyle = "danger";
		}
		
		override protected function initialize():void
		{
			super.initialize();
			transitionIn.destinationBound = new Rectangle(stage.stageWidth*0.15, stage.stageHeight*0.25, stage.stageWidth*0.7, stage.stageHeight*0.3);
			messageDisplay.layoutData = new AnchorLayoutData(NaN, padding, padding * 6, padding);
			addChild(messageDisplay);
			acceptButton.removeFromParent();
			
			var icon:ImageLoader = new ImageLoader();
			icon.width = icon.height = 160;
			icon.layoutData = new AnchorLayoutData(padding, NaN, NaN, NaN, 0);
			icon.source = Assets.getTexture("improve-11");
			addChild(icon);
			
			setInterval( updateLabel, 1000);
			rejustLayoutByTransitionData();			
		}
		
		private function updateLabel():void
		{
			waitTime --;
			messageDisplay.text = loc("popup_under_maintenance", [StrUtils.uintToTime(waitTime)]);
			if( waitTime <= 0 )
				close();
		}
		
		override public function close(dispose:Boolean=true):void
		{
			super.close(dispose);
			if( forceClose )
				NativeApplication.nativeApplication.exit();
		}
	}
}