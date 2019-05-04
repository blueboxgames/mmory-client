package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.models.Assets;
import com.gt.towers.constants.CardTypes;
import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.TiledRowsLayout;
import feathers.skins.ImageSkin;
import flash.geom.Rectangle;
import starling.core.Starling;

public class ProfileBuildingItemRenderer extends AbstractTouchableListItemRenderer
{
public var showLevel:Boolean;
private var _firstCommit:Boolean = true;
private var _width:Number;
private var _height:Number;
private var padding:int;
private var iconDisplay:ImageLoader;
private var levelDisplay:RTLLabel;
private var mySkin:ImageSkin;
private var improveDisplay:ImageLoader;

public function ProfileBuildingItemRenderer(showLevel:Boolean = true)
{
	this.showLevel = showLevel;
	super();
}

override protected function initialize():void
{
	super.initialize();
	alpha = 0;
	
	mySkin = new ImageSkin(Assets.getTexture("theme/building-button"));
	mySkin.setTextureForState("normal", Assets.getTexture("theme/building-button"));
	mySkin.setTextureForState("locked", Assets.getTexture("theme/building-button-disable"));
	mySkin.scale9Grid = new Rectangle(20, 20, 112, 74);
	backgroundSkin = mySkin;
	
	layout= new AnchorLayout();
	padding = 12;
}

override protected function commitData():void
{
	if( _data == null )
		return;
	
	if(_firstCommit)
	{
		width = _width = TiledRowsLayout(_owner.layout).typicalItemWidth;
		height = _height = TiledRowsLayout(_owner.layout).typicalItemHeight;
		_firstCommit = false;
	}
	super.commitData();

	createIcon(_data.type, _data.level);
	createLevel(_data.level);
	mySkin.defaultTexture = mySkin.getTextureForState(_data.level > 0?"normal":"locked");
	Starling.juggler.tween(this, 0.2, {delay:0.05 * index, alpha:1});
}

private function createLevel(level:int):void
{
	if( !showLevel || level <= 0 )
		return;
	if( levelDisplay == null )
	{
		levelDisplay = new RTLLabel("" + level, 0, "center", null, false, null, 0.7);
		levelDisplay.alpha = 0.8;
		levelDisplay.height = height * 0.25;
		levelDisplay.layoutData = new AnchorLayoutData(NaN, padding, padding, padding);
		addChild(levelDisplay);
	}
	else
	{
		levelDisplay.text = ""+ level;
	}
}

private function createIcon(type:int, level:int):void
{
	if( iconDisplay == null )
	{
		iconDisplay = new ImageLoader();
		iconDisplay.pixelSnapping = false;
		iconDisplay.maintainAspectRatio = false;
		iconDisplay.layoutData = new AnchorLayoutData(padding, padding, padding * 1.2, padding);
		addChild(iconDisplay);			
	}
	iconDisplay.source = Assets.getTexture("cards/" + CardTypes.get_category(type), "gui");
	iconDisplay.alpha = level > 0 ? 1 : 0.6;
	
	if( improveDisplay == null )
	{
		improveDisplay = new ImageLoader();
		improveDisplay.width = padding * 5;
		improveDisplay.layoutData = new AnchorLayoutData(padding, padding, padding * 1.2, padding);
		addChild(improveDisplay);
	}
	improveDisplay.source = Assets.getTexture("cards/" + type, "gui");
	improveDisplay.alpha = level > 0 ? 1 : 0.4;
}
}
}