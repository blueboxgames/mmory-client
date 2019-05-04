package com.gerantech.towercraft.controls.groups
{
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.MainTheme;
import feathers.controls.LayoutGroup;
import flash.geom.Rectangle;
import starling.display.Image;

public class Devider extends LayoutGroup
{
public function Devider(color:uint = 0, size:uint = 1)
{
	if( size < 1 )
		size = 1;
	backgroundSkin = new Image(AppModel.instance.theme.quadSkin);
	Image(backgroundSkin).scale9Grid = MainTheme.QUAD_SCALE9_GRID;
	Image(backgroundSkin).color = color;
}
}
}