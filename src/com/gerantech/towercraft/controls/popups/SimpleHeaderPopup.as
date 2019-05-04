package com.gerantech.towercraft.controls.popups 
{
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.MainTheme;
import feathers.controls.Button;
import feathers.layout.AnchorLayoutData;
import starling.core.Starling;
import starling.display.Image;
import starling.events.Event;
/**
* @author Mansour Djawadi
*/
public class SimpleHeaderPopup extends SimplePopup 
{
public var title:String;
public var hasCloseButton:Boolean = true;
protected var closeButton:Button;
protected var titleDisplay:ShadowLabel;
public function SimpleHeaderPopup() { super(); }
override protected function initialize() : void
{
	super.initialize();
	skin.source = appModel.theme.popupHeaderedBackgroundSkinTexture;
	skin.scale9Grid = MainTheme.POPUP_HEADERED_SCALE9_GRID;
	overlay.alpha = 0.8;
	
	titleDisplay = new ShadowLabel(title, 1, 0, "center");
	titleDisplay.layoutData = new AnchorLayoutData(15, NaN, NaN, NaN, 0);
	titleDisplay.alpha = 0;
	
	if( !hasCloseButton )
		return;
	closeButton = new Button();
	closeButton.styleName = MainTheme.STYLE_BUTTON_SMALL_DANGER;
	closeButton.defaultIcon = new Image(Assets.getTexture("theme/icon-cross", "gui"));
	closeButton.width = 88;
	closeButton.height = 74;
	closeButton.layoutData = new AnchorLayoutData(-10, -10);
	closeButton.addEventListener(Event.TRIGGERED, closeButton_triggeredHandler);
	addChild(closeButton);
}

override protected function transitionInCompleted() : void
{
	Starling.juggler.tween(titleDisplay, 0.2, {alpha:1});
	addChild(titleDisplay);
	super.transitionInCompleted();
}

protected function closeButton_triggeredHandler():void
{
	close();
}
override public function dispose():void
{
	if( hasCloseButton )
		closeButton.removeEventListener(Event.TRIGGERED, closeButton_triggeredHandler);
	super.dispose();
}
}
}