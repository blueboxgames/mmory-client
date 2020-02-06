package com.gerantech.towercraft.controls.screens
{
  import feathers.layout.AnchorLayoutData;

  import starling.display.Quad;

  public class BuddyRoad extends SimpleScreen
  {
    public function BuddyRoad() { }

    override protected function initialize():void
    {
      this.backgroundSkin = new Quad(1, 1, 0x446600)
      super.initialize();

      titleDisplay.layoutData = new AnchorLayoutData(headerSize - 120, NaN, NaN, NaN, -150);
      addChild(titleDisplay);
    }
  }
}