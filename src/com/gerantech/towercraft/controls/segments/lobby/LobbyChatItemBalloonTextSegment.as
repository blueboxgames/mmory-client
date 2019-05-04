package com.gerantech.towercraft.controls.segments.lobby
{
import com.gerantech.towercraft.controls.FastList;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.themes.MainTheme;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import feathers.layout.AnchorLayoutData;

public class LobbyChatItemBalloonTextSegment extends LobbyChatItemBalloonSegment
{
private var textDisplay:RTLLabel;
private var textLayout:AnchorLayoutData;

public function LobbyChatItemBalloonTextSegment(owner:FastList) { super(owner); }
override public function init():void
{
	super.init();
	
	textDisplay = new RTLLabel(null, MainTheme.PRIMARY_BACKGROUND_COLOR, "justify", null, true, null, 0.65, "OpenEmoji");
	if( appModel.platform == AppModel.PLATFORM_ANDROID || appModel.platform == AppModel.PLATFORM_IOS )
		textDisplay.leading = -12;
	textLayout = new AnchorLayoutData(80);
	textDisplay.layoutData = textLayout;
	addChild(textDisplay);
}

override public function commitData(_data:ISFSObject, index:int):void
{
	if( owner.loadingState == 0 && owner.dataProvider.length - index > 10 )
	{
		height = 200;
		return;
	}
	
	super.commitData(_data, index);

	textLayout.right =	( itsMe ? mySkinLayout.right : whoSkinLayout.right ) + 50;
	textLayout.left =	( itsMe ? mySkinLayout.left  : whoSkinLayout.left  ) + 50;
	textDisplay.text = data.getUtfString("t");
	textDisplay.validate();
	
	height = textDisplay.height + textLayout.top + 40;
}
}
}