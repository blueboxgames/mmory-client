package com.gerantech.towercraft.controls.sliders
{
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.utils.StrUtils;
import feathers.controls.ProgressBar;
import feathers.core.ITextRenderer;
import feathers.layout.Direction;
import feathers.layout.HorizontalAlign;
import feathers.utils.math.clamp;

public class LabeledProgressBar extends ProgressBar
{
public var horizontalAlign:String = "left";
public var labelTextRenderer:RTLLabel;
public var labelOffsetX:Number = 0;
public var labelOffsetY:Number = 0;
public function LabeledProgressBar() { super(); }
override protected function initialize():void
{
	super.initialize();
	
	if( textRenderFactory == null )
		textRenderFactory = defaultTextRendererFactory;
	
	if( hasLabelTextRenderer )
		this.invalidate(INVALIDATION_FLAG_TEXT_RENDERER);
	
	if( formatValueFactory == null )
		formatValueFactory = defultFormatValueFactory;
}



private var _clampValue:Boolean = true;
public function get clampValue():Boolean 
{
	return _clampValue;
}

public function set clampValue(value:Boolean):void 
{
	if( _clampValue == value )
		return;
	_clampValue = value;
	this.invalidate(INVALIDATION_FLAG_DATA);
}



/**
 * @private
 */
protected var _hasLabelTextRenderer:Boolean = true;

/**
 * @private
 */
public function get hasLabelTextRenderer() : Boolean
{
	return this._hasLabelTextRenderer;
}

/**
 * @private
 */
public function set hasLabelTextRenderer(value:Boolean) : void
{
	if( this.processStyleRestriction(arguments.callee) )
		return;
	if( this._hasLabelTextRenderer === value )
		return;
	this._hasLabelTextRenderer = value;
	this.invalidate(INVALIDATION_FLAG_TEXT_RENDERER);
}


private var _textRenderFactory:Function;
public function get textRenderFactory():Function 
{
	return _textRenderFactory;
}
public function set textRenderFactory(value:Function):void 
{
	_textRenderFactory = value;
	this.invalidate(INVALIDATION_FLAG_TEXT_RENDERER);
}
protected function defaultTextRendererFactory() : ITextRenderer
{
	if( !hasLabelTextRenderer )
	{
		if( labelTextRenderer != null )
		{
			labelTextRenderer.removeFromParent(true);
			labelTextRenderer = null;
		}
		return null;
	}
	
	return new ShadowLabel(null, 1, 0, "center", "ltr", false, null, 0.7);
}

private var _formatValueFactory:Function;
public function get formatValueFactory():Function 
{
	return _formatValueFactory;
}
public function set formatValueFactory(value:Function):void 
{
	_formatValueFactory = value;
	this.invalidate(INVALIDATION_FLAG_DATA);
}
protected function defultFormatValueFactory(value:Number, minimum:Number, maximum:Number) : String
{
	return StrUtils.getNumber(Math.round(value));
}

override public function set value(newValue:Number) : void
{
	if( clampValue )
		newValue = clamp(newValue, this._minimum, this._maximum);
	if( this._value == newValue )
		return;
	this._value = newValue;
	this.invalidate(INVALIDATION_FLAG_DATA);
}





/**
 * @private
 */
public function get paddingText():Number
{
	return this._paddingTextTop;
}

/**
 * @private
 */
public function set paddingText(value:Number):void
{
	this.paddingTextTop = value;
	this.paddingTextRight = value;
	this.paddingTextBottom = value;
	this.paddingTextLeft = value;
}

/**
 * @private
 */
protected var _paddingTextTop:Number = 0;

/**
 * @private
 */
public function get paddingTextTop():Number
{
	return this._paddingTextTop;
}

/**
 * @private
 */
public function set paddingTextTop(value:Number):void
{
	if( this.processStyleRestriction(arguments.callee) )
		return;
	if( this._paddingTextTop == value )
		return;
	this._paddingTextTop = value;
	this.invalidate(INVALIDATION_FLAG_STYLES);
}

/**
 * @private
 */
protected var _paddingTextRight:Number = 0;

/**
 * @private
 */
public function get paddingTextRight():Number
{
	return this._paddingTextRight;
}

/**
 * @private
 */
public function set paddingTextRight(value:Number):void
{
	if( this.processStyleRestriction(arguments.callee) )
		return;
	if( this._paddingTextRight == value )
		return;
	this._paddingTextRight = value;
	this.invalidate(INVALIDATION_FLAG_STYLES);
}

/**
 * @private
 */
protected var _paddingTextBottom:Number = 0;

/**
 * @private
 */
public function get paddingTextBottom():Number
{
	return this._paddingTextBottom;
}

/**
 * @private
 */
public function set paddingTextBottom(value:Number):void
{
	if( this.processStyleRestriction(arguments.callee) )
		return;
	if( this._paddingTextBottom == value )
		return;
	this._paddingTextBottom = value;
	this.invalidate(INVALIDATION_FLAG_STYLES);
}

/**
 * @private
 */
protected var _paddingTextLeft:Number = 0;

/**
 * @private
 */
public function get paddingTextLeft():Number
{
	return this._paddingTextLeft;
}

/**
 * @private
 */
public function set paddingTextLeft(value:Number):void
{
	if( this.processStyleRestriction(arguments.callee) )
		return;
	if( this._paddingTextLeft == value )
		return;
	this._paddingTextLeft = value;
	this.invalidate(INVALIDATION_FLAG_STYLES);
}


override protected function draw() : void
{
	if( this.isInvalid(INVALIDATION_FLAG_TEXT_RENDERER) )
	{
		labelTextRenderer = textRenderFactory();
		if( labelTextRenderer != null )
			addChild(labelTextRenderer);
	}
	
	if( this.isInvalid(INVALIDATION_FLAG_DATA) && labelTextRenderer != null )
		labelTextRenderer.text = formatValueFactory(this._value, this._minimum, this._maximum);
	
	super.draw();
}

override protected function layoutChildren() : void
{
	if( this.currentBackground !== null )
	{
		this.currentBackground.width = this.actualWidth;
		this.currentBackground.height = this.actualHeight;
	}
	
	if( this._minimum === this._maximum )
	{
		var percentage:Number = 1;
	}
	else
	{
		percentage = (this._value - this._minimum) / (this._maximum - this._minimum);
		if( percentage < 0 )
			percentage = 0;
		else if( percentage > 1 )
			percentage = 1;
	}
	if( this._direction === Direction.VERTICAL )
	{
		this.currentFill.width = this.actualWidth - this._paddingLeft - this._paddingRight;
		this.currentFill.height = this._originalFillHeight + percentage * (this.actualHeight - this._paddingTop - this._paddingBottom - this._originalFillHeight);
		this.currentFill.x = this._paddingLeft;
		this.currentFill.y = this.actualHeight - this._paddingBottom - this.currentFill.height;
	}
	else //horizontal
	{
		this.currentFill.width = this._originalFillWidth + percentage * (this.actualWidth - this._paddingLeft - this._paddingRight - this._originalFillWidth);
		this.currentFill.height = this.actualHeight - this._paddingTop - this._paddingBottom;
		
		this.currentFill.x =  this._paddingLeft + ( horizontalAlign == HorizontalAlign.RIGHT ? actualWidth - currentFill.width : 0 );
		this.currentFill.y = this._paddingTop;
	}
	
	if( this.labelTextRenderer != null )
	{
		this.labelTextRenderer.validate();
		this.labelTextRenderer.x = (this.actualWidth - this._paddingLeft - this._paddingTextLeft - this._paddingRight - this._paddingTextRight - this.labelTextRenderer.width) * 0.5 + this._paddingLeft + this._paddingTextLeft + this.labelOffsetX;
		this.labelTextRenderer.y = (this.actualHeight - this._paddingTop - this._paddingTextTop - this._paddingBottom - this._paddingTextBottom - this.labelTextRenderer.height) * 0.5 + this._paddingTop + this._paddingTextTop + this.labelOffsetY;
	}
}
}
}