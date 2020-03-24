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
import com.gerantech.towercraft.controls.indicators.CountdownIcon;
import com.gerantech.towercraft.views.ArtRules;
import com.gerantech.towercraft.views.effects.BattleParticleSystem;
import com.gerantech.towercraft.views.hb.HealthBar;
import com.gerantech.towercraft.views.hb.HealthBarDetailed;
import com.gerantech.towercraft.views.hb.HealthBarLeveled;
import com.gerantech.towercraft.views.hb.HealthBarZone;
import com.gerantech.towercraft.views.hb.IHealthBar;
import com.gerantech.towercraft.views.units.elements.ImageElement;
import com.gerantech.towercraft.views.units.elements.UnitBody;
import com.gerantech.towercraft.views.units.elements.UnitMC;
import com.gerantech.towercraft.views.weapons.BulletView;

import flash.geom.Point;
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
private var __angle:String = "i_";

public var fireDisplayFactory:Function;
public var healthbarFactory:Function;

private var deployIcon:CountdownIcon;
private var rangeDisplay:ImageElement;
private var sizeDisplay:ImageElement;
private var bodyDisplay:UnitBody;
private var shadowDisplay:UnitMC;
private var healthDisplay:IHealthBar;
private var flameParticle:BattleParticleSystem;
private var smokeParticle:BattleParticleSystem;
private var bulletParticle:BattleParticleSystem;

public function UnitView(card:Card, id:int, side:int, x:Number, y:Number, z:Number, t:Number, isDump:Boolean = false)
{
		
	if( fireDisplayFactory == null )
		fireDisplayFactory = defaultFireDisplayFactory;
	
	if( healthbarFactory == null )
		healthbarFactory = defaultHealthbarFactory;
	
	super(card, id, side, x, y, z, t);
	this.isDump = isDump;
	__x = getSideX();
	__y = getSideY();

	var appearanceDelay:Number = Math.random() * 0.5;
	
	bodyDisplay = new UnitBody(this, card, side);
	bodyDisplay.pivotX = bodyDisplay.width * 0.5;
	bodyDisplay.pivotY = bodyDisplay.height * _PIVOT_Y + appModel.artRules.getInt(card.type, ArtRules.Y);
	bodyDisplay.x = __x;
	bodyDisplay.y = __y;
	bodyDisplay.width = _WIDTH;
	bodyDisplay.height = _HEIGHT;
	__bodyScale = bodyDisplay.scale *= _SCALE;
	fieldView.unitsContainer.addChild(bodyDisplay);

	var angle:String = side == battleField.side ? "000_" : "180_";
	var body:String = appModel.artRules.get(card.type, ArtRules.BODY);
	if( body != "" )
	{
		shadowDisplay = new UnitMC(body + "/0/", "i_" + angle);
		shadowDisplay.pivotX = shadowDisplay.width * 0.5;
		shadowDisplay.pivotY = shadowDisplay.height * _PIVOT_Y + appModel.artRules.getInt(card.type, ArtRules.Y);
		shadowDisplay.x = __x;
		shadowDisplay.y = __y;
		shadowDisplay.width = _WIDTH;
		shadowDisplay.height = _HEIGHT;
		shadowDisplay.alpha = 0.3;
		shadowDisplay.color = 0;
		shadowDisplay.scaleX = __bodyScale;
		shadowDisplay.scaleY = __bodyScale * _SHADOW_SCALE;
		shadowDisplay.currentFrame = bodyDisplay.startFrame;
		Starling.juggler.add(shadowDisplay);
		fieldView.shadowsContainer.addChild(shadowDisplay);
	}

	if( !isDump && CardTypes.isTroop(card.type) )
	{
		bodyDisplay.alpha = 0;
		bodyDisplay.y = __yz - 100;
		bodyDisplay.scaleY = __bodyScale * 4;
		Starling.juggler.tween(bodyDisplay, 0.3, {delay:appearanceDelay,	alpha:0.5, y:__yz,	transition:Transitions.EASE_OUT, onComplete:defaultSummonEffectFactory});
		Starling.juggler.tween(bodyDisplay, 0.1, {delay:appearanceDelay+ 0.1,	alpha:0, repeatCount:20});
		Starling.juggler.tween(bodyDisplay, 0.3, {delay:appearanceDelay + 0.1,	scaleY:__bodyScale,	transition:Transitions.EASE_OUT_BACK});
		if( shadowDisplay != null )
		{
			shadowDisplay.scale = 0.0
			Starling.juggler.tween(shadowDisplay, 0.3, {delay:appearanceDelay + 0.3,scaleX:__bodyScale,scaleY:__bodyScale*_SHADOW_SCALE,	transition:Transitions.EASE_OUT_BACK});
		}
	}
	
	if( !isDump && card.summonTime > 0 )
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

	battleField.addEventListener(BattleEvent.STATE_CHANGE, this.battleField_stateChangeHandler);
}

override public function set_state(value:int) : int
{
	if( this.state == value )
		return this.state;
	super.set_state(value);
	if( this.state == GameObject.STATE_1_DIPLOYED )
	{
		if( deployIcon != null )
			deployIcon.scaleTo(0, 0, 0.5, function():void{deployIcon.removeFromParent(true);} );
	}
	else if( this.state == GameObject.STATE_2_MORTAL )
	{
		// finish summon animations
		bodyDisplay.play();
		bodyDisplay.x = __x;
		bodyDisplay.y = __yz;
		bodyDisplay.alpha = 1;
		bodyDisplay.scaleY = __bodyScale;
		Starling.juggler.removeTweens(bodyDisplay);
		
		if( shadowDisplay != null )
		{
			shadowDisplay.play();
			shadowDisplay.scaleX = __bodyScale;
			shadowDisplay.scaleY = __bodyScale * _SHADOW_SCALE;
			Starling.juggler.removeTweens(shadowDisplay);
		}
	}
	else if( this.state >= GameObject.STATE_4_MOVING && state <= GameObject.STATE_6_IDLE )
	{
		this.turn(UnitMC.ANIMATIONS[state - 4], __angle);
	}
	return this.state;
}

override public function attack(target:Unit) : void
{
	var _a:String =  CoreUtils.getRadString(Math.atan2(__x - target.getSideX(), __y - target.getSideY()));
	if( __angle != _a && this.state == GameObject.STATE_5_SHOOTING )
		this.turn("s_", _a);// force update animation when state not changed yet
	__angle = _a;
	super.attack(target);
	
	var fireOffset:Point = appModel.artRules.getFlamePosition(card.type, Math.atan2(x - target.x, y - target.y));
	var b:BulletView = new BulletView(battleField, this, target, bulletId, card, side, x + fireOffset.x, y, fireOffset.y / BattleField.CAMERA_ANGLE, target.x, target.y, 0);
	battleField.bullets.push(b as Bullet);
	bulletId ++;
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
	
	bodyDisplay.loop = anim == "m_";
	bodyDisplay.scaleX = (flipped ? -__bodyScale : __bodyScale );
	bodyDisplay.addEventListener(Event.COMPLETE, bodyDisplay_shootCompleteHandler);
	bodyDisplay.updateTexture(anim, dir);
	
	if( shadowDisplay != null )
	{
		shadowDisplay.loop = bodyDisplay.loop;
		shadowDisplay.scaleX = (flipped ? -__bodyScale : __bodyScale );
		shadowDisplay.updateTexture(anim, dir);
	}
}

protected function bodyDisplay_shootCompleteHandler(event:Object):void
{
	this.turn("i_", __angle);
}

override public function estimateAngle(x:Number, y:Number):Number
{
	var angle:Number = super.estimateAngle(x, y);
	if( angle == -1 )
		return angle;
	var _a:String = CoreUtils.getRadString(Math.atan2(this.getSideX() - this.getSide_X(x), this.getSideY() - this.getSide_Y(y)));
	if( __angle != _a && this.state == GameObject.STATE_4_MOVING )
		this.turn("m_", _a);// force update animation when state not changed yet
	__angle = _a;
	return angle;
}

override public function setHealth(health:Number) : Number
{
	if( this.disposed() )
		return 0;

	if( health < 0 && card.selfDammage == 0 )
		return 0;
	
	var damage:Number = super.setHealth(health);
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
		healthDisplay = this.healthbarFactory();
	healthDisplay.value = health;
	healthDisplay.setPosition(__x, __yz - card.sizeV - 60);
	if( health < 0 )
		dispose();
	
	return damage;
}

override public function set_side(value:int):int
{
	if( this.side == value )
		return value;
	if( this.healthDisplay != null )
		this.healthDisplay.side = value;
	return super.set_side(value);
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

protected function defaultHealthbarFactory():	IHealthBar
{
	if( side < 0 )
		return new HealthBarZone(fieldView, this);
	if( !CardTypes.isTroop(card.type) )
		return new HealthBarDetailed(fieldView, battleField.getColorIndex(side), card.level, cardHealth);
	return new HealthBarLeveled(fieldView, battleField.getColorIndex(side), card.level, cardHealth);
}

private function showDieAnimation():void 
{
	if( battleField.state >= BattleField.STATE_4_ENDED )
		return;

	if( CardTypes.isHero(card.type) && side != battleField.side )
		fieldView.mapBuilder.setSummonAreaEnable(true, battleField.getSummonState(battleField.side == 0 ? 1 : 0), true);

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

protected function battleField_stateChangeHandler(event:BattleEvent) : void
{
	var battleState:int = event.data as int;
	if( battleState >= BattleField.STATE_3_PAUSED )
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

	if( battleState != BattleField.STATE_2_STARTED )
		return;

	bodyDisplay.play();
	if( shadowDisplay != null )
		shadowDisplay.play();
}

override public function dispose() : void
{
	super.dispose();
	battleField.removeEventListener(BattleEvent.STATE_CHANGE, this.battleField_stateChangeHandler);
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