package com.gerantech.towercraft.controls.overlays
{
import com.gerantech.towercraft.controls.groups.Devider;
import com.gerantech.towercraft.models.vo.BattleData;
import com.gerantech.towercraft.models.vo.RewardData;
import com.gerantech.towercraft.views.effects.UIParticleSystem;
import com.gt.towers.constants.ResourceType;
import com.smartfoxserver.v2.entities.data.ISFSArray;
import feathers.controls.AutoSizeMode;
import feathers.controls.Button;
import feathers.data.ListCollection;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;
import starling.display.DisplayObject;
import starling.events.Event;

public class EndOverlay extends BaseOverlay
{
public var inTutorial:Boolean;
public var winRatio:Number = 1;
public var playerIndex:int;
public var score:int;
public var rewards:ISFSArray;

protected var initialingCompleted:Boolean;
protected var padding:int;
protected var battleData:BattleData;
protected var showAdOffer:Boolean;
private var timeoutId:uint;

public function EndOverlay(battleData:BattleData, playerIndex:int, rewards:ISFSArray, inTutorial:Boolean = false)
{
	super();
	this.battleData = battleData;
	this.playerIndex = playerIndex;
	this.rewards = rewards;
	this.inTutorial = inTutorial;
	this.battleData.outcomes = new Vector.<RewardData>();
	if( playerIndex > -1 )
	{
		this.score = rewards.getSFSObject(playerIndex).getInt("score");
		if ( rewards.size() < 2 )
			winRatio = score;
		else
			winRatio = this.score / rewards.getSFSObject(playerIndex == 0?1:0).getInt("score");
	}
}

override protected function initialize():void
{
	closeOnStage = false;
	autoSizeMode = AutoSizeMode.STAGE;
	super.initialize();
	overlay.touchable = false;
	layout = new AnchorLayout();
	padding = 48;

	appModel.sounds.addAndPlay("outcome-" + (winRatio >= 1?"victory":"defeat"));
	initialingCompleted = true;
	
	timeoutId = setTimeout(showParticle, 800);
}

private function showParticle():void 
{
	if ( !battleData.isLeft && playerIndex != -1 )
	{
		var particle:UIParticleSystem = new UIParticleSystem(winRatio >= 1 ? "scrap" : "fire", 4);
		particle.startSize *= 4;
		particle.x = stage.stageWidth * 0.5;
		particle.y = winRatio >= 1 ? -stage.stageHeight*0.1 : stage.stageHeight * 1.05;
		addChildAt(particle, 1);
	}
}


override protected function defaultOverlayFactory(color:uint = 0, alpha:Number = 0.4):DisplayObject
{
	var overlay:Devider = new Devider(battleData.isLeft || playerIndex == -1 ? 0x000000 : (winRatio > 1 ? 0x002211 : 0x331300));
	overlay.alpha = 0.7;
	overlay.width = stage.width;
	overlay.height = stage.height;
	return overlay;
}

protected function getRewardsCollection(playerIndex:int):ListCollection
{
	var ret:ListCollection = new ListCollection();
	if( playerIndex == -1 )
		return ret;

	var keys:Array = rewards.getSFSObject(playerIndex).getKeys();
	for( var i:int = 0; i < keys.length; i++)
	{
		var key:int = int(keys[i])
		if( key == ResourceType.R2_POINT && player.get_arena(player.getResource(key) - rewards.getSFSObject(playerIndex).getInt(keys[i])) == 0 )
			continue;
		if( ResourceType.isBook(key) || key == ResourceType.R1_XP || key == ResourceType.R2_POINT || key == ResourceType.R3_CURRENCY_SOFT )
			ret.push({t:key, c:rewards.getSFSObject(playerIndex).getInt(keys[i])});
	}
	return ret;
}

protected function buttons_triggeredHandler(event:Event):void
{
	if( Button(event.currentTarget).name == "retry" )
	{
		dispatchEventWith(FeathersEventType.CLEAR, false, showAdOffer);
		setTimeout(close, 10);
		return;
	}
	close();
}

override public function dispose():void 
{
	clearTimeout(timeoutId);
	super.dispose();
}
}
}