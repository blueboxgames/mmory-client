package com.gerantech.towercraft.controls.overlays
{
import com.gerantech.towercraft.controls.headers.BattleHeader;
import com.gerantech.towercraft.models.vo.BattleData;
import feathers.controls.AutoSizeMode;
import feathers.controls.LayoutGroup;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import flash.utils.setTimeout;
import starling.animation.Transitions;
import starling.core.Starling;

public class BattleStartOverlay extends BaseOverlay
{
public var mapIndex:int = 0;
public var battleData:BattleData;

private var padding:int;
private var axisHeader:BattleHeader;
private var alliseHeader:BattleHeader;
private var container:LayoutGroup;

public function BattleStartOverlay(mapIndex:int, battleData:BattleData)
{
	super();
	padding = 48;
	this.mapIndex = mapIndex;
	this.battleData = battleData;
}

override protected function initialize():void
{
	closeOnStage = false;
	autoSizeMode = AutoSizeMode.STAGE;
	hasOverlay = true;
	super.initialize();
	
	container = new LayoutGroup();
	container.layout = new AnchorLayout();
	container.x = padding;
	container.width = stage.stageWidth - padding * 2;
	container.height = stage.stageHeight;
	addChild(container);
	
	var name:String = mapIndex >-1?(loc("operation_label") + " " +(mapIndex + 1)): battleData.axis.getText("name");
	// axis elements
	if( player.get_battleswins() < 4 && player.tutorialMode == 1 )
		name = loc("trainer_label");
	axisHeader = new BattleHeader(name, false, -1);
	axisHeader.layoutData = new AnchorLayoutData(300, 100, NaN, 100);
	container.addChild(axisHeader);
	
	if( mapIndex > -1 )
	{
		setTimeout(disappear, 2000);
		return;
	}
	
	// allise elements
	name = battleData.allise.getText("name") == "guest" ? loc("guest_label") : battleData.allise.getText("name");
	alliseHeader = new BattleHeader(name, true, -1);
	alliseHeader.width = padding * 16;
	alliseHeader.layoutData = new AnchorLayoutData(800, 100, NaN, 100);
	container.addChild(alliseHeader);
	
	setTimeout(disappear, 2000);
}

public function disappear():void
{
	Starling.juggler.tween(container, 0.6, {alpha:0, y: -padding * 4, transition:Transitions.EASE_IN_BACK});
	Starling.juggler.tween(overlay, 0.5, {alpha:0});
	setTimeout(close, 800, true)
}
}
}