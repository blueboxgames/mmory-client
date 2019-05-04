package com.gerantech.towercraft.controls.buttons
{
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.themes.MainTheme;
import feathers.controls.Button;
import feathers.core.ITextRenderer;
import starling.text.TextFormat;

public class IndicatorButton extends Button
{
public var fixed:Boolean;
public function IndicatorButton()
{
	super();
	styleName = MainTheme.STYLE_BUTTON_SMALL_NORMAL;
	labelOffsetX = 2;
	labelFactory = function () : ITextRenderer
	{
		return new ShadowLabel(null, 1, 0, null, null, false, null, 0.75);
	}
}
override protected function initialize() : void
{
	super.initialize();
	labelOffsetY = Math.max(-4, height - 72);
}

override public function set label(value:String) : void
{
	if( fixed )
		super.label = "!";
	else
		super.label = value;
}
}
}