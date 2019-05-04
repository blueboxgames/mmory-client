package com.gerantech.towercraft.controls.animations
{
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.utils.StrUtils;
import feathers.controls.ImageLoader;
import starling.display.Sprite;
import starling.textures.Texture;

public class AchievedItem extends Sprite
{
public function AchievedItem(texture:Texture, count:int, size:int = 130, prefix:String = "")
{
	var labelDisplay:ShadowLabel = new ShadowLabel(prefix + StrUtils.getNumber(count), 1, 0, "right", null, false, null, size);
	labelDisplay.pixelSnapping = false;
	labelDisplay.x = -size * 0.5;
	labelDisplay.y = -size * 0.7;
	addChild(labelDisplay);
	
	var iconDisplay:ImageLoader = new ImageLoader();
	iconDisplay.width = iconDisplay.height = size;
	iconDisplay.source = texture;
	iconDisplay.x = size * 0.5;
	iconDisplay.y = -size * 0.5;
	addChild(iconDisplay);
}
}
}