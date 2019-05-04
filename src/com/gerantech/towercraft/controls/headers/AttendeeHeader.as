package com.gerantech.towercraft.controls.headers
{
import com.gerantech.towercraft.controls.TowersLayout;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.utils.StrUtils;
import com.gt.towers.constants.ResourceType;
import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

public class AttendeeHeader extends TowersLayout
{
private var point:int;
public function AttendeeHeader(name:String, point:int = 0)
{
	super();
	this.name = name;
	this.point = point;
}

override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout();
	
	var nameShadow:ShadowLabel = new ShadowLabel(name, 1, 0, "left", null, false, null, 1.2);
	nameShadow.layoutData = new AnchorLayoutData(0, NaN, NaN, 16);
	addChild(nameShadow);
	
	// point name
	if( point > 0 )
	{
		var pointIcon:ImageLoader = new ImageLoader();
		pointIcon.width = 70;
		pointIcon.source = Assets.getTexture("res-" + ResourceType.R2_POINT, "gui");
		pointIcon.layoutData = new AnchorLayoutData(80, NaN, NaN, 8);
		addChild(pointIcon);
		
		var pointDisplay:ShadowLabel = new ShadowLabel(StrUtils.getNumber(point), 1, 0, "left", null, false, null, 0.9);
		pointDisplay.layoutData = new AnchorLayoutData(80, NaN, NaN, 80);
		addChild(pointDisplay);
	}
}
}
}