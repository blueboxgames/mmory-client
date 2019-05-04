package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.controls.items.AbstractTouchableListItemRenderer;
import com.gerantech.towercraft.controls.segments.lobby.LobbyChatItemSegment;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.MainTheme;
import com.gerantech.towercraft.utils.StrUtils;
import feathers.controls.AutoSizeMode;
import feathers.controls.ImageLoader;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import starling.events.Event;
import starling.events.Touch;

public class InboxChatItemRenderer extends AbstractTouchableListItemRenderer
{
private var myId:int;
private var date:Date;
private var mySkin:ImageLoader;
private var whoSkin:ImageLoader;
private var textDisplay:RTLLabel;
private var dateDisplay:RTLLabel;
private var statusDisplay:ImageLoader;
private var textLayout:AnchorLayoutData;
private var dateLayout:AnchorLayoutData;
private var statusLayout:AnchorLayoutData;
private var mySkinLayout:AnchorLayoutData;
private var whoSkinLayout:AnchorLayoutData;

public function InboxChatItemRenderer(myId:int){ this.myId = myId; }
public function getTouch():Touch
{
	return touch;
}
override protected function initialize():void
{
	super.initialize();
	
	height = 200;
	layout			= new AnchorLayout();
	autoSizeMode	= AutoSizeMode.CONTENT;
	mySkinLayout	= new AnchorLayoutData(0, 0,	0,	120);
	whoSkinLayout	= new AnchorLayoutData(0, 120,	0,	0  );
	
	date = new Date();

	mySkin = new ImageLoader();
	mySkin.visible = false;
	mySkin.layoutData = mySkinLayout;
	mySkin.scale9Grid = LobbyChatItemSegment.BALLOON_RECT;
	mySkin.source = Assets.getTexture("socials/balloon-me", "gui");
	addChild(mySkin);
	
	whoSkin = new ImageLoader();
	whoSkin.visible = false;
	whoSkin.layoutData = whoSkinLayout;
	whoSkin.scale9Grid = LobbyChatItemSegment.BALLOON_RECT;
	whoSkin.source = Assets.getTexture("socials/balloon-who", "gui");
	addChild(whoSkin);
	
	statusLayout = new AnchorLayoutData(NaN, NaN, 35);
	statusDisplay = new ImageLoader();
	statusDisplay.height = 24;
	statusDisplay.layoutData = statusLayout;
	addChild(statusDisplay);
	
	textLayout = new AnchorLayoutData(20);
	textDisplay = new RTLLabel("", MainTheme.PRIMARY_BACKGROUND_COLOR, "justify", null, true, null, 0.65, "OpenEmoji");
	if( appModel.platform == AppModel.PLATFORM_ANDROID || appModel.platform == AppModel.PLATFORM_IOS )
		textDisplay.leading = -12;
	textDisplay.layoutData = textLayout;
	addChild(textDisplay);

	dateLayout = new AnchorLayoutData(NaN, NaN, 30);
	dateDisplay = new RTLLabel("", MainTheme.DESCRIPTION_TEXT_COLOR, null, null, false, null, 0.5, "OpenEmoji");
	dateDisplay.layoutData = dateLayout;			
	addChild(dateDisplay);
}

override protected function commitData():void
{
	super.commitData();
	if( _data == null )
		return;
	
	var itsMe:Boolean = _data.getInt("senderId") == myId;
	
	mySkin.visible = itsMe;
	whoSkin.visible = !itsMe;
	
	statusDisplay.visible = itsMe && _data.containsKey("status");
	if( statusDisplay.visible )
	{
		statusLayout.left =	( itsMe ? mySkinLayout.left  : whoSkinLayout.left  ) + 40;
		statusDisplay.source = Assets.getTexture("socials/check-blue-" + _data.getInt("status"), "gui");
	}

	textLayout.right =	( itsMe ? mySkinLayout.right : whoSkinLayout.right ) + 50;
	textLayout.left =	( itsMe ? mySkinLayout.left  : whoSkinLayout.left  ) + 50;
	textDisplay.text = _data.getUtfString("text");
	textDisplay.validate();
	height = textLayout.top + textDisplay.height + 90;
	
	date.time = _data.getLong("timestamp");
	dateDisplay.text = StrUtils.getDateString(date, true);
	dateLayout.right = (itsMe ? mySkinLayout.right : whoSkinLayout.right) + 50;
}
}
}