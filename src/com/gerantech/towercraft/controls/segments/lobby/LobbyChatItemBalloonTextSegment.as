package com.gerantech.towercraft.controls.segments.lobby
{
import com.gerantech.towercraft.controls.FastList;
import com.gerantech.towercraft.models.AppModel;
import com.smartfoxserver.v2.entities.data.ISFSObject;

import feathers.controls.text.TextBlockTextRenderer;
import feathers.layout.AnchorLayoutData;

import flash.text.engine.ElementFormat;
import flash.text.engine.FontDescription;

public class LobbyChatItemBalloonTextSegment extends LobbyChatItemBalloonSegment
{
private var textLayout:AnchorLayoutData;
private var textDisplay:TextBlockTextRenderer;
// static private const textJustifier:SpaceJustifier = new SpaceJustifier(AppModel.instance.isLTR?"en":"fa", LineJustification.ALL_BUT_MANDATORY_BREAK);
static private const fontDescription:FontDescription = new FontDescription("OpenEmoji", "normal", "normal", "device");
static public const  myFormat:ElementFormat = new ElementFormat(fontDescription, AppModel.instance.theme.gameFontSize * 0.6, 0x394144);
static public const whoFormat:ElementFormat = new ElementFormat(fontDescription, AppModel.instance.theme.gameFontSize * 0.6, 0xe9f3fc);
public function LobbyChatItemBalloonTextSegment(owner:FastList) { super(owner); }

override public function init():void
{
	super.init();

	textDisplay = new TextBlockTextRenderer();	
	textDisplay.textAlign = appModel.align;
	textDisplay.bidiLevel = appModel.isLTR ? 0 : 1;
	textDisplay.wordWrap = true;
	if( appModel.platform == AppModel.PLATFORM_ANDROID || appModel.platform == AppModel.PLATFORM_IOS )
		textDisplay.leading = -12;
	textLayout = new AnchorLayoutData(70);
	textDisplay.layoutData = textLayout;
	addChild(textDisplay);
}

override public function commitData(_data:ISFSObject, index:int):void
{
/* 	if( owner.loadingState == 0 && owner.dataProvider.length - index > 10 )
	{
		height = 200;
		return;
	}*/
		
	super.commitData(_data, index);

	textDisplay.elementFormat = itsMe ? myFormat : whoFormat;
	textDisplay.text = data.getUtfString("t");

	textLayout.right =	( itsMe ? mySkinLayout.right : whoSkinLayout.right ) + 50;
	textLayout.left =		( itsMe ? mySkinLayout.left  : whoSkinLayout.left  ) + 50;
	textDisplay.validate();
	
	height = textDisplay.height + textLayout.top + 15;
}
}
}