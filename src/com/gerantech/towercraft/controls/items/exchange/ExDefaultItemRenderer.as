package com.gerantech.towercraft.controls.items.exchange
{
import com.gerantech.towercraft.controls.buttons.MMOryButton;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.MainTheme;
import com.gerantech.towercraft.utils.StrUtils;
import com.gerantech.mmory.core.constants.ExchangeType;
import com.gerantech.mmory.core.constants.ResourceType;

import feathers.controls.ImageLoader;
import feathers.core.ITextRenderer;
import feathers.layout.AnchorLayoutData;
import feathers.skins.ImageSkin;

import flash.geom.Rectangle;

public class ExDefaultItemRenderer extends ExBaseItemRenderer
{
static public const BACKGROUND_SCALEGRID:Rectangle = new Rectangle(18, 18, 1, 1);
protected var reqType:int;
protected var reqCount:int;
protected var category:int;
protected var buttonSkin:ImageSkin;
protected var iconDisplay:ImageLoader;
protected var titleDisplay:ShadowLabel;
protected var buttonDisplay:MMOryButton;

public function ExDefaultItemRenderer(category:int){ this.category = category}
override protected function commitData():void
{
	super.commitData();
	this.skinFactory();
	this.iconFactory();
	this.buttonFactory();
	this.titleFactory();

	this.reqType = this.exchange.requirements.keys()[0];
	this.reqCount = this.exchange.requirements.get(reqType);
	
	if( this.buttonDisplay != null )
	{
		if( this.reqType != ResourceType.R5_CURRENCY_REAL )
			this.buttonDisplay.iconTexture = MMOryButton.getIcon(this.reqType, this.reqCount);
		this.buttonDisplay.label = MMOryButton.getLabel(this.reqType, this.reqCount);
	}
	if( this.iconDisplay != null )
		this.iconDisplay.source = Assets.getTexture(this.iconSourceProvider(), "gui");
	if( this.titleDisplay != null )
		this.titleDisplay.text = titleFormatter(this.exchange.outcomes.values()[0]);
}

override public function set currentState(value:String) : void
{
	super.currentState = value;
	if( this.buttonSkin != null )
		this.buttonSkin.defaultColor = this.buttonSkin.getColorForState(value);
}

private function iconSourceProvider() : String
{
	switch( this.category )
	{
		case 20: return "cards/" + exchange.outcome;
		case 120: return "books/" + exchange.outcome;
	}
	return "shop/currency-" + exchange.type;
}

protected function titleFormatter(count:int) : String
{
	if( this.category == ExchangeType.C120_MAGICS )
		return loc("arena_text") + " " + loc("num_" + (count + 1));
	return "x" + StrUtils.getNumber(count);
}


private function skinFactory():void
{
	this.skin.setTextureForState(STATE_DOWN, Assets.getTexture("shop/item-down", "gui"));
	this.skin.defaultTexture = Assets.getTexture("shop/item-" + ExCategoryItemRenderer.GET_COLOR(category), "gui");
	this.skin.setTextureForState(STATE_SELECTED, this.skin.defaultTexture);
	this.skin.setTextureForState(STATE_NORMAL, this.skin.defaultTexture);
	this.skin.scale9Grid = BACKGROUND_SCALEGRID;
}
protected function iconFactory() : void
{
	this.iconDisplay = new ImageLoader();
	this.iconDisplay.layoutData = new AnchorLayoutData(80, 28, 120, 28);
	this.addChild(this.iconDisplay);
}
protected function titleFactory() : void
{
	this.titleDisplay = new ShadowLabel(null, ExCategoryItemRenderer.GET_TEXT_COLORS(this.category), 0, null, null, false, null, category==ExchangeType.C120_MAGICS?0.8:1.1);
	this.titleDisplay.layoutData = new AnchorLayoutData(20, NaN, NaN, NaN, 0);
	this.addChild(this.titleDisplay);
}
protected function buttonFactory() : void
{
	this.buttonSkin = new ImageSkin(appModel.theme.roundSmallSkin);
	this.buttonSkin.defaultColor = ExCategoryItemRenderer.GET_COLOR(this.category);
	this.buttonSkin.setColorForState(STATE_SELECTED, this.buttonSkin.defaultColor);
	this.buttonSkin.setColorForState(STATE_NORMAL, this.buttonSkin.defaultColor);
	this.buttonSkin.setColorForState(STATE_DOWN, 0xFFFFFF);
	this.buttonSkin.scale9Grid = MainTheme.ROUND_SMALL_SCALE9_GRID;

	this.buttonDisplay = new MMOryButton();
	this.buttonDisplay.height = 82;
	this.buttonDisplay.iconOffsetY = 5;
	this.buttonDisplay.isEnabled = false;
	this.buttonDisplay.disabledSkin = buttonSkin;
	this.buttonDisplay.iconSize = MMOryButton.DEFAULT_ICON_SIZE;
	this.buttonDisplay.layoutData = new AnchorLayoutData(NaN, 20, 42, 20);
	this.buttonDisplay.labelFactory = this.buttonLabelFactory;
	this.addChild(this.buttonDisplay);
}
protected function buttonLabelFactory() : ITextRenderer
{
	return new ShadowLabel(null, 1, 0, "center", null, false, null, 0.9);
}
}
}