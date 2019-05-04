package com.gerantech.towercraft.models
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.filesystem.File;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import feathers.system.DeviceCapabilities;
	
	import starling.text.BitmapFont;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	
	public class Assets
	{
		[Embed(source="../../../../assets/fonts/fontclash-font.atf", mimeType="application/octet-stream")]
		public static const fontTexture:Class;
		[Embed(source="../../../../assets/fonts/fontclash-font.fnt", mimeType="application/octet-stream")]
		public static const fontXml:Class;
		
		private static var fonts:Dictionary = new Dictionary();
		
		public static function getFont(name:String="font"):BitmapFont
		{
			if( fonts[name] == undefined )
			{
				var texture:Texture = Texture.fromAtfData(new Assets[name + "Texture"](), 1, false);
				var xml:XML = XML(new Assets[name + "Xml"]);
				fonts[name] = new BitmapFont(texture, xml);
			}
			return fonts[name];
		}
		
		/**
		 * Texture Atlas 
		 */
		[Embed(source="../../../../assets/images/gui.atf", mimeType="application/octet-stream")]
		public static const guiAtlasTexture:Class;
		[Embed(source="../../../../assets/images/gui.xml", mimeType="application/octet-stream")]
		public static const guiAtlasXml:Class;
		
		public static const BACKGROUND_GRID:Rectangle = new Rectangle(2, 2, 6, 6);
		
		private static var allTextures:Dictionary = new Dictionary();
		private static var allTextureAtlases:Dictionary = new Dictionary();
		
		/*private static var allScaled3Textures:Dictionary = new Dictionary();
		private static var allScaled9Textures:Dictionary = new Dictionary();
		private static var sclaed9Names:Array;
		private static var sclaed9NamesComplete:Function;*/
		
		/**
		 * Returns a texture from this class based on a string key.
		 * @param name A key that matches a static constant of Bitmap type.
		 * @return a starling texture.
		 */
		private static function getTextureByBitmap(name:String):Texture
		{
			if( allTextures[name] == undefined )
				allTextures[name] = Texture.fromAtfData(new Assets[name](), 1, false);
			return allTextures[name];
		}
		
		/**
		 * Returns the Texture atlas instance.
		 * @return the TextureAtlas instance (there is only oneinstance per app)
		 */
		private static function getAtlas(name:String):TextureAtlas
		{
			if( allTextureAtlases[name] == undefined )
			{
				var texture:Texture = getTextureByBitmap(name+"AtlasTexture");
				var xml:XML = XML(new Assets[name+"AtlasXml"]);
				allTextureAtlases[name] = new TextureAtlas(texture, xml);
			}
			return allTextureAtlases[name];
		}
		
		/**
		 * Returns a texture from this class based on a string key.
		 * @param name A key that found a texture from atlas.
		 * @return the Texture instance (there is only oneinstance per app).
		 */
		public static function getTexture(texturName:String, atlasName:String ="gui" ):Texture
		{
			return getAtlas(atlasName).getTexture(texturName);
		} 
		public static function getTextures(texturName:String, atlasName:String ="gui" ):Vector.<Texture>
		{
			return getAtlas(atlasName).getTextures(texturName);
		}
		
		/**
		 * Returns a scale9Textures from this class based on a string key.
		 * @param name A key that matches a static constant of Bitmap type.
		 * @return a starling scale9Textures.
		 */
		public static function getSclaed9Textures(name:String):Texture
		{
			if( allTextures[name] == undefined )
			{
				var bmp:Bitmap = new Assets[name+"Bitmap"]();
				
				var scale:Number = DeviceCapabilities.dpi/640;
				var bitmapWidth:uint = Math.round(bmp.width*scale*0.5)*2;
				var bitmapHeight:uint = Math.round(bmp.height*scale*0.5)*2;
				var mat:Matrix = new Matrix();
				mat.scale(bitmapWidth / bmp.width, bitmapHeight / bmp.height);
				var destBD:BitmapData = new BitmapData(bitmapWidth, bitmapHeight, true, 0);
				destBD.draw(bmp, mat);
				
				allTextures[name] = Texture.fromBitmapData(destBD);
				//allScaled9Textures[name] = new Scale9Textures(texture, new Rectangle(bitmapWidth/2-1,bitmapHeight/2-1,2,2));
			}
			return allTextures[name];
		}
		
		/*public static function save(name:String = "skin"):void
		{
		var bmp:Bitmap = new Assets[name+"AtlasTexture"]();
		var bmd:BitmapData = bmp.bitmapData;
		
		var texture:Texture = Texture.fromBitmapData(bmd);
		var xml:XML = XML(new Assets[name+"AtlasXml"]);
		var atlas:TextureAtlas = new TextureAtlas(texture, xml);
		var names:Vector.<String> = atlas.getNames();
		var textureLen:uint = names.length;
		var textureIndex:uint = 0;
		var textureName:String;
		var bd:BitmapData;
		
		saveTexture();
		function saveTexture():void
		{
		textureName = names[textureIndex];
		bd = new BitmapData(atlas.getRegion(textureName).width, atlas.getRegion(textureName).height);
		bd.copyPixels(bmd, atlas.getRegion(textureName), new Point(0, 0));
		var gts:GTStreamer = new GTStreamer(File.desktopDirectory.resolvePath("as/"+textureName.substr(0, saveTexture.length-4)+".png"), savedTexture, null, null, false, false);
		gts.save(PNGEncoder.encode(bd));
		bd.dispose();
		}
		
		function savedTexture(gts:GTStreamer):void
		{
		textureIndex ++;
		if(textureIndex < names.length)
		saveTexture();
		else
		{
		
		trace("all textures saved.");
		}
		}
		}*/
		
		
		public function dispose():void
		{
			/*if(this.atlas)
			{
			//if anything is keeping a reference to the texture, we don't
			//want it to keep a reference to the theme too.
			this.atlas.texture.root.onRestore = null;
			
			this.atlas.dispose();
			this.atlas = null;
			}
			*/
		}
		
		static private var animAssetsLoadCallback:Function;
		static public var animationAssetsLoaded:Boolean;
		static public function loadAnimationAssets(callback:Function, ...args) : void
		{
			for each( var item:String in args )
				checkLoadingAssets(item);
			
			//AppModel.instance.assets.verbose = true;
			var needLoading:Boolean;
			function checkLoadingAssets(item:String) : void
			{
				if( AppModel.instance.assets.getTexture(item + "_tex") == null )
				{
					AppModel.instance.assets.enqueue(File.applicationDirectory.resolvePath( "assets/animations/" + item ));
					needLoading = true;
				}
			}
			if( needLoading )
			{
				animAssetsLoadCallback = callback;
				AppModel.instance.assets.loadQueue(assets_loadCallback);
			}
			else
			{
				callback();
			}
		}
		private static function assets_loadCallback(ratio:Number) : void
		{
			if( ratio >= 1 && animAssetsLoadCallback != null )
			{
				animationAssetsLoaded = true;
				animAssetsLoadCallback();
				animAssetsLoadCallback = null;
			}
		}
	}
}