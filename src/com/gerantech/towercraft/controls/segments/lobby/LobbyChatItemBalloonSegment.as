package com.gerantech.towercraft.controls.segments.lobby
{
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.utils.StrUtils;
import com.smartfoxserver.v2.entities.data.ISFSObject;

import feathers.controls.AutoSizeMode;
import feathers.controls.ImageLoader;
import feathers.controls.List;
import feathers.controls.text.TextBlockTextRenderer;
import feathers.layout.AnchorLayoutData;

import flash.filters.DropShadowFilter;
import flash.filters.GlowFilter;
import flash.geom.Rectangle;
import flash.text.engine.ElementFormat;
import flash.text.engine.FontDescription;

public class LobbyChatItemBalloonSegment extends LobbyChatItemSegment
{
protected var senderDisplay:TextBlockTextRenderer;
protected var dateDisplay:RTLLabel;
//protected var roleDisplay:RTLLabel;

protected var mySkin:ImageLoader;
protected var whoSkin:ImageLoader;

protected var senderLayout:AnchorLayoutData;
//protected var roleLayout:AnchorLayoutData;
protected var mySkinLayout:AnchorLayoutData;
protected var whoSkinLayout:AnchorLayoutData;
protected var dateLayout:AnchorLayoutData;

static public const MY_SCALEGRID:Rectangle = new Rectangle(18, 68, 2, 2);
static public const WHO_SCALEGRID:Rectangle = new Rectangle(44, 68, 2, 2);
// static private const textJustifier:SpaceJustifier = new SpaceJustifier(AppModel.instance.isLTR?"en":"fa", LineJustification.ALL_BUT_MANDATORY_BREAK);
static private const fontDescription:FontDescription = new FontDescription("SourceSansPro", "bold", "normal", "embeddedCFF");
static public const mySFormat:ElementFormat = new ElementFormat(fontDescription, AppModel.instance.theme.gameFontSize * 0.6, 0xFFFFFF);
static public const whSFormat:ElementFormat = new ElementFormat(fontDescription, AppModel.instance.theme.gameFontSize * 0.6, 0xAFDCFC);

public function LobbyChatItemBalloonSegment(owner:List) { super(owner); }
override public function init():void
{
	super.init();
	autoSizeMode	= AutoSizeMode.CONTENT;
	mySkinLayout	= new AnchorLayoutData(0, 0,	0,	120);
	whoSkinLayout	= new AnchorLayoutData(0, 120,	0,	0  );
	
	mySkin = new ImageLoader();
	mySkin.visible = false;
	mySkin.layoutData = mySkinLayout;
	mySkin.scale9Grid = LobbyChatItemSegment.BALLOON_RECT;
	mySkin.source = appModel.assets.getTexture("socials/balloon-me");
	addChild(mySkin);
	
	whoSkin = new ImageLoader();
	whoSkin.scale9Grid = LobbyChatItemSegment.BALLOON_RECT;
	whoSkin.visible = false;
	whoSkin.layoutData = whoSkinLayout;
	whoSkin.source = appModel.assets.getTexture("socials/balloon-who");
	addChild(whoSkin);
	
	senderLayout = new AnchorLayoutData(16);
	senderDisplay = new TextBlockTextRenderer();	
	// senderDisplay.bidiLevel = appModel.isLTR ? 0 : 1;
	senderDisplay.layoutData = senderLayout;
	senderDisplay.nativeFilters = [new GlowFilter(0x00, 1, 3, 3, 3), new DropShadowFilter(2, 90, 0x00, 1, 0, 0) ];
	addChild(senderDisplay);
	
	/*roleDisplay = new RTLLabel(null, MainTheme.PRIMARY_BACKGROUND_COLOR, null, null, false, null, 0.7);
	roleLayout = new AnchorLayoutData( padding );
	roleDisplay.layoutData = roleLayout;
	addChild(roleDisplay);*/
	
	dateLayout = new AnchorLayoutData(8, NaN, NaN, 15);
	dateDisplay = new RTLLabel(null, 0x82B7F8, null, null, false, null, 0.5);
	dateDisplay.layoutData = dateLayout;			
	addChild(dateDisplay);
}

override public function commitData(_data:ISFSObject, index:int):void
{
	super.commitData(_data, index);
	
	mySkin.visible = itsMe;
	whoSkin.visible = !itsMe;
	
	senderDisplay.elementFormat = itsMe ? mySFormat : whSFormat;
	senderDisplay.text = data.getUtfString("s");
	senderLayout.right = (itsMe ? mySkinLayout.right : whoSkinLayout.right) + 50;
	
	//roleDisplay.text = user == null?"":(loc("lobby_role_" + user.getInt("permission")));
	//roleLayout.left = ( itsMe ? otherPadding : padding ) + inPadding;
	
	dateDisplay.text = StrUtils.toElapsed(timeManager.now - data.getInt("u"));
	dateLayout.left = (itsMe ? mySkinLayout.left : whoSkinLayout.left) + 40;
}
}
}