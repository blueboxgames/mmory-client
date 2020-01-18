package com.gerantech.towercraft.controls.popups
{
import com.gerantech.mmory.core.constants.PrefsTypes;
import com.gerantech.towercraft.Game;
import com.gerantech.towercraft.controls.FastList;
import com.gerantech.towercraft.controls.items.SettingsItemRenderer;
import com.gerantech.towercraft.controls.items.exchange.ExCategoryItemRenderer;
import com.gerantech.towercraft.controls.overlays.TransitionData;
import com.gerantech.towercraft.controls.segments.InboxSegment;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.managers.BillingManager;
import com.gerantech.towercraft.managers.SoundManager;
import com.gerantech.towercraft.managers.oauth.OAuthManager;
import com.gerantech.towercraft.models.vo.SettingsData;
import com.gerantech.towercraft.models.vo.UserData;
import com.gerantech.towercraft.utils.Localizations;

import feathers.controls.ScrollBarDisplayMode;
import feathers.controls.ScrollPolicy;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayoutData;

import flash.geom.Rectangle;
import flash.net.URLRequest;
import flash.net.navigateToURL;

import starling.events.Event;

public class SettingsPopup extends SimpleHeaderPopup
{
private var list:FastList;
public function SettingsPopup()
{
	var _h:int = 1400;
	var _p:int = 48;
	transitionIn = new TransitionData();
	transitionOut = new TransitionData();
	transitionOut.destinationAlpha = 0;
	transitionIn.sourceBound = transitionOut.destinationBound = new Rectangle(_p,	stageHeight* 0.5 - _h * 0.4,	stageWidth - _p * 2,	_h * 0.8);
	transitionOut.sourceBound = transitionIn.destinationBound = new Rectangle(_p,	stageHeight* 0.5 - _h * 0.5,	stageWidth - _p * 2,	_h * 1.0);
	title = loc("settings_page");
}

override protected function showElements():void
{
	if( transitionState < TransitionData.STATE_IN_COMPLETED )
		return;
	
	super.showElements();
	
	list = new FastList();
	list.dataProvider = getSettingsData();
	list.verticalScrollPolicy = ScrollPolicy.OFF;
	list.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
	list.layoutData = new AnchorLayoutData(150, 40, 70, 40);
	list.addEventListener(FeathersEventType.FOCUS_IN, list_focusInHandler);
	list.itemRendererFactory = function():IListItemRenderer { return new SettingsItemRenderer(); }
	addChild(list);
	
	var versionLabel:RTLLabel = new RTLLabel("v. " + appModel.descriptor.versionLabel + " for " + appModel.descriptor.market + " in " + appModel.descriptor.server + ", User: " + (player.id * 2), 0x444488, null, "ltr", false, null, 0.55);
	versionLabel.layoutData = new AnchorLayoutData(NaN, 10,  10);
	versionLabel.touchable = false;
	addChild(versionLabel);
}

private function list_focusInHandler(event:Event):void
{
	var settingData:SettingsData = event.data as SettingsData;
	if( settingData.type == SettingsData.TYPE_TOGGLE )
	{
		if( settingData.key == PrefsTypes.AUTH_41_GOOGLE )
		{
			if( player.prefs.getAsBool(PrefsTypes.AUTH_41_GOOGLE) )
			{
				OAuthManager.instance.signout();
				list.dataProvider.updateItemAt(settingData.index);
				return;
			}
			OAuthManager.instance.addEventListener(OAuthManager.AUTHENTICATE, socialManager_eventsHandler);
			OAuthManager.instance.signin();
			return;
		}
		
		UserData.instance.prefs.setBool(settingData.key, settingData.value);//setSetting(settingData.key, settingData.value as int );
		list.dataProvider.updateItemAt(settingData.index);
		if( settingData.key == PrefsTypes.SETTINGS_1_MUSIC )
		{
			if( player.prefs.getAsBool(PrefsTypes.SETTINGS_1_MUSIC) )
				appModel.sounds.play("main-theme", NaN, 100, 0, SoundManager.SINGLE_FORCE_THIS);
			else
				appModel.sounds.stopAll();
		}
	}
	else
	{
		switch( int(settingData.value) )
		{
			case SettingsData.LOCALES :
				showLocalePopup();
				break;
			case SettingsData.RENAME :
				appModel.navigator.addPopup(new SelectNamePopup());
				break;
			case SettingsData.LINK_DEVICE :
				appModel.navigator.addPopup(new LinkDevicePopup());
				break;
			case SettingsData.BUG_REPORT :
				InboxSegment.openThread();
				close()
				break;
			case SettingsData.RATING :
				BillingManager.instance.rate();
				break;
			default:
				navigateTo(int(settingData.value));
				break;
		}
	}
}

private function showLocalePopup():void 
{
	var buttonsPopup:SimpleListPopup = new SimpleListPopup();
	buttonsPopup.buttonsWidth = 460;
	buttonsPopup.buttonHeight = 120;
	buttonsPopup.addEventListener(Event.SELECT, buttonsPopup_selectHandler);
	buttonsPopup.buttons = Localizations.instance.getLocalesByMarket(appModel.descriptor.market);
	appModel.navigator.addPopup(buttonsPopup);
	function buttonsPopup_selectHandler(event:Event) : void
	{
		buttonsPopup.removeEventListener(Event.SELECT, buttonsPopup_selectHandler);
		UserData.instance.prefs.addEventListener(Event.COMPLETE, prefs_completeHandler);
		UserData.instance.prefs.changeLocale(event.data as String);
	}
}

protected function prefs_completeHandler(event:Event) : void 
{
	UserData.instance.prefs.removeEventListener(Event.COMPLETE, prefs_completeHandler);
	titleDisplay.text = title = loc("settings_page");
	list.dataProvider.updateAll();
	ExCategoryItemRenderer.placeholders = null;
	appModel.navigator.rootScreenID = Game.DASHBOARD_SCREEN;
}

protected function socialManager_eventsHandler(event:Event):void
{
	OAuthManager.instance.removeEventListener(OAuthManager.AUTHENTICATE, socialManager_eventsHandler);
	list.dataProvider.updateItemAt(4);
}

private function navigateTo(key:int):void
{
	navigateToURL(new URLRequest(Localizations.instance.get("setting_value_" + key)));	
}

private function getSettingsData():ListCollection
{
	var source:Array = new Array();
	source.push( new SettingsData(PrefsTypes.SETTINGS_1_MUSIC,			SettingsData.TYPE_TOGGLE, player.prefs.getAsBool(PrefsTypes.SETTINGS_1_MUSIC)));
	source.push( new SettingsData(PrefsTypes.SETTINGS_2_SFX,			SettingsData.TYPE_TOGGLE, player.prefs.getAsBool(PrefsTypes.SETTINGS_2_SFX)));
	source.push( new SettingsData(PrefsTypes.SETTINGS_3_NOTIFICATION, 	SettingsData.TYPE_TOGGLE, player.prefs.getAsBool(PrefsTypes.SETTINGS_3_NOTIFICATION)));
	source.push( new SettingsData(PrefsTypes.SETTINGS_5_ADS, 			SettingsData.TYPE_TOGGLE, player.prefs.getAsBool(PrefsTypes.SETTINGS_5_ADS)));
	source.push( new SettingsData(PrefsTypes.AUTH_41_GOOGLE,            SettingsData.TYPE_TOGGLE, player.prefs.getAsBool(PrefsTypes.AUTH_41_GOOGLE)));
	
	source.push( new SettingsData(SettingsData.TYPE_BUTTON, 			SettingsData.TYPE_LABEL_BUTTONS,	null,	[PrefsTypes.SETTINGS_4_LOCALE, SettingsData.RENAME]));
	source.push( new SettingsData(SettingsData.TYPE_BUTTON, 			SettingsData.TYPE_LABEL_BUTTONS,	null,	[SettingsData.BUG_REPORT, SettingsData.LINK_DEVICE]));
	source.push( new SettingsData(SettingsData.TYPE_BUTTON, 			SettingsData.TYPE_LABEL_BUTTONS,	null,	[SettingsData.LEGALS, SettingsData.FAQ]));
	source.push( new SettingsData(SettingsData.TYPE_BUTTON, 			SettingsData.TYPE_ICON_BUTTONS,		null, 	[SettingsData.TELEGRAM, SettingsData.INSTAGRAM, SettingsData.RATING]));
	return new ListCollection(source);
}
}
}