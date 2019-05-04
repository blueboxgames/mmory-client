package com.gerantech.towercraft.controls
{
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import starling.filters.ColorMatrixFilter;
public class BattleDeckCard extends TowersLayout
{
public var cardType:int;
private var cardView:BuildingCard;
private var _filter:ColorMatrixFilter;
public function BattleDeckCard(cardType:int)
{
	super();
	touchGroup = true;
	this.cardType = cardType;
	_filter = new ColorMatrixFilter();
	_filter.adjustSaturation(-1);
}

override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout();
	
	cardView = new BuildingCard(false, false, false, true);
	cardView.layoutData = new AnchorLayoutData(0, 0, NaN, 0);
	addChild(cardView);
	cardView.setData(cardType);
}

public function updateData():void
{
	isEnabled = appModel.battleFieldView.battleData.getAlliseEllixir() >= cardView.elixirSize;
}

public function setData(cardType:int) : void 
{
	this.cardType = cardType;
	if( cardView != null )
		cardView.setData(cardType);	
}

override public function set isEnabled(value:Boolean) : void 
{
	if( super.isEnabled == value )
		return;
	super.isEnabled = value;
	touchable = value;
	cardView.filter = value ? null : _filter;
}
}
}