package com.gerantech.towercraft.controls.segments.lobby
{
import com.gerantech.towercraft.controls.FastList;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.MainTheme;
import com.gerantech.towercraft.utils.StrUtils;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import feathers.controls.AutoSizeMode;
import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayoutData;
import flash.geom.Rectangle;

public class LobbyChatItemBalloonSegment extends LobbyChatItemSegment
{
protected var senderDisplay:RTLLabel;
//protected var roleDisplay:RTLLabel;
protected var dateDisplay:RTLLabel;

protected var mySkin:ImageLoader;
protected var whoSkin:ImageLoader;

protected var date:Date;
protected var senderLayout:AnchorLayoutData;
//protected var roleLayout:AnchorLayoutData;
protected var mySkinLayout:AnchorLayoutData;
protected var whoSkinLayout:AnchorLayoutData;
protected var dateLayout:AnchorLayoutData;

public function LobbyChatItemBalloonSegment(owner:FastList) { super(owner); }
override public function init():void
{
	super.init();
	autoSizeMode	= AutoSizeMode.CONTENT;
	mySkinLayout	= new AnchorLayoutData(0, 0,	0,	120);
	whoSkinLayout	= new AnchorLayoutData(0, 120,	0,	0  );
	
	date = new Date();
	var padding:int = 20;

	mySkin = new ImageLoader();
	mySkin.visible = false;
	mySkin.layoutData = mySkinLayout;
	mySkin.scale9Grid = LobbyChatItemSegment.BALLOON_RECT;
	mySkin.source = Assets.getTexture("socials/balloon-me", "gui");
	addChild(mySkin);
	
	whoSkin = new ImageLoader();
	whoSkin.scale9Grid = LobbyChatItemSegment.BALLOON_RECT;
	whoSkin.visible = false;
	whoSkin.layoutData = whoSkinLayout;
	whoSkin.source = Assets.getTexture("socials/balloon-who", "gui");
	addChild(whoSkin);
	
	senderDisplay = new RTLLabel("", MainTheme.PRIMARY_BACKGROUND_COLOR, null, null, false, null, 0.7);
	senderLayout = new AnchorLayoutData(padding);
	senderDisplay.layoutData = senderLayout;
	addChild(senderDisplay);
	
/*	roleDisplay = new RTLLabel("", MainTheme.PRIMARY_BACKGROUND_COLOR, null, null, false, null, 0.7);
	roleLayout = new AnchorLayoutData( padding );
	roleDisplay.layoutData = roleLayout;
	addChild(roleDisplay);*/
	
	dateLayout = new AnchorLayoutData(padding);
	dateDisplay = new RTLLabel("", MainTheme.DESCRIPTION_TEXT_COLOR, null, null, false, null, 0.5, "OpenEmoji");
	dateDisplay.layoutData = dateLayout;			
	addChild(dateDisplay);
}

override public function commitData(_data:ISFSObject, index:int):void
{
	super.commitData(_data, index);
	
	mySkin.visible = itsMe;
	whoSkin.visible = !itsMe;
	
	senderDisplay.text = data.getUtfString("s");
	senderLayout.right = (itsMe ? mySkinLayout.right : whoSkinLayout.right) + 50;
	
	//roleDisplay.text = user == null?"":(loc("lobby_role_" + user.getShort("permission")));
	//roleLayout.left = ( itsMe ? otherPadding : padding ) + inPadding;
	
	date.time = data.getInt("u") * 1000;
	dateDisplay.text = StrUtils.dateToTime(date);
	dateLayout.left = (itsMe ? mySkinLayout.left : whoSkinLayout.left) + 40;
}
}
}