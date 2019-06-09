package com.gerantech.towercraft.controls.items.exchange
{
import com.gerantech.mmory.core.exchanges.ExchangeItem;
import com.gerantech.towercraft.controls.items.EmoteItemRenderer;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.themes.MainTheme;
import com.gerantech.towercraft.utils.StrUtils;

import dragonBones.starling.StarlingArmatureDisplay;
import dragonBones.starling.StarlingTextureData;

import feathers.controls.ImageLoader;
import feathers.core.ITextRenderer;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayoutData;

import starling.events.Event;
import starling.textures.SubTexture;
import starling.textures.Texture;

public class ExEmotItemRenderer extends ExDefaultItemRenderer
{
public function ExEmotItemRenderer(category:int) { super(category); }
protected var emoteArmature:StarlingArmatureDisplay;
override protected function initialize() : void
{
	this.exchangeManager.addEventListener(FeathersEventType.BEGIN_INTERACTION, exchangeManager_beginInteractionHandler);
	super.initialize();
}

override protected function commitData() : void
{
	this.removeChildren();
	super.commitData();
	if( this.exchange.numExchanges > 0 )
	{
		this.buttonDisplay.label = loc("achieved_label");
		this.buttonDisplay.iconTexture = null;
		return;
	}
}
override protected function iconFactory() : void
{
	var iconBGDisplay:ImageLoader = new ImageLoader();
	iconBGDisplay.color = 0xCCDDEE;
	iconBGDisplay.source = appModel.theme.roundMediumSkin;
	iconBGDisplay.scale9Grid = MainTheme.ROUND_MEDIUM_SCALE9_GRID;
	iconBGDisplay.layoutData = new AnchorLayoutData(32, 32, 150, 32);
	this.addChild(iconBGDisplay);

	super.iconFactory();
	this.iconDisplay.layoutData = new AnchorLayoutData(52, 52, 150, 52);

	// this.emoteArmature = ChatSegment.factory.buildArmatureDisplay("emote");
	// this.emoteArmature.animation.timeScale = 0;
	// this.emoteArmature.scale = 0.7;
	// this.emoteArmature.touchable = false;
	// this.addChild(this.emoteArmature as DisplayObject);
}

override protected function iconSourceProvider() : Texture
{
	var std:StarlingTextureData =  EmoteItemRenderer.atlas.textures[StrUtils.getZeroNum(exchange.outcome+"", 2) + "-00"];
	return new SubTexture(EmoteItemRenderer.atlas.texture, std.region);
}

override protected function titleFactory() : void
{
}

override protected function buttonLabelFactory() : ITextRenderer
{
	if( this.exchange.numExchanges == 0)
		return new ShadowLabel(null, 0x2ee723, 0, "center", null, false, null, 0.85);
	return new RTLLabel(null, 0x000088, "center", null, false, null, 0.85);
}

override protected function exchangeManager_endInteractionHandler(event:Event):void {}
protected function exchangeManager_beginInteractionHandler(event:Event):void 
{
	this.resetData(event.data as ExchangeItem);
}
}
}