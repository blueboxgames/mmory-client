package com.gerantech.towercraft.controls.groups
{
  import com.gerantech.towercraft.controls.texts.NativeLabel;
  import com.gerantech.towercraft.models.AppModel;
  import com.gerantech.towercraft.utils.GTStreamer;

  import flash.display.BitmapData;
  import flash.display.Sprite;
  import flash.filesystem.File;
  import flash.text.TextField;
  import flash.text.TextFormat;
  import com.gerantech.towercraft.utils.Localizations;

  public class ShareImageFactory extends Sprite
  {
    public var size:int = 512;

    public function ShareImageFactory()
    {
      new GTStreamer(File.applicationStorageDirectory.resolvePath("assets/embasador.png"), loader_comleteHandler, null, null, true);
    }
    
    private function loader_comleteHandler(stream:GTStreamer):void
    {
      addChild(stream.loader);

      var padding:int = 32;
      var messageField:NativeLabel = new NativeLabel(Localizations.instance.get("invite_friend_label"), this.size - padding * 2, 1, "justify", null, true, "center");
      messageField.x = padding;
      messageField.y = 355 + padding;
      addChild(messageField);

      var tagField:TextField = new TextField();
      tagField.embedFonts = true;
      tagField.defaultTextFormat = new TextFormat("SourceSans", 22, 0xFFCCAA, true);
      tagField.text = "#" + AppModel.instance.game.player.nickName;
      tagField.x = 256 - tagField.width * 0.5; 
      tagField.y = 470;
      addChild(tagField);
    }

    public function export():BitmapData
    {
      var data:BitmapData = new BitmapData(size, size);
      data.draw(this);
      return data;
    }
  }
}