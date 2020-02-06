package com.gerantech.towercraft.controls.screens
{
  import com.gerantech.towercraft.controls.items.LeagueItemRenderer;

  import feathers.layout.AnchorLayoutData;

  import starling.display.Quad;

  public class BuddyRoad extends SimpleScreen
  {
    public function BuddyRoad() { }

    override protected function initialize():void
    {
      this.backgroundSkin = new Quad(1, 1, 0x446600)
      super.initialize();

    	LeagueItemRenderer.HEIGHT = stageHeight;
      LeagueItemRenderer.ITS_ME = false;
      LeagueItemRenderer.LEAGUE = 1;
      LeagueItemRenderer.STEP = 0;
      var road:LeagueItemRenderer = new LeagueItemRenderer();
      road.index = 1;
      road.data = game.buddyRoad;
      road.layoutData = new AnchorLayoutData(0, 30, 0, 10);
      this.addChild(road);

      this.titleDisplay.layoutData = new AnchorLayoutData(headerSize - 120, NaN, NaN, NaN, -135);
      this.addChild(this.titleDisplay);
    }
  }
}