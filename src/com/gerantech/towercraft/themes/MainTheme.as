/*
Copyright 2012-2017 Bowler Hat LLC

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
*/
package com.gerantech.towercraft.themes
{

import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import feathers.controls.Alert;
import feathers.controls.AutoComplete;
import feathers.controls.Button;
import feathers.controls.ButtonGroup;
import feathers.controls.ButtonState;
import feathers.controls.Callout;
import feathers.controls.Check;
import feathers.controls.DateTimeSpinner;
import feathers.controls.Drawers;
import feathers.controls.GroupedList;
import feathers.controls.Header;
import feathers.controls.ImageLoader;
import feathers.controls.ItemRendererLayoutOrder;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.List;
import feathers.controls.NumericStepper;
import feathers.controls.PageIndicator;
import feathers.controls.Panel;
import feathers.controls.PanelScreen;
import feathers.controls.PickerList;
import feathers.controls.ProgressBar;
import feathers.controls.Radio;
import feathers.controls.ScrollContainer;
import feathers.controls.ScrollScreen;
import feathers.controls.ScrollText;
import feathers.controls.Scroller;
import feathers.controls.SimpleScrollBar;
import feathers.controls.Slider;
import feathers.controls.SpinnerList;
import feathers.controls.StepperButtonLayoutMode;
import feathers.controls.TabBar;
import feathers.controls.TextArea;
import feathers.controls.TextCallout;
import feathers.controls.TextInput;
import feathers.controls.TextInputState;
import feathers.controls.ToggleButton;
import feathers.controls.ToggleSwitch;
import feathers.controls.TrackLayoutMode;
import feathers.controls.popups.BottomDrawerPopUpContentManager;
import feathers.controls.popups.CalloutPopUpContentManager;
import feathers.controls.renderers.BaseDefaultItemRenderer;
import feathers.controls.renderers.DefaultGroupedListHeaderOrFooterRenderer;
import feathers.controls.renderers.DefaultGroupedListItemRenderer;
import feathers.controls.renderers.DefaultListItemRenderer;
import feathers.controls.text.ITextEditorViewPort;
import feathers.controls.text.StageTextTextEditor;
import feathers.controls.text.TextBlockTextEditor;
import feathers.controls.text.TextFieldTextEditorViewPort;
import feathers.core.FeathersControl;
import feathers.core.ITextEditor;
import feathers.core.ITextRenderer;
import feathers.core.PopUpManager;
import feathers.layout.Direction;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.RelativePosition;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import feathers.media.FullScreenToggleButton;
import feathers.media.MuteToggleButton;
import feathers.media.PlayPauseToggleButton;
import feathers.media.SeekSlider;
import feathers.skins.ImageSkin;
import feathers.system.DeviceCapabilities;
import feathers.themes.StyleNameFunctionTheme;
import flash.geom.Rectangle;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.display.Quad;
import starling.text.TextFormat;
import starling.textures.Texture;

/**
* The base class for the "Metal Works" theme for mobile Feathers apps.
* Handles everything except asset loading, which is left to subclasses.
*
* @see MetalWorksMobileTheme
* @see MetalWorksMobileThemeWithAssetManager
*/
public class MainTheme extends StyleNameFunctionTheme
{
static public const FONT_NAME:String = "SourceSansPro";

/**
 * The stack of fonts to use for controls that don't use embedded fonts.
 */
static public const FONT_NAME_STACK:String = "SourceSansPro,Helvetica,_sans";

static public const PRIMARY_BACKGROUND_COLOR:uint = 0x3d4759;
static public const LIGHT_TEXT_COLOR:uint = 0xe5e5e5;
static public const DARK_TEXT_COLOR:uint = 0x1a1816;
static public const SELECTED_TEXT_COLOR:uint = 0xff9900;
static public const LIGHT_DISABLED_TEXT_COLOR:uint = 0x8a8a8a;
static public const DARK_DISABLED_TEXT_COLOR:uint = 0x383430;
static public const LIST_BACKGROUND_COLOR:uint = 0x383430;
static public const GROUPED_LIST_HEADER_BACKGROUND_COLOR:uint = 0x2e2a26;
static public const GROUPED_LIST_FOOTER_BACKGROUND_COLOR:uint = 0x2e2a26;
static public const MODAL_OVERLAY_COLOR:uint = 0x29241e;
static public const MODAL_OVERLAY_ALPHA:Number = 0.8;
static public const DRAWER_OVERLAY_COLOR:uint = 0x29241e;
static public const DRAWER_OVERLAY_ALPHA:Number = 0.4;
static public const VIDEO_OVERLAY_COLOR:uint = 0x1a1816;
static public const VIDEO_OVERLAY_ALPHA:Number = 0.2;

static public const SELECTED_BACKGROUND_COLOR:uint = 0x80cbc4;
static public const PRIMARY_TEXT_COLOR:uint = 0xF0FFFF;//0xE0F2F1;
static public const DESCRIPTION_TEXT_COLOR:uint = 0xA0B2B1;//0xE0F2F1;
static public const SECONDARY_BACKGROUND_COLOR:uint = 0xE0F2F1;//0xE0F2F1;
static public const CHROME_COLOR:uint = 0xE0F2F1;//0xE0F2F1;
static public const ACCENT_COLOR:uint = 0x96000E;//0x96000E;

static public const STYLE_GREEN:uint = 0x97C42C;
static public const STYLE_BLUE:uint = 0x3F6FB2;
static public const STYLE_RED:uint = 0xEB2542;
static public const STYLE_GRAY:uint = 0x333333;
static public const STYLE_ORANGE:uint = 0xF49D27;

static public const STYLE_BUTTON_NORMAL:String = "feathers-normal-button";
static public const STYLE_BUTTON_HILIGHT:String = "feathers-hiight-button";
static public const STYLE_BUTTON_DANGER:String = "feathers-danger-button";
static public const STYLE_BUTTON_NEUTRAL:String = "feathers-neutral-button";
static public const STYLE_BUTTON_DISABLE:String = "feathers-disable-button";
static public const STYLE_BUTTON_SMALL_NORMAL:String = "feathers-small-normal-button";
static public const STYLE_BUTTON_SMALL_HILIGHT:String = "feathers-small-hiight-button";
static public const STYLE_BUTTON_SMALL_DANGER:String = "feathers-small-danger-button";
static public const STYLE_BUTTON_SMALL_NEUTRAL:String = "feathers-small-neutral-button";
static public const STYLE_BUTTON_SMALL_DARK:String = "feathers-small-dark-button";
static public const STYLE_BUTTON_SMALL_DISABLE:String = "feathers-small-disable-button";

static public const QUAD_SCALE9_GRID:Rectangle = new Rectangle(2, 2, 2, 2);
static public const DEFAULT_BACKGROUND_SCALE9_GRID:Rectangle = new Rectangle(8, 8, 2, 2);
static public const BUTTON_SCALE9_GRID:Rectangle = new Rectangle(23, 23, 1, 1);
static public const BUTTON_SMALL_SCALE9_GRID:Rectangle = new Rectangle(13, 13, 1, 1);
static public const SLIDER_SCALE9_GRID:Rectangle = new Rectangle(10, 23, 1, 1);
static public const SMALL_BACKGROUND_SCALE9_GRID:Rectangle = new Rectangle(4, 4, 2, 2);
static public const BACK_BUTTON_SCALE9_GRID:Rectangle = new Rectangle(13, 0, 1, 28);
static public const FORWARD_BUTTON_SCALE9_GRID:Rectangle = new Rectangle(3, 0, 1, 28);
static public const POPUP_SCALE9_GRID:Rectangle = new Rectangle(14, 15, 2, 46);
static public const POPUP_HEADERED_SCALE9_GRID:Rectangle = new Rectangle(14, 112, 2, 2);
static public const POPUP_INSIDE_SCALE9_GRID:Rectangle = new Rectangle(14, 15, 2, 1);
static public const CALLOUT_SCALE9_GRID:Rectangle = new Rectangle(14, 14, 2, 16);
static public const ITEM_RENDERER_SCALE9_GRID:Rectangle = new Rectangle(17, 22, 4, 10);
static public const ITEM_RENDERER_RANK_SCALE9_GRID:Rectangle = new Rectangle(270, 50, 2, 1);
static public const INSET_ITEM_RENDERER_MIDDLE_SCALE9_GRID:Rectangle = new Rectangle(2, 2, 1, 40);
static public const INSET_ITEM_RENDERER_FIRST_SCALE9_GRID:Rectangle = new Rectangle(7, 7, 1, 35);
static public const INSET_ITEM_RENDERER_LAST_SCALE9_GRID:Rectangle = new Rectangle(7, 2, 1, 35);
static public const INSET_ITEM_RENDERER_SINGLE_SCALE9_GRID:Rectangle = new Rectangle(7, 7, 1, 30);
static public const TAB_SCALE9_GRID:Rectangle = new Rectangle(15, 15, 3, 2);
static public const SPINNER_LIST_SELECTION_OVERLAY_SCALE9_GRID:Rectangle = new Rectangle(2, 6, 1, 32);
static public const HORIZONTAL_SCROLL_BAR_THUMB_SCALE9_GRID:Rectangle = new Rectangle(4, 0, 4, 5);
static public const VERTICAL_SCROLL_BAR_THUMB_SCALE9_GRID:Rectangle = new Rectangle(0, 4, 5, 4);
static public const SHADOW_SIDE_SCALE9_GRID:Rectangle = new Rectangle(2, 2, 14, 14);
static public const HEADER_SKIN_TEXTURE_REGION:Rectangle = new Rectangle(1, 1, 128, 64);
static public const RIBBON_SCALE9_GRID:Rectangle = new Rectangle(92, 60, 6, 6);
static public const ROUND_MEDIUM_SCALE9_GRID:Rectangle = new Rectangle(18, 18, 2, 2);
static public const ROUND_SMALL_SCALE9_GRID:Rectangle = new Rectangle(11, 11, 1, 1);

/**
 * @private
 * The theme's custom style name for item renderers in a SpinnerList.
 */
protected static const THEME_STYLE_NAME_SPINNER_LIST_ITEM_RENDERER:String = "metal-works-mobile-spinner-list-item-renderer";

/**
 * @private
 * The theme's custom style name for item renderers in a PickerList.
 */
protected static const THEME_STYLE_NAME_TABLET_PICKER_LIST_ITEM_RENDERER:String = "metal-works-mobile-tablet-picker-list-item-renderer";

/**
 * @private
 * The theme's custom style name for buttons in an Alert's button group.
 */
protected static const THEME_STYLE_NAME_ALERT_BUTTON_GROUP_BUTTON:String = "metal-works-mobile-alert-button-group-button";

/**
 * @private
 * The theme's custom style name for the thumb of a horizontal SimpleScrollBar.
 */
protected static const THEME_STYLE_NAME_HORIZONTAL_SIMPLE_SCROLL_BAR_THUMB:String = "metal-works-mobile-horizontal-simple-scroll-bar-thumb";

/**
 * @private
 * The theme's custom style name for the thumb of a vertical SimpleScrollBar.
 */
protected static const THEME_STYLE_NAME_VERTICAL_SIMPLE_SCROLL_BAR_THUMB:String = "metal-works-mobile-vertical-simple-scroll-bar-thumb";

/**
 * @private
 * The theme's custom style name for the minimum track of a horizontal slider.
 */
protected static const THEME_STYLE_NAME_HORIZONTAL_SLIDER_MINIMUM_TRACK:String = "metal-works-mobile-horizontal-slider-minimum-track";

/**
 * @private
 * The theme's custom style name for the maximum track of a horizontal slider.
 */
protected static const THEME_STYLE_NAME_HORIZONTAL_SLIDER_MAXIMUM_TRACK:String = "metal-works-mobile-horizontal-slider-maximum-track";

/**
 * @private
 * The theme's custom style name for the minimum track of a vertical slider.
 */
protected static const THEME_STYLE_NAME_VERTICAL_SLIDER_MINIMUM_TRACK:String = "metal-works-mobile-vertical-slider-minimum-track";

/**
 * @private
 * The theme's custom style name for the maximum track of a vertical slider.
 */
protected static const THEME_STYLE_NAME_VERTICAL_SLIDER_MAXIMUM_TRACK:String = "metal-works-mobile-vertical-slider-maximum-track";

/**
 * @private
 * The theme's custom style name for the item renderer of the DateTimeSpinner's SpinnerLists.
 */
protected static const THEME_STYLE_NAME_DATE_TIME_SPINNER_LIST_ITEM_RENDERER:String = "metal-works-mobile-date-time-spinner-list-item-renderer";

/**
 * The default global text renderer factory for this theme creates a
 * TextBlockTextRenderer.
 */
protected static function textRendererFactory():ITextRenderer
{
	return new ShadowLabel();
}

/**
 * The default global text editor factory for this theme creates a
 * StageTextTextEditor.
 */
protected static function textEditorFactory():ITextEditor
{
	return new StageTextTextEditor();
}

/**
 * The text editor factory for a TextArea creates a
 * TextFieldTextEditorViewPort.
 */
protected static function textAreaTextEditorFactory():ITextEditorViewPort
{
	return new TextFieldTextEditorViewPort();
}

/**
 * The text editor factory for a NumericStepper creates a
 * TextBlockTextEditor.
 */
protected static function stepperTextEditorFactory():TextBlockTextEditor
{
	//we're only using this text editor in the NumericStepper because
	//isEditable is false on the TextInput. this text editor is not
	//suitable for mobile use if the TextInput needs to be editable
	//because it can't use the soft keyboard or other mobile-friendly UI
	return new TextBlockTextEditor();
}

/**
 * The pop-up factory for a PickerList creates a SpinnerList.
 */
protected static function pickerListSpinnerListFactory():SpinnerList
{
	return new SpinnerList();
}

/**
 * This theme's scroll bar type is SimpleScrollBar.
 */
protected static function scrollBarFactory():SimpleScrollBar
{
	return new SimpleScrollBar();
}

protected static function popUpOverlayFactory():DisplayObject
{
	var quad:Quad = new Quad(100, 100, MODAL_OVERLAY_COLOR);
	quad.alpha = MODAL_OVERLAY_ALPHA;
	return quad;
}

/**
 * Constructor.
 */
public function MainTheme()
{
	super();
	new FontRegistor();
	initialize();
}

/**
 * A smaller font size for details.
 */
public var smallFontSize:int;

/**
 * A normal font size.
 */
public var regularFontSize:int;
/**
 * A game font size.
 */
public var gameFontSize:int;

/**
 * A larger font size for headers.
 */
public var largeFontSize:int;

/**
 * An extra large font size.
 */
public var extraLargeFontSize:int;

/**
 * The size, in pixels, of major regions in the grid. Used for sizing
 * containers and larger UI controls.
 */
public var gridSize:int;

/**
 * The size, in pixels, of minor regions in the grid. Used for larger
 * padding and gaps.
 */
public var gutterSize:int;

/**
 * The size, in pixels, of smaller padding and gaps within the major
 * regions in the grid.
 */
public var smallGutterSize:int;

/**
 * The size, in pixels, of smaller padding and gaps within controls.
 */
public var smallControlGutterSize:int;

/**
 * The width, in pixels, of UI controls that span across multiple grid regions.
 */
public var wideControlSize:int;

/**
 * The size, in pixels, of a typical UI control.
 */
public var controlSize:int;

/**
 * The size, in pixels, of smaller UI controls.
 */
public var smallControlSize:int;

/**
 * The size, in pixels, of borders;
 */
public var borderSize:int;

public var popUpFillSize:int;
public var calloutBackgroundMinSize:int;
public var calloutArrowOverlapGap:int;
public var scrollBarGutterSize:int;

/**
 * The font styles for standard-sized, light text.
 */
public var lightFontStyles:TextFormat;

/**
 * The font styles for standard-sized, dark text.
 */
public var darkFontStyles:TextFormat;

/**
 * The font styles for standard-sized, selected text.
 */
public var selectedFontStyles:TextFormat;

/**
 * The font styles for standard-sized, light, disabled text.
 */
public var lightDisabledFontStyles:TextFormat;

/**
 * The font styles for small, light text.
 */
public var smallLightFontStyles:TextFormat;

/**
 * The font styles for small, light, disabled text.
 */
public var smallLightDisabledFontStyles:TextFormat;

/**
 * The font styles for large, light text.
 */
public var largeLightFontStyles:TextFormat;

/**
 * The font styles for large, dark text.
 */
public var largeDarkFontStyles:TextFormat;

/**
 * The font styles for large, light, disabled text.
 */
public var largeLightDisabledFontStyles:TextFormat;

/**
 * The font styles for light UI text.
 */
public var lightUIFontStyles:TextFormat;

/**
 * The font styles for dark UI text.
 */
public var darkUIFontStyles:TextFormat;

/**
 * The font styles for selected UI text.
 */
public var selectedUIFontStyles:TextFormat;

/**
 * The font styles for light, centered UI text.
 */
public var lightCenteredUIFontStyles:TextFormat;

/**
 * The font styles for light, centered, disabled UI text.
 */
public var lightCenteredDisabledUIFontStyles:TextFormat;

/**
 * The font styles for light disabled UI text.
 */
public var lightDisabledUIFontStyles:TextFormat;

/**
 * The font styles for dark, disabled UI text.
 */
public var darkDisabledUIFontStyles:TextFormat;

/**
 * The font styles for large, light UI text.
 */
public var largeLightUIFontStyles:TextFormat;

/**
 * The font styles for large, dark UI text.
 */
public var largeDarkUIFontStyles:TextFormat;

/**
 * The font styles for large, selected UI text.
 */
public var largeSelectedUIFontStyles:TextFormat;

/**
 * The font styles for large, light, disabled UI text.
 */
public var largeLightUIDisabledFontStyles:TextFormat;

/**
 * The font styles for large, dark, disabled UI text.
 */
public var largeDarkUIDisabledFontStyles:TextFormat;

/**
 * The font styles for extra-large, light UI text.
 */
public var xlargeLightUIFontStyles:TextFormat;

/**
 * The font styles for extra-large, light, disabled UI text.
 */
public var xlargeLightUIDisabledFontStyles:TextFormat;

/**
 * The font styles for standard-sized, light text for a text input.
 */
public var lightInputFontStyles:TextFormat;

/**
 * The font styles for standard-sized, light, disabled text for a text input.
 */
public var lightDisabledInputFontStyles:TextFormat;

/**
 * ScrollText uses TextField instead of FTE, so it has a separate TextFormat.
 */
public var lightScrollTextFontStyles:TextFormat;

/**
 * ScrollText uses TextField instead of FTE, so it has a separate disabled TextFormat.
 */
public var lightDisabledScrollTextFontStyles:TextFormat;

/**
 * The texture atlas that contains skins for this theme. This base class
 * does not initialize this member variable. Subclasses are expected to
 * load the assets somehow and set the <code>atlas</code> member
 * variable before calling <code>initialize()</code>.
 *
 * Initializes the textures by extracting them from the atlas and
 * setting up any scaling grids that are needed.
 */
public function get quadSkin() : Texture { return Assets.getTexture("theme/quad-skin", "gui"); }
public function get backgroundSliderSkin() : Texture { return Assets.getTexture("theme/slider-background-skin", "gui"); }
public function get backgroundSkinTexture() : Texture { return Assets.getTexture("theme/background-skin", "gui"); }
public function get backgroundDisabledSkinTexture() : Texture { return Assets.getTexture("theme/background-disabled-skin", "gui"); }
public function get backgroundInsetSkinTexture() : Texture { return Assets.getTexture("theme/background-inset-skin", "gui"); }
public function get backgroundInsetDisabledSkinTexture() : Texture { return Assets.getTexture("theme/background-inset-disabled-skin", "gui"); }
public function get backgroundInsetFocusedSkinTexture() : Texture { return Assets.getTexture("theme/background-focused-skin", "gui"); }
public function get backgroundInsetDangerSkinTexture() : Texture { return Assets.getTexture("theme/background-inset-danger-skin", "gui"); }
public function get backgroundLightBorderSkinTexture() : Texture { return Assets.getTexture("theme/background-light-border-skin", "gui"); }
public function get backgroundDarkBorderSkinTexture() : Texture { return Assets.getTexture("theme/background-dark-border-skin", "gui"); }
public function get backgroundDangerBorderSkinTexture() : Texture { return Assets.getTexture("theme/background-danger-border-skin", "gui"); }

public function get buttonUpSkinTexture() : Texture { return Assets.getTexture("theme/button-normal-up-skin", "gui"); }
public function get buttonDownSkinTexture() : Texture { return Assets.getTexture("theme/button-normal-down-skin", "gui"); }
public function get buttonDangerUpSkinTexture() : Texture { return Assets.getTexture("theme/button-danger-up-skin", "gui"); }
public function get buttonDangerDownSkinTexture() : Texture { return Assets.getTexture("theme/button-danger-down-skin", "gui"); }
public function get buttonNeutralUpSkinTexture() : Texture { return Assets.getTexture("theme/button-neutral-up-skin", "gui"); }
public function get buttonNeutralDownSkinTexture() : Texture { return Assets.getTexture("theme/button-neutral-down-skin", "gui"); }
public function get buttonHilightUpSkinTexture() : Texture { return Assets.getTexture("theme/button-hilight-up-skin", "gui"); }
public function get buttonHilightDownSkinTexture() : Texture { return Assets.getTexture("theme/button-hilight-down-skin", "gui"); }
public function get buttonDisabledSkinTexture() : Texture { return Assets.getTexture("theme/button-disabled-skin", "gui"); }
public function get buttonSmallUpSkinTexture() : Texture { return Assets.getTexture("theme/button-small-up-skin", "gui"); }
public function get buttonSmallDownSkinTexture() : Texture { return Assets.getTexture("theme/button-small-down-skin", "gui"); }
public function get buttonSmallDangerUpSkinTexture() : Texture { return Assets.getTexture("theme/button-small-danger-up-skin", "gui"); }
public function get buttonSmallDangerDownSkinTexture() : Texture { return Assets.getTexture("theme/button-small-danger-down-skin", "gui"); }
public function get buttonSmallNeutralUpSkinTexture() : Texture { return Assets.getTexture("theme/button-small-neutral-up-skin", "gui"); }
public function get buttonSmallNeutralDownSkinTexture() : Texture { return Assets.getTexture("theme/button-small-neutral-down-skin", "gui"); }
public function get buttonSmallDarkUpSkinTexture() : Texture { return Assets.getTexture("theme/button-small-dark-up-skin", "gui"); }
public function get buttonSmallDarkDownSkinTexture() : Texture { return Assets.getTexture("theme/button-small-dark-down-skin", "gui"); }
public function get buttonSmallHilightUpSkinTexture() : Texture { return Assets.getTexture("theme/button-small-hilight-up-skin", "gui"); }
public function get buttonSmallHilightDownSkinTexture() : Texture { return Assets.getTexture("theme/button-small-hilight-down-skin", "gui"); }
public function get buttonSmallDisabledSkinTexture() : Texture { return Assets.getTexture("theme/button-small-disabled-skin", "gui"); }
public function get buttonSelectedUpSkinTexture() : Texture { return Assets.getTexture("theme/toggle-button-selected-up-skin", "gui"); }
public function get buttonSelectedDisabledSkinTexture() : Texture { return Assets.getTexture("theme/toggle-button-selected-disabled-skin", "gui"); }
public function get buttonCallToActionUpSkinTexture() : Texture { return Assets.getTexture("theme/call-to-action-button-up-skin", "gui"); }
public function get buttonCallToActionDownSkinTexture() : Texture { return Assets.getTexture("theme/call-to-action-button-down-skin", "gui"); }
public function get buttonBackUpSkinTexture() : Texture { return Assets.getTexture("theme/back-button-up-skin", "gui"); }
public function get buttonBackDownSkinTexture() : Texture { return Assets.getTexture("theme/back-button-down-skin", "gui"); }
public function get buttonBackDisabledSkinTexture() : Texture { return Assets.getTexture("theme/back-button-disabled-skin", "gui"); }
public function get buttonForwardUpSkinTexture() : Texture { return Assets.getTexture("theme/forward-button-up-skin", "gui"); }
public function get buttonForwardDownSkinTexture() : Texture { return Assets.getTexture("theme/forward-button-down-skin", "gui"); }
public function get buttonForwardDisabledSkinTexture() : Texture { return Assets.getTexture("theme/forward-button-disabled-skin", "gui"); }

public function get tabUpSkinTexture() : Texture { return Assets.getTexture("theme/tab-up-skin", "gui"); }
public function get tabDownSkinTexture() : Texture { return Assets.getTexture("theme/tab-selected-skin", "gui"); }
public function get tabSelectedSkinTexture() : Texture { return Assets.getTexture("theme/tab-selected-skin", "gui"); }
public function get tabDisabledSkinTexture() : Texture { return Assets.getTexture("theme/tab-disabled-skin", "gui"); }

public function get pickerListButtonIconTexture() : Texture { return Assets.getTexture("theme/picker-list-button-icon", "gui"); }
public function get pickerListButtonSelectedIconTexture() : Texture { return Assets.getTexture("theme/picker-list-button-selected-icon", "gui"); }
public function get pickerListButtonIconDisabledTexture() : Texture { return Assets.getTexture("theme/picker-list-button-disabled-icon", "gui"); }
public function get pickerListItemSelectedIconTexture() : Texture { return Assets.getTexture("theme/picker-list-item-renderer-selected-icon", "gui"); }

public function get spinnerListSelectionOverlaySkinTexture() : Texture { return Assets.getTexture("theme/spinner-list-selection-overlay-skin", "gui"); }

public function get checkUpIconTexture() : Texture { return Assets.getTexture("theme/check-up-icon", "gui"); }
public function get checkDownIconTexture() : Texture { return Assets.getTexture("theme/check-down-icon", "gui"); }
public function get checkDisabledIconTexture() : Texture { return Assets.getTexture("theme/check-disabled-icon", "gui"); }
public function get checkSelectedUpIconTexture() : Texture { return Assets.getTexture("theme/check-selected-up-icon", "gui"); }
public function get checkSelectedDownIconTexture() : Texture { return Assets.getTexture("theme/check-selected-down-icon", "gui"); }
public function get checkSelectedDisabledIconTexture() : Texture { return Assets.getTexture("theme/check-selected-disabled-icon", "gui"); }

public function get radioUpIconTexture() : Texture { return this.checkUpIconTexture; }
public function get radioDownIconTexture() : Texture { return this.checkDownIconTexture; }
public function get radioDisabledIconTexture() : Texture { return this.checkDisabledIconTexture; }
public function get radioSelectedUpIconTexture() : Texture { return Assets.getTexture("theme/radio-selected-up-icon", "gui"); }
public function get radioSelectedDownIconTexture() : Texture { return Assets.getTexture("theme/radio-selected-down-icon", "gui"); }
public function get radioSelectedDisabledIconTexture() : Texture { return Assets.getTexture("theme/radio-selected-disabled-icon", "gui"); }

public function get pageIndicatorSelectedSkinTexture() : Texture { return Assets.getTexture("theme/page-indicator-selected-symbol", "gui"); }
public function get pageIndicatorNormalSkinTexture() : Texture { return Assets.getTexture("theme/page-indicator-symbol", "gui"); }

public function get searchIconTexture() : Texture { return Assets.getTexture("theme/search-icon", "gui"); }
public function get searchIconDisabledTexture() : Texture { return Assets.getTexture("theme/search-disabled-icon", "gui"); }

public function get itemRendererUpSkinTexture() : Texture { return Assets.getTexture("theme/item-renderer-up-skin", "gui"); }
public function get itemRendererSelectedSkinTexture() : Texture { return Assets.getTexture("theme/item-renderer-selected-skin", "gui"); }
public function get itemRendererDisabledSkinTexture() : Texture { return Assets.getTexture("theme/item-renderer-disabled-skin", "gui"); }
public function get itemRendererDangerSkinTexture() : Texture { return Assets.getTexture("theme/item-renderer-danger-skin", "gui"); }
public function get insetItemRendererUpSkinTexture() : Texture { return Assets.getTexture("theme/inset-item-renderer-up-skin", "gui"); }
public function get insetItemRendererSelectedSkinTexture() : Texture { return Assets.getTexture("theme/inset-item-renderer-selected-up-skin", "gui"); }
public function get insetItemRendererFirstUpSkinTexture() : Texture { return Assets.getTexture("theme/first-inset-item-renderer-up-skin", "gui"); }
public function get insetItemRendererFirstSelectedSkinTexture() : Texture { return Assets.getTexture("theme/first-inset-item-renderer-selected-up-skin", "gui"); }
public function get insetItemRendererLastUpSkinTexture() : Texture { return Assets.getTexture("theme/last-inset-item-renderer-up-skin", "gui"); }
public function get insetItemRendererLastSelectedSkinTexture() : Texture { return Assets.getTexture("theme/last-inset-item-renderer-selected-up-skin", "gui"); }
public function get insetItemRendererSingleUpSkinTexture() : Texture { return Assets.getTexture("theme/single-inset-item-renderer-up-skin", "gui"); }
public function get insetItemRendererSingleSelectedSkinTexture() : Texture { return Assets.getTexture("theme/single-inset-item-renderer-selected-up-skin", "gui"); }
public function get popupBackgroundSkinTexture() : Texture { return Assets.getTexture("theme/popup-background-skin", "gui"); }
public function get popupHeaderedBackgroundSkinTexture() : Texture { return Assets.getTexture("theme/popup-headered-background-skin", "gui"); }
public function get popupInsideBackgroundSkinTexture() : Texture { return Assets.getTexture("theme/popup-inside-background-skin", "gui"); }
public function get headerBackgroundSkinTexture() : Texture { return Assets.getTexture("theme/header-background-skin", "gui"); }
public function get headerPopupBackgroundSkinTexture() : Texture { return Assets.getTexture("theme/header-popup-background-skin", "gui"); }
public function get roundMediumSkin() : Texture { return Assets.getTexture("theme/round-medium-skin", "gui"); }
public function get roundMediumInnerSkin() : Texture { return Assets.getTexture("theme/round-medium-inner-skin", "gui"); }
public function get roundSmallSkin() : Texture { return Assets.getTexture("theme/round-small-skin", "gui"); }
public function get roundSmallInnerSkin() : Texture { return Assets.getTexture("theme/round-small-inner-skin", "gui"); }

public function get calloutTopArrowSkinTexture() : Texture { return Assets.getTexture("theme/callout-arrow-top-skin", "gui"); }
public function get calloutRightArrowSkinTexture() : Texture { return Assets.getTexture("theme/callout-arrow-right-skin", "gui"); }
public function get calloutBottomArrowSkinTexture() : Texture { return Assets.getTexture("theme/callout-arrow-bottom-skin", "gui"); }
public function get calloutLeftArrowSkinTexture() : Texture { return Assets.getTexture("theme/callout-arrow-left-skin", "gui"); }
public function get dangerCalloutTopArrowSkinTexture() : Texture { return Assets.getTexture("theme/danger-callout-arrow-top-skin", "gui"); }
public function get dangerCalloutRightArrowSkinTexture() : Texture { return Assets.getTexture("theme/danger-callout-arrow-right-skin", "gui"); }
public function get dangerCalloutBottomArrowSkinTexture() : Texture { return Assets.getTexture("theme/danger-callout-arrow-bottom-skin", "gui"); }
public function get dangerCalloutLeftArrowSkinTexture() : Texture { return Assets.getTexture("theme/danger-callout-arrow-left-skin", "gui"); }

public function get horizontalScrollBarThumbSkinTexture() : Texture { return Assets.getTexture("theme/horizontal-simple-scroll-bar-thumb-skin", "gui"); }
public function get verticalScrollBarThumbSkinTexture() : Texture { return Assets.getTexture("theme/vertical-simple-scroll-bar-thumb-skin", "gui"); }

public function get listDrillDownAccessoryTexture() : Texture { return Assets.getTexture("theme/item-renderer-drill-down-accessory-icon", "gui"); }
public function get listDrillDownAccessorySelectedTexture() : Texture { return Assets.getTexture("theme/item-renderer-drill-down-accessory-selected-icon", "gui"); }
	
/*public function get playPauseButtonPlayUpIconTexture() : Texture { return Assets.getTexture("theme/play-pause-toggle-button-play-up-icon", "gui"); }
public function get playPauseButtonPlayDownIconTexture() : Texture { return Assets.getTexture("theme/play-pause-toggle-button-play-down-icon", "gui"); }
public function get playPauseButtonPauseUpIconTexture() : Texture { return Assets.getTexture("theme/play-pause-toggle-button-pause-up-icon", "gui"); }
public function get playPauseButtonPauseDownIconTexture() : Texture { return Assets.getTexture("theme/play-pause-toggle-button-pause-down-icon", "gui"); }
public function get overlayPlayPauseButtonPlayUpIconTexture() : Texture { return Assets.getTexture("theme/overlay-play-pause-toggle-button-play-up-icon", "gui"); }
public function get overlayPlayPauseButtonPlayDownIconTexture() : Texture { return Assets.getTexture("theme/overlay-play-pause-toggle-button-play-down-icon", "gui"); }
public function get fullScreenToggleButtonEnterUpIconTexture() : Texture { return Assets.getTexture("theme/full-screen-toggle-button-enter-up-icon", "gui"); }
public function get fullScreenToggleButtonEnterDownIconTexture() : Texture { return Assets.getTexture("theme/full-screen-toggle-button-enter-down-icon", "gui"); }
public function get fullScreenToggleButtonExitUpIconTexture() : Texture { return Assets.getTexture("theme/full-screen-toggle-button-exit-up-icon", "gui"); }
public function get fullScreenToggleButtonExitDownIconTexture() : Texture { return Assets.getTexture("theme/full-screen-toggle-button-exit-down-icon", "gui"); }*/
public function get muteToggleButtonMutedUpIconTexture() : Texture { return Assets.getTexture("theme/mute-toggle-button-muted-up-icon", "gui"); }
public function get muteToggleButtonMutedDownIconTexture() : Texture { return Assets.getTexture("theme/mute-toggle-button-muted-down-icon", "gui"); }
public function get muteToggleButtonLoudUpIconTexture() : Texture { return Assets.getTexture("theme/mute-toggle-button-loud-up-icon", "gui"); }
public function get muteToggleButtonLoudDownIconTexture() : Texture { return Assets.getTexture("theme/mute-toggle-button-loud-down-icon", "gui"); }
public function get seekSliderProgressSkinTexture() : Texture { return Assets.getTexture("theme/seek-slider-progress-skin", "gui"); }

//protected var volumeSliderMinimumTrackSkinTexture:Texture;
//protected var volumeSliderMaximumTrackSkinTexture:Texture;


/**
 * Initializes the theme. Expected to be called by subclasses after the
 * assets have been loaded and the skin texture atlas has been created.
 */
protected function initialize():void
{
	this.initializeDimensions();
	this.initializeFonts();
	this.initializeGlobals();
	this.initializeStage();
	this.initializeStyleProviders();
}

/**
 * Sets the stage background color.
 */
protected function initializeStage():void
{
	this.starling.stage.color = PRIMARY_BACKGROUND_COLOR;
	this.starling.nativeStage.color = 0;// PRIMARY_BACKGROUND_COLOR;
}

/**
 * Initializes global variables (not including global style providers).
 */
protected function initializeGlobals():void
{
	FeathersControl.defaultTextRendererFactory = textRendererFactory;
	FeathersControl.defaultTextEditorFactory = textEditorFactory;

	PopUpManager.overlayFactory = popUpOverlayFactory;
	Callout.stagePadding = this.smallGutterSize;
}

/**
 * Initializes common values used for setting the dimensions of components.
 */
protected function initializeDimensions():void
{
	this.gridSize = 44;
	this.smallControlGutterSize = 6;
	this.smallGutterSize = 8;
	this.gutterSize = 12;
	this.controlSize = 36;//28;
	this.smallControlSize = 12;
	this.popUpFillSize = 276;
	this.calloutBackgroundMinSize = 12;
	this.calloutArrowOverlapGap = -2;
	this.scrollBarGutterSize = 2;
	this.wideControlSize = this.gridSize * 3 + this.gutterSize * 2;
	this.borderSize = 1;
}

/**
 * Initializes font sizes and formats.
 */
protected function initializeFonts():void
{
	this.smallFontSize = 40;
	this.gameFontSize = 56//12;
	this.regularFontSize = 56;// 12
	this.largeFontSize = 64;
	this.extraLargeFontSize = 72;

	this.lightFontStyles = new TextFormat(FONT_NAME, this.regularFontSize, LIGHT_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
	this.darkFontStyles = new TextFormat(FONT_NAME, this.regularFontSize, DARK_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
	this.lightDisabledFontStyles = new TextFormat(FONT_NAME, this.regularFontSize, LIGHT_DISABLED_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
	this.selectedFontStyles = new TextFormat(FONT_NAME, this.regularFontSize, SELECTED_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);

	this.smallLightFontStyles = new TextFormat(FONT_NAME, this.smallFontSize, LIGHT_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
	this.smallLightDisabledFontStyles = new TextFormat(FONT_NAME, this.smallFontSize, LIGHT_DISABLED_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);

	this.largeLightFontStyles = new TextFormat(FONT_NAME, this.largeFontSize, LIGHT_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
	this.largeDarkFontStyles = new TextFormat(FONT_NAME, this.largeFontSize, DARK_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
	this.largeLightDisabledFontStyles = new TextFormat(FONT_NAME, this.largeFontSize, LIGHT_DISABLED_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);

	this.lightUIFontStyles = new TextFormat(FONT_NAME, this.regularFontSize, LIGHT_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
	this.lightUIFontStyles.bold = true;
	this.darkUIFontStyles = new TextFormat(FONT_NAME, this.regularFontSize, DARK_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
	this.darkUIFontStyles.bold = true;
	this.selectedUIFontStyles = new TextFormat(FONT_NAME, this.regularFontSize, SELECTED_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
	this.selectedUIFontStyles.bold = true;
	this.lightDisabledUIFontStyles = new TextFormat(FONT_NAME, this.regularFontSize, LIGHT_DISABLED_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
	this.lightDisabledUIFontStyles.bold = true;
	this.darkDisabledUIFontStyles = new TextFormat(FONT_NAME, this.regularFontSize, DARK_DISABLED_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
	this.darkDisabledUIFontStyles.bold = true;
	this.lightCenteredUIFontStyles = new TextFormat(FONT_NAME, this.regularFontSize, LIGHT_TEXT_COLOR, HorizontalAlign.CENTER, VerticalAlign.TOP);
	this.lightCenteredUIFontStyles.bold = true;
	this.lightCenteredDisabledUIFontStyles = new TextFormat(FONT_NAME, this.regularFontSize, LIGHT_TEXT_COLOR, HorizontalAlign.CENTER, VerticalAlign.TOP);
	this.lightCenteredDisabledUIFontStyles.bold = true;

	this.largeLightUIFontStyles = new TextFormat(FONT_NAME, this.largeFontSize, LIGHT_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
	this.largeLightUIFontStyles.bold = true;
	this.largeDarkUIFontStyles = new TextFormat(FONT_NAME, this.largeFontSize, DARK_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
	this.largeDarkUIFontStyles.bold = true;
	this.largeSelectedUIFontStyles = new TextFormat(FONT_NAME, this.largeFontSize, SELECTED_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
	this.largeSelectedUIFontStyles.bold = true;
	this.largeLightUIDisabledFontStyles = new TextFormat(FONT_NAME, this.largeFontSize, LIGHT_DISABLED_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
	this.largeLightUIDisabledFontStyles.bold = true;
	this.largeDarkUIDisabledFontStyles = new TextFormat(FONT_NAME, this.largeFontSize, DARK_DISABLED_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
	this.largeDarkUIDisabledFontStyles.bold = true;

	this.xlargeLightUIFontStyles = new TextFormat(FONT_NAME, this.extraLargeFontSize, LIGHT_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
	this.xlargeLightUIFontStyles.bold = true;
	this.xlargeLightUIDisabledFontStyles = new TextFormat(FONT_NAME, this.extraLargeFontSize, LIGHT_DISABLED_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
	this.xlargeLightUIDisabledFontStyles.bold = true;

	this.lightInputFontStyles = new TextFormat(FONT_NAME_STACK, this.regularFontSize, LIGHT_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
	this.lightDisabledInputFontStyles = new TextFormat(FONT_NAME_STACK, this.regularFontSize, LIGHT_DISABLED_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);

	this.lightScrollTextFontStyles = new TextFormat(FONT_NAME_STACK, this.regularFontSize, LIGHT_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
	this.lightDisabledScrollTextFontStyles = new TextFormat(FONT_NAME_STACK, this.regularFontSize, LIGHT_DISABLED_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
}

/**
 * Sets global style providers for all components.
 */
protected function initializeStyleProviders():void
{
	//alert
	this.getStyleProviderForClass(Alert).defaultStyleFunction = this.setAlertStyles;
	this.getStyleProviderForClass(ButtonGroup).setFunctionForStyleName(Alert.DEFAULT_CHILD_STYLE_NAME_BUTTON_GROUP, this.setAlertButtonGroupStyles);
	this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_ALERT_BUTTON_GROUP_BUTTON, this.setAlertButtonGroupButtonStyles);
	this.getStyleProviderForClass(Header).setFunctionForStyleName(Alert.DEFAULT_CHILD_STYLE_NAME_HEADER, this.setPopUpHeaderStyles);

	//auto-complete
	this.getStyleProviderForClass(AutoComplete).defaultStyleFunction = this.setTextInputStyles;
	this.getStyleProviderForClass(List).setFunctionForStyleName(AutoComplete.DEFAULT_CHILD_STYLE_NAME_LIST, this.setDropDownListStyles);

	//button
	this.getStyleProviderForClass(Button).defaultStyleFunction = this.setButtonStyles;
	//this.getStyleProviderForClass(Button).setFunctionForStyleName(Button.ALTERNATE_STYLE_NAME_CALL_TO_ACTION_BUTTON, this.setCallToActionButtonStyles);
	this.getStyleProviderForClass(Button).setFunctionForStyleName(Button.ALTERNATE_STYLE_NAME_QUIET_BUTTON, this.setQuietButtonStyles);
	this.getStyleProviderForClass(Button).setFunctionForStyleName(Button.ALTERNATE_STYLE_NAME_DANGER_BUTTON, this.setDangerButtonStyles);
	this.getStyleProviderForClass(Button).setFunctionForStyleName(Button.ALTERNATE_STYLE_NAME_BACK_BUTTON, this.setBackButtonStyles);
	this.getStyleProviderForClass(Button).setFunctionForStyleName(Button.ALTERNATE_STYLE_NAME_FORWARD_BUTTON, this.setForwardButtonStyles);
	this.getStyleProviderForClass(Button).setFunctionForStyleName(STYLE_BUTTON_HILIGHT, this.setHilightButtonStyles);
	this.getStyleProviderForClass(Button).setFunctionForStyleName(STYLE_BUTTON_NEUTRAL, this.setNeutralButtonStyles);
	
	this.getStyleProviderForClass(Button).setFunctionForStyleName(STYLE_BUTTON_SMALL_NORMAL, this.setSmallNormalButtonStyles);
	this.getStyleProviderForClass(Button).setFunctionForStyleName(STYLE_BUTTON_SMALL_DANGER, this.setSmallDangerButtonStyles);
	this.getStyleProviderForClass(Button).setFunctionForStyleName(STYLE_BUTTON_SMALL_HILIGHT, this.setSmallHilightButtonStyles);
	this.getStyleProviderForClass(Button).setFunctionForStyleName(STYLE_BUTTON_SMALL_NEUTRAL, this.setSmallNeutralButtonStyles);
	this.getStyleProviderForClass(Button).setFunctionForStyleName(STYLE_BUTTON_SMALL_DARK, this.setSmallDarkButtonStyles);

	//button group
	this.getStyleProviderForClass(ButtonGroup).defaultStyleFunction = this.setButtonGroupStyles;
	this.getStyleProviderForClass(Button).setFunctionForStyleName(ButtonGroup.DEFAULT_CHILD_STYLE_NAME_BUTTON, this.setButtonGroupButtonStyles);
	this.getStyleProviderForClass(ToggleButton).setFunctionForStyleName(ButtonGroup.DEFAULT_CHILD_STYLE_NAME_BUTTON, this.setButtonGroupButtonStyles);

	//callout
	this.getStyleProviderForClass(Callout).defaultStyleFunction = this.setCalloutStyles;

	//check
	this.getStyleProviderForClass(Check).defaultStyleFunction = this.setCheckStyles;

	//date time spinner
	this.getStyleProviderForClass(DateTimeSpinner).defaultStyleFunction = this.setDateTimeSpinnerStyles;
	this.getStyleProviderForClass(DefaultListItemRenderer).setFunctionForStyleName(THEME_STYLE_NAME_DATE_TIME_SPINNER_LIST_ITEM_RENDERER, this.setDateTimeSpinnerListItemRendererStyles);

	//drawers
	this.getStyleProviderForClass(Drawers).defaultStyleFunction = this.setDrawersStyles;

	//grouped list
	this.getStyleProviderForClass(GroupedList).defaultStyleFunction = this.setGroupedListStyles;
	this.getStyleProviderForClass(GroupedList).setFunctionForStyleName(GroupedList.ALTERNATE_STYLE_NAME_INSET_GROUPED_LIST, this.setInsetGroupedListStyles);
	this.getStyleProviderForClass(DefaultGroupedListItemRenderer).defaultStyleFunction = this.setItemRendererStyles;
	this.getStyleProviderForClass(DefaultGroupedListItemRenderer).setFunctionForStyleName(GroupedList.ALTERNATE_CHILD_STYLE_NAME_INSET_ITEM_RENDERER, this.setInsetGroupedListMiddleItemRendererStyles);
	this.getStyleProviderForClass(DefaultGroupedListItemRenderer).setFunctionForStyleName(GroupedList.ALTERNATE_CHILD_STYLE_NAME_INSET_FIRST_ITEM_RENDERER, this.setInsetGroupedListFirstItemRendererStyles);
	this.getStyleProviderForClass(DefaultGroupedListItemRenderer).setFunctionForStyleName(GroupedList.ALTERNATE_CHILD_STYLE_NAME_INSET_LAST_ITEM_RENDERER, this.setInsetGroupedListLastItemRendererStyles);
	this.getStyleProviderForClass(DefaultGroupedListItemRenderer).setFunctionForStyleName(GroupedList.ALTERNATE_CHILD_STYLE_NAME_INSET_SINGLE_ITEM_RENDERER, this.setInsetGroupedListSingleItemRendererStyles);
	this.getStyleProviderForClass(DefaultGroupedListItemRenderer).setFunctionForStyleName(DefaultGroupedListItemRenderer.ALTERNATE_STYLE_NAME_DRILL_DOWN, this.setDrillDownItemRendererStyles);
	this.getStyleProviderForClass(DefaultGroupedListItemRenderer).setFunctionForStyleName(DefaultGroupedListItemRenderer.ALTERNATE_STYLE_NAME_CHECK, this.setCheckItemRendererStyles);

	//header
	this.getStyleProviderForClass(Header).defaultStyleFunction = this.setHeaderStyles;

	//header and footer renderers for grouped list
	this.getStyleProviderForClass(DefaultGroupedListHeaderOrFooterRenderer).defaultStyleFunction = this.setGroupedListHeaderRendererStyles;
	this.getStyleProviderForClass(DefaultGroupedListHeaderOrFooterRenderer).setFunctionForStyleName(GroupedList.DEFAULT_CHILD_STYLE_NAME_FOOTER_RENDERER, this.setGroupedListFooterRendererStyles);
	this.getStyleProviderForClass(DefaultGroupedListHeaderOrFooterRenderer).setFunctionForStyleName(GroupedList.ALTERNATE_CHILD_STYLE_NAME_INSET_HEADER_RENDERER, this.setInsetGroupedListHeaderRendererStyles);
	this.getStyleProviderForClass(DefaultGroupedListHeaderOrFooterRenderer).setFunctionForStyleName(GroupedList.ALTERNATE_CHILD_STYLE_NAME_INSET_FOOTER_RENDERER, this.setInsetGroupedListFooterRendererStyles);

	//labels
	this.getStyleProviderForClass(Label).defaultStyleFunction = this.setLabelStyles;
	this.getStyleProviderForClass(Label).setFunctionForStyleName(Label.ALTERNATE_STYLE_NAME_HEADING, this.setHeadingLabelStyles);
	this.getStyleProviderForClass(Label).setFunctionForStyleName(Label.ALTERNATE_STYLE_NAME_DETAIL, this.setDetailLabelStyles);

	//layout group
	this.getStyleProviderForClass(LayoutGroup).setFunctionForStyleName(LayoutGroup.ALTERNATE_STYLE_NAME_TOOLBAR, setToolbarLayoutGroupStyles);

	//list
	this.getStyleProviderForClass(List).defaultStyleFunction = this.setListStyles;
	this.getStyleProviderForClass(DefaultListItemRenderer).defaultStyleFunction = this.setItemRendererStyles;
	this.getStyleProviderForClass(DefaultListItemRenderer).setFunctionForStyleName(DefaultListItemRenderer.ALTERNATE_STYLE_NAME_DRILL_DOWN, this.setDrillDownItemRendererStyles);
	this.getStyleProviderForClass(DefaultListItemRenderer).setFunctionForStyleName(DefaultListItemRenderer.ALTERNATE_STYLE_NAME_CHECK, this.setCheckItemRendererStyles);

	//numeric stepper
	this.getStyleProviderForClass(NumericStepper).defaultStyleFunction = this.setNumericStepperStyles;
	this.getStyleProviderForClass(TextInput).setFunctionForStyleName(NumericStepper.DEFAULT_CHILD_STYLE_NAME_TEXT_INPUT, this.setNumericStepperTextInputStyles);
	this.getStyleProviderForClass(Button).setFunctionForStyleName(NumericStepper.DEFAULT_CHILD_STYLE_NAME_DECREMENT_BUTTON, this.setNumericStepperButtonStyles);
	this.getStyleProviderForClass(Button).setFunctionForStyleName(NumericStepper.DEFAULT_CHILD_STYLE_NAME_INCREMENT_BUTTON, this.setNumericStepperButtonStyles);

	//page indicator
	this.getStyleProviderForClass(PageIndicator).defaultStyleFunction = this.setPageIndicatorStyles;

	//panel
	this.getStyleProviderForClass(Panel).defaultStyleFunction = this.setPanelStyles;
	this.getStyleProviderForClass(Header).setFunctionForStyleName(Panel.DEFAULT_CHILD_STYLE_NAME_HEADER, this.setPopUpHeaderStyles);

	//panel screen
	this.getStyleProviderForClass(PanelScreen).defaultStyleFunction = this.setPanelScreenStyles;
	this.getStyleProviderForClass(Header).setFunctionForStyleName(PanelScreen.DEFAULT_CHILD_STYLE_NAME_HEADER, this.setPanelScreenHeaderStyles);

	//picker list (see also: list and item renderers)
	this.getStyleProviderForClass(PickerList).defaultStyleFunction = this.setPickerListStyles;
	this.getStyleProviderForClass(List).setFunctionForStyleName(PickerList.DEFAULT_CHILD_STYLE_NAME_LIST, this.setPickerListPopUpListStyles);
	this.getStyleProviderForClass(Button).setFunctionForStyleName(PickerList.DEFAULT_CHILD_STYLE_NAME_BUTTON, this.setPickerListButtonStyles);
	this.getStyleProviderForClass(ToggleButton).setFunctionForStyleName(PickerList.DEFAULT_CHILD_STYLE_NAME_BUTTON, this.setPickerListButtonStyles);
	this.getStyleProviderForClass(DefaultListItemRenderer).setFunctionForStyleName(THEME_STYLE_NAME_TABLET_PICKER_LIST_ITEM_RENDERER, this.setPickerListItemRendererStyles);

	//progress bar
	this.getStyleProviderForClass(ProgressBar).defaultStyleFunction = this.setProgressBarStyles;

	//radio
	this.getStyleProviderForClass(Radio).defaultStyleFunction = this.setRadioStyles;

	//scroll container
	this.getStyleProviderForClass(ScrollContainer).defaultStyleFunction = this.setScrollContainerStyles;
	this.getStyleProviderForClass(ScrollContainer).setFunctionForStyleName(ScrollContainer.ALTERNATE_STYLE_NAME_TOOLBAR, this.setToolbarScrollContainerStyles);

	//scroll screen
	this.getStyleProviderForClass(ScrollScreen).defaultStyleFunction = this.setScrollScreenStyles;

	//scroll text
	this.getStyleProviderForClass(ScrollText).defaultStyleFunction = this.setScrollTextStyles;

	//simple scroll bar
	this.getStyleProviderForClass(SimpleScrollBar).defaultStyleFunction = this.setSimpleScrollBarStyles;
	this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_HORIZONTAL_SIMPLE_SCROLL_BAR_THUMB, this.setHorizontalSimpleScrollBarThumbStyles);
	this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_VERTICAL_SIMPLE_SCROLL_BAR_THUMB, this.setVerticalSimpleScrollBarThumbStyles);

	//slider
	this.getStyleProviderForClass(Slider).defaultStyleFunction = this.setSliderStyles;
	this.getStyleProviderForClass(Button).setFunctionForStyleName(Slider.DEFAULT_CHILD_STYLE_NAME_THUMB, this.setSimpleButtonStyles);
	this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_HORIZONTAL_SLIDER_MINIMUM_TRACK, this.setHorizontalSliderMinimumTrackStyles);
	this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_HORIZONTAL_SLIDER_MAXIMUM_TRACK, this.setHorizontalSliderMaximumTrackStyles);
	this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_VERTICAL_SLIDER_MINIMUM_TRACK, this.setVerticalSliderMinimumTrackStyles);
	this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_VERTICAL_SLIDER_MAXIMUM_TRACK, this.setVerticalSliderMaximumTrackStyles);

	//spinner list
	this.getStyleProviderForClass(SpinnerList).defaultStyleFunction = this.setSpinnerListStyles;
	this.getStyleProviderForClass(DefaultListItemRenderer).setFunctionForStyleName(THEME_STYLE_NAME_SPINNER_LIST_ITEM_RENDERER, this.setSpinnerListItemRendererStyles);

	//tab bar
	this.getStyleProviderForClass(TabBar).defaultStyleFunction = this.setTabBarStyles;
	this.getStyleProviderForClass(ToggleButton).setFunctionForStyleName(TabBar.DEFAULT_CHILD_STYLE_NAME_TAB, this.setTabStyles);

	//text input
	this.getStyleProviderForClass(TextInput).defaultStyleFunction = this.setTextInputStyles;
	this.getStyleProviderForClass(TextInput).setFunctionForStyleName(TextInput.ALTERNATE_STYLE_NAME_SEARCH_TEXT_INPUT, this.setSearchTextInputStyles);
	this.getStyleProviderForClass(TextCallout).setFunctionForStyleName(TextInput.DEFAULT_CHILD_STYLE_NAME_ERROR_CALLOUT, this.setTextInputErrorCalloutStyles);

	//text area
	this.getStyleProviderForClass(TextArea).defaultStyleFunction = this.setTextAreaStyles;
	this.getStyleProviderForClass(TextFieldTextEditorViewPort).setFunctionForStyleName(TextArea.DEFAULT_CHILD_STYLE_NAME_TEXT_EDITOR, this.setTextAreaTextEditorStyles);
	this.getStyleProviderForClass(TextCallout).setFunctionForStyleName(TextArea.DEFAULT_CHILD_STYLE_NAME_ERROR_CALLOUT, this.setTextAreaErrorCalloutStyles);

	//text callout
	this.getStyleProviderForClass(TextCallout).defaultStyleFunction = this.setTextCalloutStyles;

	//toggle button
	this.getStyleProviderForClass(ToggleButton).defaultStyleFunction = this.setButtonStyles;
	this.getStyleProviderForClass(ToggleButton).setFunctionForStyleName(Button.ALTERNATE_STYLE_NAME_QUIET_BUTTON, this.setQuietButtonStyles);

	//toggle switch
	this.getStyleProviderForClass(ToggleSwitch).defaultStyleFunction = this.setToggleSwitchStyles;
	this.getStyleProviderForClass(Button).setFunctionForStyleName(ToggleSwitch.DEFAULT_CHILD_STYLE_NAME_THUMB, this.setSimpleButtonStyles);
	this.getStyleProviderForClass(ToggleButton).setFunctionForStyleName(ToggleSwitch.DEFAULT_CHILD_STYLE_NAME_THUMB, this.setSimpleButtonStyles);
	this.getStyleProviderForClass(Button).setFunctionForStyleName(ToggleSwitch.DEFAULT_CHILD_STYLE_NAME_ON_TRACK, this.setToggleSwitchTrackStyles);
	//we don't need a style function for the off track in this theme
	//the toggle switch layout uses a single track

	//media controls

	/*//play/pause toggle button
	this.getStyleProviderForClass(PlayPauseToggleButton).defaultStyleFunction = this.setPlayPauseToggleButtonStyles;
	this.getStyleProviderForClass(PlayPauseToggleButton).setFunctionForStyleName(PlayPauseToggleButton.ALTERNATE_STYLE_NAME_OVERLAY_PLAY_PAUSE_TOGGLE_BUTTON, this.setOverlayPlayPauseToggleButtonStyles);

	//full screen toggle button
	this.getStyleProviderForClass(FullScreenToggleButton).defaultStyleFunction = this.setFullScreenToggleButtonStyles;

	//mute toggle button
	this.getStyleProviderForClass(MuteToggleButton).defaultStyleFunction = this.setMuteToggleButtonStyles;*/

	//seek slider
	this.getStyleProviderForClass(SeekSlider).defaultStyleFunction = this.setSeekSliderStyles;
	this.getStyleProviderForClass(Button).setFunctionForStyleName(SeekSlider.DEFAULT_CHILD_STYLE_NAME_THUMB, this.setSeekSliderThumbStyles);
	this.getStyleProviderForClass(Button).setFunctionForStyleName(SeekSlider.DEFAULT_CHILD_STYLE_NAME_MINIMUM_TRACK, this.setSeekSliderMinimumTrackStyles);
	this.getStyleProviderForClass(Button).setFunctionForStyleName(SeekSlider.DEFAULT_CHILD_STYLE_NAME_MAXIMUM_TRACK, this.setSeekSliderMaximumTrackStyles);

/*	//volume slider
	this.getStyleProviderForClass(VolumeSlider).defaultStyleFunction = this.setVolumeSliderStyles;
	this.getStyleProviderForClass(Button).setFunctionForStyleName(VolumeSlider.DEFAULT_CHILD_STYLE_NAME_THUMB, this.setVolumeSliderThumbStyles);
	this.getStyleProviderForClass(Button).setFunctionForStyleName(VolumeSlider.DEFAULT_CHILD_STYLE_NAME_MINIMUM_TRACK, this.setVolumeSliderMinimumTrackStyles);
	this.getStyleProviderForClass(Button).setFunctionForStyleName(VolumeSlider.DEFAULT_CHILD_STYLE_NAME_MAXIMUM_TRACK, this.setVolumeSliderMaximumTrackStyles);
*/
}

protected function pageIndicatorNormalSymbolFactory():DisplayObject
{
	var symbol:ImageLoader = new ImageLoader();
	symbol.source = this.pageIndicatorNormalSkinTexture;
	return symbol;
}

protected function pageIndicatorSelectedSymbolFactory():DisplayObject
{
	var symbol:ImageLoader = new ImageLoader();
	symbol.source = this.pageIndicatorSelectedSkinTexture;
	return symbol;
}

//-------------------------
// Shared
//-------------------------

protected function setScrollerStyles(scroller:Scroller):void
{
	scroller.horizontalScrollBarFactory = scrollBarFactory;
	scroller.verticalScrollBarFactory = scrollBarFactory;
}

protected function setSimpleButtonStyles(button:Button):void
{
	var skin:ImageSkin = new ImageSkin(this.buttonUpSkinTexture);
	skin.setTextureForState(ButtonState.DOWN, this.buttonDownSkinTexture);
	skin.setTextureForState(ButtonState.DISABLED, this.buttonDisabledSkinTexture);
	skin.scale9Grid = BUTTON_SCALE9_GRID;
	skin.width = this.controlSize;
	skin.height = this.controlSize;
	skin.minWidth = this.controlSize;
	skin.minHeight = this.controlSize;
	button.defaultSkin = skin;

	button.hasLabelTextRenderer = false;

	button.minTouchWidth = this.gridSize;
	button.minTouchHeight = this.gridSize;
}

protected function setDropDownListStyles(list:List):void
{
	var backgroundSkin:ImageSkin = new ImageSkin(this.itemRendererUpSkinTexture);
	backgroundSkin.scale9Grid = ITEM_RENDERER_SCALE9_GRID;
	backgroundSkin.width = this.gridSize;
	backgroundSkin.height = this.gridSize;
	backgroundSkin.minWidth = this.gridSize;
	backgroundSkin.minHeight = this.gridSize;
	list.backgroundSkin = backgroundSkin;

	var layout:VerticalLayout = new VerticalLayout();
	layout.horizontalAlign = HorizontalAlign.JUSTIFY;
	layout.maxRowCount = 4;
	list.layout = layout;
}

//-------------------------
// Alert
//-------------------------

protected function setAlertStyles(alert:Alert):void
{
	this.setScrollerStyles(alert);

	var backgroundSkin:Image = new Image(this.backgroundLightBorderSkinTexture);
	backgroundSkin.scale9Grid = SMALL_BACKGROUND_SCALE9_GRID;
	alert.backgroundSkin = backgroundSkin;

	alert.fontStyles = this.lightFontStyles;

	alert.paddingTop = this.gutterSize;
	alert.paddingRight = this.gutterSize;
	alert.paddingBottom = this.smallGutterSize;
	alert.paddingLeft = this.gutterSize;
	alert.outerPadding = this.borderSize;
	alert.gap = this.smallGutterSize;
	alert.maxWidth = this.popUpFillSize;
	alert.maxHeight = this.popUpFillSize;
}

//see Panel section for Header styles

protected function setAlertButtonGroupStyles(group:ButtonGroup):void
{
	group.direction = Direction.HORIZONTAL;
	group.horizontalAlign = HorizontalAlign.CENTER;
	group.verticalAlign = VerticalAlign.JUSTIFY;
	group.distributeButtonSizes = false;
	group.gap = this.smallGutterSize;
	group.padding = this.smallGutterSize;
	group.customButtonStyleName = THEME_STYLE_NAME_ALERT_BUTTON_GROUP_BUTTON;
}

protected function setAlertButtonGroupButtonStyles(button:Button):void
{
	this.setButtonStyles(button);

	var skin:ImageSkin = ImageSkin(button.defaultSkin);
	skin.minWidth = 2 * this.controlSize;
}

//-------------------------
// Button
//-------------------------

protected function setBaseButtonStyles(button:Button):void
{
	button.paddingTop = this.smallControlGutterSize;
	button.paddingBottom = this.smallControlGutterSize + 12;
	button.paddingLeft = this.gutterSize;
	button.paddingRight = this.gutterSize;
	button.gap = this.smallControlGutterSize;
	button.minGap = this.smallControlGutterSize;
	button.minTouchWidth = this.gridSize;
	button.minTouchHeight = this.gridSize;
	
	//button.iconOffsetX = button.labelOffsetX = 2;
	//button.iconOffsetY = button.labelOffsetY = -6;
}

protected function setButtonStyles(button:Button):void
{
	var skin:ImageSkin = new ImageSkin(this.buttonUpSkinTexture);
	skin.setTextureForState(ButtonState.DOWN, this.buttonDownSkinTexture);
	skin.setTextureForState(ButtonState.DISABLED, this.buttonDisabledSkinTexture);
	if( button is ToggleButton )
	{
		//for convenience, this function can style both a regular button
		//and a toggle button
		skin.selectedTexture = this.buttonSelectedUpSkinTexture;
		skin.setTextureForState(ButtonState.DISABLED_AND_SELECTED, this.buttonSelectedDisabledSkinTexture);
	}
	skin.scale9Grid = BUTTON_SCALE9_GRID;
	skin.width = this.controlSize;
	skin.height = this.controlSize;
	skin.minWidth = this.controlSize;
	skin.minHeight = this.controlSize;
	button.defaultSkin = skin;

	button.fontStyles = this.darkUIFontStyles;
	button.disabledFontStyles = this.darkDisabledUIFontStyles;

	this.setBaseButtonStyles(button);
}

protected function setCallToActionButtonStyles(button:Button):void
{
	var skin:ImageSkin = new ImageSkin(this.buttonCallToActionUpSkinTexture);
	skin.setTextureForState(ButtonState.DOWN, this.buttonCallToActionDownSkinTexture);
	skin.setTextureForState(ButtonState.DISABLED, this.buttonDisabledSkinTexture);
	skin.scale9Grid = BUTTON_SCALE9_GRID;
	skin.width = this.controlSize;
	skin.height = this.controlSize;
	skin.minWidth = this.controlSize;
	skin.minHeight = this.controlSize;
	button.defaultSkin = skin;

	button.fontStyles = this.darkUIFontStyles;
	button.disabledFontStyles = this.darkDisabledUIFontStyles;

	this.setBaseButtonStyles(button);
}

protected function setQuietButtonStyles(button:Button):void
{
	var defaultSkin:Quad = new Quad(this.controlSize, this.controlSize, 0xff00ff);
	defaultSkin.alpha = 0;
	button.defaultSkin = defaultSkin;

	var otherSkin:ImageSkin = new ImageSkin(null);
	otherSkin.setTextureForState(ButtonState.DOWN, this.buttonDownSkinTexture);
	otherSkin.setTextureForState(ButtonState.DISABLED, this.buttonDisabledSkinTexture);
	button.downSkin = otherSkin;
	button.disabledSkin = otherSkin;
	if(button is ToggleButton)
	{
		//for convenience, this function can style both a regular button
		//and a toggle button
		var toggleButton:ToggleButton = ToggleButton(button);
		otherSkin.selectedTexture = this.buttonSelectedUpSkinTexture;
		toggleButton.defaultSelectedSkin = otherSkin;
	}
	otherSkin.scale9Grid = BUTTON_SCALE9_GRID;
	otherSkin.width = this.controlSize;
	otherSkin.height = this.controlSize;
	otherSkin.minWidth = this.controlSize;
	otherSkin.minHeight = this.controlSize;

	button.fontStyles = this.lightUIFontStyles;
	button.setFontStylesForState(ButtonState.DOWN, this.darkUIFontStyles);
	button.setFontStylesForState(ButtonState.DISABLED, this.lightDisabledUIFontStyles);
	if(button is ToggleButton)
	{
		//for convenience, this function can style both a regular button
		//and a toggle button
		toggleButton.selectedFontStyles = this.darkUIFontStyles;
		toggleButton.setFontStylesForState(ButtonState.DISABLED_AND_SELECTED, this.darkDisabledUIFontStyles);
	}

	button.paddingTop = this.smallControlGutterSize;
	button.paddingBottom = this.smallControlGutterSize;
	button.paddingLeft = this.smallGutterSize;
	button.paddingRight = this.smallGutterSize;
	button.gap = this.smallControlGutterSize;
	button.minGap = this.smallControlGutterSize;
	button.minTouchWidth = button.minTouchHeight = this.gridSize;
}

public function setDangerButtonStyles(button:Button):void {
	setButtonColorStyle(button, this.buttonDangerUpSkinTexture,			this.buttonDangerDownSkinTexture,		this.buttonDisabledSkinTexture,		BUTTON_SCALE9_GRID); }
public function setNeutralButtonStyles(button:Button):void {
	setButtonColorStyle(button, this.buttonNeutralUpSkinTexture,		this.buttonNeutralDownSkinTexture,		this.buttonDisabledSkinTexture,		BUTTON_SCALE9_GRID); }
public function setHilightButtonStyles(button:Button):void {
	setButtonColorStyle(button, this.buttonHilightUpSkinTexture,		this.buttonHilightDownSkinTexture,		this.buttonDisabledSkinTexture,		BUTTON_SCALE9_GRID); }

public function setSmallNormalButtonStyles(button:Button):void {
	setButtonColorStyle(button, this.buttonSmallUpSkinTexture,			this.buttonSmallDownSkinTexture,		this.buttonSmallDisabledSkinTexture, BUTTON_SMALL_SCALE9_GRID); }
public function setSmallDangerButtonStyles(button:Button):void {
	setButtonColorStyle(button, this.buttonSmallDangerUpSkinTexture,	this.buttonSmallDangerDownSkinTexture,	this.buttonSmallDisabledSkinTexture, BUTTON_SMALL_SCALE9_GRID); }
public function setSmallHilightButtonStyles(button:Button):void {
	setButtonColorStyle(button, this.buttonSmallHilightUpSkinTexture,	this.buttonSmallHilightDownSkinTexture,	this.buttonSmallDisabledSkinTexture, BUTTON_SMALL_SCALE9_GRID); }
public function setSmallNeutralButtonStyles(button:Button):void {
	setButtonColorStyle(button, this.buttonSmallNeutralUpSkinTexture,	this.buttonSmallNeutralDownSkinTexture,	this.buttonSmallDisabledSkinTexture, BUTTON_SMALL_SCALE9_GRID); }
public function setSmallDarkButtonStyles(button:Button):void {
	setButtonColorStyle(button, this.buttonSmallDarkUpSkinTexture,		this.buttonSmallDarkDownSkinTexture,	this.buttonSmallDisabledSkinTexture, BUTTON_SMALL_SCALE9_GRID); }

public function setButtonColorStyle(button:Button, upTexture:Texture, downTexture:Texture, disableTexture:Texture, scaleGrid:Rectangle):void
{
	var skin:ImageSkin = new ImageSkin(upTexture);
	skin.setTextureForState(ButtonState.DOWN, downTexture);
	skin.setTextureForState(ButtonState.DISABLED, disableTexture);
	//skin.pixelSnapping = false
	skin.scale9Grid = scaleGrid;
	skin.width = this.controlSize;
	skin.height = this.controlSize;
	skin.minWidth = this.controlSize;
	skin.minHeight = this.controlSize;
	button.defaultSkin = skin;

	button.fontStyles = this.darkUIFontStyles;
	button.disabledFontStyles = this.darkDisabledUIFontStyles;

	this.setBaseButtonStyles(button);
}

protected function setBackButtonStyles(button:Button):void
{
	var skin:ImageSkin = new ImageSkin(this.buttonBackUpSkinTexture);
	skin.setTextureForState(ButtonState.DOWN, this.buttonBackDownSkinTexture);
	skin.setTextureForState(ButtonState.DISABLED, this.buttonBackDisabledSkinTexture);
	skin.scale9Grid = BACK_BUTTON_SCALE9_GRID;
	skin.width = this.controlSize;
	skin.height = this.controlSize;
	skin.minWidth = this.controlSize;
	skin.minHeight = this.controlSize;
	button.defaultSkin = skin;

	button.fontStyles = this.darkUIFontStyles;
	button.disabledFontStyles = this.darkDisabledUIFontStyles;

	this.setBaseButtonStyles(button);

	button.paddingLeft = this.gutterSize + this.smallGutterSize;
}

protected function setForwardButtonStyles(button:Button):void
{
	var skin:ImageSkin = new ImageSkin(this.buttonForwardUpSkinTexture);
	skin.setTextureForState(ButtonState.DOWN, this.buttonForwardDownSkinTexture);
	skin.setTextureForState(ButtonState.DISABLED, this.buttonForwardDisabledSkinTexture);
	skin.scale9Grid = FORWARD_BUTTON_SCALE9_GRID;
	skin.width = this.controlSize;
	skin.height = this.controlSize;
	skin.minWidth = this.controlSize;
	skin.minHeight = this.controlSize;
	button.defaultSkin = skin;

	button.fontStyles = this.darkUIFontStyles;
	button.disabledFontStyles = this.darkDisabledUIFontStyles;

	this.setBaseButtonStyles(button);

	button.paddingRight = this.gutterSize + this.smallGutterSize;
}

//-------------------------
// ButtonGroup
//-------------------------

protected function setButtonGroupStyles(group:ButtonGroup):void
{
	group.gap = this.smallGutterSize;
}

protected function setButtonGroupButtonStyles(button:Button):void
{
	var skin:ImageSkin = new ImageSkin(this.buttonUpSkinTexture);
	skin.setTextureForState(ButtonState.DOWN, this.buttonDownSkinTexture);
	skin.setTextureForState(ButtonState.DISABLED, this.buttonDisabledSkinTexture);
	if(button is ToggleButton)
	{
		//for convenience, this function can style both a regular button
		//and a toggle button
		skin.selectedTexture = this.buttonSelectedUpSkinTexture;
		skin.setTextureForState(ButtonState.DISABLED_AND_SELECTED, this.buttonSelectedDisabledSkinTexture);
	}
	skin.scale9Grid = BUTTON_SCALE9_GRID;
	skin.width = this.popUpFillSize;
	skin.height = this.gridSize;
	skin.minWidth = this.gridSize;
	skin.minHeight = this.gridSize;
	button.defaultSkin = skin;

	button.fontStyles = this.largeDarkUIFontStyles;
	button.disabledFontStyles = this.largeDarkUIDisabledFontStyles;

	button.paddingTop = this.smallGutterSize;
	button.paddingBottom = this.smallGutterSize;
	button.paddingLeft = this.gutterSize;
	button.paddingRight = this.gutterSize;
	button.gap = this.smallGutterSize;
	button.minGap = this.smallGutterSize;
	button.horizontalAlign = HorizontalAlign.CENTER;
	button.minTouchWidth = this.gridSize;
	button.minTouchHeight = this.gridSize;
}

//-------------------------
// Callout
//-------------------------

protected function setCalloutStyles(callout:Callout):void
{
	var backgroundSkin:Image = new Image(this.backgroundLightBorderSkinTexture);
	backgroundSkin.scale9Grid = SMALL_BACKGROUND_SCALE9_GRID;
	backgroundSkin.width = this.calloutBackgroundMinSize;
	backgroundSkin.height = this.calloutBackgroundMinSize;
	callout.backgroundSkin = backgroundSkin;

	var topArrowSkin:Image = new Image(this.calloutTopArrowSkinTexture);
	callout.topArrowSkin = topArrowSkin;
	callout.topArrowGap = this.calloutArrowOverlapGap;

	var rightArrowSkin:Image = new Image(this.calloutRightArrowSkinTexture);
	callout.rightArrowSkin = rightArrowSkin;
	callout.rightArrowGap = this.calloutArrowOverlapGap;

	var bottomArrowSkin:Image = new Image(this.calloutBottomArrowSkinTexture);
	callout.bottomArrowSkin = bottomArrowSkin;
	callout.bottomArrowGap = this.calloutArrowOverlapGap;

	var leftArrowSkin:Image = new Image(this.calloutLeftArrowSkinTexture);
	callout.leftArrowSkin = leftArrowSkin;
	callout.leftArrowGap = this.calloutArrowOverlapGap;

	callout.padding = this.smallGutterSize;
}

protected function setDangerCalloutStyles(callout:Callout):void
{
	var backgroundSkin:Image = new Image(this.backgroundDangerBorderSkinTexture);
	backgroundSkin.scale9Grid = SMALL_BACKGROUND_SCALE9_GRID;
	backgroundSkin.width = this.calloutBackgroundMinSize;
	backgroundSkin.height = this.calloutBackgroundMinSize;
	callout.backgroundSkin = backgroundSkin;

	var topArrowSkin:Image = new Image(this.dangerCalloutTopArrowSkinTexture);
	callout.topArrowSkin = topArrowSkin;
	callout.topArrowGap = this.calloutArrowOverlapGap;

	var rightArrowSkin:Image = new Image(this.dangerCalloutRightArrowSkinTexture);
	callout.rightArrowSkin = rightArrowSkin;
	callout.rightArrowGap = this.calloutArrowOverlapGap;

	var bottomArrowSkin:Image = new Image(this.dangerCalloutBottomArrowSkinTexture);
	callout.bottomArrowSkin = bottomArrowSkin;
	callout.bottomArrowGap = this.calloutArrowOverlapGap;

	var leftArrowSkin:Image = new Image(this.dangerCalloutLeftArrowSkinTexture);
	callout.leftArrowSkin = leftArrowSkin;
	callout.leftArrowGap = this.calloutArrowOverlapGap;

	callout.padding = this.smallGutterSize;
}

//-------------------------
// Check
//-------------------------

protected function setCheckStyles(check:Check):void
{
	var skin:Quad = new Quad(this.controlSize, this.controlSize);
	skin.alpha = 0;
	check.defaultSkin = skin;

	var icon:ImageSkin = new ImageSkin(this.checkUpIconTexture);
	icon.selectedTexture = this.checkSelectedUpIconTexture;
	icon.setTextureForState(ButtonState.DOWN, this.checkDownIconTexture);
	icon.setTextureForState(ButtonState.DISABLED, this.checkDisabledIconTexture);
	icon.setTextureForState(ButtonState.DOWN_AND_SELECTED, this.checkSelectedDownIconTexture);
	icon.setTextureForState(ButtonState.DISABLED_AND_SELECTED, this.checkSelectedDisabledIconTexture);
	check.defaultIcon = icon;

	check.fontStyles = this.lightUIFontStyles;
	check.disabledFontStyles = this.lightDisabledUIFontStyles;

	check.horizontalAlign = HorizontalAlign.LEFT;
	check.gap = this.smallControlGutterSize;
	check.minGap = this.smallControlGutterSize;
	check.minTouchWidth = this.gridSize;
	check.minTouchHeight = this.gridSize;
}

//-------------------------
// DateTimeSpinner
//-------------------------

protected function setDateTimeSpinnerStyles(spinner:DateTimeSpinner):void
{
	spinner.customItemRendererStyleName = THEME_STYLE_NAME_DATE_TIME_SPINNER_LIST_ITEM_RENDERER;
}

protected function setDateTimeSpinnerListItemRendererStyles(itemRenderer:DefaultListItemRenderer):void
{
	this.setSpinnerListItemRendererStyles(itemRenderer);

	itemRenderer.accessoryPosition = RelativePosition.LEFT;
	itemRenderer.gap = this.smallGutterSize;
	itemRenderer.minGap = this.smallGutterSize;
	itemRenderer.accessoryGap = this.smallGutterSize;
	itemRenderer.minAccessoryGap = this.smallGutterSize;
}

//-------------------------
// Drawers
//-------------------------

protected function setDrawersStyles(drawers:Drawers):void
{
	var overlaySkin:Quad = new Quad(10, 10, DRAWER_OVERLAY_COLOR);
	overlaySkin.alpha = DRAWER_OVERLAY_ALPHA;
	drawers.overlaySkin = overlaySkin;

	var topDrawerDivider:Quad = new Quad(this.borderSize, this.borderSize, DRAWER_OVERLAY_COLOR);
	drawers.topDrawerDivider = topDrawerDivider;

	var rightDrawerDivider:Quad = new Quad(this.borderSize, this.borderSize, DRAWER_OVERLAY_COLOR);
	drawers.rightDrawerDivider = rightDrawerDivider;

	var bottomDrawerDivider:Quad = new Quad(this.borderSize, this.borderSize, DRAWER_OVERLAY_COLOR);
	drawers.bottomDrawerDivider = bottomDrawerDivider;

	var leftDrawerDivider:Quad = new Quad(this.borderSize, this.borderSize, DRAWER_OVERLAY_COLOR);
	drawers.leftDrawerDivider = leftDrawerDivider;
}

//-------------------------
// GroupedList
//-------------------------

protected function setGroupedListStyles(list:GroupedList):void
{
	this.setScrollerStyles(list);
	var backgroundSkin:Quad = new Quad(this.gridSize, this.gridSize, LIST_BACKGROUND_COLOR);
	list.backgroundSkin = backgroundSkin;
}

//see List section for item renderer styles

protected function setGroupedListHeaderRendererStyles(renderer:DefaultGroupedListHeaderOrFooterRenderer):void
{
	renderer.backgroundSkin = new Quad(1, 1, GROUPED_LIST_HEADER_BACKGROUND_COLOR);

	renderer.fontStyles = this.lightUIFontStyles;
	renderer.disabledFontStyles = this.lightDisabledUIFontStyles;

	renderer.horizontalAlign = HorizontalAlign.LEFT;
	renderer.paddingTop = this.smallGutterSize;
	renderer.paddingBottom = this.smallGutterSize;
	renderer.paddingLeft = this.smallGutterSize + this.gutterSize;
	renderer.paddingRight = this.gutterSize;
}

protected function setGroupedListFooterRendererStyles(renderer:DefaultGroupedListHeaderOrFooterRenderer):void
{
	renderer.backgroundSkin = new Quad(1, 1, GROUPED_LIST_FOOTER_BACKGROUND_COLOR);

	renderer.fontStyles = this.lightFontStyles;
	renderer.disabledFontStyles = this.lightDisabledFontStyles;

	renderer.horizontalAlign = HorizontalAlign.CENTER;
	renderer.paddingTop = renderer.paddingBottom = this.smallGutterSize;
	renderer.paddingLeft = this.smallGutterSize + this.gutterSize;
	renderer.paddingRight = this.gutterSize;
}

protected function setInsetGroupedListStyles(list:GroupedList):void
{
	list.customItemRendererStyleName = GroupedList.ALTERNATE_CHILD_STYLE_NAME_INSET_ITEM_RENDERER;
	list.customFirstItemRendererStyleName = GroupedList.ALTERNATE_CHILD_STYLE_NAME_INSET_FIRST_ITEM_RENDERER;
	list.customLastItemRendererStyleName = GroupedList.ALTERNATE_CHILD_STYLE_NAME_INSET_LAST_ITEM_RENDERER;
	list.customSingleItemRendererStyleName = GroupedList.ALTERNATE_CHILD_STYLE_NAME_INSET_SINGLE_ITEM_RENDERER;
	list.customHeaderRendererStyleName = GroupedList.ALTERNATE_CHILD_STYLE_NAME_INSET_HEADER_RENDERER;
	list.customFooterRendererStyleName = GroupedList.ALTERNATE_CHILD_STYLE_NAME_INSET_FOOTER_RENDERER;

	var layout:VerticalLayout = new VerticalLayout();
	layout.useVirtualLayout = true;
	layout.padding = this.smallGutterSize;
	layout.gap = 0;
	layout.horizontalAlign = HorizontalAlign.JUSTIFY;
	layout.verticalAlign = VerticalAlign.TOP;
	list.layout = layout;
}

protected function setInsetGroupedListItemRendererStyles(itemRenderer:DefaultGroupedListItemRenderer, defaultSkinTexture:Texture, selectedAndDownSkinTexture:Texture, scale9Grid:Rectangle):void
{
	var skin:ImageSkin = new ImageSkin(defaultSkinTexture);
	skin.selectedTexture = selectedAndDownSkinTexture;
	skin.setTextureForState(ButtonState.DOWN, selectedAndDownSkinTexture);
	skin.scale9Grid = scale9Grid;
	skin.width = this.gridSize;
	skin.height = this.gridSize;
	skin.minWidth = this.gridSize;
	skin.minHeight = this.gridSize;
	itemRenderer.defaultSkin = skin;

	itemRenderer.fontStyles = this.largeLightFontStyles;
	itemRenderer.disabledFontStyles = this.largeLightDisabledFontStyles;
	itemRenderer.selectedFontStyles = this.largeDarkFontStyles;
	itemRenderer.setFontStylesForState(ButtonState.DOWN, this.largeDarkFontStyles);

	itemRenderer.iconLabelFontStyles = this.lightFontStyles;
	itemRenderer.iconLabelDisabledFontStyles = this.lightDisabledFontStyles;
	itemRenderer.iconLabelSelectedFontStyles = this.darkFontStyles;
	itemRenderer.setIconLabelFontStylesForState(ButtonState.DOWN, this.darkFontStyles);

	itemRenderer.accessoryLabelFontStyles = this.lightFontStyles;
	itemRenderer.accessoryLabelDisabledFontStyles = this.lightDisabledFontStyles;
	itemRenderer.accessoryLabelSelectedFontStyles = this.darkFontStyles;
	itemRenderer.setAccessoryLabelFontStylesForState(ButtonState.DOWN, this.darkFontStyles);

	itemRenderer.horizontalAlign = HorizontalAlign.LEFT;
	itemRenderer.paddingTop = this.smallGutterSize;
	itemRenderer.paddingBottom = this.smallGutterSize;
	itemRenderer.paddingLeft = this.gutterSize + this.smallGutterSize;
	itemRenderer.paddingRight = this.gutterSize;
	itemRenderer.gap = this.gutterSize;
	itemRenderer.minGap = this.gutterSize;
	itemRenderer.iconPosition = RelativePosition.LEFT;
	itemRenderer.accessoryGap = Number.POSITIVE_INFINITY;
	itemRenderer.minAccessoryGap = this.gutterSize;
	itemRenderer.accessoryPosition = RelativePosition.RIGHT;
	itemRenderer.minTouchWidth = this.gridSize;
	itemRenderer.minTouchHeight = this.gridSize;
}

protected function setInsetGroupedListMiddleItemRendererStyles(renderer:DefaultGroupedListItemRenderer):void
{
	this.setInsetGroupedListItemRendererStyles(renderer, this.insetItemRendererUpSkinTexture, this.insetItemRendererSelectedSkinTexture, INSET_ITEM_RENDERER_MIDDLE_SCALE9_GRID);
}

protected function setInsetGroupedListFirstItemRendererStyles(renderer:DefaultGroupedListItemRenderer):void
{
	this.setInsetGroupedListItemRendererStyles(renderer, this.insetItemRendererFirstUpSkinTexture, this.insetItemRendererFirstSelectedSkinTexture, INSET_ITEM_RENDERER_FIRST_SCALE9_GRID);
}

protected function setInsetGroupedListLastItemRendererStyles(renderer:DefaultGroupedListItemRenderer):void
{
	this.setInsetGroupedListItemRendererStyles(renderer, this.insetItemRendererLastUpSkinTexture, this.insetItemRendererLastSelectedSkinTexture, INSET_ITEM_RENDERER_LAST_SCALE9_GRID);
}

protected function setInsetGroupedListSingleItemRendererStyles(renderer:DefaultGroupedListItemRenderer):void
{
	this.setInsetGroupedListItemRendererStyles(renderer, this.insetItemRendererSingleUpSkinTexture, this.insetItemRendererSingleSelectedSkinTexture, INSET_ITEM_RENDERER_SINGLE_SCALE9_GRID);
}

protected function setInsetGroupedListHeaderRendererStyles(headerRenderer:DefaultGroupedListHeaderOrFooterRenderer):void
{
	var defaultSkin:Quad = new Quad(this.controlSize, this.controlSize, 0xff00ff);
	defaultSkin.alpha = 0;
	headerRenderer.backgroundSkin = defaultSkin;

	headerRenderer.fontStyles = this.lightUIFontStyles;
	headerRenderer.disabledFontStyles = this.lightDisabledUIFontStyles;

	headerRenderer.horizontalAlign = HorizontalAlign.LEFT;
	headerRenderer.paddingTop = this.smallGutterSize;
	headerRenderer.paddingBottom = this.smallGutterSize;
	headerRenderer.paddingLeft = this.gutterSize + this.smallGutterSize;
	headerRenderer.paddingRight = this.gutterSize;
}

protected function setInsetGroupedListFooterRendererStyles(footerRenderer:DefaultGroupedListHeaderOrFooterRenderer):void
{
	var defaultSkin:Quad = new Quad(this.controlSize, this.controlSize, 0xff00ff);
	defaultSkin.alpha = 0;
	footerRenderer.backgroundSkin = defaultSkin;

	footerRenderer.fontStyles = this.lightFontStyles;
	footerRenderer.disabledFontStyles = this.lightDisabledFontStyles;

	footerRenderer.horizontalAlign = HorizontalAlign.CENTER;
	footerRenderer.paddingTop = this.smallGutterSize;
	footerRenderer.paddingBottom = this.smallGutterSize;
	footerRenderer.paddingLeft = this.gutterSize + this.smallGutterSize;
	footerRenderer.paddingRight = this.gutterSize;
}

//-------------------------
// Header
//-------------------------

protected function setHeaderStyles(header:Header):void
{
	var backgroundSkin:ImageSkin = new ImageSkin(this.headerBackgroundSkinTexture);
	backgroundSkin.tileGrid = new Rectangle();
	backgroundSkin.width = this.gridSize;
	backgroundSkin.height = this.gridSize;
	backgroundSkin.minWidth = this.gridSize;
	backgroundSkin.minHeight = this.gridSize;
	header.backgroundSkin = backgroundSkin;

	header.fontStyles = this.xlargeLightUIFontStyles;
	header.disabledFontStyles = this.xlargeLightUIDisabledFontStyles;

	header.padding = this.smallGutterSize;
	header.gap = this.smallGutterSize;
	header.titleGap = this.smallGutterSize;
}

//-------------------------
// Label
//-------------------------

protected function setLabelStyles(label:Label):void
{
	label.fontStyles = this.lightFontStyles;
	label.disabledFontStyles = this.lightDisabledFontStyles;
}

protected function setHeadingLabelStyles(label:Label):void
{
	label.fontStyles = this.largeLightFontStyles;
	label.disabledFontStyles = this.largeLightDisabledFontStyles;
}

protected function setDetailLabelStyles(label:Label):void
{
	label.fontStyles = this.smallLightFontStyles;
	label.disabledFontStyles = this.smallLightDisabledFontStyles;
}

//-------------------------
// LayoutGroup
//-------------------------

protected function setToolbarLayoutGroupStyles(group:LayoutGroup):void
{
	if(!group.layout)
	{
		var layout:HorizontalLayout = new HorizontalLayout();
		layout.padding = this.smallGutterSize;
		layout.gap = this.smallGutterSize;
		layout.verticalAlign = VerticalAlign.MIDDLE;
		group.layout = layout;
	}

	var backgroundSkin:ImageSkin = new ImageSkin(this.headerBackgroundSkinTexture);
	backgroundSkin.tileGrid = new Rectangle();
	backgroundSkin.width = this.gridSize;
	backgroundSkin.height = this.gridSize;
	backgroundSkin.minWidth = this.gridSize;
	backgroundSkin.minHeight = this.gridSize;
	group.backgroundSkin = backgroundSkin;
}

//-------------------------
// List
//-------------------------

protected function setListStyles(list:List):void
{
	this.setScrollerStyles(list);
	//var backgroundSkin:Quad = new Quad(this.gridSize, this.gridSize, LIST_BACKGROUND_COLOR);
	//list.backgroundSkin = backgroundSkin;
}

protected function setItemRendererStyles(itemRenderer:BaseDefaultItemRenderer):void
{
	var skin:ImageSkin = new ImageSkin(this.itemRendererUpSkinTexture);
	skin.selectedTexture = this.itemRendererSelectedSkinTexture;
	skin.setTextureForState(ButtonState.DOWN, this.itemRendererSelectedSkinTexture);
	skin.scale9Grid = ITEM_RENDERER_SCALE9_GRID;
	skin.width = this.gridSize;
	skin.height = this.gridSize;
	skin.minWidth = this.gridSize;
	skin.minHeight = this.gridSize;
	itemRenderer.defaultSkin = skin;

	itemRenderer.fontStyles = this.largeLightFontStyles;
	itemRenderer.disabledFontStyles = this.largeLightDisabledFontStyles;
	itemRenderer.selectedFontStyles = this.largeDarkFontStyles;
	itemRenderer.setFontStylesForState(ButtonState.DOWN, this.largeDarkFontStyles);

	itemRenderer.iconLabelFontStyles = this.lightFontStyles;
	itemRenderer.iconLabelDisabledFontStyles = this.lightDisabledFontStyles;
	itemRenderer.iconLabelSelectedFontStyles = this.darkFontStyles;
	itemRenderer.setIconLabelFontStylesForState(ButtonState.DOWN, this.darkFontStyles);

	itemRenderer.accessoryLabelFontStyles = this.lightFontStyles;
	itemRenderer.accessoryLabelDisabledFontStyles = this.lightDisabledFontStyles;
	itemRenderer.accessoryLabelSelectedFontStyles = this.darkFontStyles;
	itemRenderer.setAccessoryLabelFontStylesForState(ButtonState.DOWN, this.darkFontStyles);

	itemRenderer.horizontalAlign = HorizontalAlign.LEFT;
	itemRenderer.paddingTop = this.smallGutterSize;
	itemRenderer.paddingBottom = this.smallGutterSize;
	itemRenderer.paddingLeft = this.gutterSize;
	itemRenderer.paddingRight = this.gutterSize;
	itemRenderer.gap = this.gutterSize;
	itemRenderer.minGap = this.gutterSize;
	itemRenderer.iconPosition = RelativePosition.LEFT;
	itemRenderer.accessoryGap = Number.POSITIVE_INFINITY;
	itemRenderer.minAccessoryGap = this.gutterSize;
	itemRenderer.accessoryPosition = RelativePosition.RIGHT;
	itemRenderer.minTouchWidth = this.gridSize;
	itemRenderer.minTouchHeight = this.gridSize;
}

protected function setDrillDownItemRendererStyles(itemRenderer:DefaultListItemRenderer):void
{
	this.setItemRendererStyles(itemRenderer);

	itemRenderer.itemHasAccessory = false;

	var accessorySkin:ImageSkin = new ImageSkin(this.listDrillDownAccessoryTexture);
	accessorySkin.selectedTexture = this.listDrillDownAccessorySelectedTexture;
	accessorySkin.setTextureForState(ButtonState.DOWN, this.listDrillDownAccessorySelectedTexture);
	itemRenderer.defaultAccessory = accessorySkin;
}

protected function setCheckItemRendererStyles(itemRenderer:BaseDefaultItemRenderer):void
{
	var skin:ImageSkin = new ImageSkin(this.itemRendererUpSkinTexture);
	skin.setTextureForState(ButtonState.DOWN, this.itemRendererSelectedSkinTexture);
	skin.scale9Grid = ITEM_RENDERER_SCALE9_GRID;
	skin.width = this.gridSize;
	skin.height = this.gridSize;
	skin.minWidth = this.gridSize;
	skin.minHeight = this.gridSize;
	itemRenderer.defaultSkin = skin;

	var defaultSelectedIcon:ImageLoader = new ImageLoader();
	defaultSelectedIcon.source = this.pickerListItemSelectedIconTexture;
	itemRenderer.defaultSelectedIcon = defaultSelectedIcon;
	defaultSelectedIcon.validate();

	var defaultIcon:Quad = new Quad(defaultSelectedIcon.width, defaultSelectedIcon.height, 0xff00ff);
	defaultIcon.alpha = 0;
	itemRenderer.defaultIcon = defaultIcon;

	itemRenderer.fontStyles = this.largeLightFontStyles;
	itemRenderer.disabledFontStyles = this.largeLightDisabledFontStyles;
	itemRenderer.setFontStylesForState(ButtonState.DOWN, this.largeDarkFontStyles);

	itemRenderer.iconLabelFontStyles = this.lightFontStyles;
	itemRenderer.iconLabelDisabledFontStyles = this.lightDisabledFontStyles;
	itemRenderer.setIconLabelFontStylesForState(ButtonState.DOWN, this.darkFontStyles);

	itemRenderer.accessoryLabelFontStyles = this.lightFontStyles;
	itemRenderer.accessoryLabelDisabledFontStyles = this.lightDisabledFontStyles;
	itemRenderer.setAccessoryLabelFontStylesForState(ButtonState.DOWN, this.darkFontStyles);

	itemRenderer.itemHasIcon = false;
	itemRenderer.horizontalAlign = HorizontalAlign.LEFT;
	itemRenderer.paddingTop = this.smallGutterSize;
	itemRenderer.paddingBottom = this.smallGutterSize;
	itemRenderer.paddingLeft = this.gutterSize;
	itemRenderer.paddingRight = this.gutterSize;
	itemRenderer.gap = Number.POSITIVE_INFINITY;
	itemRenderer.minGap = this.gutterSize;
	itemRenderer.iconPosition = RelativePosition.RIGHT;
	itemRenderer.accessoryGap = this.smallGutterSize;
	itemRenderer.minAccessoryGap = this.smallGutterSize;
	itemRenderer.accessoryPosition = RelativePosition.BOTTOM;
	itemRenderer.layoutOrder = ItemRendererLayoutOrder.LABEL_ACCESSORY_ICON;
	itemRenderer.minTouchWidth = this.gridSize;
	itemRenderer.minTouchHeight = this.gridSize;
}

//-------------------------
// NumericStepper
//-------------------------

protected function setNumericStepperStyles(stepper:NumericStepper):void
{
	stepper.buttonLayoutMode = StepperButtonLayoutMode.SPLIT_HORIZONTAL;
	stepper.incrementButtonLabel = "+";
	stepper.decrementButtonLabel = "-";
}

protected function setNumericStepperTextInputStyles(input:TextInput):void
{
	var backgroundSkin:ImageSkin = new ImageSkin(this.backgroundSkinTexture);
	backgroundSkin.setTextureForState(TextInputState.DISABLED, this.backgroundDisabledSkinTexture);
	backgroundSkin.setTextureForState(TextInputState.FOCUSED, this.backgroundInsetFocusedSkinTexture);
	backgroundSkin.scale9Grid = DEFAULT_BACKGROUND_SCALE9_GRID;
	backgroundSkin.width = this.controlSize;
	backgroundSkin.height = this.controlSize;
	backgroundSkin.minWidth = this.controlSize;
	backgroundSkin.minHeight = this.controlSize;
	input.backgroundSkin = backgroundSkin;

	input.textEditorFactory = stepperTextEditorFactory;
	input.fontStyles = this.lightCenteredUIFontStyles;
	input.disabledFontStyles = this.lightCenteredDisabledUIFontStyles;

	input.minTouchWidth = this.gridSize;
	input.minTouchHeight = this.gridSize;
	input.gap = this.smallControlGutterSize;
	input.paddingTop = this.smallControlGutterSize;
	input.paddingRight = this.smallGutterSize;
	input.paddingBottom = this.smallControlGutterSize;
	input.paddingLeft = this.smallGutterSize;
	input.isEditable = false;
	input.isSelectable = false;
}

protected function setNumericStepperButtonStyles(button:Button):void
{
	this.setButtonStyles(button);
	button.keepDownStateOnRollOut = true;
}

//-------------------------
// PageIndicator
//-------------------------

protected function setPageIndicatorStyles(pageIndicator:PageIndicator):void
{
	pageIndicator.normalSymbolFactory = this.pageIndicatorNormalSymbolFactory;
	pageIndicator.selectedSymbolFactory = this.pageIndicatorSelectedSymbolFactory;
	pageIndicator.gap = this.smallGutterSize;
	pageIndicator.padding = this.smallGutterSize;
	pageIndicator.minTouchWidth = this.smallControlSize * 2;
	pageIndicator.minTouchHeight = this.smallControlSize * 2;
}

//-------------------------
// Panel
//-------------------------

protected function setPanelStyles(panel:Panel):void
{
	this.setScrollerStyles(panel);

	var backgroundSkin:Image = new Image(this.backgroundLightBorderSkinTexture);
	backgroundSkin.scale9Grid = SMALL_BACKGROUND_SCALE9_GRID;
	panel.backgroundSkin = backgroundSkin;
	panel.padding = this.smallGutterSize;
	panel.outerPadding = this.borderSize;
}

protected function setPopUpHeaderStyles(header:Header):void
{
	header.padding = this.smallGutterSize;
	header.gap = this.smallGutterSize;
	header.titleGap = this.smallGutterSize;

	header.fontStyles = this.xlargeLightUIFontStyles;
	header.disabledFontStyles = this.xlargeLightUIDisabledFontStyles;

	var backgroundSkin:ImageSkin = new ImageSkin(this.headerPopupBackgroundSkinTexture);
	backgroundSkin.tileGrid = new Rectangle();
	backgroundSkin.width = this.gridSize;
	backgroundSkin.height = this.gridSize;
	backgroundSkin.minWidth = this.gridSize;
	backgroundSkin.minHeight = this.gridSize;
	header.backgroundSkin = backgroundSkin;
}

//-------------------------
// PanelScreen
//-------------------------

protected function setPanelScreenStyles(screen:PanelScreen):void
{
	this.setScrollerStyles(screen);
}

protected function setPanelScreenHeaderStyles(header:Header):void
{
	this.setHeaderStyles(header);
	header.useExtraPaddingForOSStatusBar = true;
}

//-------------------------
// PickerList
//-------------------------

protected function setPickerListStyles(list:PickerList):void
{
	if(DeviceCapabilities.isPhone(this.starling.nativeStage))
	{
		list.listFactory = pickerListSpinnerListFactory;
		list.popUpContentManager = new BottomDrawerPopUpContentManager();
	}
	else //tablet or desktop
	{
		list.popUpContentManager = new CalloutPopUpContentManager();
		list.customItemRendererStyleName = THEME_STYLE_NAME_TABLET_PICKER_LIST_ITEM_RENDERER;
	}
}

protected function setPickerListPopUpListStyles(list:List):void
{
	this.setDropDownListStyles(list);
}

protected function setPickerListItemRendererStyles(itemRenderer:BaseDefaultItemRenderer):void
{
	var skin:ImageSkin = new ImageSkin(this.itemRendererUpSkinTexture);
	skin.setTextureForState(ButtonState.DOWN, this.itemRendererSelectedSkinTexture);
	skin.scale9Grid = ITEM_RENDERER_SCALE9_GRID;
	skin.width = this.popUpFillSize;
	skin.height = this.gridSize;
	skin.minWidth = this.popUpFillSize;
	skin.minHeight = this.gridSize;
	itemRenderer.defaultSkin = skin;

	var defaultSelectedIcon:ImageLoader = new ImageLoader();
	defaultSelectedIcon.source = this.pickerListItemSelectedIconTexture;
	itemRenderer.defaultSelectedIcon = defaultSelectedIcon;
	defaultSelectedIcon.validate();

	var defaultIcon:Quad = new Quad(defaultSelectedIcon.width, defaultSelectedIcon.height, 0xff00ff);
	defaultIcon.alpha = 0;
	itemRenderer.defaultIcon = defaultIcon;

	itemRenderer.fontStyles = this.largeLightFontStyles;
	itemRenderer.disabledFontStyles = this.largeLightDisabledFontStyles;
	itemRenderer.setFontStylesForState(ButtonState.DOWN, this.largeDarkFontStyles);

	itemRenderer.iconLabelFontStyles = this.lightFontStyles;
	itemRenderer.iconLabelDisabledFontStyles = this.lightDisabledFontStyles;
	itemRenderer.setIconLabelFontStylesForState(ButtonState.DOWN, this.darkFontStyles);

	itemRenderer.accessoryLabelFontStyles = this.lightFontStyles;
	itemRenderer.accessoryLabelDisabledFontStyles = this.lightDisabledFontStyles;
	itemRenderer.setAccessoryLabelFontStylesForState(ButtonState.DOWN, this.darkFontStyles);

	itemRenderer.itemHasIcon = false;
	itemRenderer.horizontalAlign = HorizontalAlign.LEFT;
	itemRenderer.paddingTop = this.smallGutterSize;
	itemRenderer.paddingBottom = this.smallGutterSize;
	itemRenderer.paddingLeft = this.gutterSize;
	itemRenderer.paddingRight = this.gutterSize;
	itemRenderer.gap = Number.POSITIVE_INFINITY;
	itemRenderer.minGap = this.gutterSize;
	itemRenderer.iconPosition = RelativePosition.RIGHT;
	itemRenderer.accessoryGap = this.smallGutterSize;
	itemRenderer.minAccessoryGap = this.smallGutterSize;
	itemRenderer.accessoryPosition = RelativePosition.BOTTOM;
	itemRenderer.layoutOrder = ItemRendererLayoutOrder.LABEL_ACCESSORY_ICON;
	itemRenderer.minTouchWidth = this.gridSize;
	itemRenderer.minTouchHeight = this.gridSize;
}

protected function setPickerListButtonStyles(button:Button):void
{
	this.setButtonStyles(button);

	var icon:ImageSkin = new ImageSkin(this.pickerListButtonIconTexture);
	icon.selectedTexture = this.pickerListButtonSelectedIconTexture;
	icon.setTextureForState(ButtonState.DISABLED, this.pickerListButtonIconDisabledTexture);
	button.defaultIcon = icon;

	button.gap = Number.POSITIVE_INFINITY;
	button.minGap = this.gutterSize;
	button.iconPosition = RelativePosition.RIGHT;
}

//-------------------------
// ProgressBar
//-------------------------

protected function setProgressBarStyles(progress:ProgressBar):void
{
	var backgroundSkin:Image = new Image(this.backgroundSliderSkin);
	backgroundSkin.scale9Grid = SLIDER_SCALE9_GRID;
	if(progress.direction == Direction.VERTICAL)
	{
		backgroundSkin.width = this.smallControlSize;
		backgroundSkin.height = this.wideControlSize;
	}
	else
	{
		backgroundSkin.width = this.wideControlSize;
		backgroundSkin.height = this.smallControlSize;
	}
	progress.backgroundDisabledSkin = progress.backgroundSkin = backgroundSkin;

	var fillSkin:Image = new Image(Assets.getTexture("theme/slider-fill-skin", "gui"));
	fillSkin.scale9Grid = SLIDER_SCALE9_GRID;
	fillSkin.width = this.smallControlSize;
	fillSkin.height = this.smallControlSize;
	progress.fillSkin = fillSkin;

	var fillDisabledSkin:Image = new Image(Assets.getTexture("theme/slider-fill-neutral-skin", "gui"));
	fillDisabledSkin.scale9Grid = SLIDER_SCALE9_GRID;
	fillDisabledSkin.width = this.smallControlSize;
	fillDisabledSkin.height = this.smallControlSize;
	progress.fillDisabledSkin = fillDisabledSkin;
}

//-------------------------
// Radio
//-------------------------

protected function setRadioStyles(radio:Radio):void
{
	var skin:Quad = new Quad(this.controlSize, this.controlSize);
	skin.alpha = 0;
	radio.defaultSkin = skin;

	var icon:ImageSkin = new ImageSkin(this.radioUpIconTexture);
	icon.selectedTexture = this.radioSelectedUpIconTexture;
	icon.setTextureForState(ButtonState.DOWN, this.radioDownIconTexture);
	icon.setTextureForState(ButtonState.DISABLED, this.radioDisabledIconTexture);
	icon.setTextureForState(ButtonState.DOWN_AND_SELECTED, this.radioSelectedDownIconTexture);
	icon.setTextureForState(ButtonState.DISABLED_AND_SELECTED, this.radioSelectedDisabledIconTexture);
	radio.defaultIcon = icon;

	radio.fontStyles = this.lightUIFontStyles;
	radio.disabledFontStyles = this.lightDisabledUIFontStyles;

	radio.horizontalAlign = HorizontalAlign.LEFT;
	radio.gap = this.smallControlGutterSize;
	radio.minGap = this.smallControlGutterSize;
	radio.minTouchWidth = this.gridSize;
	radio.minTouchHeight = this.gridSize;
}

//-------------------------
// ScrollContainer
//-------------------------

protected function setScrollContainerStyles(container:ScrollContainer):void
{
	this.setScrollerStyles(container);
}

protected function setToolbarScrollContainerStyles(container:ScrollContainer):void
{
	this.setScrollerStyles(container);
	if(!container.layout)
	{
		var layout:HorizontalLayout = new HorizontalLayout();
		layout.padding = this.smallGutterSize;
		layout.gap = this.smallGutterSize;
		layout.verticalAlign = VerticalAlign.MIDDLE;
		container.layout = layout;
	}

	var backgroundSkin:ImageSkin = new ImageSkin(this.headerBackgroundSkinTexture);
	backgroundSkin.tileGrid = new Rectangle();
	backgroundSkin.width = this.gridSize;
	backgroundSkin.height = this.gridSize;
	backgroundSkin.minWidth = this.gridSize;
	backgroundSkin.minHeight = this.gridSize;
	container.backgroundSkin = backgroundSkin;
}

//-------------------------
// ScrollScreen
//-------------------------

protected function setScrollScreenStyles(screen:ScrollScreen):void
{
	this.setScrollerStyles(screen);
}

//-------------------------
// ScrollText
//-------------------------

protected function setScrollTextStyles(text:ScrollText):void
{
	this.setScrollerStyles(text);

	text.fontStyles = this.lightScrollTextFontStyles;
	text.disabledFontStyles = this.lightDisabledScrollTextFontStyles;

	text.padding = this.gutterSize;
	text.paddingRight = this.gutterSize + this.smallGutterSize;
}

//-------------------------
// SimpleScrollBar
//-------------------------

protected function setSimpleScrollBarStyles(scrollBar:SimpleScrollBar):void
{
	if(scrollBar.direction == Direction.HORIZONTAL)
	{
		scrollBar.paddingRight = this.scrollBarGutterSize;
		scrollBar.paddingBottom = this.scrollBarGutterSize;
		scrollBar.paddingLeft = this.scrollBarGutterSize;
		scrollBar.customThumbStyleName = THEME_STYLE_NAME_HORIZONTAL_SIMPLE_SCROLL_BAR_THUMB;
	}
	else
	{
		scrollBar.paddingTop = this.scrollBarGutterSize;
		scrollBar.paddingRight = this.scrollBarGutterSize;
		scrollBar.paddingBottom = this.scrollBarGutterSize;
		scrollBar.customThumbStyleName = THEME_STYLE_NAME_VERTICAL_SIMPLE_SCROLL_BAR_THUMB;
	}
}

protected function setHorizontalSimpleScrollBarThumbStyles(thumb:Button):void
{
	var defaultSkin:Image = new Image(this.horizontalScrollBarThumbSkinTexture);
	defaultSkin.scale9Grid = HORIZONTAL_SCROLL_BAR_THUMB_SCALE9_GRID;
	defaultSkin.width = this.gutterSize;
	thumb.defaultSkin = defaultSkin;
	thumb.hasLabelTextRenderer = false;
}

protected function setVerticalSimpleScrollBarThumbStyles(thumb:Button):void
{
	var defaultSkin:Image = new Image(this.verticalScrollBarThumbSkinTexture);
	defaultSkin.scale9Grid = VERTICAL_SCROLL_BAR_THUMB_SCALE9_GRID;
	defaultSkin.height = this.gutterSize;
	thumb.defaultSkin = defaultSkin;
	thumb.hasLabelTextRenderer = false;
}

//-------------------------
// Slider
//-------------------------

protected function setSliderStyles(slider:Slider):void
{
	slider.trackLayoutMode = TrackLayoutMode.SPLIT;
	if(slider.direction == Direction.VERTICAL)
	{
		slider.customMinimumTrackStyleName = THEME_STYLE_NAME_VERTICAL_SLIDER_MINIMUM_TRACK;
		slider.customMaximumTrackStyleName = THEME_STYLE_NAME_VERTICAL_SLIDER_MAXIMUM_TRACK;
	}
	else //horizontal
	{
		slider.customMinimumTrackStyleName = THEME_STYLE_NAME_HORIZONTAL_SLIDER_MINIMUM_TRACK;
		slider.customMaximumTrackStyleName = THEME_STYLE_NAME_HORIZONTAL_SLIDER_MAXIMUM_TRACK;
	}
}

protected function setHorizontalSliderMinimumTrackStyles(track:Button):void
{
	var skin:ImageSkin = new ImageSkin(this.backgroundSkinTexture);
	skin.disabledTexture = this.backgroundDisabledSkinTexture;
	skin.scale9Grid = DEFAULT_BACKGROUND_SCALE9_GRID;
	skin.width = this.wideControlSize;
	skin.height = this.controlSize;
	skin.minWidth = this.wideControlSize;
	skin.minHeight = this.controlSize;
	track.defaultSkin = skin;

	track.hasLabelTextRenderer = false;
}

protected function setHorizontalSliderMaximumTrackStyles(track:Button):void
{
	var skin:ImageSkin = new ImageSkin(this.backgroundSkinTexture);
	skin.disabledTexture = this.backgroundDisabledSkinTexture;
	skin.scale9Grid = DEFAULT_BACKGROUND_SCALE9_GRID;
	skin.width = this.wideControlSize;
	skin.minWidth = this.wideControlSize;
	skin.height = this.controlSize;
	skin.minHeight = this.controlSize;
	track.defaultSkin = skin;

	track.hasLabelTextRenderer = false;
}

protected function setVerticalSliderMinimumTrackStyles(track:Button):void
{
	var skin:ImageSkin = new ImageSkin(this.backgroundSkinTexture);
	skin.disabledTexture = this.backgroundDisabledSkinTexture;
	skin.scale9Grid = DEFAULT_BACKGROUND_SCALE9_GRID;
	skin.width = this.controlSize;
	skin.height = this.wideControlSize;
	skin.minWidth = this.controlSize;
	skin.minHeight = this.wideControlSize;
	track.defaultSkin = skin;

	track.hasLabelTextRenderer = false;
}

protected function setVerticalSliderMaximumTrackStyles(track:Button):void
{
	var skin:ImageSkin = new ImageSkin(this.backgroundSkinTexture);
	skin.disabledTexture = this.backgroundDisabledSkinTexture;
	skin.scale9Grid = DEFAULT_BACKGROUND_SCALE9_GRID;
	skin.width = this.controlSize;
	skin.height = this.wideControlSize;
	skin.minWidth = this.controlSize;
	skin.minHeight = this.wideControlSize;
	track.defaultSkin = skin;

	track.hasLabelTextRenderer = false;
}

//-------------------------
// SpinnerList
//-------------------------

protected function setSpinnerListStyles(list:SpinnerList):void
{
	this.setScrollerStyles(list);
	
	var backgroundSkin:Image = new Image(this.backgroundDarkBorderSkinTexture);
	backgroundSkin.scale9Grid = SMALL_BACKGROUND_SCALE9_GRID;
	list.backgroundSkin = backgroundSkin;
	
	var selectionOverlaySkin:Image = new Image(this.spinnerListSelectionOverlaySkinTexture);
	selectionOverlaySkin.scale9Grid = SPINNER_LIST_SELECTION_OVERLAY_SCALE9_GRID;
	list.selectionOverlaySkin = selectionOverlaySkin;
	
	list.customItemRendererStyleName = THEME_STYLE_NAME_SPINNER_LIST_ITEM_RENDERER;

	list.paddingTop = this.borderSize;
	list.paddingBottom = this.borderSize;
}

protected function setSpinnerListItemRendererStyles(itemRenderer:DefaultListItemRenderer):void
{
	var defaultSkin:Quad = new Quad(this.gridSize, this.gridSize, 0xff00ff);
	defaultSkin.alpha = 0;
	itemRenderer.defaultSkin = defaultSkin;

	itemRenderer.fontStyles = this.largeLightFontStyles;
	itemRenderer.disabledFontStyles = this.largeLightDisabledFontStyles;

	itemRenderer.iconLabelFontStyles = this.lightFontStyles;
	itemRenderer.iconLabelDisabledFontStyles = this.lightDisabledFontStyles;

	itemRenderer.accessoryLabelFontStyles = this.lightFontStyles;
	itemRenderer.accessoryLabelDisabledFontStyles = this.lightDisabledFontStyles;

	itemRenderer.horizontalAlign = HorizontalAlign.LEFT;
	itemRenderer.paddingTop = this.smallGutterSize;
	itemRenderer.paddingBottom = this.smallGutterSize;
	itemRenderer.paddingLeft = this.gutterSize;
	itemRenderer.paddingRight = this.gutterSize;
	itemRenderer.gap = this.gutterSize;
	itemRenderer.minGap = this.gutterSize;
	itemRenderer.iconPosition = RelativePosition.LEFT;
	itemRenderer.accessoryGap = Number.POSITIVE_INFINITY;
	itemRenderer.minAccessoryGap = this.gutterSize;
	itemRenderer.accessoryPosition = RelativePosition.RIGHT;
	itemRenderer.minTouchWidth = this.gridSize;
	itemRenderer.minTouchHeight = this.gridSize;
}

//-------------------------
// TabBar
//-------------------------

protected function setTabBarStyles(tabBar:TabBar):void
{
	tabBar.distributeTabSizes = true;
}

protected function setTabStyles(tab:ToggleButton):void
{
	var skin:ImageSkin = new ImageSkin(this.tabUpSkinTexture);
	skin.selectedTexture = this.tabSelectedSkinTexture;
	skin.setTextureForState(ButtonState.DOWN, this.tabDownSkinTexture);
	skin.setTextureForState(ButtonState.DISABLED, this.tabDisabledSkinTexture);
	//skin.setTextureForState(ButtonState.DISABLED_AND_SELECTED, this.tabSelectedDisabledSkinTexture);
	skin.scale9Grid = TAB_SCALE9_GRID;
	skin.width = this.gridSize;
	skin.height = this.gridSize;
	skin.minWidth = this.gridSize;
	skin.minHeight = this.gridSize;
	tab.defaultSkin = skin;

	tab.fontStyles = this.lightUIFontStyles;
	tab.disabledFontStyles = this.lightDisabledUIFontStyles;
	tab.selectedFontStyles = this.darkUIFontStyles;

	tab.paddingTop = this.smallGutterSize;
	tab.paddingBottom = this.smallGutterSize;
	tab.paddingLeft = this.gutterSize;
	tab.paddingRight = this.gutterSize;
	tab.gap = this.smallGutterSize;
	tab.minGap = this.smallGutterSize;
	tab.minTouchWidth = this.gridSize;
	tab.minTouchHeight = this.gridSize;
}

//-------------------------
// TextArea
//-------------------------

protected function setTextAreaStyles(textArea:TextArea):void
{
	this.setScrollerStyles(textArea);

	var skin:ImageSkin = new ImageSkin(this.backgroundInsetSkinTexture);
	skin.setTextureForState(TextInputState.DISABLED, this.backgroundDisabledSkinTexture);
	skin.setTextureForState(TextInputState.FOCUSED, this.backgroundInsetFocusedSkinTexture);
	skin.setTextureForState(TextInputState.ERROR, this.backgroundInsetDangerSkinTexture);
	skin.scale9Grid = DEFAULT_BACKGROUND_SCALE9_GRID;
	skin.width = this.wideControlSize;
	skin.height = this.wideControlSize;
	textArea.backgroundSkin = skin;

	textArea.fontStyles = this.lightInputFontStyles;
	textArea.disabledFontStyles = this.lightDisabledInputFontStyles;

	textArea.textEditorFactory = textAreaTextEditorFactory;
}

protected function setTextAreaTextEditorStyles(textEditor:TextFieldTextEditorViewPort):void
{
	textEditor.padding = this.smallGutterSize;
}

protected function setTextAreaErrorCalloutStyles(callout:TextCallout):void
{
	this.setDangerCalloutStyles(callout);

	callout.fontStyles = this.lightFontStyles;
	callout.disabledFontStyles = this.lightDisabledFontStyles;

	callout.horizontalAlign = HorizontalAlign.LEFT;
	callout.verticalAlign = VerticalAlign.TOP;
}

//-------------------------
// TextCallout
//-------------------------

protected function setTextCalloutStyles(callout:TextCallout):void
{
	this.setCalloutStyles(callout);

	callout.fontStyles = this.lightFontStyles;
	callout.disabledFontStyles = this.lightDisabledFontStyles;
}

//-------------------------
// TextInput
//-------------------------

protected function setBaseTextInputStyles(input:TextInput):void
{
	var skin:ImageSkin = new ImageSkin(this.backgroundInsetSkinTexture);
	skin.setTextureForState(TextInputState.DISABLED, this.backgroundInsetDisabledSkinTexture);
	skin.setTextureForState(TextInputState.FOCUSED, this.backgroundInsetFocusedSkinTexture);
	skin.setTextureForState(TextInputState.ERROR, this.backgroundInsetDangerSkinTexture);
	skin.scale9Grid = DEFAULT_BACKGROUND_SCALE9_GRID;
	skin.width = this.wideControlSize;
	skin.height = this.controlSize;
	skin.minWidth = this.controlSize;
	skin.minHeight = this.controlSize;
	input.backgroundSkin = skin;

	input.fontStyles = this.lightInputFontStyles;
	input.disabledFontStyles = this.lightDisabledInputFontStyles;

	input.promptFontStyles = this.lightFontStyles;
	input.promptDisabledFontStyles = this.lightDisabledFontStyles;

	input.minTouchWidth = this.gridSize;
	input.minTouchHeight = this.gridSize;
	input.gap = this.smallControlGutterSize;
	input.paddingTop = this.smallControlGutterSize;
	input.paddingRight = this.smallGutterSize;
	input.paddingBottom = this.smallControlGutterSize;
	input.paddingLeft = this.smallGutterSize;
	input.verticalAlign = VerticalAlign.MIDDLE;
}

protected function setTextInputStyles(input:TextInput):void
{
	this.setBaseTextInputStyles(input);
}

protected function setTextInputErrorCalloutStyles(callout:TextCallout):void
{
	this.setDangerCalloutStyles(callout);

	callout.fontStyles = this.lightFontStyles;
	callout.disabledFontStyles = this.lightDisabledFontStyles;

	callout.horizontalAlign = HorizontalAlign.LEFT;
	callout.verticalAlign = VerticalAlign.TOP;
}

protected function setSearchTextInputStyles(input:TextInput):void
{
	this.setBaseTextInputStyles(input);

	input.fontStyles = this.lightInputFontStyles;
	input.disabledFontStyles = this.lightDisabledInputFontStyles;

	input.promptFontStyles = this.lightFontStyles;
	input.promptDisabledFontStyles = this.lightDisabledFontStyles;

	var icon:ImageSkin = new ImageSkin(this.searchIconTexture);
	icon.setTextureForState(TextInputState.DISABLED, this.searchIconDisabledTexture);
	input.defaultIcon = icon;
}

//-------------------------
// ToggleSwitch
//-------------------------

protected function setToggleSwitchStyles(toggle:ToggleSwitch):void
{
	toggle.trackLayoutMode = TrackLayoutMode.SINGLE;

	toggle.offLabelFontStyles = this.lightUIFontStyles;
	toggle.offLabelDisabledFontStyles = this.lightDisabledUIFontStyles;
	toggle.onLabelFontStyles = this.selectedUIFontStyles;
	toggle.onLabelDisabledFontStyles = this.lightDisabledUIFontStyles;
}

//see Shared section for thumb styles

protected function setToggleSwitchTrackStyles(track:Button):void
{
	var skin:ImageSkin = new ImageSkin(this.backgroundSkinTexture);
	skin.disabledTexture = this.backgroundDisabledSkinTexture;
	skin.scale9Grid = DEFAULT_BACKGROUND_SCALE9_GRID;
	skin.width = Math.round(this.controlSize * 2.5);
	skin.height = this.controlSize;
	track.defaultSkin = skin;
	track.hasLabelTextRenderer = false;
}

//-------------------------
// PlayPauseToggleButton
//-------------------------
/*
protected function setPlayPauseToggleButtonStyles(button:PlayPauseToggleButton):void
{
	var skin:Quad = new Quad(this.controlSize, this.controlSize);
	skin.alpha = 0;
	button.defaultSkin = skin;

	var icon:ImageSkin = new ImageSkin(this.playPauseButtonPlayUpIconTexture);
	icon.selectedTexture = this.playPauseButtonPauseUpIconTexture;
	icon.setTextureForState(ButtonState.DOWN, this.playPauseButtonPlayDownIconTexture);
	icon.setTextureForState(ButtonState.DOWN_AND_SELECTED, this.playPauseButtonPauseDownIconTexture);
	button.defaultIcon = icon;

	button.hasLabelTextRenderer = false;

	button.minTouchWidth = this.gridSize;
	button.minTouchHeight = this.gridSize;
}

protected function setOverlayPlayPauseToggleButtonStyles(button:PlayPauseToggleButton):void
{
	var icon:ImageSkin = new ImageSkin(null);
	icon.setTextureForState(ButtonState.UP, this.overlayPlayPauseButtonPlayUpIconTexture);
	icon.setTextureForState(ButtonState.HOVER, this.overlayPlayPauseButtonPlayUpIconTexture);
	icon.setTextureForState(ButtonState.DOWN, this.overlayPlayPauseButtonPlayDownIconTexture);
	button.defaultIcon = icon;

	button.hasLabelTextRenderer = false;

	var overlaySkin:Quad = new Quad(1, 1, VIDEO_OVERLAY_COLOR);
	overlaySkin.alpha = VIDEO_OVERLAY_ALPHA;
	button.upSkin = overlaySkin;
	button.hoverSkin = overlaySkin;
}

//-------------------------
// FullScreenToggleButton
//-------------------------

protected function setFullScreenToggleButtonStyles(button:FullScreenToggleButton):void
{
	var skin:Quad = new Quad(this.controlSize, this.controlSize);
	skin.alpha = 0;
	button.defaultSkin = skin;

	var icon:ImageSkin = new ImageSkin(this.fullScreenToggleButtonEnterUpIconTexture);
	icon.selectedTexture = this.fullScreenToggleButtonExitUpIconTexture;
	icon.setTextureForState(ButtonState.DOWN, this.fullScreenToggleButtonEnterDownIconTexture);
	icon.setTextureForState(ButtonState.DOWN_AND_SELECTED, this.fullScreenToggleButtonExitDownIconTexture);
	button.defaultIcon = icon;

	button.hasLabelTextRenderer = false;

	button.minTouchWidth = this.gridSize;
	button.minTouchHeight = this.gridSize;
}

//-------------------------
// MuteToggleButton
//-------------------------

protected function setMuteToggleButtonStyles(button:MuteToggleButton):void
{
	var skin:Quad = new Quad(this.controlSize, this.controlSize);
	skin.alpha = 0;
	button.defaultSkin = skin;

	var icon:ImageSkin = new ImageSkin(this.muteToggleButtonLoudUpIconTexture);
	icon.selectedTexture = this.muteToggleButtonMutedUpIconTexture;
	icon.setTextureForState(ButtonState.DOWN, this.muteToggleButtonLoudDownIconTexture);
	icon.setTextureForState(ButtonState.DOWN_AND_SELECTED, this.muteToggleButtonMutedDownIconTexture);
	button.defaultIcon = icon;

	button.hasLabelTextRenderer = false;
	button.showVolumeSliderOnHover = false;

	button.minTouchWidth = this.gridSize;
	button.minTouchHeight = this.gridSize;
}
*/
//-------------------------
// SeekSlider
//-------------------------

protected function setSeekSliderStyles(slider:SeekSlider):void
{
	slider.trackLayoutMode = TrackLayoutMode.SPLIT;
	slider.showThumb = false;
	var progressSkin:Image = new Image(this.seekSliderProgressSkinTexture);
	progressSkin.scale9Grid = DEFAULT_BACKGROUND_SCALE9_GRID;
	progressSkin.width = this.smallControlSize;
	progressSkin.height = this.smallControlSize;
	slider.progressSkin = progressSkin;
}

protected function setSeekSliderThumbStyles(thumb:Button):void
{
	var thumbSize:Number = 6;
	thumb.defaultSkin = new Quad(thumbSize, thumbSize);
	thumb.hasLabelTextRenderer = false;
	thumb.minTouchWidth = this.gridSize;
	thumb.minTouchHeight = this.gridSize;
}

protected function setSeekSliderMinimumTrackStyles(track:Button):void
{
	var defaultSkin:ImageSkin = new ImageSkin(this.buttonUpSkinTexture);
	defaultSkin.scale9Grid = BUTTON_SCALE9_GRID;
	defaultSkin.width = this.wideControlSize;
	defaultSkin.height = this.smallControlSize;
	defaultSkin.minWidth = this.wideControlSize;
	defaultSkin.minHeight = this.smallControlSize;
	track.defaultSkin = defaultSkin;
	track.hasLabelTextRenderer = false;
	track.minTouchHeight = this.gridSize;
}

protected function setSeekSliderMaximumTrackStyles(track:Button):void
{
	var defaultSkin:ImageSkin = new ImageSkin(this.backgroundSkinTexture);
	defaultSkin.scale9Grid = DEFAULT_BACKGROUND_SCALE9_GRID;
	defaultSkin.width = this.wideControlSize;
	defaultSkin.height = this.smallControlSize;
	defaultSkin.minHeight = this.smallControlSize;
	track.defaultSkin = defaultSkin;
	track.hasLabelTextRenderer = false;
	track.minTouchHeight = this.gridSize;
}

//-------------------------
// VolumeSlider
//-------------------------

/*protected function setVolumeSliderStyles(slider:VolumeSlider):void
{
	slider.direction = Direction.HORIZONTAL;
	slider.trackLayoutMode = TrackLayoutMode.SPLIT;
	slider.showThumb = false;
}

protected function setVolumeSliderThumbStyles(thumb:Button):void
{
	var thumbSize:Number = 6;
	var defaultSkin:Quad = new Quad(thumbSize, thumbSize);
	defaultSkin.width = 0;
	defaultSkin.height = 0;
	thumb.defaultSkin = defaultSkin;
	thumb.hasLabelTextRenderer = false;
}

protected function setVolumeSliderMinimumTrackStyles(track:Button):void
{
	var defaultSkin:ImageLoader = new ImageLoader();
	defaultSkin.scaleContent = false;
	defaultSkin.source = this.volumeSliderMinimumTrackSkinTexture;
	track.defaultSkin = defaultSkin;
	track.hasLabelTextRenderer = false;
	track.minTouchHeight = this.gridSize;
}

protected function setVolumeSliderMaximumTrackStyles(track:Button):void
{
	var defaultSkin:ImageLoader = new ImageLoader();
	defaultSkin.scaleContent = false;
	defaultSkin.horizontalAlign = HorizontalAlign.RIGHT;
	defaultSkin.source = this.volumeSliderMaximumTrackSkinTexture;
	track.defaultSkin = defaultSkin;
	track.hasLabelTextRenderer = false;
	track.minTouchHeight = this.gridSize;
}
*/
}
}