package com.gerantech.towercraft.views.weapons 
{
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.views.ArtRules;
import com.gerantech.towercraft.views.BattleFieldView;
import com.gerantech.towercraft.views.effects.BattleParticleSystem;
import com.gt.towers.battle.BattleField;
import com.gt.towers.battle.GameObject;
import com.gt.towers.battle.bullets.Bullet;
import com.gt.towers.battle.units.Card;
import com.gt.towers.events.BattleEvent;
import starling.core.Starling;
import starling.display.Image;
import starling.display.MovieClip;
import starling.events.Event;
import starling.utils.MathUtil;

/**
* ...
* @author Mansour Djawadi
*/
public class BulletView extends Bullet 
{
public var bulletDisplayFactory:Function;
public var hitDisplayFactory:Function;
private var bulletDisplay:MovieClip;
private var shadowDisplay:Image;
private var rotation:Number;

public function BulletView(battleField:BattleField, id:int, card:Card, side:int, x:Number, y:Number, z:Number, fx:Number, fy:Number, fz:Number) 
{
	super(battleField, id, card, side, x, y, z, fx, fy, fz);
	rotation = MathUtil.normalizeAngle( -Math.atan2( -dx, -dy -dz * BattleField.CAMERA_ANGLE));
	
	if( bulletDisplayFactory == null )
		bulletDisplayFactory = defaultBulletDisplayFactory;
		
	if( hitDisplayFactory == null )
		hitDisplayFactory = defaultHitDisplayFactory;
}

override public function fireEvent(dispatcherId:int, type:String, data:*) : void
{
	if( type == BattleEvent.STATE_CHANGE )
	{
		if( state == GameObject.STATE_1_DIPLOYED )
		{
			appModel.sounds.addAndPlayRandom(appModel.artRules.getArray(card.type, ArtRules.ATTACK_SFX));
			bulletDisplayFactory();
		}
		else if ( state == GameObject.STATE_5_SHOOTING )
		{
			hitDisplayFactory();
			if( BattleField.DEBUG_MODE )
			{
				var damageAreaDisplay:Image = new Image(appModel.assets.getTexture("damage-range"));
				damageAreaDisplay.pivotX = damageAreaDisplay.width * 0.5;
				damageAreaDisplay.pivotY = damageAreaDisplay.height * 0.5;
				damageAreaDisplay.width = card.bulletDamageArea * 2;
				damageAreaDisplay.height = card.bulletDamageArea * 2 * BattleField.CAMERA_ANGLE;
				damageAreaDisplay.x = getSideX();
				damageAreaDisplay.y = getSideY();
				fieldView.effectsContainer.addChild(damageAreaDisplay);
				Starling.juggler.tween(damageAreaDisplay, 0.5, {scale:0, onComplete:damageAreaDisplay.removeFromParent, onCompleteArgs:[true]});
			}
		}
	}
}

override public function setPosition(x:Number, y:Number, z:Number, forced:Boolean = false) : Boolean
{
	if( disposed() )
		return false;

	if( !super.setPosition(x, y, z, forced) )
		return false;

	var _x:Number = this.getSideX();
	var _y:Number = this.getSideY();
	//if( card.type == 151 )
		//trace(id, "side:" + side," x:" + this.x, " y:" + this.y, " z:" + this.z, " _y:" + _y);
	
	if( bulletDisplay != null )
	{
		bulletDisplay.x = _x;
		bulletDisplay.y = _y + this.z * BattleField.CAMERA_ANGLE;
	}
	
	if( shadowDisplay != null )
	{
		shadowDisplay.x = _x;
		shadowDisplay.y = _y;
	} 

	return true;
}

private function defaultBulletDisplayFactory() : void 
{
	var bullet:String = appModel.artRules.get(card.type, ArtRules.BULLET);
	if( bullet == "" || bullet.substr(0,3) == "ps-" )
		return;
	bulletDisplay = new MovieClip(appModel.assets.getTextures("bullets/" + bullet + "/"));
	bulletDisplay.pivotX = bulletDisplay.width * 0.5;
	bulletDisplay.pivotY = bulletDisplay.height * 0.5;
	bulletDisplay.rotation = rotation;
	fieldView.effectsContainer.addChild(bulletDisplay);
	if( bulletDisplay.numFrames > 1 )
	{
		bulletDisplay.loop = true;
		Starling.juggler.add(bulletDisplay);
		bulletDisplay.play();
	}
	
	shadowDisplay = new Image(appModel.assets.getTexture("troops-shadow"));
	shadowDisplay.pivotX = shadowDisplay.width * 0.5;
	shadowDisplay.pivotY = shadowDisplay.height * 0.5;
	fieldView.unitsContainer.addChildAt(shadowDisplay, 0);
}

protected function defaultHitDisplayFactory() : void
{
	var hit:String = appModel.artRules.get(card.type, ArtRules.HIT);
	if( hit == "" )
		return;
		
	/*if( hit.substr(0,3) == "ps-" )
	{//"hits/" + hit + "/" +
		var hitParticle:BattleParticleSystem = new BattleParticleSystem(hit, hit, 1, true, true);
		hitParticle.x = getSideX();
		hitParticle.y = getSideY();
		fieldView.effectsContainer.addChild(hitParticle);
		return;
	}*/
	
	if( hit == "explode-" )
		fieldView.shake();
	
	var hitDisplay:MovieClip = new MovieClip(appModel.assets.getTextures("hits/" + hit), 45);
	hitDisplay.pivotX = hitDisplay.width * 0.5;
	hitDisplay.pivotY = hitDisplay.height * 0.5;
	hitDisplay.width = card.bulletDamageArea * 2.8;
	hitDisplay.scaleY = hitDisplay.scaleX;
	hitDisplay.x = getSideX();
	hitDisplay.y = getSideY();
	fieldView.effectsContainer.addChild(hitDisplay);
	hitDisplay.play();
	Starling.juggler.add(hitDisplay);
	hitDisplay.addEventListener(Event.COMPLETE, function() : void { Starling.juggler.remove(hitDisplay); hitDisplay.removeFromParent(true); });

	appModel.sounds.addAndPlayRandom(appModel.artRules.getArray(card.type, ArtRules.HIT_SFX));
}

override public function dispose():void
{
	if( shadowDisplay != null )
		shadowDisplay.removeFromParent(true);
	
	if( bulletDisplay != null )
	{
		Starling.juggler.remove(bulletDisplay);
		bulletDisplay.removeFromParent(true);
	}
	
	super.dispose();
}

protected function get appModel():		AppModel		{	return AppModel.instance;			}
protected function get fieldView():		BattleFieldView {	return appModel.battleFieldView;	}
}
}