package com.gerantech.towercraft.controls.buttons
{
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	import com.gerantech.towercraft.themes.MainTheme;
	
	import feathers.controls.ButtonState;
	import feathers.controls.ImageLoader;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.skins.ImageSkin;
	
	public class BattleChestButton extends SimpleLayoutButton
	{
		private var labelDisplay:RTLLabel;
		private var shadowDisplay:RTLLabel;
		private var iconDisplay:ImageLoader;
		
		private var labelLayoutData:AnchorLayoutData;
		private var shadowLayoutData:AnchorLayoutData;
		
		private var padding:Number;
		
		public function BattleChestButton()
		{
			if( width == 0 )
				width = 240;
			minWidth = 72;
			minHeight = 72;
			height = maxHeight = 128;
			
			padding = 8;
			layout = new AnchorLayout();
			shadowLayoutData = new AnchorLayoutData(NaN, padding, NaN, padding, NaN, -padding*0.8);
			labelLayoutData = new AnchorLayoutData(NaN, padding, NaN, padding, NaN, -padding*0.3);
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			skin = new ImageSkin(appModel.theme.buttonUpSkinTexture);
			skin.setTextureForState(ButtonState.UP, appModel.theme.buttonUpSkinTexture);
			skin.setTextureForState(ButtonState.DOWN, appModel.theme.buttonDownSkinTexture);
			skin.setTextureForState(ButtonState.DISABLED, appModel.theme.buttonDisabledSkinTexture);
			skin.scale9Grid = MainTheme.BUTTON_SCALE9_GRID;
			backgroundSkin = skin;
			
			shadowDisplay = new RTLLabel("", 0x000000, "center");
			shadowDisplay.pixelSnapping = false;
			shadowDisplay.touchable = false;
			shadowDisplay.layoutData = shadowLayoutData;
			addChild(shadowDisplay);
			
			labelDisplay = new RTLLabel("", 0XFFFFFF, "center");
			labelDisplay.pixelSnapping = false;
			labelDisplay.touchable = false;
			labelDisplay.layoutData = labelLayoutData;
			addChild(labelDisplay);
			
			iconDisplay = new ImageLoader();
			iconDisplay.touchable = false;
			iconDisplay.height = height * 0.7;
			iconDisplay.layoutData = new AnchorLayoutData(NaN, padding, NaN, NaN, NaN, padding*0.4);
			//iconDisplay.source = _icon;
			addChild(iconDisplay);
		}
		
		
		override public function set currentState(value:String):void
		{
			if(super.currentState == value)
				return;
			
			super.currentState = value;
			shadowLayoutData.verticalCenter = -padding*(value==ButtonState.DOWN?0.5:0.8)
		}
		
	}
}