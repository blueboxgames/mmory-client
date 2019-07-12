package com.gerantech.towercraft.controls
{
import com.gerantech.mmory.core.constants.CardTypes;

import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
public class BattleDeckCard extends TowersLayout
{
private var _type:int;
private var cardView:CardView;
public function BattleDeckCard(type:int)
{
	super();
	touchGroup = true;
	this.type = type;
}

override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout();
	
	cardView = new CardView();
	cardView.type = this._type;
	cardView.showElixir = true;
	cardView.height = width * CardView.VERICAL_SCALE;
	cardView.layoutData = new AnchorLayoutData(0, 0, NaN, 0);
	addChild(cardView);
}

public function updateData():void
{
	isEnabled = appModel.battleFieldView.battleData.getAlliseEllixir() >= cardView.elixir;
}

public function set type(value:int) : void 
{
	this._type = value;
	if( cardView != null )
		cardView.type = this._type;	
}
public function get type() : int 
{
	return this._type;
}

override public function set isEnabled(value:Boolean) : void 
{
	if( super.isEnabled == value )
		return;
	super.isEnabled = value;
	touchable = value;
	cardView.availablity = value ? CardTypes.AVAILABLITY_EXISTS : CardTypes.AVAILABLITY_WAIT;
}
}
}