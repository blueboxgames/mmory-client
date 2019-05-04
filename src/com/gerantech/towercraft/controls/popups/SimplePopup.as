package com.gerantech.towercraft.controls.popups
{
import com.gerantech.towercraft.themes.MainTheme;
import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

public class SimplePopup extends AbstractPopup
{
protected var skin:ImageLoader;
protected var padding:int;
public function SimplePopup(){ super(); }
override protected function initialize():void
{
	super.initialize();
	
	layout = new AnchorLayout();
	padding = 36;
	
	skin = new ImageLoader();
	skin.source = appModel.theme.popupBackgroundSkinTexture;
	skin.scale9Grid = MainTheme.POPUP_SCALE9_GRID;
	skin.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	addChild(skin);
}

protected function showElements() : void { }
override protected function transitionInCompleted() : void
{
	super.transitionInCompleted();
	showElements();
}
}
}