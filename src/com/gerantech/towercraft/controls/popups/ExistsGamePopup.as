package com.gerantech.towercraft.controls.popups
{
import com.gerantech.towercraft.controls.items.ExistGamesListItemRenderer;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.vo.UserData;
import com.smartfoxserver.v2.entities.data.SFSObject;

import feathers.controls.renderers.IListItemRenderer;
import feathers.layout.AnchorLayoutData;

import starling.events.Event;
import com.gerantech.towercraft.models.AppModel;


public class ExistsGamePopup extends SimpleListPopup
{

public function ExistsGamePopup(buttons:Array)
{
	super(buttons);
	this.buttonsWidth = 750;
	this.paddingTop = 280;
	this.padding = 36;
}
override protected function initialize():void
{
	if( this.buttons.length < 3 || appModel.platform == AppModel.PLATFORM_WINDOWS )
	{
		var newGame:SFSObject = new SFSObject();
		newGame.putUtfString("name", loc("popup_user_exists_button"));
		newGame.putLong("id", -2);
		newGame.putText("password", "");
		this.buttons.push(newGame);
	}

	super.initialize();
	list.itemRendererFactory = function ():IListItemRenderer { return new ExistGamesListItemRenderer(buttonHeight); };
	this.closeOnOverlay = this.closeOnStage = this.closeWithKeyboard = false;

	var titleDisplay:ShadowLabel = new ShadowLabel(loc("popup_user_exists"), 0xDDFFFF, 0, "center", null, true, "center", 0.9);
	titleDisplay.layoutData = new AnchorLayoutData(paddingTop * 0.1, NaN, NaN, NaN, 0);
	addChild(titleDisplay);
}

override protected function list_changeHandler(event:Event):void
{
	var item:SFSObject = list.selectedItem as SFSObject;
	UserData.instance.id = item.getLong("id");
	UserData.instance.password = item.getText("password");
	UserData.instance.save();
	dispatchEventWith(Event.SELECT, false, item);
	close();
}
}
}