package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.models.vo.InboxThread;
import com.gerantech.towercraft.themes.MainTheme;
import com.gerantech.towercraft.utils.StrUtils;

import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.skins.ImageSkin;

public class InboxThreadItemRenderer extends AbstractTouchableListItemRenderer
{
private var mySkin:ImageSkin;
private var inData:InboxThread;
private var dateDisplay:RTLLabel;
private var senderDisplay:RTLLabel;
private var messageDisplay:RTLLabel;

public function InboxThreadItemRenderer() {}
override protected function initialize():void
{
	super.initialize();
	
	layout = new AnchorLayout();
	height = 160;
	
	mySkin = new ImageSkin(appModel.theme.itemRendererBulgyUpSkinTexture);
	mySkin.setTextureForState(STATE_NORMAL,		appModel.theme.itemRendererBulgyUpSkinTexture);
	mySkin.setTextureForState(STATE_SELECTED,	appModel.theme.itemRendererBulgySelectedSkinTexture);
	mySkin.setTextureForState(STATE_DISABLED,	appModel.theme.itemRendererBulgyDangerSkinTexture);
	mySkin.scale9Grid = MainTheme.ITEM_RENDERER_BULGY_SCALE9_GRID;
	backgroundSkin = mySkin;
	
	senderDisplay = new RTLLabel(null, 0x3d3d3d, null, null, false, null, 0.8);
	senderDisplay.layoutData = new AnchorLayoutData(15, appModel.isLTR?NaN:24, NaN, appModel.isLTR?24:NaN);
	senderDisplay.width = 760;
	addChild(senderDisplay);

	messageDisplay = new RTLLabel(null, 0x5f5f5f, null, null, false, null, 0.55);
	messageDisplay.touchable = false;
	messageDisplay.truncateToFit = true;
	messageDisplay.layoutData = new AnchorLayoutData(NaN, 24, 36, 24);
	addChild(messageDisplay);
	
	dateDisplay = new RTLLabel(null, 0x5f5f5f, null, null, false, null, 0.5);
	dateDisplay.touchable = false;
	dateDisplay.layoutData = new AnchorLayoutData(15, appModel.isLTR?15:NaN, NaN, appModel.isLTR?NaN:20);
	addChild(dateDisplay);
}

override protected function commitData():void
{
	super.commitData();
	if( _data == null || _owner == null )
		return;
	
	inData = new InboxThread(_data);
	var txt:String = inData.text.split("\n").join(". ");
	messageDisplay.text = txt.substr(0, 2) == "__"?loc(txt.substr(2), [inData.owner]):txt;
	dateDisplay.text = StrUtils.toElapsed(timeManager.now-inData.timestamp/1000);
	senderDisplay.text = inData.owner;
	updateSkin();
}

private function updateSkin():void
{
	trace(inData.owner, inData.isSender, inData.status);
	switch( inData.status )
	{
		case 1:		mySkin.defaultTexture = mySkin.getTextureForState(STATE_NORMAL);		break;
		case 2:		mySkin.defaultTexture = mySkin.getTextureForState(STATE_DISABLED);	break;
		default:	mySkin.defaultTexture = mySkin.getTextureForState(STATE_SELECTED);	break;
	}
}
}
}