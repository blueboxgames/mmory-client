package com.gerantech.towercraft.controls.buttons 
{
import com.gerantech.towercraft.utils.StrUtils;
import com.gt.towers.battle.units.Card;
/**
* @author Mansour Djawadi
*/
public class IndicatorCard extends Indicator 
{
private var timeoutId:uint;
public function IndicatorCard(direction:String, type:int, autoApdate:Boolean = true)
{
	super(direction, type, true, false, autoApdate);
	clampValue = false;
}
override protected function initialize():void
{
	super.initialize();
/* 	iconDisplay.maintainAspectRatio = false;
	iconDisplay.source = Assets.getTexture("theme/upgrade-ready");
	iconDisplay.layoutData = new AnchorLayoutData(NaN, direction == "ltr"?NaN: -height*0.5, NaN, direction == "ltr"? -height*0.5:NaN);

	iconDisplay.y = -10;
	iconDisplay.width = 70;
	iconDisplay.height = 80;
 */	
	this.formatValueFactory = function(value:Number, minimum:Number, maximum:Number) : String
	{
		if( value >= maximum )
			return loc("upgrade_label");
		return StrUtils.getNumber(Math.round(value) + "/" + maximum);
	}
}

override public function setData(minimum:Number, value:Number, maximum:Number, changeDuration:Number = 0):void
{
	var card:Card = player.cards.get(type);
	maximum = Card.get_upgradeCards(card == null?1:card.level, card == null?0:card.rarity);
	super.setData(minimum, value, maximum, changeDuration);
	if( this.progressBar != null )
		this.progressBar.isEnabled = this.value >= maximum;
/* 	var _upgradable:Boolean = this.value >= maximum;

	if( iconDisplay == null ) 
		return;
	
	Starling.juggler.removeDelayedCalls(punchArrow);
	if( _upgradable )
		Starling.juggler.delayCall(punchArrow, changeDuration);
	else
		reset();
 */
}

/* private function reset():void 
{
	stopPunching();
	iconDisplay.removeFromParent();
	if( progressBar != null )
		progressBar.paddingTextLeft = 0;
	if( progressBar != null )
		progressBar.isEnabled = false;
}

private function punchArrow(delay:Number = 0):void
{
	stopPunching();
	if( progressBar != null )
	{
		progressBar.paddingTextLeft = 40;
		progressBar.isEnabled = true;
	}
	addChild(iconDisplay);
	Starling.juggler.delayCall(animateIconDisplay, delay);
}
private function animateIconDisplay():void
{
	iconDisplay.y = -45;
	iconDisplay.height = 90;
	Starling.juggler.tween(iconDisplay, 0.9, {y:-10, height:70, transition:Transitions.EASE_OUT_BACK, onComplete:punchArrow, onCompleteArgs:[3]});
}

private function stopPunching():void
{
	iconDisplay.y = -10;
	iconDisplay.height = 70;
	Starling.juggler.removeDelayedCalls(animateIconDisplay);
	if( iconDisplay != null )
		Starling.juggler.removeTweens(iconDisplay);
} */

override public function dispose():void
{
	// stopPunching();
	super.dispose();
}
}
}