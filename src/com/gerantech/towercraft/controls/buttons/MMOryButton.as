package com.gerantech.towercraft.controls.buttons 
{
import com.gerantech.towercraft.controls.overlays.HandPoint;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.utils.StrUtils;
import feathers.controls.Button;
import feathers.core.ITextRenderer;
import feathers.layout.RelativePosition;
import flash.geom.Point;
import flash.utils.setTimeout;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.events.Event;
import starling.textures.Texture;

/**
* @author Mansour Djawadi
*/
public class MMOryButton extends Button 
{
static public const DEFAULT_ICON_SIZE:Point = new Point(64, 64);
public var iconSize:Point;
public var messagePosition:String = RelativePosition.BOTTOM;

protected var _message:String;
protected var _iconTexture:Texture;
protected var _messageRenderFactory:Function;
protected var messageTextRenderer:ITextRenderer;
private var handPoint:HandPoint;

static public function getIcon(type:int, count:int) : Texture
{
	if( type > 0 && count > 0 )
		return Assets.getTexture("res-" + type, "gui");
	if( type == -2 )
		return Assets.getTexture("extra-time", "gui");
	return null;
}

static public function getLabel(type:int, count:*) : String
{
	if( !(count is int) )
		return count;
	if( count == -2 )
		return StrUtils.loc("open_label");
	if( count == -1 )
		return StrUtils.loc("start_open_label");
	if( count == 0 )
		return StrUtils.loc("free_label");
	return StrUtils.getCurrencyFormat(count)//+ " " + currency;
}


public function MMOryButton() 
{
	super();
	this.iconPosition = RelativePosition.RIGHT;
	this._messageRenderFactory = this.defaultMessageRendererFactory;
}

public function get messageRenderFactory() : Function 
{
	return this._messageRenderFactory;
}
public function set messageRenderFactory(value:Function) : void 
{
	this._messageRenderFactory = value;
	this.invalidate(INVALIDATION_FLAG_TEXT_EDITOR);
}
protected function defaultMessageRendererFactory() : ITextRenderer
{
	return new ShadowLabel(this._message, 1, 0, "center", null, false, null, 0.7);
}

/**
 * 
 * Small text renderer <b>top or bottom of button</b> for description
 * <p>if message <b>is not null</b>, you can see text element ;) !</p>
 */
public function get message() : String
{
	return this._message;
}
public function set message(value:String) : void
{
	if( this._message == value )
		return;
	this._message = value;
	if( this._message != null )
		this.invalidate(INVALIDATION_FLAG_TEXT_EDITOR);
	this.invalidate(INVALIDATION_FLAG_DATA);
}


public function get iconTexture() : Texture
{
	return this._iconTexture;
}
/**
 * @private
 */
public function set iconTexture(value:Texture) : void
{
	if( this._iconTexture == value )
		return;
	
	this._iconTexture = value;
	
	if( this._iconTexture == null )
	{
		super.defaultIcon = null;
		return;
	}

	super.defaultIcon = new Image(this._iconTexture);
	if( this.iconSize == null )
		return;
	super.defaultIcon.width = this.iconSize.x;
	super.defaultIcon.height = this.iconSize.y;
}

/**
 * @private
 */
override public function set defaultIcon(value:DisplayObject) : void
{
	throw new Error("Can not set default icon to mmory button!");
}

protected function refreshMessage() : void
{
	if( this.messageTextRenderer == null )
		return;
	
	this.messageTextRenderer.visible = this._message !== null && this._message.length > 0;
	
	if( !this.messageTextRenderer.visible )
		return;
	
	this.messageTextRenderer.isEnabled = this._isEnabled;
	this.messageTextRenderer.text = this._message;
	this.messageTextRenderer.validate();
}

override protected function draw() : void
{
	if( this._invalidationFlags[INVALIDATION_FLAG_TEXT_EDITOR] )
	{
		if( this.messageTextRenderer == null ) 
			this.messageTextRenderer = this.messageRenderFactory();
		if( this.messageTextRenderer != null )
			this.addChild(DisplayObject(this.messageTextRenderer));
	}
	
	if( this.isInvalid(INVALIDATION_FLAG_DATA) )
		this.refreshMessage();
	
	super.draw();
}

/**
 * Positions and sizes the button's content.
 * <p>For internal use in subclasses.</p>
 */
override protected function layoutContent() : void
{
	var messageRenderer:DisplayObject = DisplayObject(this.messageTextRenderer);
	if( messageRenderer == null || !messageRenderer.visible )
	{
		this.iconOffsetY = 0;
		this.labelOffsetY = 0;
	}
	else
	{
		messageRenderer.width = this.actualWidth - this._paddingRight - this._paddingLeft;
		messageRenderer.x = this.actualWidth - this._paddingRight - messageRenderer.width;
		if( this.messagePosition == RelativePosition.BOTTOM )
		{
			this.iconOffsetY = -27;
			this.labelOffsetY = -26;
			messageRenderer.y = this.actualHeight - this.paddingBottom - messageRenderer.height;
		}
		else
		{
			this.iconOffsetY = 27;
			this.labelOffsetY = 28;
			messageRenderer.y = this.paddingTop;
		}
	}
	super.layoutContent();
}

public function showTutorHint(offsetX:Number = 0, offsetY:Number = 0) : void 
{

	
	this.handPoint = new HandPoint(this.actualWidth * 0.5 + offsetX, offsetY);
	this.addEventListener(Event.TRIGGERED, this_triggeredHandler);
	setTimeout(addChild, 200, this.handPoint);
}
protected function this_triggeredHandler(event:Event) : void 
{
	this.removeEventListener(Event.TRIGGERED, this_triggeredHandler);
	if( this.handPoint != null )
		this.handPoint.removeFromParent(true);
}

override public function dispose() : void
{
	this.removeEventListener(Event.TRIGGERED, this_triggeredHandler);
	super.dispose();
}
}
}