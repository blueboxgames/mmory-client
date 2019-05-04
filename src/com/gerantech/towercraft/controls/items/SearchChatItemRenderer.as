package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.MainTheme;
import com.gerantech.towercraft.utils.StrUtils;
import com.smartfoxserver.v2.entities.data.SFSObject;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import starling.display.Image;
import starling.events.Event;

public class SearchChatItemRenderer extends AbstractTouchableListItemRenderer
{
private var padding:int;
private var date:Date;
private var message:SFSObject;
private var playerDisplay:com.gerantech.towercraft.controls.texts.RTLLabel;
private var messageDisplay:com.gerantech.towercraft.controls.texts.RTLLabel;
private var dateDisplay:com.gerantech.towercraft.controls.texts.RTLLabel;

public function SearchChatItemRenderer(){}
override protected function initialize():void
{
	super.initialize();
	this.height = 220;
	
	layout = new AnchorLayout();
	padding = 16;
	date = new Date();
	
	var mySkin:Image = new Image(appModel.theme.itemRendererUpSkinTexture);
	mySkin.scale9Grid = MainTheme.ITEM_RENDERER_SCALE9_GRID;
	backgroundSkin = mySkin;
	
	playerDisplay = new RTLLabel(null, 0, null, null, false, null, 0.6);
	playerDisplay.width = padding * 12;
	playerDisplay.layoutData = new AnchorLayoutData(padding, appModel.isLTR?NaN:padding, NaN, appModel.isLTR?padding:NaN );
	addChild(playerDisplay);

	messageDisplay = new RTLLabel(null, 0, "justify", null, true, null, 0.55);
	messageDisplay.layoutData = new AnchorLayoutData(padding * 4, padding, padding, padding );
	addChild(messageDisplay);
	
	dateDisplay = new RTLLabel(null, 0, "justify", "ltr", false, null, 0.6);
	dateDisplay.touchable = false;
	dateDisplay.alpha = 0.8;
	dateDisplay.layoutData = new AnchorLayoutData(padding, padding, NaN, padding );
	addChild(dateDisplay);
}

override protected function commitData():void
{
	super.commitData();
	if( _data == null || _owner == null )
		return;

	message = _data as SFSObject;
	date.time = message.getLong("u") * 1000;
	dateDisplay.text = StrUtils.getDateString(date, true) + "  -  " + message.getUtfString("ln");
	playerDisplay.text = message.getUtfString("s");
	messageDisplay.text = message.getUtfString("t");
}
}
}