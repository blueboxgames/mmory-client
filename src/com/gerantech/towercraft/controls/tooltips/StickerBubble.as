package com.gerantech.towercraft.controls.tooltips
{
	import com.gerantech.towercraft.controls.TowersLayout;
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	import com.gerantech.towercraft.models.Assets;
	
	import flash.geom.Rectangle;
	
	import feathers.layout.HorizontalLayout;
	
	import starling.display.Image;

	public class StickerBubble extends TowersLayout
	{
		private var _label:String = "";
		private var _type:int = -1;
		
		private var labelDisplay:RTLLabel;
		private var inverse:Boolean;
		
		public function StickerBubble(inverse:Boolean = false)
		{
			super();
			this.inverse = inverse;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			touchable = false;
			
			var sk:Image = new Image(Assets.getTexture("tooltip-bg-" + (inverse?"top-left":"bot-right"), "gui"));
			sk.scale9Grid = new Rectangle(inverse?38:14, inverse?38:14, 2, 2);
			backgroundSkin = sk;
			
			var hlayout:HorizontalLayout = new HorizontalLayout();
			hlayout.padding = 36;
			hlayout.paddingTop = (inverse?60:24);
			hlayout.paddingBottom = (inverse?36:72);
			layout = hlayout;
			
			labelDisplay = new RTLLabel(_label, 0, "center", null, false, null, 1.2);
			labelDisplay.pixelSnapping = false;
			addChild(labelDisplay);
		}
		
		public function get label():String
		{
			return _label;
		}
		public function set label(value:String):void
		{
			if( _label == value )
				return;
			_label = value;
			if(labelDisplay)
				labelDisplay.text = _label;
		}
		
		public function get type():int
		{
			return _type;
		}
		public function set type(value:int):void
		{
            if(_type == value && _type < 0 )
				return;
			_type = value;
			label = loc( "sticker_" + _type );
		}
	}
}