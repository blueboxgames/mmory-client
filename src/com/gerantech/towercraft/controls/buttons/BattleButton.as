package com.gerantech.towercraft.controls.buttons 
{
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.vo.UserData;
import com.gerantech.towercraft.utils.StrUtils;
import com.gt.towers.constants.PrefsTypes;
import com.gt.towers.socials.Challenge;
import com.gt.towers.utils.maps.IntIntMap;
import feathers.controls.ButtonState;
import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import flash.geom.Rectangle;
import starling.core.Starling;

/**
* ...
* @author Mansour Djawadi
*/
public class BattleButton extends SimpleLayoutButton 
{
private var label:String;
private var background:String;
private var scale9Grid:Rectangle;
private var shadowRect:Rectangle;
private var backgroundDisplay:ImageLoader;
private var labelDisplay:ShadowLabel;
private var _x:Number;
private var _y:Number;
private var _width:Number;
private var _height:Number;

public function BattleButton(background:String, label:String, x:Number, y:Number, width:Number, height:Number, scale9Grid:Rectangle = null, shadowRect:Rectangle = null) 
{
	super();
	this.label = label;
	this.background = background;
	this.scale9Grid = scale9Grid;
	this.shadowRect = shadowRect;
	_x = this.x = x;
	_y = this.y = y;
	_width = this.width = width;
	_height = this.height = height;
	pivotY = this.height * 0.5;
}

override protected function initialize() : void
{
	super.initialize();
	layout = new AnchorLayout();
	
	backgroundDisplay = new ImageLoader();
	backgroundDisplay.source = Assets.getTexture("home/" + background, "gui");
	if( scale9Grid != null )
		backgroundDisplay.scale9Grid = scale9Grid;
	if( shadowRect != null )
		backgroundDisplay.layoutData = new AnchorLayoutData(-shadowRect.y, -shadowRect.width, -shadowRect.height, -shadowRect.x);
	else
		backgroundDisplay.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	addChild(backgroundDisplay);

	// cost elements ....
	var cost:IntIntMap = Challenge.getRunRequiements(UserData.instance.challengeIndex);
	var costType:int = cost.keys()[0];
	var costValue:int = cost.get(costType);

	labelDisplay = new ShadowLabel(label, 1, 0, "center", null, false, null, 1.5);
	labelDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, costValue > 0 ? -40 : -10);
	addChild(labelDisplay);
	if( costValue <= 0 )
		return;
	
	var costBGDisplay:ImageLoader = new ImageLoader();
	costBGDisplay.source = Assets.getTexture("home/button-battle-footer", "gui");
	costBGDisplay.layoutData = new AnchorLayoutData(NaN, 100, 18, 100);
	costBGDisplay.scale9Grid = new Rectangle(29, 42, 2, 1);
	costBGDisplay.height = 80
	addChild(costBGDisplay);

	var costIconDisplay:ImageLoader = new ImageLoader();
	costIconDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 30, 73);
	costIconDisplay.source = Assets.getTexture("res-" + costType, "gui");
	costIconDisplay.width = costIconDisplay.height = 76;
	costIconDisplay.touchable = false;
	addChild(costIconDisplay);

	var costLabelDisplay:ShadowLabel = new ShadowLabel(StrUtils.getNumber(costValue), 1, 0, null, null, false, null, 1.1);
	costLabelDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, -30, 76);
	costLabelDisplay.touchable = false;
	addChild(costLabelDisplay);
}

/**
 * Triggers the button.
 */
override protected function trigger() : void
{
	if( player.getTutorStep() >= PrefsTypes.T_018_CARD_UPGRADED )
		super.trigger();
}

override public function set currentState(value:String):void
{
	super.currentState = value;
	if ( value == ButtonState.DOWN )
	{
		this.x = _x + 20;
		this.y = _y + 20;
		this.width = _width - 40;
		this.height = _height - 40;
	}
	else
	{
		this.x = _x;
		this.y = _y;
		this.width = _width;
		this.height = _height;
	}
	if( labelDisplay != null )
		labelDisplay.scale = value == ButtonState.DOWN ? 0.9 : 1;
}
}
}