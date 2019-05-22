package com.gerantech.towercraft.controls
{
	import com.gerantech.towercraft.controls.buttons.Indicator;
	import com.gerantech.towercraft.controls.buttons.IndicatorCard;
	import com.gerantech.towercraft.controls.sliders.LabeledProgressBar;
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	import com.gerantech.towercraft.controls.texts.ShadowLabel;
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.themes.MainTheme;
	import com.gerantech.towercraft.utils.StrUtils;
	import com.gt.towers.constants.CardFeatureType;
	import com.gt.towers.constants.CardTypes;
	import com.gt.towers.constants.ResourceType;
	import com.gt.towers.scripts.ScriptEngine;

	import feathers.controls.ImageLoader;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;

	import flash.geom.Rectangle;

	import starling.display.DisplayObject;
	import starling.display.Image;

	public class CardView extends TowersLayout
	{
		static public const RARITY_COLORS:Object = {0:0x4296FD, 1:0xF98900, 2:0xD016FF};
		static private var FRAME_SCALEGRID:Rectangle = new Rectangle(27, 25, 1, 1);
		static private var SLIDER_SCALEGRID:Rectangle = new Rectangle(16, 16, 1, 1);
		static public var VERICAL_SCALE:Number = 1.44;

		protected var _type:int = -1;
		protected var _level:int = -1;
		protected var _rarity:int = 0;
		protected var _elixir:int = -1;
		protected var _quantity:int = -1;
		protected var _availablity:int = 0;
		protected var _showRarity:Boolean;
		protected var _showSlider:Boolean;
		protected var _showElixir:Boolean;

		protected var levelDisplay:RTLLabel;
		protected var sliderDisplay:Indicator;
		protected var iconDisplay:ImageLoader;
		protected var frameDisplay:ImageLoader;
		protected var elixirDisplay:ShadowLabel;
		protected var levelBackground:ImageLoader;
		protected var elixirBackground:ImageLoader;
		protected var quantityDisplay:ShadowLabel;

		public function CardView()
		{
				super();
		}

		override protected function initialize():void
		{
			super.initialize();
			this.layout= new AnchorLayout();
		}		

		/**
		 * Properties for dynamic adding elements
		 */
		public function get type():int
		{
			return this._type;
		}
		public function set type(value:int):void
		{
			if( this._type == value )
				return;
			this._type = value;
			if( this._type > 100 )
			{
				this._availablity = player.getAvailablity(this._type)
				this._rarity = ScriptEngine.getInt(CardFeatureType.F00_RARITY, this._type)
				this._elixir = ScriptEngine.getInt(CardFeatureType.F02_ELIXIR_SIZE, this._type)
			}
			this.invalidate(INVALIDATION_FLAG_DATA);
		}

		public function get level():int
		{
			return this._level;
		}
		public function set level(value:int):void
		{
			if( this._level == value )
				return;
			this._level = value;
			this.invalidate(INVALIDATION_FLAG_DATA);
		}

		public function get rarity():int
		{
			return this._rarity;
		}

		public function get elixir():int
		{
			return this._elixir;
		}
		public function get showElixir():Boolean
		{
			return this._showElixir;
		}
		public function set showElixir(value:Boolean):void
		{
			if( this._showElixir == value )
				return;
			this._showElixir = value;
			if( this._showElixir && this._type > 100 )
				this._elixir = ScriptEngine.getInt(CardFeatureType.F02_ELIXIR_SIZE, this._type);
			this.invalidate(INVALIDATION_FLAG_DATA);
		}

		public function get quantity():int
		{
			return this._quantity;
		}
		public function set quantity(value:int):void
		{
			if( this._quantity == value )
				return;
			this._quantity = value;
			this.invalidate(INVALIDATION_FLAG_DATA);
		}

		public function get showSlider():Boolean
		{
			return this._showSlider;
		}
		public function set showSlider(value:Boolean):void
		{
			if( this._showSlider == value )
				return;
			this._showSlider = value;
			this.invalidate(INVALIDATION_FLAG_DATA);
		}

		public function get availablity():int
		{
			return _availablity;
		}


		override protected function draw() : void
		{
			if( this.isInvalid(INVALIDATION_FLAG_DATA) )
			{
				this.baseElementsFactory();
				this.levelDisplayFactory();
				this.quantityDisplayFactory();
				this.sliderDisplayFactory();
				this.elixirDisplayFactory();
			}
			super.draw();
		}

		/**
		 * Factories
		 */
		protected function baseElementsFactory():void
		{
			if( this.iconDisplay == null )
			{
				this.iconDisplay = new ImageLoader();
				this.iconDisplay.layoutData = new AnchorLayoutData(12, 12, NaN, 12);
				this.addChildAt(this.iconDisplay as DisplayObject, 0);
			}
			this.iconDisplay.source = Assets.getTexture("cards/" + this._type, "gui", availablity != CardTypes.AVAILABLITY_EXISTS);

			if( this.frameDisplay == null )
			{
				this.frameDisplay = new ImageLoader();
				this.frameDisplay.scale9Grid = FRAME_SCALEGRID;
				this.frameDisplay.source = Assets.getTexture("cards/frame", "gui");
				this.frameDisplay.layoutData = new AnchorLayoutData(0, 0, 0, 0);
				this.addChildAt(this.frameDisplay, 1);
			}

			this.frameDisplay.color = this._availablity != CardTypes.AVAILABLITY_EXISTS ? 0x7777AA : RARITY_COLORS[this._rarity];
		}

		protected function levelDisplayFactory():void
		{
			if( !ResourceType.isCard(this._type) || this._availablity != CardTypes.AVAILABLITY_EXISTS || this._type < 0 || this._level <= 0 )
			{
				if( this.levelDisplay != null )
				{
					this.levelDisplay.removeFromParent(true);
					this.levelDisplay = null;

					this.levelBackground.removeFromParent(true);
					this.levelBackground = null;
				}
				return;
			}
			
			if( this.levelDisplay == null )
			{
				this.levelDisplay = new RTLLabel(null, 1, "center", null, false, null, 0.65);
				this.levelDisplay.width = 42;
				this.levelDisplay.layoutData = new AnchorLayoutData(NaN, 20, this._showSlider ? 82 : 27);
				this.addChild(this.levelDisplay);
			}
			this.levelDisplay.text = StrUtils.getNumber(this._level);
			
			if( this.levelBackground == null )
			{
				this.levelBackground = new ImageLoader();
				this.levelBackground.color = 0x161616;
				this.levelBackground.width = 66;
				this.levelBackground.height = 45;
				this.levelBackground.source = appModel.theme.roundSmallSkin;
				this.levelBackground.scale9Grid = MainTheme.ROUND_SMALL_SCALE9_GRID;
				this.levelBackground.layoutData = new AnchorLayoutData(NaN, 0, this._showSlider ? 85 : 30);
				this.addChildAt(this.levelBackground as DisplayObject, 1);
			}
		}
		
		protected function elixirDisplayFactory():void
		{
			if( !this._showElixir || this.availablity == CardTypes.AVAILABLITY_NOT || !ResourceType.isCard(this._type) )
			{
				if( this.elixirDisplay != null )
				{
					this.elixirDisplay.removeFromParent(true);
					this.elixirDisplay = null;

					this.elixirBackground.removeFromParent(true);
					this.elixirBackground = null;
				}
				return;
			}

			if( this.elixirDisplay == null )
			{
				this.elixirBackground = new ImageLoader();
				this.elixirBackground.width = elixirBackground.height = 90;
				this.elixirBackground.layoutData = new AnchorLayoutData(-25, NaN, NaN, -12);
				this.addChildAt(this.elixirBackground as DisplayObject, 3);

				this.elixirDisplay = new ShadowLabel(null, 1, 0x660000, "center", null, false, null, 0.9);
				this.elixirDisplay.width = 100;
				this.elixirDisplay.layoutData = new AnchorLayoutData(-3, NaN, NaN, -15);
				this.addChild(this.elixirDisplay as DisplayObject);
			}
			this.elixirDisplay.text =  StrUtils.getNumber(this._elixir);
			this.elixirBackground.source = Assets.getTexture("cards/elixir", "gui");
		}
		
		protected function quantityDisplayFactory():void
		{
			if( this._quantity <= 0 || this.availablity != CardTypes.AVAILABLITY_EXISTS )
			{
				if( this.quantityDisplay != null )
				{
					this.quantityDisplay.removeFromParent(true);
					this.quantityDisplay = null;
				}
				return;
			}
			
			if( this.quantityDisplay == null )
			{
				this.quantityDisplay = new ShadowLabel(null, 1, 0, null, "ltr", false, null, 1.3);
				this.quantityDisplay.layoutData = new AnchorLayoutData(NaN, 30, 20);
				this.addChild(this.quantityDisplay as DisplayObject);
			}
			this.quantityDisplay.text = (ResourceType.isCard(type) ? "x" : "+") + StrUtils.getNumber(quantity);
		}

		protected function sliderDisplayFactory():void
		{
			if( !this._showSlider || this.availablity < CardTypes.AVAILABLITY_WAIT )
			{
				if( this.sliderDisplay != null )
				{
					this.sliderDisplay.removeFromParent(true);
					this.sliderDisplay = null;
				}
				return;
			}				
			if( this.sliderDisplay == null )
			{
				if( ResourceType.isCard(this._type) )
					this.sliderDisplay = new IndicatorCard("ltr", this._type) as Indicator;
				else
					this.sliderDisplay = new Indicator("ltr", this._type, false, false);
				this.sliderDisplay.progressBarFactory = slider_progressbarFactory;
				this.sliderDisplay.layoutData = new AnchorLayoutData(NaN, 2, 23, 2);
				this.addChildAt(this.sliderDisplay as DisplayObject, 3);
				this.sliderDisplay.height = 68;
			}
			this.sliderDisplay.setData(0, -1, this.sliderDisplay.maximum);
		}

		protected function slider_progressbarFactory():LabeledProgressBar
		{
			var ret:LabeledProgressBar = new LabeledProgressBar();
			var bg:Image = new Image(Assets.getTexture("cards/slider-background", "gui"));
			bg.scale9Grid = SLIDER_SCALEGRID;
			bg.color = RARITY_COLORS[this._rarity];
			ret.backgroundSkin = bg;
			ret.backgroundDisabledSkin = bg;

			ret.fillPaddingTop = ret.fillPaddingRight = ret.fillPaddingBottom = ret.fillPaddingLeft = 8;

			ret.clampValue = false;
			ret.formatValueFactory = sliderDisplay.formatValueFactory;;
			ret.layoutData = new AnchorLayoutData(0, 0, 0, 0);
			ret.labelOffsetX = 0;
			ret.labelOffsetY = 1;
			ret.isEnabled = false;
			return ret;
		}

		override public function addChildAt(child:starling.display.DisplayObject, index:int):starling.display.DisplayObject
		{
			return super.addChildAt(child, Math.min(index, numChildren));
		}
	}
}