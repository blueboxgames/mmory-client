package com.gerantech.towercraft.controls.segments 
{
import com.gerantech.towercraft.controls.FastList;
import com.gerantech.towercraft.controls.buttons.MMOryButton;
import com.gerantech.towercraft.controls.items.lobby.LobbyChatItemRenderer;
import com.gerantech.towercraft.controls.overlays.TransitionData;
import com.gerantech.towercraft.controls.popups.SimpleListPopup;
import com.gerantech.towercraft.controls.texts.CustomTextInput;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.MainTheme;
import com.gt.towers.constants.MessageTypes;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import dragonBones.objects.DragonBonesData;
import dragonBones.starling.StarlingFactory;
import feathers.controls.Button;
import feathers.controls.ScrollBarDisplayMode;
import feathers.controls.ScrollPolicy;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import flash.geom.Rectangle;
import flash.text.ReturnKeyLabel;
import flash.text.SoftKeyboardType;
import flash.utils.setTimeout;
import starling.animation.Transitions;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.events.Event;
/**
* ...
* @author Mansour Djawadi
*/
public class ChatSegment extends Segment 
{
static public var dragonBonesData:DragonBonesData;
static public var factory:StarlingFactory;

protected var padding:int;
protected var footerSize:int;
protected var chatList:FastList;
protected var chatEnableButton:MMOryButton;
protected var chatLayout:VerticalLayout;
protected var chatTextInput:CustomTextInput;
protected var _buttonsEnabled:Boolean = true;
protected var _chatEnabled:Boolean = false;
protected var autoScroll:Boolean = true;
private var startScrollBarIndicator:Number = 0;

public function ChatSegment()
{
	super();
	Assets.loadAnimationAssets(animation_loadCallback, "emotes");
}

protected function animation_loadCallback():void 
{
	if( ChatSegment.factory == null )
	{
		ChatSegment.factory = new StarlingFactory();
		ChatSegment.dragonBonesData = ChatSegment.factory.parseDragonBonesData(appModel.assets.getObject("emotes_ske"));
		ChatSegment.factory.parseTextureAtlasData(appModel.assets.getObject("emotes_tex"), appModel.assets.getTexture("emotes_tex"));
	}
}

protected function showElements() : void
{
	padding = 16;
	footerSize = 120;
	
	chatLayout = new VerticalLayout();
	chatLayout.gap = padding;
	chatLayout.paddingTop = padding * 2;
    chatLayout.paddingBottom = footerSize + padding * 2;
	chatLayout.hasVariableItemDimensions = true;
	chatLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
	chatLayout.verticalAlign = VerticalAlign.BOTTOM;
	
	chatList = new FastList(false);
	chatList.layout = chatLayout;
    chatList.layoutData = new AnchorLayoutData(21, 0, 0, 0);
	chatList.itemRendererFactory = function ():IListItemRenderer { return new LobbyChatItemRenderer()};
	chatList.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
	chatList.addEventListener(Event.CHANGE, chatList_changeHandler);
	chatList.addEventListener(FeathersEventType.FOCUS_IN, chatList_focusInHandler);
	chatList.addEventListener(FeathersEventType.CREATION_COMPLETE, chatList_createCompleteHandler);
	chatList.dataProvider = new ListCollection();
	chatList.validate();
	chatList.loadingState = 1;
	addChild(chatList);

	chatTextInput = new CustomTextInput(SoftKeyboardType.DEFAULT, ReturnKeyLabel.DONE, 0, false, appModel.align);
	chatTextInput.maxChars = 160;
	chatTextInput.textEditorProperties.autoCorrect = true;
	chatTextInput.height = footerSize;
    chatTextInput.layoutData = new AnchorLayoutData(NaN, padding, padding, padding);
    chatTextInput.addEventListener(FeathersEventType.ENTER, sendButton_triggeredHandler);
    chatTextInput.addEventListener(FeathersEventType.FOCUS_OUT, chatTextInput_focusOutHandler);
	
    chatEnableButton = new MMOryButton();
	chatEnableButton.styleName = MainTheme.STYLE_BUTTON_SMALL_NEUTRAL;
    chatEnableButton.width = chatEnableButton.height = footerSize;
    chatEnableButton.iconTexture = Assets.getTexture("socials/icon-text", "gui");
    chatEnableButton.layoutData = new AnchorLayoutData(NaN, padding, padding, NaN);
    chatEnableButton.addEventListener(Event.TRIGGERED, chatButton_triggeredHandler);
    addChild(chatEnableButton);
}

protected function chatList_createCompleteHandler(event:Event):void
{
	chatList.removeEventListener(FeathersEventType.CREATION_COMPLETE, chatList_createCompleteHandler);
	scrollToEnd();
    setTimeout(chatList.addEventListener, 1000, Event.SCROLL, chatList_scrollHandler);
}

protected function chatList_changeHandler(event:Event):void
{
	if( chatList.selectedItem == null )
		return;
/*	var msgPack:ISFSObject = chatList.selectedItem as SFSObject;
	if( msgPack.getShort("m") == MessageTypes.M30_FRIENDLY_BATTLE  )
	{
		var myBattleId:int = manager.getMyRequestBattleId();
		if( myBattleId > -1 && msgPack.getInt("bid") != myBattleId )
			return;
		
		if( msgPack.getShort("st") > 1 )
			return;
		
		var params:SFSObject = new SFSObject();
		params.putShort("m", MessageTypes.M30_FRIENDLY_BATTLE);
		params.putInt("bid", msgPack.getInt("bid"));
		params.putShort("st", msgPack.getShort("st"));
		SFSConnection.instance.sendExtensionRequest(SFSCommands.LOBBY_PUBLIC_MESSAGE, params, manager.lobby );
	}
*/}

protected function chatList_scrollHandler(event:Event):void
{
    var scrollPos:Number = Math.max(0, chatList.verticalScrollPosition);
    scrollChatList(startScrollBarIndicator - scrollPos);
    startScrollBarIndicator = scrollPos;
}

protected function scrollChatList(changes:Number):void
{
	//trace(changes, chatList.verticalScrollPosition, chatList.maxVerticalScrollPosition)
    if( changes > 10 )
        autoScroll = false;
	else if( chatList.verticalScrollPosition == chatList.maxVerticalScrollPosition )
        autoScroll = true;
}

protected function scrollToEnd():void
{
    chatList.scrollToDisplayIndex(Math.max(0, chatList.dataProvider.length - 1));
    autoScroll = true;
}

protected function chatList_focusInHandler(event:Event) : void
{
	if( !_buttonsEnabled )
        return;
	var selectedItem:LobbyChatItemRenderer = event.data as LobbyChatItemRenderer;
	if( selectedItem == null )
		return;
	
	var msgPack:ISFSObject = selectedItem.data as ISFSObject;
	// prevent hints for my messages
	if( msgPack.getInt("i") != player.id && msgPack.getShort("m") == MessageTypes.M0_TEXT )
		showSimpleListPopup(msgPack, selectedItem, buttonsPopup_selectHandler, buttonsPopup_selectHandler, "lobby_report")
}

protected function showSimpleListPopup(data:Object, selectedItem:DisplayObject, selectHandler:Function, closeHaandler:Function, ... buttons):void
{
	var buttonsPopup:SimpleListPopup = new SimpleListPopup(buttons);
	buttonsPopup.buttons = buttons;
	buttonsPopup.data = data;
	buttonsPopup.addEventListener(Event.SELECT, selectHandler);
	buttonsPopup.addEventListener(Event.CLOSE, closeHaandler);
	buttonsPopup.buttonsWidth = 320;
	buttonsPopup.buttonHeight = 120;
	var floatingW:int = buttonsPopup.buttonsWidth + buttonsPopup.padding * 2;
	var floatingH:int = buttonsPopup.buttonHeight * buttonsPopup.buttons.length + buttonsPopup.padding * 2;
	var floatingY:int = selectedItem.getBounds(stage).y + floatingH * 0.5;
	var ti:TransitionData = new TransitionData(0.2);
	var to:TransitionData = new TransitionData(0.2);
	to.sourceConstrain = ti.destinationConstrain = this.getBounds(stage);
	ti.transition = Transitions.EASE_OUT_BACK;
	to.sourceAlpha = 1;
	to.destinationAlpha = 0;
	var offsetX:Number = 0;
	if( selectedItem is LobbyChatItemRenderer )
		offsetX = LobbyChatItemRenderer(selectedItem).getTouch().globalX;
	to.destinationBound = ti.sourceBound = new Rectangle(offsetX - floatingW / 2, floatingY + buttonsPopup.buttonHeight / 2 - floatingH * 0.4, floatingW, floatingH * 0.8);
	to.sourceBound = ti.destinationBound = new Rectangle(offsetX - floatingW / 2, floatingY + buttonsPopup.buttonHeight / 2 - floatingH * 0.5, floatingW, floatingH);
	buttonsPopup.transitionIn = ti;
	buttonsPopup.transitionOut = to;
	appModel.navigator.addPopup(buttonsPopup);	
}

protected function buttonsPopup_selectHandler(event:Event):void
{
	var buttonsPopup:SimpleListPopup = event.currentTarget as SimpleListPopup;
	buttonsPopup.removeEventListener(Event.SELECT, buttonsPopup_selectHandler);
	buttonsPopup.removeEventListener(Event.CLOSE, buttonsPopup_selectHandler);
	
	if( event.type == Event.CLOSE )
		return;
}

protected function chatButton_triggeredHandler(event:Event):void
{
    enabledChatting(true);
	scrollToEnd();
    autoScroll = true;
}

protected function sendButton_triggeredHandler(event:Event):void
{
	if( chatTextInput.text == "" )
		return;
	if( areUVerbose() )
	{
		appModel.navigator.addLog(loc("lobby_message_limit"));
		return;
	}
	
	/*var params:SFSObject = new SFSObject();
	params.putUtfString("t", preText + StrUtils.getSimpleString(chatTextInput.text));
	SFSConnection.instance.sendExtensionRequest(SFSCommands.LOBBY_PUBLIC_MESSAGE, params, manager.lobby );*/
	chatTextInput.text = "";
}

private function areUVerbose():Boolean 
{
	/*var last:ISFSObject = manager.messages.getItemAt(manager.messages.length - 1) as SFSObject;
	if ( last != null && last.getInt("i") == player.id && last.containsKey("t") )
		return (last.getText("t").split("\n").length > 5 );*/
	return false;
}

private function chatTextInput_focusOutHandler(event:Event):void
{
    setTimeout(enabledChatting, 100, false);
}

public function enabledChatting(value:Boolean):void
{
    if( _chatEnabled == value )
        return;
    
    _chatEnabled = value;
    
    if( _chatEnabled )
    {
        chatEnableButton.removeFromParent();
        addChild(chatTextInput);
        chatTextInput.setFocus();
    }
    else
    {
        chatTextInput.removeFromParent();
        addChild(chatEnableButton);
    }
}

public function set buttonsEnabled(value:Boolean):void
{
	if( _buttonsEnabled == value )
		return;
	
	_buttonsEnabled = value;
	chatTextInput.isEnabled = _buttonsEnabled;
    chatEnableButton.isEnabled = _buttonsEnabled;
    chatList.verticalScrollPolicy = _buttonsEnabled ? ScrollPolicy.AUTO : ScrollPolicy.OFF;
	dispatchEventWith(Event.READY, true, _buttonsEnabled);
}

protected function isInvalidMessage(message:String) : Boolean 
{
	if( message == "" )
		return true;
	if( message.split("\n").length > 3 || message.split("\r").length > 3 )
	{
		chatTextInput.text = "";
		appModel.navigator.addLog(loc("lobby_message_unauthorized"));
		return true;
	}
	return false;
}
}
}