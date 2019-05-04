package com.gerantech.towercraft.controls.overlays
{
import com.gerantech.towercraft.events.LoadingEvent;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.Assets;

import flash.utils.clearTimeout;
import flash.utils.setTimeout;

import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

import starling.core.Starling;

public class LowConnectionOverlay extends BaseOverlay
{
private var timeoutId:uint;
public function LowConnectionOverlay()
{
	super();
	closeOnOverlay = closeOnStage = false;
}

override protected function initialize():void
{
	super.initialize();
	overlay.alpha = 0.2;
	
	layout = new AnchorLayout();
	
	var imageDisplay:ImageLoader = new ImageLoader();
	imageDisplay.source = Assets.getTexture("connection-alert");
	imageDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, 0);
	addChild(imageDisplay);
	
	Starling.juggler.tween(imageDisplay, 1, {repeatCount:12, alpha:0});
	timeoutId = setTimeout(addReloadPopup, 15000);
}

private function addReloadPopup():void
{
	appModel.navigator.removeAllPopups();
	appModel.navigator.removeAllOverlays();
	SFSConnection.instance.disconnect();
	//appModel.loadingManager.dispatchEvent(new LoadingEvent(LoadingEvent.CONNECTION_LOST))	
}

override public function dispose():void
{
	clearTimeout(timeoutId);
	super.dispose();
}
}
}