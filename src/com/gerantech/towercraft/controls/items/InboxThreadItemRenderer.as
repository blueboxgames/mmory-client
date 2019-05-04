package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.vo.InboxThread;
import com.gerantech.towercraft.themes.MainTheme;
import com.gerantech.towercraft.utils.StrUtils;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSObject;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import starling.display.Image;

public class InboxThreadItemRenderer extends AbstractTouchableListItemRenderer
{
private var senderDisplay:ShadowLabel;
private var messageDisplay:RTLLabel;
private var dateDisplay:RTLLabel;
private var inData:InboxThread;
private var date:Date;

public function InboxThreadItemRenderer() {}
override protected function initialize():void
{
	super.initialize();
	
	layout = new AnchorLayout();
	height = 160;
	date = new Date();
	
	var mySkin:Image = new Image(appModel.theme.itemRendererUpSkinTexture);
	mySkin.scale9Grid = MainTheme.ITEM_RENDERER_SCALE9_GRID;
	backgroundSkin = mySkin;
	
	senderDisplay = new ShadowLabel("", 1, 0, null, null, false, null, 0.8);
	senderDisplay.layoutData = new AnchorLayoutData(16, appModel.isLTR?NaN:24, NaN, appModel.isLTR?24:NaN);
	senderDisplay.width = 760;
	addChild(senderDisplay);

	messageDisplay = new RTLLabel("", 0, null, null, false, null, 0.6);
	messageDisplay.touchable = false;
	messageDisplay.truncateToFit = true;
	messageDisplay.layoutData = new AnchorLayoutData(NaN, 24, 24, 24);
	addChild(messageDisplay);
	
	dateDisplay = new RTLLabel("", 0, null, null, false, null, 0.6);
	dateDisplay.touchable = false;
	dateDisplay.layoutData = new AnchorLayoutData(20, appModel.isLTR?20:NaN, NaN, appModel.isLTR?NaN:20);
	addChild(dateDisplay);
}

override protected function commitData():void
{
	super.commitData();
	if( _data == null || _owner == null )
		return;

	inData = new InboxThread(_data);
	date.time = inData.timestamp;
	var txt:String = inData.text.split("\n").join(". ");
	messageDisplay.text = txt.substr(0, 2) == "__"?loc(txt.substr(2), [inData.owner]):txt;
	dateDisplay.text = StrUtils.getDateString(date);
	senderDisplay.text = inData.owner;
//	updateSkin();
}

private function updateSkin():void
{
	/*switch( message.getShort("status") )
	{
		case 1:		mySkin.texture = appModel.theme.itemRendererDisabledSkinTexture; break;
		case 2:		mySkin.texture = appModel.theme.itemRendererDangerSkinTexture; break;
		default:	mySkin.texture = appModel.theme.itemRendererSelectedSkinTexture; break;
	}*/
	senderDisplay.alpha = _data.status == 0 ? 1 : 0.8;
	messageDisplay.alpha = _data.status == 0 ? 0.92 : 0.8;
}
}
}