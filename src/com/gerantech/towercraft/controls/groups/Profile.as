package com.gerantech.towercraft.controls.groups 
{
import com.gerantech.towercraft.controls.TowersLayout;
import com.gerantech.towercraft.controls.buttons.Indicator;
import com.gerantech.towercraft.controls.buttons.IndicatorPoint;
import com.gerantech.towercraft.controls.buttons.IndicatorXP;
import com.gerantech.towercraft.controls.buttons.MMOryButton;
import com.gerantech.towercraft.controls.popups.ProfilePopup;
import com.gerantech.towercraft.controls.popups.SettingsPopup;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.MainTheme;
import com.gt.towers.constants.PrefsTypes;
import com.gt.towers.constants.ResourceType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import flash.geom.Rectangle;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.events.Event;

/**
* ...
* @author Mansour Djawadi
*/
public class Profile extends TowersLayout 
{
public function Profile() {	super(); }
override protected function initialize() : void
{
	height = 164;
	super.initialize();
	layout = new AnchorLayout();
	touchable = player.getTutorStep() >= 47;
    var scale9:Rectangle = new Rectangle(16, 16, 4, 4);
	
	var skin:Image = new Image(appModel.theme.roundMediumInnerSkin);
	skin.scale9Grid = MainTheme.ROUND_MEDIUM_SCALE9_GRID;
	skin.color = 0;
	skin.alpha = 0.25;
	backgroundSkin = skin;

	var nameDisplay:ShadowLabel = new ShadowLabel(player.nickName, 1, 0, "left", null, false, null, 0.8);
	nameDisplay.layoutData = new AnchorLayoutData(15, NaN, NaN, 110);
	addEventListener("nameUpdate", function ():void { nameDisplay.text = player.nickName; });
	addChild(nameDisplay);

	var padding:int = 20;
	var indicatorPoint:IndicatorPoint = new IndicatorPoint("rtl");
	indicatorPoint.layoutData = new AnchorLayoutData(NaN, NaN, padding, 70);
	indicatorPoint.addEventListener(Event.SELECT, buttons_eventsHandler);
	indicatorPoint.name = "pointIndicator";
	indicatorPoint.width = 250;
	indicatorPoint.height = 60;
	addChild(indicatorPoint);

	var indicatorXP:IndicatorXP = new IndicatorXP("ltr");
	indicatorXP.layoutData = new AnchorLayoutData(NaN, 310, padding);
	indicatorXP.addEventListener(Event.SELECT, buttons_eventsHandler);
	indicatorXP.name = "xpIndicator";
	indicatorXP.labelOffsetX = 15;
	indicatorXP.width = 200;
	indicatorXP.height = 60;
	addChild(indicatorXP);
	
	// profile button
	var profileButton:MMOryButton = new MMOryButton();
	profileButton.styleName = MainTheme.STYLE_BUTTON_SMALL_DARK;
	profileButton.iconTexture = Assets.getTexture("home/profile", "gui");
	profileButton.addEventListener(Event.TRIGGERED, buttons_eventsHandler);
	profileButton.layoutData = new AnchorLayoutData(NaN, padding * 2 + 100, NaN, NaN, NaN, 2);
	profileButton.width = profileButton.height = 100;
	profileButton.name = "profileButton";
	addChild(profileButton);
	
	// settings button
	var settingsButton:MMOryButton = new MMOryButton();
	settingsButton.styleName = MainTheme.STYLE_BUTTON_SMALL_DARK;
	settingsButton.iconTexture = Assets.getTexture("home/settings", "gui");
	settingsButton.addEventListener(Event.TRIGGERED, buttons_eventsHandler);
	settingsButton.layoutData = new AnchorLayoutData(NaN, padding, NaN, NaN, NaN, 2);
	settingsButton.width = settingsButton.height = 100;
	settingsButton.name = "settingsButton";
	addChild(settingsButton);
}

private function buttons_eventsHandler(event:Event) : void 
{
	switch(DisplayObject(event.currentTarget).name)
	{
	case "profileButton":	appModel.navigator.addPopup(new ProfilePopup	({name:player.nickName, id:player.id}));	break;
	case "settingsButton":	appModel.navigator.addPopup(new SettingsPopup	());										break;
	}
}
}
}