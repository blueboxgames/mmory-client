package com.gerantech.towercraft.controls.segments.lobby
{
import com.gerantech.towercraft.controls.FastList;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.MainTheme;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import feathers.controls.Button;
import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayoutData;
import starling.display.Image;

public class LobbyChatItemBattleSegment extends LobbyChatItemSegment
{
private var labelDisplay:ShadowLabel;
private var messageDisplay:RTLLabel;
private var actionButton:Button;
private var messageLayout:AnchorLayoutData;
public function LobbyChatItemBattleSegment(owner:FastList) { super(owner); }
override public function init():void
{
	super.init();

	height = 220;
	backgroundFactory();
	
	actionButton = new Button();
	actionButton.width = 240;
	actionButton.height = 120;
	actionButton.styleName = MainTheme.STYLE_BUTTON_SMALL_DANGER;
	actionButton.layoutData = new AnchorLayoutData(NaN, 70, NaN, NaN, NaN, 0);
	addChild(actionButton);
	
	messageDisplay = new RTLLabel("", 0, "center", null, false, null, 0.8);
	messageLayout = new AnchorLayoutData(NaN, actionButton.width + 90, NaN, 20, NaN, 0);
	messageDisplay.layoutData = messageLayout;
	addChild(messageDisplay);
}
override public function commitData(_data:ISFSObject, index:int):void
{
	super.commitData(_data, index);
	actionButton.visible = data.getShort("st") < 2;
	messageLayout.right = data.getShort("st") < 2 ? (actionButton.width + 20) : 10;
	
	if( data.getShort("st") == 0 )
	{
		//actionButton.styleName = itsMe ? "neutral" : "danger";
		actionButton.label = loc( itsMe ? "popup_cancel_label" : "lobby_battle_accept" );
		messageDisplay.text = loc( itsMe ? "lobby_battle_me" : "lobby_battle_request", [data.getUtfString("s")]);
	}
	else if( data.getShort("st") == 1 )
	{
		actionButton.label = loc( "lobby_battle_spectate" );
		messageDisplay.text = loc( "lobby_battle_in", [data.getUtfString("s"), data.getUtfString("o")]);
	}	
	else if( data.getShort("st") == 2 )
	{
		messageDisplay.text = loc( "lobby_battle_ended", [data.getUtfString("s"), data.getUtfString("o")]);
	}
}
}
}