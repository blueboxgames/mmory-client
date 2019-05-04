package com.gerantech.towercraft.controls.buttons
{
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	
	import feathers.controls.ButtonState;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	
	import starling.display.Quad;

	public class LobbyTabButton extends SimpleLayoutButton
	{
		private var label:String;
		private var shadowDisplay:RTLLabel;
		private var labelDisplay:RTLLabel;

		private var padding:int;

		private var labelLayoutData:AnchorLayoutData;
		
		public function LobbyTabButton(label:String, visible:Boolean = false)
		{
			super();
			this.label = label;
			this.visible = visible;
			labelLayoutData = new AnchorLayoutData(NaN, padding, NaN, padding, NaN, 0);
		}
		
		override protected function initialize():void
		{
			super.initialize();
			layout = new AnchorLayout();
			
			padding = 8;
			backgroundSkin = new Quad(1,1);
			backgroundSkin.alpha = 0;
						
			shadowDisplay = new RTLLabel(label, 0x000000, "center", null, false, null, 0.9);
			shadowDisplay.pixelSnapping = false;
			shadowDisplay.touchable = false;
			shadowDisplay.layoutData = new AnchorLayoutData(NaN, padding, NaN, padding, NaN, padding);
			addChild(shadowDisplay);
			
			labelDisplay = new RTLLabel(label, 0XFFFFFF, "center", null, false, null, 0.9);
			labelDisplay.pixelSnapping = false;
			labelDisplay.touchable = false;
			labelDisplay.layoutData = labelLayoutData;
			addChild(labelDisplay);
			changeStyle(currentState);
		}
		
		override public function set currentState(value:String):void
		{
			if(super.currentState == value)
				return;
			
			super.currentState = value;
			if( labelDisplay )
				changeStyle(value);
		}
		
		private function changeStyle(value:String):void
		{
			labelLayoutData.verticalCenter = value==ButtonState.DISABLED?padding*0.5:0;
			labelDisplay.alpha = value==ButtonState.DISABLED?0.7:1;
			shadowDisplay.visible = value!=ButtonState.DISABLED;
		}
	}
}