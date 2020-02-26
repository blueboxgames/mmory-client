package com.gerantech.towercraft.views.units
{
import com.gerantech.mmory.core.battle.BattleField;
import com.gerantech.mmory.core.battle.GameObject;
import com.gerantech.mmory.core.battle.bullets.Bullet;
import com.gerantech.mmory.core.battle.units.Card;
import com.gerantech.mmory.core.battle.units.Unit;
import com.gerantech.mmory.core.constants.CardTypes;
import com.gerantech.mmory.core.events.BattleEvent;
import com.gerantech.mmory.core.utils.CoreUtils;
import com.gerantech.mmory.core.utils.Point3;
import com.gerantech.towercraft.controls.indicators.CountdownIcon;
import com.gerantech.towercraft.controls.sliders.battle.HealthBarDetailed;
import com.gerantech.towercraft.controls.sliders.battle.HealthBarLeveled;
import com.gerantech.towercraft.views.ArtRules;
import com.gerantech.towercraft.views.effects.BattleParticleSystem;
import com.gerantech.towercraft.views.units.elements.ImageElement;
import com.gerantech.towercraft.views.units.elements.UnitBody;
import com.gerantech.towercraft.views.units.elements.UnitMC;
import com.gerantech.towercraft.views.weapons.BulletView;

import flash.utils.setTimeout;

import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.MovieClip;
import starling.events.Event;
import starling.utils.Color;

public class UnitView extends BaseUnit
{
static public const _WIDTH:int = 512;
static public const _HEIGHT:int = 512;
static public const _SCALE:Number = 1;
static public const _PIVOT_Y:Number = 0.65;
static public const _SHADOW_SCALE:Number = -0.5;

private var __x:Number;
private var __y:Number;
private var __yz:Number;
private var _muted:Boolean = true;
private var __bodyScale:Number;

public var fireDisplayFactory:Function;

private var deployIcon:CountdownIcon;
private var rangeDisplay:ImageElement;
private var sizeDisplay:ImageElement;
private var bodyDisplay:UnitBody;
private var shadowDisplay:UnitMC;
private var healthDisplay:HealthBarLeveled;
private var flameParticle:BattleParticleSystem;
private var smokeParticle:BattleParticleSystem;
private var bulletParticle:BattleParticleSystem;

public function UnitView(card:Card, id:int, side:int, x:Number, y:Number, z:Number, t:Number)
{
	super(card, id, side, x, y, z, t);
	__x = getSideX();
	__y = getSideY();

	var appearanceDelay:Number = Math.random() * 0.5;
	
	bodyDisplay = new UnitBody(this, card, side);
	bodyDisplay.pivotX = bodyDisplay.width * 0.5;
	bodyDisplay.pivotY = bodyDisplay.height * _PIVOT_Y + appModel.artRules.getInt(card.type, "y");
	bodyDisplay.x = __x;
	bodyDisplay.y = __y;
	bodyDisplay.width = _WIDTH;
	bodyDisplay.height = _HEIGHT;
	__bodyScale = bodyDisplay.scale *= _SCALE;
	fieldView.unitsContainer.addChild(bodyDisplay);

	var angle:String = side == battleField.side ? "000_" : "180_";
  shadowDisplay = new UnitMC(appModel.artRules.get(card.type, ArtRules.TEXTURE) + "/0/", "m_" + angle);
	shadowDisplay.pivotX = shadowDisplay.width * 0.5;
	shadowDisplay.pivotY = shadowDisplay.height * _PIVOT_Y + appModel.artRules.getInt(card.type, "y");
	// shadowDisplay.skewX = 10;
	shadowDisplay.x = __x;
	shadowDisplay.y = __y;
	shadowDisplay.width = _WIDTH;
	shadowDisplay.height = _HEIGHT;
	shadowDisplay.alpha = 0.3;
	shadowDisplay.color = 0;
	shadowDisplay.scaleX = __bodyScale;
	shadowDisplay.scaleY = __bodyScale * _SHADOW_SCALE;
	shadowDisplay.currentFrame = bodyDisplay.startFrame;
	shadowDisplay.pause();
	Starling.juggler.add(shadowDisplay);
	fieldView.shadowsContainer.addChild(shadowDisplay);

	if( CardTypes.isTroop(card.type) )
	{
		bodyDisplay.alpha = 0;
		bodyDisplay.y = __yz - 100;
		bodyDisplay.scaleY = __bodyScale * 4;
		Starling.juggler.tween(bodyDisplay, 0.3, {delay:appearanceDelay,	alpha:0.5, y:__yz,	transition:Transitions.EASE_OUT, onComplete:defaultSummonEffectFactory});
		Starling.juggler.tween(bodyDisplay, 0.1, {delay:appearanceDelay+ 0.1,	alpha:0, repeatCount:20});
		Starling.juggler.tween(bodyDisplay, 0.3, {delay:appearanceDelay + 0.1,	scaleY:__bodyScale,	transition:Transitions.EASE_OUT_BACK});
		shadowDisplay.scale = 0.0
		Starling.juggler.tween(shadowDisplay, 0.3, {delay:appearanceDelay + 0.3,scaleX:__bodyScale,scaleY:__bodyScale*_SHADOW_SCALE,	transition:Transitions.EASE_OUT_BACK});
	}
	
	if( card.summonTime > 0 )
	{
		deployIcon = new CountdownIcon();
		deployIcon.stop();
		deployIcon.scale = 0.5;
		deployIcon.x = __x;
		deployIcon.y = __yz - 80;
		deployIcon.rotateTo(0, 360, card.summonTime / 1000);
		setTimeout(fieldView.guiImagesContainer.addChild, appearanceDelay * 1000, deployIcon);
	}
	if( battleField.debugMode )
	{
		sizeDisplay = new ImageElement(null, appModel.assets.getTexture("map/damage-range"));
		sizeDisplay.pivotX = sizeDisplay.width * 0.5;
		sizeDisplay.pivotY = sizeDisplay.height * 0.5;
		sizeDisplay.width = card.sizeH * 2;
		sizeDisplay.height = card.sizeH * 2 * BattleField.CAMERA_ANGLE;
		sizeDisplay.color = Color.NAVY;
		sizeDisplay.x = __x;
		sizeDisplay.y = __y;
		fieldView.unitsContainer.addChild(sizeDisplay);
		
		rangeDisplay = new ImageElement(this, appModel.assets.getTexture("map/damage-range"));
		rangeDisplay.pivotX = rangeDisplay.width * 0.5;
		rangeDisplay.pivotY = rangeDisplay.height * 0.5;
		rangeDisplay.width = card.bulletRangeMax * 2;
		rangeDisplay.height = card.bulletRangeMax * 1.42;
		rangeDisplay.alpha = 0.1;
		rangeDisplay.x = __x;
		rangeDisplay.y = __y;
		fieldView.unitsContainer.addChildAt(rangeDisplay, 0);
	}
	
	if( fireDisplayFactory == null )
		fireDisplayFactory = defaultFireDisplayFactory;

	battleField.addEventListener(BattleEvent.PAUSE, battleField_pauseHandler);
}

override public function setState(state:int) : Boolean
{
	var _state:int = super.state;
	if( !super.setState(state) )
		return false;
	
	if( state == GameObject.STATE_1_DIPLOYED )
	{
		if( deployIcon != null )
			deployIcon.scaleTo(0, 0, 0.5, function():void{deployIcon.removeFromParent(true);} );
	}
	else if( state == GameObject.STATE_2_MORTAL )
	{
		// finish summon animations
		bodyDisplay.pause();
		bodyDisplay.x = __x;
		bodyDisplay.y = __yz;
		bodyDisplay.alpha = 1;
		bodyDisplay.scaleY = __bodyScale;
		Starling.juggler.removeTweens(bodyDisplay);
		
		shadowDisplay.scaleX = __bodyScale;
		shadowDisplay.scaleY = __bodyScale * _SHADOW_SCALE;
		Starling.juggler.removeTweens(shadowDisplay);
	}
	else if( state == GameObject.STATE_3_WAITING )
	{
		bodyDisplay.currentFrame = 0;
		shadowDisplay.currentFrame = 0;
		if ( _state != GameObject.STATE_5_SHOOTING )
		{
			shadowDisplay.pause();
			bodyDisplay.pause();
			if( CardTypes.isHero(card.type) )
			{
				bodyDisplay.updateTexture("m_", side == battleField.side ? "000_" : "180_");
				shadowDisplay.updateTexture("m_", side == battleField.side ? "000_" : "180_");
			}
		}
	}
	else if( state == GameObject.STATE_4_MOVING || state == GameObject.STATE_5_SHOOTING )
	{
		bodyDisplay.play();
		shadowDisplay.play();
	}
	return true;
}

override public function attack(enemy:Unit) : void
{
	super.attack(enemy);
	var rad:Number = Math.atan2(__x - getSide_X(enemy.x), getSide_Y(y) - getSide_Y(enemy.y));
	var fireOffset:Point3 = ArtRules.getFlamePosition(card.type, rad);
	fireDisplayFactory(__x + fireOffset.x, __y + fireOffset.y, rad);
	
	fireOffset = ArtRules.getFlamePosition(card.type, Math.atan2(x - enemy.x, y - enemy.y));
	var b:BulletView = new BulletView(battleField, bulletId, card, side, x + fireOffset.x, y, fireOffset.y / BattleField.CAMERA_ANGLE, enemy.x, enemy.y, 0);
	b.targetId = enemy.id;
	battleField.bullets.push(b as Bullet);
	bulletId ++;
	turn("s_", CoreUtils.getRadString(Math.atan2(__x - enemy.getSideX(), __y - enemy.getSideY())));
}

override public function setPosition(x:Number, y:Number, z:Number, forced:Boolean = false) : Boolean
{
	if( disposed() )
		return false;
	
	var _x:Number = getSideX();
	var _y:Number = getSideY();
	if( !super.setPosition(x, y, z, forced) )
		return false;
	
	__x = getSideX();
	__y = getSideY();
	__yz = __y + this.z * BattleField.CAMERA_ANGLE;
	
	if( bodyDisplay != null )
	{
		bodyDisplay.x = __x;
		bodyDisplay.y = __yz;	
	}
	
	if( shadowDisplay != null )
	{
		shadowDisplay.x = __x;
		shadowDisplay.y = __y;
	}

	if( healthDisplay != null )
		healthDisplay.setPosition(__x, __yz - card.sizeV - 60);

	if( rangeDisplay != null )
	{
		rangeDisplay.x = __x;
		rangeDisplay.y = __y;
	}
	
	if( sizeDisplay != null )
	{
		sizeDisplay.x = __x;
		sizeDisplay.y = __y;
	}
	return true;
}

private function turn(anim:String, dir:String):void
{
	if( bodyDisplay == null )
		return;

	var flipped:Boolean = false;
	if( dir == "-45" || dir == "-90" || dir == "-35" )
	{
		if( dir == "-45" )
			dir = dir.replace("-45", "045");
		else if( dir == "-90" )
			dir = dir.replace("-90", "090");
		else
			dir = dir.replace("-35", "135");
		flipped = true;
	}
	shadowDisplay.loop = anim == "m_";
	shadowDisplay.scaleX = (flipped ? -__bodyScale : __bodyScale );
	shadowDisplay.updateTexture(anim, dir);
	
	bodyDisplay.loop = shadowDisplay.loop;
	bodyDisplay.scaleX = (flipped ? -__bodyScale : __bodyScale );
	bodyDisplay.updateTexture(anim, dir);
}

override public function estimateAngle(x:Number, y:Number):Number
{
	var angle:Number = super.estimateAngle(x, y); 
	if( angle == -1 )
		return angle;

	if( state == GameObject.STATE_4_MOVING )
	turn("m_", CoreUtils.getRadString(Math.atan2(this.getSideX() - this.getSide_X(x), this.getSideY() - this.getSide_Y(y))));
	return angle;
}

override public function setHealth(health:Number) : Number
{
	if( this.disposed() )
		return 0;

	if( this.id < 6 && health < 0 && health > -10 && this.card.type > 200 )
		return 0;
	
	var damage:Number =  super.setHealth(health);
	if( damage == 0 )
		return damage;
	
	if( bodyDisplay != null && damage > 0.01 )
	{
		bodyDisplay.color = side == 0 ? 0x8888FF : 0xFF8888;
		bodyDisplay.scaleY = __bodyScale * 0.9; 
		setTimeout( function() : void
		{
			if( bodyDisplay != null && bodyDisplay.parent != null )
				bodyDisplay.color = 0xFFFFFF;
				bodyDisplay.scaleY = __bodyScale; 
		}, 50);
	}

	if( healthDisplay == null )
	{
		if( CardTypes.isTroop(card.type) )
			healthDisplay = new HealthBarLeveled(fieldView, battleField.getColorIndex(side), card.level, cardHealth);
		else
			healthDisplay = new HealthBarDetailed(fieldView, battleField.getColorIndex(side), card.level, cardHealth) as HealthBarLeveled;
		healthDisplay.initialize();
	}
	healthDisplay.value = health;
	healthDisplay.setPosition(__x, __yz - card.sizeV - 60);
	if( health < 0 )
		dispose();
	
	return damage;
}

protected function defaultSummonEffectFactory() : void
{
	var summon:String = appModel.artRules.get(card.type, ArtRules.SUMMON);
	if( summon == "" )
		return;

	var summonDisplay:MovieClip = new MovieClip(appModel.assets.getTextures("summons/" + summon), 30);
	summonDisplay.pivotX = summonDisplay.width * 0.5;
	summonDisplay.pivotY = summonDisplay.height * _PIVOT_Y;
	summonDisplay.width = summonDisplay.height = _WIDTH;
	summonDisplay.x = getSideX();
	summonDisplay.y = getSideY();
	fieldView.shadowsContainer.addChild(summonDisplay);
	summonDisplay.play();
	Starling.juggler.add(summonDisplay);
	summonDisplay.addEventListener(Event.COMPLETE, die_completeHandler);
	function die_completeHandler():void
	{
		Starling.juggler.remove(summonDisplay);
		summonDisplay.removeFromParent(true);
	}
}

public function showWinnerFocus():void 
{
	var winnerDisplay:ImageElement = new ImageElement(this, appModel.assets.getTexture("map/damage-range"));
	winnerDisplay.pivotX = winnerDisplay.width * 0.5;
	winnerDisplay.pivotY = winnerDisplay.height * 0.5;
	winnerDisplay.width = 500;
	winnerDisplay.height = 500 * BattleField.CAMERA_ANGLE;
	winnerDisplay.x = getSideX();
	winnerDisplay.y = getSideY();
	fieldView.unitsContainer.addChildAt(winnerDisplay, 0);
	Starling.juggler.tween(winnerDisplay, 1, {scale:0, transition:Transitions.EASE_IN_BACK, onComplete:winnerDisplay.removeFromParent, onCompleteArgs:[true]});
}

protected function defaultFireDisplayFactory(x:Number, y:Number, rotation:Number) : void 
{
	// flame particle
	var flame:String = appModel.artRules.get(card.type, ArtRules.FLAME);
	if( flame != "" )
	{
		if( flameParticle == null )
			flameParticle = new BattleParticleSystem(this, "flame-" + flame, "flames/flame-" + flame, 1, false, false);
		flameParticle.scale = ArtRules.getFlameSize(card.type)
		flameParticle.x = x;
		flameParticle.pivotY = flameParticle.height *	0.9;
		flameParticle.y = y;
		flameParticle.rotation = -rotation;
		flameParticle.start();
		fieldView.effectsContainer.addChild(flameParticle);
	}

	// smoke particle
	var smoke:String = appModel.artRules.get(card.type, ArtRules.SMOKE);
	if( smoke != "" )
	{
		if( smokeParticle == null )
			smokeParticle = new BattleParticleSystem(this, "smoke-" + smoke, "smokes/smoke-" + flame, 1, false, false);
		smokeParticle.scale = ArtRules.getSmokeSize(card.type)
		smokeParticle.x = x;
		smokeParticle.y = y;
		smokeParticle.pivotY = smokeParticle.height *	0.9;
		smokeParticle.start()
		fieldView.effectsContainer.addChild(smokeParticle);
	}

	// bullet particles
	var bulletPS:String = appModel.artRules.get(card.type, ArtRules.BULLET);
	if( bulletPS.substr(0,3) == "ps-" )
	{
		if( bulletParticle == null )
			bulletParticle = new BattleParticleSystem(this, bulletPS, "bullets/" + bulletPS + "/" + bulletPS, 1, false, false);
		bulletParticle.x = x;
		bulletParticle.pivotY = bulletParticle.height *	0.9;
		bulletParticle.y = y;
		bulletParticle.rotation = -rotation;
		bulletParticle.start();
		fieldView.effectsContainer.addChild(bulletParticle);
	}
}

private function showDieAnimation():void 
{
	if( battleField.state >= BattleField.STATE_4_ENDED )
		return;

	if( CardTypes.isHero(card.type) && side != battleField.side )
		fieldView.mapBuilder.setSummonAreaEnable(true, battleField.getSummonState(battleField.side == 0 ? 1 : 0));

	var die:String = appModel.artRules.get(card.type, ArtRules.DIE);
	if( die == "" )
		return;

	var dieDisplay:MovieClip = new MovieClip(appModel.assets.getTextures("die/" + die), 30);
	dieDisplay.pivotX = dieDisplay.width * 0.5;
	dieDisplay.pivotY = dieDisplay.height * _PIVOT_Y;
	dieDisplay.width = dieDisplay.height = _WIDTH;
	dieDisplay.x = getSideX();
	dieDisplay.y = getSideY();
	fieldView.shadowsContainer.addChild(dieDisplay);
	dieDisplay.play();
	Starling.juggler.add(dieDisplay);
	dieDisplay.addEventListener(Event.COMPLETE, die_completeHandler);
	function die_completeHandler():void
	{
		Starling.juggler.remove(dieDisplay);
		dieDisplay.currentFrame = dieDisplay.numFrames - 1;
		if( die.substring(0, 2) != "u-" )
			dieDisplay.removeFromParent(true);
	}

	// shake camera
	fieldView.shake(appModel.artRules.getNumber(card.type, ArtRules.DIE_SHAKE));

	// play die sfx randomly
	appModel.sounds.addAndPlayRandom(appModel.artRules.getArray(card.type, ArtRules.DIE_SFX));
}

protected function battleField_pauseHandler(event:BattleEvent) : void
{
	var state:int = event.data as int;
	if( state >= BattleField.STATE_3_PAUSED )
	{
		if( bodyDisplay != null )
		{
			Starling.juggler.removeTweens(bodyDisplay);
			bodyDisplay.scale = __bodyScale;
			bodyDisplay.alpha = 1;
			bodyDisplay.pause();
		}
		
		if( shadowDisplay != null )
		{
			Starling.juggler.removeTweens(shadowDisplay);
			shadowDisplay.scaleX = __bodyScale;
			shadowDisplay.scaleY = __bodyScale * _SHADOW_SCALE;
			shadowDisplay.alpha = 0.3;
			shadowDisplay.pause();
		}
		return;
	}

	if( state != GameObject.STATE_4_MOVING )
		return;

	bodyDisplay.play();
	shadowDisplay.play();
}

override public function dispose() : void
{
	super.dispose();
	battleField.removeEventListener(BattleEvent.PAUSE, battleField_pauseHandler);
	bodyDisplay.removeFromParent(true);
	if( shadowDisplay != null )
		shadowDisplay.removeFromParent(true);
	if( rangeDisplay != null )
		rangeDisplay.removeFromParent(true);
	if( deployIcon != null )
		deployIcon.removeFromParent(true);
	if( sizeDisplay != null )
		sizeDisplay.removeFromParent(true);
	if( healthDisplay != null )
		healthDisplay.dispose();
	showDieAnimation();
}

public function set alpha(value:Number):void 
{
	bodyDisplay.alpha = value;
	if( shadowDisplay != null )
		shadowDisplay.alpha = value - 0.7;
	if( rangeDisplay != null )
		rangeDisplay.alpha = value;
	if( healthDisplay != null )
		healthDisplay.alpha = value;
	if( deployIcon != null )
		deployIcon.alpha = value;
}
}
}