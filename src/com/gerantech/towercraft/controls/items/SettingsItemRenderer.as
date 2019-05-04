package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.controls.buttons.MMOryButton;
import com.gerantech.towercraft.controls.groups.Spacer;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.vo.SettingsData;
import com.gerantech.towercraft.themes.MainTheme;
import feathers.controls.Button;
import feathers.core.ITextRenderer;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import starling.display.Image;
import starling.events.Event;
import starling.textures.Texture;

public class SettingsItemRenderer extends AbstractTouchableListItemRenderer
{
private var settingData:SettingsData;
private var nameDisplay:RTLLabel;
private var checkDisplay:RTLLabel;
private var buttonDisplay:Button;

public function SettingsItemRenderer(){}
override protected function initialize():void
{
	super.initialize();
	height = 120;
	
	var hlayout:HorizontalLayout = new HorizontalLayout();
	//hlayout.paddingLeft = hlayout.paddingRight = 48;
	hlayout.gap = 16;
	hlayout.padding = 6;
	hlayout.verticalAlign = VerticalAlign.MIDDLE;
	layout = hlayout;
}

override protected function commitData():void
{
	super.commitData();
	if( _data == null )
		return;

	removeChildren();
	settingData = _data as SettingsData;
	settingData.index = index;
	
	if( settingData.type == SettingsData.TYPE_TOGGLE )
	{
		nameDisplay = new RTLLabel(loc("setting_label_" + settingData.key), 0x333366, null, null, false, null, 0.75);
		nameDisplay.layoutData = new HorizontalLayoutData(100);
		addChild(nameDisplay);
		
		var btn:MMOryButton = addIconButton(settingData.key);
		btn.styleName = settingData.value ? MainTheme.STYLE_BUTTON_SMALL_NORMAL : MainTheme.STYLE_BUTTON_SMALL_DANGER;
	}
	else if( settingData.type == SettingsData.TYPE_ICON_BUTTONS )
	{
		if( !appModel.isLTR )
			addChild(new Spacer(false));
		var list:Array = settingData.data as Array;
		for( var i:int = 0; i < list.length; i++ )
			addIconButton(list[i]);
	}
	else if( settingData.type == SettingsData.TYPE_LABEL_BUTTONS )
	{
		list = settingData.data as Array;
		for( i = 0; i < list.length; i++ )
			addLabelButton(list[i]);
	}
/*	else
	{
		buttonDisplay = new Button();
		//buttonDisplay.iconLayout = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, -3);
		buttonDisplay.width = 140;
		buttonDisplay.styleName = MainTheme.STYLE_BUTTON_SMALL_N;
		if( settingData.type == SettingsData.TYPE_BUTTON )
		{
			buttonDisplay.label = loc("setting_label_" + settingData.key);
		}
		else
		{
			buttonDisplay.defaultIcon = new Image(Assets.getTexture("settings/" + settingData.key, "gui"));
			buttonDisplay.styleName = settingData.value ? MainTheme.STYLE_BUTTON_SMALL_NORMAL : MainTheme.STYLE_BUTTON_SMALL_DANGER; 
		}
		
		buttonDisplay.layoutData = new HorizontalLayoutData(settingData.type == SettingsData.TYPE_BUTTON ? 100 : NaN, 100);
		buttonDisplay.addEventListener(Event.TRIGGERED, buttons_triggeredHandler);
		addChild(buttonDisplay);
	}*/
}

private function addLabelButton(type:int):void
{
	var btn:MMOryButton = new MMOryButton();
	btn.labelFactory = function () : ITextRenderer { return new ShadowLabel(null, 1, 0, "center", null, false, null, 0.7)};
	btn.addEventListener(Event.TRIGGERED, buttons_triggeredHandler);
	var txt:Texture = Assets.getTexture("settings/" + type, "gui");
	btn.styleName = MainTheme.STYLE_BUTTON_SMALL_NEUTRAL;
	btn.label = loc("setting_label_" + type);
	btn.layoutData = new HorizontalLayoutData(100, 100);
	if( txt != null )
		btn.iconTexture = txt;
	btn.name = type.toString();
	addChild(btn);
}

private function addIconButton(type:int) : MMOryButton
{
	var btn:MMOryButton = new MMOryButton();
	btn.addEventListener(Event.TRIGGERED, buttons_triggeredHandler);
	btn.iconTexture = Assets.getTexture("settings/" + type, "gui");
	btn.styleName = MainTheme.STYLE_BUTTON_SMALL_NEUTRAL;
	btn.layoutData = new HorizontalLayoutData(NaN, 100);
	btn.name = type.toString();
	btn.width = 220;
	addChild(btn);
	return btn;
}

protected function buttons_triggeredHandler(event:Event):void
{
	if( settingData.type == SettingsData.TYPE_TOGGLE )
		settingData.value = !settingData.value;
	else 
		settingData.value = Button(event.currentTarget).name;
	
	_owner.dispatchEventWith(FeathersEventType.FOCUS_IN, false, settingData);
}
}
}