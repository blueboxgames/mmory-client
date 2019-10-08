package com.gerantech.towercraft.controls.buttons
{
	import com.gerantech.towercraft.models.AppModel;
	import com.gerantech.towercraft.themes.MainTheme;
	import com.gerantech.towercraft.utils.StrUtils;

	import feathers.controls.ButtonState;
	import feathers.controls.ImageLoader;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.skins.ImageSkin;

	import starling.textures.Texture;

	public class EmblemButton extends SimpleLayoutButton
	{
		private var _value:int;
		private var iconDisplay:ImageLoader;
		public function EmblemButton(value:int)
		{
			super();
			this.value = value;
		}

		override protected function initialize():void
		{
			super.initialize();
			var padding:int = 16;
			layout = new AnchorLayout();
			
			skin = new ImageSkin(appModel.theme.itemRendererUpSkinTexture);
			skin.setTextureForState(ButtonState.UP, appModel.theme.itemRendererUpSkinTexture);
			skin.setTextureForState(ButtonState.DOWN, appModel.theme.itemRendererSelectedSkinTexture);
			skin.scale9Grid = MainTheme.ITEM_RENDERER_SCALE9_GRID
			backgroundSkin = skin;
			
			iconDisplay = new ImageLoader();
			iconDisplay.source = getTexture(_value);
			iconDisplay.layoutData = new AnchorLayoutData(padding, padding, padding*1.3, padding);
			addChild(iconDisplay);
		}
		
		public function get value():int
		{
			return _value;
		}
		public function set value(val:int):void
		{
			if( _value == val )
				return;
			
			_value = val;
			if( iconDisplay != null )
				iconDisplay.source = getTexture(_value);
		}

		static public function loadAtlas(loadCallback:Function) : void
		{
			var txt:Texture = AppModel.instance.assets.getTexture("emblem-000");
		}

		static public function getTexture(index:int) : Texture
		{
			return AppModel.instance.assets.getTexture("emblem-" + StrUtils.getZeroNum(index.toString()));
		}


	}
}