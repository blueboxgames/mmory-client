package com.gerantech.towercraft.controls.items 
{
import com.gerantech.towercraft.controls.segments.ChatSegment;
import com.gerantech.towercraft.controls.segments.lobby.LobbyChatItemSegment;
import com.gerantech.towercraft.models.Assets;
import dragonBones.starling.StarlingArmatureDisplay;
import feathers.layout.TiledRowsLayout;
import starling.display.Image;
/**
* ...
* @author Mansour Djawadi
*/
public class EmoteItemRenderer extends AbstractTouchableListItemRenderer 
{
private var emoteArmature:StarlingArmatureDisplay;

public function EmoteItemRenderer() 
{
	super();
	
	var background:Image = new Image(Assets.getTexture("socials/balloon", "gui"));
	background.scale9Grid = LobbyChatItemSegment.BALLOON_RECT;
	backgroundSkin = background;
	
	emoteArmature = ChatSegment.factory.buildArmatureDisplay("emote");
	emoteArmature.scale = 0.7;
	emoteArmature.touchable = false;
	addChild(emoteArmature);
}

override protected function commitData() : void
{
	super.commitData();
	width = TiledRowsLayout(_owner.layout).typicalItemWidth;
	height = TiledRowsLayout(_owner.layout).typicalItemHeight;

	emoteArmature.x = width * 0.5;
	emoteArmature.y = height - 20;
	emoteArmature.animation.gotoAndStopByFrame("st-" + data);	
}
}
}