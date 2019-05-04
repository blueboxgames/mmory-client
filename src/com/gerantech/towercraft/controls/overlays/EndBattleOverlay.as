package com.gerantech.towercraft.controls.overlays
{
import com.gerantech.towercraft.controls.headers.BattleHeader;
import com.gerantech.towercraft.controls.items.BattleOutcomeRewardItemRenderer;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.vo.BattleData;
import com.gerantech.towercraft.models.vo.RewardData;
import com.gerantech.towercraft.themes.MainTheme;
import com.gt.towers.constants.ExchangeType;
import com.gt.towers.constants.ResourceType;
import com.gt.towers.exchanges.ExchangeItem;
import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import feathers.controls.Button;
import feathers.controls.List;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;
import starling.core.Starling;
import starling.display.Quad;
import starling.events.Event;

public class EndBattleOverlay extends EndOverlay
{
private var reward_1:ISFSObject;
private var reward_2:ISFSObject;
public function EndBattleOverlay(battleData:BattleData, playerIndex:int, rewards:ISFSArray, tutorialMode:Boolean = false)
{
	super(battleData, playerIndex, rewards, tutorialMode);
}
override protected function initialize():void
{
	super.initialize();
	reward_1 = rewards.getSFSObject(playerIndex ==-1?1:1 - playerIndex);
	reward_2 = rewards.getSFSObject(playerIndex ==-1?0:playerIndex);
	var isDraw:Boolean = reward_1.getInt("score") == reward_2.getInt("score") ;
	var pi:int = playerIndex == -1 ? 0 : playerIndex;
	
	if( isDraw || battleData.battleField.friendlyMode )
	{
		var drawLabel:ShadowLabel = new ShadowLabel(loc(battleData.battleField.friendlyMode?"buddy_battle":"draw_label"), 1, 0, null, null, false, null, 1.4);
		drawLabel.layoutData = new AnchorLayoutData(padding * 3.5, NaN, NaN, NaN, 0);
		addChild(drawLabel);
	}
	
	// axis
	var name:String = reward_1.getText("name");
	if( player.inTutorial() && player.tutorialMode == 1 )
		name = loc("trainer_label");
	var axisHeader:BattleHeader = new BattleHeader(name, reward_1.getInt("id") == player.id, reward_1.getInt("score"));
	axisHeader.layoutData = new AnchorLayoutData(padding * 11, 100, NaN, 100);
	addChild(axisHeader);
	//axisHeader.addScoreImages(reward_1.getInt("score"));
	if( !isDraw )
		axisHeader.showWinnerLabel(reward_1.getInt("score") > reward_2.getInt("score"));
	
	// allise
	name = reward_2.getText("name") == "guest" ? loc("guest_label") : reward_2.getText("name");
	var alliseHeader:BattleHeader = new BattleHeader(name, reward_2.getInt("id") == player.id, reward_2.getInt("score"));
	alliseHeader.layoutData = new AnchorLayoutData(padding * 21, 100, NaN, 100);
	addChild(alliseHeader);
	if( !isDraw )
		alliseHeader.showWinnerLabel(reward_2.getInt("score") > reward_1.getInt("score"));

	var hlayout:HorizontalLayout = new HorizontalLayout();
	hlayout.horizontalAlign = HorizontalAlign.CENTER;
	hlayout.verticalAlign = VerticalAlign.MIDDLE;
	hlayout.useVirtualLayout = false;
	hlayout.gap = padding * 2;
	
	if( playerIndex > -1 )
	{
		if( reward_2.getInt("score") > 0 && !battleData.battleField.friendlyMode )
			appModel.battleFieldView.battleData.outcomes.push(new RewardData(stageWidth * 0.5, padding * 21, ResourceType.R17_STARS, reward_2.getInt("score")));
		
		var _rewards:ListCollection = getRewardsCollection(playerIndex);
		if( _rewards.length > 0 )
		{
			var rewardsList:List = new List();
			rewardsList.backgroundSkin = new Quad(1, 1, 0);
			rewardsList.backgroundSkin.alpha = 0.6;
			rewardsList.height = 280;
			rewardsList.layout = hlayout;
			rewardsList.layoutData = new AnchorLayoutData(padding * 26, 0, NaN, 0);
			rewardsList.itemRendererFactory = function ():IListItemRenderer { return new BattleOutcomeRewardItemRenderer(battleData); }
			rewardsList.dataProvider = _rewards;
			addChild(rewardsList);
		}
	}
	
	var closeBatton:Button = new Button();
	closeBatton.width = 300;
	closeBatton.height = 140;
	closeBatton.name = "close";
	closeBatton.label = loc("popup_ok_label");
	closeBatton.styleName = MainTheme.STYLE_BUTTON_NEUTRAL;
	closeBatton.addEventListener(Event.TRIGGERED, buttons_triggeredHandler);
	closeBatton.layoutData = new AnchorLayoutData((rewardsList != null?33:28) * padding, NaN, NaN, NaN, 0);
	Starling.juggler.tween(closeBatton, 0.5, {delay:0.9, alpha:1});
	closeBatton.alpha = 0;
	addChild(closeBatton);
}

override protected function getRewardsCollection(playerIndex:int) : ListCollection
{
	var ret:ListCollection = super.getRewardsCollection(playerIndex);
	
	if( battleData.battleField.friendlyMode || reward_1.getInt("score") > reward_2.getInt("score") )
		return ret;
	
	if( exchanger.findItem(ExchangeType.C110_BATTLES, ExchangeItem.CHEST_STATE_EMPTY, timeManager.now) == null )
		ret.push({t:"-1", c:loc("battle_no_book")});
	if( player.get_arena(player.get_point() - reward_2.getInt("point")) > 0 && battleData.sfsData.getInt("mode") == 0 )
		ret.push({t:"-2", c:loc("battle_no_point")});
	return ret;
}
}
}