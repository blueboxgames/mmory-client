package com.gerantech.towercraft.controls
{
	import com.gerantech.towercraft.models.AppModel;
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.themes.MainTheme;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.text.TextFormat;

	public class LobbyBalloon extends Sprite
	{
		private var _unreads:int = -1;
		
		private var unreadsLabel:TextField;
		
		public function LobbyBalloon(unreads:int)
		{
			this.unreads = unreads;
			pivotX = width * 0.5;
			pivotY = height;
			
			var background:Image = new Image(Assets.getTexture("lobby-balloon"));
			background.pivotX = background.width * 0.5;
			background.pivotY = background.height;
			addChild(background);
			
			var tf:TextFormat = new TextFormat("SourceSans", 25, 0xFFFFFF);
			
			unreadsLabel = new TextField(100, 100, unreads.toString(), tf);
			unreadsLabel.pixelSnapping = false;
			unreadsLabel.pivotX = unreadsLabel.width * 0.5;
			unreadsLabel.pivotY = unreadsLabel.height*0.75;
			addChild(unreadsLabel);
		}
		
		public function get unreads():int
		{
			return _unreads;
		}
		public function set unreads(value:int):void
		{
			if( value == _unreads )
				return;
			visible = value > 0;
			_unreads = value;
			if( value == 0)
				return;
			if( unreadsLabel )
				unreadsLabel.text = _unreads.toString();	
		}
	}
}