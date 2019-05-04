package com.gerantech.towercraft.controls.buttons 
{
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.utils.StrUtils;
import com.gt.towers.constants.ResourceType;
import feathers.controls.ButtonState;
import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayoutData;
import starling.textures.Texture;
/**
* ...
* @author Mansour Djawadi
*/
public class DiscountButton extends ExchangeButton 
{
	private var _originCount:int;
	private var originLayoutData:AnchorLayoutData;
	private var originDisplay:RTLLabel;

public function DiscountButton() 
{
	super();
	height = maxHeight = 140;
	labelLayoutData = new AnchorLayoutData(NaN, padding, NaN, padding, NaN, 0);
	originLayoutData = new AnchorLayoutData(NaN, padding * 5, NaN, padding * 5, NaN, -padding * 4.0);
}

override protected function initialize():void
{
	originDisplay = new RTLLabel(StrUtils.getCurrencyFormat(_originCount), 0xBB0000, "center");
	originDisplay.layoutData = originLayoutData;
	addChild(originDisplay);
	
	var priceLine:ImageLoader = new ImageLoader();
	priceLine.source = Assets.getTexture("shop/discount-line", "gui");
	priceLine.layoutData = new AnchorLayoutData(NaN, padding * 5, NaN, padding * 5, NaN, -padding * 4.0);
	addChild(priceLine);
	
	super.initialize();
}

override public function set type(value:int):void
{
	if( super.type == value )
		return;
	super.type = value;
	
	var hasIcon:Boolean = value > 0 && value != ResourceType.R5_CURRENCY_REAL;
	if( hasIcon )
		icon = Assets.getTexture("res-" + value, "gui");;
}

override public function set icon(value:Texture):void
{
	super.icon = value;
	originLayoutData.right = (super.icon == null?5:14) * padding;
}

override public function set currentState(value:String):void
{
	if( super.currentState == value )
		return;
	
	super.currentState = value;
	setInvalidationFlag(INVALIDATION_FLAG_ALL);
}

public function get originCount():int 
{
	return _originCount;
}
public function set originCount(value:int):void 
{
	if( _originCount == value )
		return;
	_originCount = value;
	if( originDisplay != null )
		originDisplay.text = StrUtils.getCurrencyFormat(_originCount);
}
}
}