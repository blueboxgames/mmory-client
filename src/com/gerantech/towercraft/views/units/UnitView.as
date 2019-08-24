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
import com.gerantech.towercraft.views.UnitMC;
import com.gerantech.towercraft.views.effects.BattleParticleSystem;
import com.gerantech.towercraft.views.units.elements.ImageElement;
import com.gerantech.towercraft.views.weapons.BulletView;

import flash.utils.setTimeout;

import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;
import starling.display.MovieClip;
import starling.events.Event;
import starling.filters.ColorMatrixFilter;
import starling.utils.Color;
import com.gerantech.towercraft.views.units.elements.UnitBody;

public class UnitView extends BaseUnit
{
static public const _WIDTH:int = 300;
static public const _HEIGHT:int = 300;
static public const _SCALE:Number = 0.95;
static public const _PIVOT_Y:Number = 0.75;

private var shadowScale:Number;
private var bodyScale:Number;
private var __x:Number;
private var __y:Number;
private var __yz:Number;
private var _muted:Boolean = true;

public var fireDisplayFactory:Function;

private var deployIcon:CountdownIcon;
private var baseDisplay:ImageElement;
private var rangeDisplay:ImageElement;
private var sizeDisplay:ImageElement;
private var bodyDisplay:UnitBody;
private var shadowDisplay:UnitMC;
private var healthDisplay:HealthBarLeveled;
private var flameParticle:BattleParticleSystem;
private var smokeParticle:BattleParticleSystem;
private var bulletParticle:BattleParticleSystem;
private var hitFilterBase:ColorMatrixFilter;
private var hitFilterBody:ColorMatrixFilter;

public function UnitView(card:Card, id:int, side:int, x:Number, y:Number, z:Number)
{
	super(card, id, side, x, y, z);
	__x = getSideX();
	__y = getSideY();

	var appearanceDelay:Number = Math.random() * 0.5;
	
	if( appModel.artRules.get(card.type, ArtRules.BASE) != "" )
	{
		baseDisplay = new ImageElement(this, appModel.assets.getTexture(card.type + "/" + battleField.getColorIndex(side) + "/base"));
		baseDisplay.pivotX = baseDisplay.width * 0.5;
		baseDisplay.pivotY = baseDisplay.height * _PIVOT_Y;
		baseDisplay.x = __x;
		baseDisplay.y = __y - 1;
		baseDisplay.width = _WIDTH;
		baseDisplay.height = _HEIGHT;
		baseDisplay.scale *= _SCALE;
		fieldView.unitsContainer.addChild(baseDisplay);
	}

	bodyDisplay = new UnitBody(this);
	bodyDisplay.pivotX = bodyDisplay.width * 0.5;
	bodyDisplay.pivotY = bodyDisplay.height * _PIVOT_Y;
	bodyDisplay.x = __x;
	bodyDisplay.y = __y;
	bodyDisplay.width = _WIDTH;
	bodyDisplay.height = _HEIGHT;
	bodyScale = bodyDisplay.scale *= _SCALE;
	fieldView.unitsContainer.addChild(bodyDisplay);

	shadowDisplay = new UnitMC(card.type + "/", "m_" + (side == battleField.side ? "000_" : "180_"));
	shadowDisplay.alpha = 0.4;
	shadowDisplay.pivotX = shadowDisplay.width * 0.5;
	shadowDisplay.pivotY = shadowDisplay.height * _PIVOT_Y;
	shadowDisplay.x = __x;
	shadowDisplay.y = __y;
	shadowDisplay.width = _WIDTH;
	shadowDisplay.height = _HEIGHT;
	shadowScale = shadowDisplay.scale *= _SCALE;
	shadowDisplay.currentFrame = bodyDisplay.startFrame;
	shadowDisplay.pause();
	Starling.juggler.add(shadowDisplay);
	fieldView.shadowsContainer.addChild(shadowDisplay);

	if( CardTypes.isTroop(card.type) )
	{
		bodyDisplay.alpha = 0;
		bodyDisplay.y = __yz - 100;
		bodyDisplay.scaleY = bodyScale * 4;
		Starling.juggler.tween(bodyDisplay, 0.3, {delay:appearanceDelay,		alpha:0.5, y:__yz,	transition:Transitions.EASE_OUT, onComplete:defaultSummonEffectFactory});
		Starling.juggler.tween(bodyDisplay, 0.3, {delay:appearanceDelay + 0.1,	scaleY:bodyScale,	transition:Transitions.EASE_OUT_BACK});
		
		shadowDisplay.scale = 0.1
		Starling.juggler.tween(shadowDisplay, 0.3, {delay:appearanceDelay + 0.1,scale:shadowScale,	transition:Transitions.EASE_OUT_BACK});
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
	
	if( BattleField.DEBUG_MODE )
	{
		sizeDisplay = new ImageElement(this, appModel.assets.getTexture("damage-range"));
		sizeDisplay.pivotX = sizeDisplay.width * 0.5;
		sizeDisplay.pivotY = sizeDisplay.height * 0.5;
		sizeDisplay.width = card.sizeH * 2;
		sizeDisplay.height = card.sizeH * 1.42;
		sizeDisplay.color = Color.NAVY;
		sizeDisplay.x = __x;
		sizeDisplay.y = __y;
		fieldView.unitsContainer.addChildAt(sizeDisplay, 0);
		
		rangeDisplay = new ImageElement(this, appModel.assets.getTexture("damage-range"));
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
		bodyDisplay.scaleY = bodyScale;
		Starling.juggler.removeTweens(bodyDisplay);
		
		shadowDisplay.scale = shadowScale;
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

override public function fireEvent(dispatcherId:int, type:String, data:*) : void
{
	if( type == BattleEvent.ATTACK )
	{
		var enemy:Unit = data as Unit;
		var rad:Number = Math.atan2(__x - getSide_X(enemy.x), getSide_Y(y) - getSide_Y(enemy.y));
		var fireOffset:Point3 = ArtRules.getFlamePosition(card.type, rad);
		fireDisplayFactory(__x + fireOffset.x, __y + fireOffset.y, rad);
		
		fireOffset = ArtRules.getFlamePosition(card.type, Math.atan2(x - enemy.x, y - enemy.y));
		var b:BulletView = new BulletView(battleField, enemy.bulletId, card, side, x + fireOffset.x, y, fireOffset.y / BattleField.CAMERA_ANGLE, enemy.x, enemy.y, 0);
		b.targetId = enemy.id;
		battleField.bullets.set(enemy.bulletId, b as Bullet);
		enemy.bulletId ++;
		switchAnimation("s_", battleField.units.get(enemy.id).getSideX(), __x, battleField.units.get(enemy.id).getSideY(), __y);
	}
	super.fireEvent(dispatcherId, type, data);
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
	switchAnimation("m_", __x, _x, __y, _y);
	
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

private function switchAnimation(anim:String, x:Number, oldX:Number, y:Number, oldY:Number):void
{
	if( bodyDisplay == null )
		return;
	if( x == GameObject.NaN )
		x = this.x;
	if( y == GameObject.NaN )
		y = this.y;

	var flipped:Boolean = false;
	var dir:String = CoreUtils.getRadString(Math.atan2(oldX - x, oldY - y));
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
	
	shadowDisplay.loop = anim == "m_";;
	//shadowDisplay.scaleX = (flipped ? -shadowDisplay.scaleY : shadowDisplay.scaleY );
	shadowDisplay.updateTexture(anim, dir);
	
	bodyDisplay.loop = shadowDisplay.loop;
	bodyDisplay.scaleX = (flipped ? -bodyScale : bodyScale );
	bodyDisplay.updateTexture(anim, dir);
}

override public function setHealth(health:Number) : Number
{
	if( this.disposed() )
		return 0;

	var damage:Number =  super.setHealth(health);
	if( damage == 0 )
		return damage;
	
	if( bodyDisplay != null && damage > 0.01 )
	{
		if( hitFilterBody == null )
		{
			hitFilterBody = new ColorMatrixFilter();
			hitFilterBody.adjustBrightness(0.6);
			hitFilterBase = new ColorMatrixFilter();
			hitFilterBase.adjustBrightness(0.6);
		}
		bodyDisplay.filter = hitFilterBody;
		if( baseDisplay != null )
			baseDisplay.filter = hitFilterBase;
		setTimeout( function() : void
		{
			if( bodyDisplay != null && bodyDisplay.parent != null )
				bodyDisplay.filter = null;
			if( baseDisplay != null && baseDisplay.parent != null )
				baseDisplay.filter = null;
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
	Starling.juggler.tween(bodyDisplay, 0.2, {alpha:0, repeatCount:9});

	var summonParticle:BattleParticleSystem = new BattleParticleSystem(this, "summon-base", "summons/summon-base", 1, false, true);
	summonParticle.scaleY = BattleField.CAMERA_ANGLE;
	summonParticle.x = getSideX();
	summonParticle.y = getSideY();
	summonParticle.alpha = 0.06;
	summonParticle.start(-1);
	fieldView.unitsContainer.addChildAt(summonParticle, 0);
	return;
	
	var summonDisplay:MovieClip = new MovieClip(appModel.assets.getTextures("summons/explode-"), 35);
	summonDisplay.pivotX = summonDisplay.width * 0.5;
	summonDisplay.pivotY = summonDisplay.height * 0.5;
	summonDisplay.width = ArtRules.getShadowSize(card.type) * 2.00;
	summonDisplay.height = summonDisplay.width * BattleField.CAMERA_ANGLE;
	summonDisplay.x = getSideX();
	summonDisplay.y = getSideY();
	fieldView.unitsContainer.addChildAt(summonDisplay, 0);
	summonDisplay.play();
	Starling.juggler.add(summonDisplay);
	summonDisplay.addEventListener(Event.COMPLETE, function() : void { Starling.juggler.remove(summonDisplay); summonDisplay.removeFromParent(true); });
}

public function showWinnerFocus():void 
{
	var winnerDisplay:Image = new Image(appModel.assets.getTexture("damage-range"));
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
	var die:String = appModel.artRules.get(card.type, ArtRules.DIE);
	if( die == "" )
		return;

	var dieDisplay:MovieClip = new MovieClip(appModel.assets.getTextures("die/" + die), 30);
	dieDisplay.pivotX = dieDisplay.width * 0.5;
	dieDisplay.pivotY = dieDisplay.height * 0.5;
	dieDisplay.width = (card.sizeH * 0.7) + 130;
	dieDisplay.scaleY = dieDisplay.scaleX;
	dieDisplay.scaleX *= Math.random() > 0.5 ? -1 : 1;
	dieDisplay.color = 0xFF0000 + Math.random() * 5000;
	dieDisplay.x = getSideX();
	dieDisplay.y = getSideY();
	fieldView.shadowsContainer.addChild(dieDisplay);
	dieDisplay.play();
	Starling.juggler.add(dieDisplay);
	dieDisplay.addEventListener(Event.COMPLETE, function() : void { Starling.juggler.remove(dieDisplay); dieDisplay.removeFromParent(true); });
}

protected function battleField_pauseHandler(event:BattleEvent) : void
{
	var state:int = event.data as int;
	if( state >= BattleField.STATE_3_PAUSED )
	{
		if( bodyDisplay != null )
		{
			Starling.juggler.removeTweens(bodyDisplay);
			bodyDisplay.scale = bodyScale;
			bodyDisplay.alpha = 1;
			bodyDisplay.pause();
		}
		
		if( shadowDisplay != null )
		{
			Starling.juggler.removeTweens(shadowDisplay);
			shadowDisplay.scale = shadowScale;
			shadowDisplay.alpha = 0.2;
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
	if( CardTypes.isHero(card.type) && side != battleField.side )
		fieldView.mapBuilder.changeSummonArea(id < 4);
	bodyDisplay.removeFromParent(true);
	if( shadowDisplay != null )
		shadowDisplay.removeFromParent(true);
	if( baseDisplay != null )
		baseDisplay.removeFromParent(true);
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
		shadowDisplay.alpha = value - 0.6;
	if( rangeDisplay != null )
		rangeDisplay.alpha = value;
	if( healthDisplay != null )
		healthDisplay.alpha = value;
	if( deployIcon != null )
		deployIcon.alpha = value;
}
}
}