package com.gerantech.towercraft.controls.overlays
{
import com.gerantech.towercraft.controls.TileBackground;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.views.effects.UIParticleSystem;
import com.gt.towers.constants.CardFeatureType;
import com.gt.towers.scripts.ScriptEngine;
import com.smartfoxserver.v2.entities.data.SFSObject;
import dragonBones.events.EventObject;
import dragonBones.starling.StarlingArmatureDisplay;
import dragonBones.starling.StarlingEvent;
import dragonBones.starling.StarlingTextureData;
import feathers.controls.AutoSizeMode;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import flash.geom.Rectangle;
import starling.display.DisplayObject;
import starling.events.Event;
import starling.textures.SubTexture;
import starling.textures.Texture;

public class NewCardOverlay extends EarnOverlay
{
private var cardArmature:StarlingArmatureDisplay;
private var titleDisplay:ShadowLabel;
private var descriptionDisplay:RTLLabel;
public function NewCardOverlay(type:int)
{
	super(type);
	var params:SFSObject = new SFSObject();
	params.putInt("c", type);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.CARD_NEW, params);
	autoSizeMode = AutoSizeMode.STAGE;
	
}
override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout();
	appModel.navigator.activeScreen.visible = false;// hide back items for better perfomance
}
override protected function defaultOverlayFactory(color:uint = 0, alpha:Number = 0.4) : DisplayObject
{
	var overlay:TileBackground = new TileBackground("home/pistole-tile", 0.8, true, 0x88);
	overlay.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	overlay.touchable = true;
	return overlay;
}

override protected function addedToStageHandler(event:Event) : void
{
	super.addedToStageHandler(event);
	closeOnStage = false;
	
	appModel.sounds.setVolume("main-theme", 0.3);
	
	cardArmature = OpenBookOverlay.factory.buildArmatureDisplay("collect");
	cardArmature.scale = 2;
	cardArmature.touchable = false;
	cardArmature.x = stageWidth * 0.5;
	cardArmature.y = stageHeight * 0.8;
	cardArmature.addEventListener(EventObject.SOUND_EVENT, armature_soundEventHandler);
	addChild(cardArmature);
	
	var rarity:int = ScriptEngine.getInt(CardFeatureType.F00_RARITY, type);
	// change card
	var texture:Texture = Assets.getTexture("cards/" + type, "gui");
	var subtexture:SubTexture = new SubTexture(texture, new Rectangle(0, 0, texture.width, texture.height));
	StarlingTextureData(cardArmature.armature.getSlot("template-card").skinSlotData.getDisplay("cards/template-card").texture).texture = subtexture;
	
	// change rarity color
	texture = Assets.getTexture("cards/bevel-card-back-" + rarity, "gui");
	subtexture = new SubTexture(texture, new Rectangle(0, 0, texture.width, texture.height));
	StarlingTextureData(cardArmature.armature.getSlot("bevel-card-back").skinSlotData.getDisplay("cards/bevel-card").texture).texture = subtexture;
	
	cardArmature.animation.gotoAndPlayByTime("open", 0, 1);
	
	var newLabel:RTLLabel = new RTLLabel(loc("new_card_label"), 1, null, null, false, null, 1.3)
	newLabel.layoutData = new AnchorLayoutData(stageHeight * 0.25, NaN, NaN, NaN, 0);
	addChild(newLabel);
}

// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= EVENT HANDLERS =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
protected function armature_soundEventHandler(event:StarlingEvent) : void
{
	if( event.eventObject.name == "scoreboard-change-0" )
		showDetails();

	appModel.sounds.addAndPlay(event.eventObject.name);
}
protected function showDetails() : void
{
	closeOnStage = true;
	var bounds:Rectangle = cardArmature.armature.getSlot("template-card").display.getBounds(this);
	
	// explode under card
	var explode:UIParticleSystem = new UIParticleSystem("explode", 0.1);
	explode.startSize *= 4;
	explode.speed *= 4
	explode.x = bounds.x + bounds.width * 0.5;
	explode.y = bounds.y + bounds.height * 0.5;
	addChildAt(explode, 1);
	
	// scraps particles
	var scraps:UIParticleSystem = new UIParticleSystem("scrap", 5);
	scraps.startSize *= 4;
	scraps.x = stageWidth * 0.5;
	scraps.y = -stageHeight * 0.1;
	addChildAt(scraps, 1);

	var titleDisplay:ShadowLabel = new ShadowLabel(loc("card_title_" + type), 1, 0, null, null, false, null, 1.9);
	titleDisplay.layoutData = new AnchorLayoutData(stageHeight * 0.7, NaN, NaN, NaN, 0);
	addChild(titleDisplay);
}

override public function dispose() : void
{
	appModel.navigator.activeScreen.visible = true;
	appModel.sounds.setVolume("main-theme", 1);
	cardArmature.removeEventListener(EventObject.SOUND_EVENT, armature_soundEventHandler);
	super.dispose();
}
}
}