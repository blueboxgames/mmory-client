package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.themes.MainTheme;
import com.gerantech.towercraft.utils.StrUtils;
import com.smartfoxserver.v2.entities.data.SFSObject;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import starling.display.Image;

public class BanMessageItemRenderer extends AbstractTouchableListItemRenderer
{
static private var date:Date = new Date();
static private var now:Number = date.time;
private var msg:SFSObject;
private var mySkin:Image;
private var playerDisplay:RTLLabel;
private var messageDisplay:RTLLabel;
public function BanMessageItemRenderer(){}
override protected function initialize():void
{
	super.initialize();
	
	layout = new AnchorLayout();
	height = 340;
	
	mySkin = new Image(appModel.theme.itemRendererDisabledSkinTexture);
	mySkin.scale9Grid = MainTheme.ITEM_RENDERER_SCALE9_GRID;
	backgroundSkin = mySkin;
	
	playerDisplay = new RTLLabel("", 1, null, "ltr", false, "justify", 0.6);
	playerDisplay.layoutData = new AnchorLayoutData(12, 32, NaN, 32);
	addChild(playerDisplay);

	messageDisplay = new RTLLabel("", 0xAADDDD, "justify", null, true, null, 0.5);
	messageDisplay.layoutData = new AnchorLayoutData(64, 32, 32, 32);
	addChild(messageDisplay);
}

override protected function commitData():void
{
	super.commitData();
	if( _data == null || _owner == null )
		return;
	msg = _data as SFSObject;
	date.time = msg.getLong("expire_at");
	var expireAt:String = StrUtils.getDateString(date);
	date.time = msg.getLong("timestamp");
	var timestamp:String = StrUtils.getDateString(date);
	playerDisplay.text = msg.getUtfString("name") + "  =>    exp:" + expireAt + "   time:" + timestamp + "   mode:" + msg.getInt("mode") + "   count:" + msg.getInt("time");;
	messageDisplay.text = msg.getUtfString("message");
	mySkin.texture = msg.getLong("expire_at") > now ? appModel.theme.itemRendererDangerSkinTexture : appModel.theme.itemRendererUpSkinTexture;
}
}
}