package com.gerantech.towercraft.controls.floatings
{
	import com.gerantech.towercraft.controls.buttons.CustomButton;
	import com.gerantech.towercraft.models.Assets;
	
	import feathers.controls.ButtonState;
	import feathers.controls.ImageLoader;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	
	import starling.display.DisplayObject;
	import starling.events.Event;

	public class MapElementFloating extends BaseFloating
	{
		public var element:DisplayObject;
		public var locked:Boolean;
		
		public function MapElementFloating(element:DisplayObject, locked)
		{
			this.element = element;
			this.locked = locked;
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			overlay.visible = false;
			layout = new AnchorLayout();
			
			var simpleLayoutButton:CustomButton = new CustomButton();
			simpleLayoutButton.layoutData = new AnchorLayoutData(0, 0, 0, 0);
			simpleLayoutButton.label = loc("map-"+element.name);
			simpleLayoutButton.addEventListener(Event.TRIGGERED, buttonTrigeredHandler);
			simpleLayoutButton.initializeNow()
			simpleLayoutButton.skin.defaultTexture = locked?appModel.theme.buttonDisabledSkinTexture:appModel.theme.buttonUpSkinTexture;
			simpleLayoutButton.skin.setTextureForState(ButtonState.UP, locked?appModel.theme.buttonDisabledSkinTexture:appModel.theme.buttonUpSkinTexture);
			simpleLayoutButton.skin.setTextureForState(ButtonState.DOWN, locked?appModel.theme.buttonDisabledSkinTexture:appModel.theme.buttonDownSkinTexture);
			addChild(simpleLayoutButton);
			
			if( locked )
			{
				var lockDisplay:ImageLoader = new ImageLoader();
				lockDisplay.width = lockDisplay.height = height*0.6;
				lockDisplay.source = Assets.getTexture("improve-lock");
				lockDisplay.layoutData = new AnchorLayoutData(NaN, height*0.10, NaN, NaN, NaN, 0);
				lockDisplay.touchable = false;
				addChild(lockDisplay);
			}
		}
		
		private function buttonTrigeredHandler(event:Event):void
		{
			dispatchEventWith(Event.SELECT, false, element);
		}
	}
}