package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.controls.BuildingCard;
import com.gerantech.towercraft.controls.overlays.OpenBookOverlay;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.vo.BattleData;
import com.gerantech.towercraft.models.vo.RewardData;
import com.gerantech.towercraft.utils.StrUtils;
import com.gt.towers.constants.ResourceType;
import com.smartfoxserver.v2.entities.data.SFSObject;
import dragonBones.starling.StarlingArmatureDisplay;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import flash.geom.Rectangle;
import starling.core.Starling;
import starling.display.Image;
import starling.events.Event;

public class BattleOutcomeRewardItemRenderer extends AbstractTouchableListItemRenderer
{
private var reward:SFSObject;
private var iconDisplay:Image;
private var labelDisplay:RTLLabel;
private var battleData:BattleData;
private var buildingCrad:BuildingCard;
private var armatureDisplay:StarlingArmatureDisplay;

public function BattleOutcomeRewardItemRenderer(battleData:BattleData){ this.battleData = battleData; }
override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout();
	height = width = 200;
}

override protected function commitData():void
{
	super.commitData();
	
	if( ResourceType.isBook(_data.t) )
	{
		armatureDisplay = OpenBookOverlay.factory.buildArmatureDisplay(_data.t.toString());
		armatureDisplay.x = width * 0.5;
		armatureDisplay.y = height * 0.5;
		armatureDisplay.scale = 0.8;
		armatureDisplay.animation.timeScale = 0;
		armatureDisplay.animation.gotoAndStopByProgress("appear", 1);
		addChild(armatureDisplay);
	}
	else
	{
		iconDisplay = new Image(Assets.getTexture("res-" + _data.t, "gui"));
		iconDisplay.x = width * 0.50;
		iconDisplay.y = height * 0.35;
		iconDisplay.alignPivot();
		iconDisplay.pixelSnapping = false;
		addChild(iconDisplay);
		
		var isComment:Boolean = int(_data.t) < 0;trace(int(_data.t), isComment)
		labelDisplay = new RTLLabel(StrUtils.getNumber(_data.c), 1, null, isComment ? null : "ltr", false, null, isComment ? 0.5 : 1);
		labelDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, isComment ? 80 : 60);
		labelDisplay.alpha = isComment ? 0.7 : 1;
		addChild(labelDisplay);
		
	}
	_owner.addEventListener(FeathersEventType.CREATION_COMPLETE, owner_createCompleteHandler);
}

protected function owner_createCompleteHandler(e:Event):void 
{
	_owner.removeEventListener(FeathersEventType.CREATION_COMPLETE, owner_createCompleteHandler);
	if( _data.c != 0 )// && !SFSConnection.instance.mySelf.isSpectator
	{
		var rect:Rectangle = getBounds(stage);
		battleData.outcomes.push(new RewardData(rect.x + rect.width * 0.5, rect.y + rect.height * 0.5, _data.t, _data.c));
	}
}

override protected function feathersControl_removedFromStageHandler(event:Event):void
{
	if( iconDisplay == null )
		Starling.juggler.removeTweens(iconDisplay);
	super.feathersControl_removedFromStageHandler(event);
}
}
}