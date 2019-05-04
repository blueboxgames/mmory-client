package com.gerantech.towercraft.controls 
{
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.MainTheme;
import feathers.controls.ImageLoader;
import feathers.controls.LayoutGroup;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import flash.geom.Rectangle;
import starling.events.Event;
import flash.geom.Point;
import starling.display.Image;

/**
* ...
* @author Mansour Djawadi
*/
public class TileBackground extends TowersLayout 
{
private var tiledBG:Image;
private var movingSpeed:Number;
public function TileBackground(image:String, movingSpeed:Number = 0.3, hasInnerShadow:Boolean = true, backgroundColor:int = -1) 
{
	layout = new AnchorLayout();
	this.movingSpeed = movingSpeed;
	
	if( backgroundColor > -1 )
	{
		var skin:Image = new Image(appModel.theme.quadSkin);
		skin.color = backgroundColor;
		skin.scale9Grid = MainTheme.QUAD_SCALE9_GRID;
		backgroundSkin = skin;
	}
	
	tiledBG = new Image(Assets.getTexture(image, "gui"));
	tiledBG.tileGrid = new Rectangle(0, 0, tiledBG.width, tiledBG.height);
	tiledBG.alpha = 0.1;
	tiledBG.pixelSnapping = false;
	addChild(tiledBG);
	
	if( movingSpeed != 0 )
		addEventListener(FeathersEventType.CREATION_COMPLETE, creationCompleteHandler);
	
	if( hasInnerShadow )
	{
		var shadowDisplay:ImageLoader = new ImageLoader();
		shadowDisplay.source = Assets.getTexture("radial-gradient-shadow", "gui");
		shadowDisplay.layoutData = new AnchorLayoutData(0, 0, 0, 0);
		shadowDisplay.scale9Grid = new Rectangle(2, 2, 12, 12);
		shadowDisplay.color = 0x000022;
		shadowDisplay.alpha = 0.6;
		addChild(shadowDisplay);
	}
}

protected function creationCompleteHandler(e:Event):void 
{
	removeEventListener(FeathersEventType.CREATION_COMPLETE, creationCompleteHandler);
	tiledBG.x = -tiledBG.tileGrid.width;
	tiledBG.y = 0;
	tiledBG.width = width + tiledBG.tileGrid.width;
	tiledBG.height = height + tiledBG.tileGrid.height;
	addEventListener(Event.ENTER_FRAME, enterFrameHandler);
}

protected function enterFrameHandler(e:Event):void 
{
	if( tiledBG.x > 0 )
		tiledBG.x = -tiledBG.tileGrid.width;
	if( tiledBG.y < -tiledBG.tileGrid.height )
		tiledBG.y = 0;
	
	var delta:Number = 1;
	tiledBG.x += movingSpeed * delta;
	tiledBG.y -= movingSpeed * delta;
}
override public function dispose() : void
{
	removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
	super.dispose();
}
}
}