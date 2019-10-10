package com.gerantech.towercraft.controls.items 
{
import com.gerantech.towercraft.controls.segments.lobby.LobbyChatItemSegment;
import com.gerantech.towercraft.models.AppModel;

import dragonBones.objects.DragonBonesData;
import dragonBones.starling.StarlingArmatureDisplay;
import dragonBones.starling.StarlingFactory;
import dragonBones.starling.StarlingTextureAtlasData;

import feathers.layout.TiledRowsLayout;

import starling.display.DisplayObject;
import starling.display.Image;
/**
* ...
* @author Mansour Djawadi
*/
public class EmoteItemRenderer extends AbstractTouchableListItemRenderer 
{
static public var dragonBonesData:DragonBonesData;
static public var factory:StarlingFactory;
static public var atlas:StarlingTextureAtlasData;
static private var atlasLoadCalback:Function;
static public function loadEmotes(loadCallback:Function) : void
{
	EmoteItemRenderer.atlasLoadCalback = loadCallback;
	animation_loadCallback();
}
static private function animation_loadCallback():void 
{
	if( EmoteItemRenderer.factory == null )
	{
		EmoteItemRenderer.factory = new StarlingFactory();
		EmoteItemRenderer.dragonBonesData = EmoteItemRenderer.factory.parseDragonBonesData(AppModel.instance.assets.getObject("emotes_ske"));
		EmoteItemRenderer.factory.parseTextureAtlasData(AppModel.instance.assets.getObject("emotes_tex"), AppModel.instance.assets.getTexture("emotes_tex"));
		EmoteItemRenderer.atlas = EmoteItemRenderer.factory.getTextureAtlasData("emotes")[0] as StarlingTextureAtlasData
	}
	EmoteItemRenderer.atlasLoadCalback();
}

private var emoteArmature:StarlingArmatureDisplay;
public function EmoteItemRenderer() 
{
	super();
	
	var background:Image = new Image(appModel.assets.getTexture("socials/balloon"));
	background.scale9Grid = LobbyChatItemSegment.BALLOON_RECT;
	backgroundSkin = background;
	
	emoteArmature = EmoteItemRenderer.factory.buildArmatureDisplay("emote");
	emoteArmature.scale = 0.7;
	emoteArmature.touchable = false;
	addChild(emoteArmature as DisplayObject);
}

override protected function commitData() : void
{
	super.commitData();
	width = TiledRowsLayout(_owner.layout).typicalItemWidth;
	height = TiledRowsLayout(_owner.layout).typicalItemHeight;

	emoteArmature.x = width * 0.5;
	emoteArmature.y = height - 20;
	emoteArmature.animation.gotoAndStopByFrame("st-" + data);	
}
}
}