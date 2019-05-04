package com.gerantech.towercraft.controls.screens
{
import com.gerantech.towercraft.controls.TileBackground;
import com.gerantech.towercraft.controls.buttons.MMOryButton;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.MainTheme;
import feathers.controls.Button;
import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import starling.display.Image;
import starling.events.Event;

public class SimpleScreen extends BaseCustomScreen
{
public var title:String = "";
public var showGradientShadow:Boolean = true;
public var showTileAnimationn:Boolean = true;
protected var headerSize:int = 150;
protected var footerSize:int = 150;
protected var titleDisplay:ShadowLabel;
protected var closeButton:MMOryButton;
public function SimpleScreen(){ super(); }
override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout();
	
	if( showTileAnimationn )
	{
		var tileBacground:TileBackground = new TileBackground("home/pistole-tile", 0.3, showGradientShadow);
		tileBacground.layoutData = new AnchorLayoutData(0, 0, 0, 0);
		addChild(tileBacground);
	}
	
	closeButton = new MMOryButton();
	closeButton.width = 220;
	closeButton.height = 140;
	closeButton.styleName = MainTheme.STYLE_BUTTON_HILIGHT;
	closeButton.iconTexture = appModel.theme.buttonBackDownSkinTexture;
	closeButton.addEventListener(Event.TRIGGERED, cloaseButton_triggeredHandler);
	closeButton.layoutData = new AnchorLayoutData( NaN, NaN, 40, 40);
	addChild(closeButton);
	
	titleDisplay = new ShadowLabel(title);
	titleDisplay.layoutData = new AnchorLayoutData(headerSize - 100, NaN, NaN, NaN, 0);
	addChild(titleDisplay);
}

protected function cloaseButton_triggeredHandler(event:Event) : void 
{
	appModel.navigator.popScreen();
}
}
}