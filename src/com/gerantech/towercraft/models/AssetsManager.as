package com.gerantech.towercraft.models
{
  import flash.display.BitmapData;
  import flash.filters.ColorMatrixFilter;
  import flash.geom.Point;
  import flash.utils.Dictionary;

  import starling.assets.AssetManager;
  import starling.assets.AssetType;
  import starling.display.Image;
  import starling.text.BitmapFont;
  import starling.textures.Texture;

  public class AssetsManager extends AssetManager
  {
    public function AssetsManager() { super(1); }
    public function getGrayTexture(name:String):Texture
    {
      var ret:Texture = super.getTexture("__gray_" + name);
      if( ret == null )
      {
        trace("__gray_" + name);
        ret = this.gray(super.getTexture(name));
        this.addAsset("__gray_" + name, ret, AssetType.TEXTURE);
      }
      return ret;
    }

    private function gray(texture:Texture):Texture
		{
			if( texture == null )
				return null;
			var _bitmapData:BitmapData = new Image(texture).drawToBitmapData();
			const rc:Number = 1/3, gc:Number = 1/3, bc:Number = 1/3;
			_bitmapData.applyFilter(_bitmapData, _bitmapData.rect, new Point(), new ColorMatrixFilter([rc, gc, bc, 0, 0,		rc, gc, bc, 0, 0,		rc, gc, bc, 0, 0,		0, 0, 0, 1, 0]));
			return Texture.fromBitmapData(_bitmapData);
		}



    [Embed(source="../../../../assets/fonts/fontclash-font.atf", mimeType="application/octet-stream")]
		public static const fontTexture:Class;
		[Embed(source="../../../../assets/fonts/fontclash-font.fnt", mimeType="application/octet-stream")]
		public static const fontXml:Class;
		
		private var fonts:Dictionary = new Dictionary();
		
		public function getFont(name:String="font"):BitmapFont
		{
			if( fonts[name] == undefined )
			{
				var texture:Texture = Texture.fromAtfData(new AssetsManager[name + "Texture"](), 1, false);
				var xml:XML = XML(new AssetsManager[name + "Xml"]);
				fonts[name] = new BitmapFont(texture, xml);
			}
			return fonts[name];
		}

  }
}