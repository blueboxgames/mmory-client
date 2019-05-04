package com.gerantech.towercraft.controls.popups
{
import com.gerantech.towercraft.controls.BuildingCard;
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.buttons.ExchangeButton;
import com.gerantech.towercraft.controls.buttons.ExchangeDButton;
import com.gerantech.towercraft.controls.buttons.MMOryButton;
import com.gerantech.towercraft.controls.groups.ColorGroup;
import com.gerantech.towercraft.controls.groups.Devider;
import com.gerantech.towercraft.controls.items.CardFeatureItemRenderer;
import com.gerantech.towercraft.controls.overlays.TransitionData;
import com.gerantech.towercraft.controls.texts.LTRLable;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.vo.UserData;
import com.gerantech.towercraft.themes.MainTheme;
import com.gt.towers.battle.units.Card;
import com.gt.towers.constants.CardFeatureType;
import com.gt.towers.constants.CardTypes;
import com.gt.towers.constants.PrefsTypes;
import com.gt.towers.constants.ResourceType;
import com.gt.towers.scripts.ScriptEngine;
import feathers.controls.List;
import feathers.controls.ScrollPolicy;
import feathers.controls.renderers.IListItemRenderer;
import feathers.core.ITextRenderer;
import feathers.data.ListCollection;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.RelativePosition;
import feathers.layout.TiledRowsLayout;
import feathers.layout.VerticalLayout;
import flash.geom.Point;
import flash.geom.Rectangle;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.events.Event;

public class CardDetailsPopup extends SimpleHeaderPopup
{
private var cardDisplay:BuildingCard;
public var cardType:int;
public var showButton:Boolean = true;
public function CardDetailsPopup(){ super(); }
override protected function initialize():void
{
	title = loc("card_title_" + cardType);
	
	// create transition in data
	var _h:int = showButton ? 1280 : 940;
	var _p:int = 48;
	transitionIn = new TransitionData();
	transitionOut = new TransitionData();
	transitionOut.destinationAlpha = 0;
	transitionIn.sourceBound = transitionOut.destinationBound = new Rectangle(_p,	stageHeight* 0.5 - _h * 0.4,	stageWidth - _p * 2,	_h * 0.8);
	transitionOut.sourceBound = transitionIn.destinationBound = new Rectangle(_p,	stageHeight* 0.5 - _h * 0.5,	stageWidth - _p * 2,	_h * 1.0);
	
	super.initialize();

	var insideBG:Devider = new Devider(0xBBBBBB);
	insideBG.layoutData = new AnchorLayoutData(110, 0, NaN, 0);
	insideBG.height = 510;
	insideBG.alpha = 0.5;
	addChild(insideBG);
	
	cardDisplay = new BuildingCard(true, true, false, false);
	cardDisplay.width = 300;
	cardDisplay.layoutData = new AnchorLayoutData(150, appModel.isLTR?NaN:padding, NaN, appModel.isLTR?padding:NaN);
	addChild(cardDisplay);
	cardDisplay.setData(cardType);
}

override protected function transitionInCompleted():void
{
	super.transitionInCompleted();
	padding = 50;

	var rarity:int = ScriptEngine.getInt(CardFeatureType.F00_RARITY, cardType, 1);
	var rarityPalette:ColorGroup = new ColorGroup();
	rarityPalette.backgroundColor = CardTypes.getRarityColor(rarity);
	rarityPalette.label = loc("card_rarity_" + rarity);
	rarityPalette.width = (transitionIn.destinationBound.width - padding * 13) * 0.48;
	rarityPalette.layoutData = new AnchorLayoutData(160, appModel.isLTR?padding:380, NaN, appModel.isLTR?380:padding);
	addChild(rarityPalette);
	
	/*var categoryPalette:ColorGroup = new ColorGroup(loc("card_category_" + building.category));
	categoryPalette.width = (transitionIn.destinationBound.width - padding * 13) * 0.48;
	categoryPalette.layoutData = new AnchorLayoutData(padding * 3.7, appModel.isLTR?padding:NaN, NaN, appModel.isLTR?NaN:padding);
	addChild(categoryPalette);*/
	
	var messageDisplay:RTLLabel = new RTLLabel(loc("card_message_" + cardType), 0, "justify", null, true, null, 0.6);
	messageDisplay.layoutData = new AnchorLayoutData(290, appModel.isLTR?padding:380, NaN, appModel.isLTR?380:padding);
	addChild(messageDisplay);
	
	// features ....
	
	CardFeatureItemRenderer.IN_DETAILS = true;
	CardFeatureItemRenderer.CARD_TYPE = cardType;
	CardFeatureItemRenderer.UPGRADABLE = player.cards.exists(cardType) && player.cards.get(cardType).upgradable();
	var features:Vector.<int> = CardFeatureType.getRelatedTo(cardType)._list;
	if( ScriptEngine.get(CardFeatureType.F03_QUANTITY, cardType) > 1 )
		features.push(CardFeatureType.F03_QUANTITY);
	
	var featureLayout:TiledRowsLayout = new TiledRowsLayout();
	featureLayout.horizontalAlign = HorizontalAlign.LEFT;
	featureLayout.requestedColumnCount = 2;
	featureLayout.useSquareTiles = false;
	featureLayout.gap = 6;
	featureLayout.typicalItemWidth = (transitionOut.sourceBound.width - padding * 2 - featureLayout.gap - 1) / featureLayout.requestedColumnCount;
	
	var featureList:List = new List();
	featureList.layout = featureLayout;
	featureList.layoutData = new AnchorLayoutData(660, padding, NaN, padding);
	featureList.horizontalScrollPolicy = featureList.verticalScrollPolicy = ScrollPolicy.OFF;
	featureList.itemRendererFactory = function ():IListItemRenderer { return new CardFeatureItemRenderer(); }
	featureList.dataProvider = new ListCollection(features);
	addChild(featureList);

	var card:Card = player.cards.get(cardType);
	if( card == null )
		return;
		
	// remove new badge
	if( card.level == -1 )
		dispatchEventWith(Event.UPDATE, false, cardType);
	
	var inDeck:Boolean = player.getSelectedDeck().existsValue(cardType);

	var upgradeCost:int = Card.get_upgradeCost(card.level, card.rarity);
	var upgradeButton:MMOryButton = new MMOryButton();
	//upgradeButton.disableSelectDispatching = true;
	upgradeButton.alpha = 0;
	upgradeButton.width = 270;
	upgradeButton.height = 160;
	upgradeButton.paddingBottom = 26;
	upgradeButton.message = loc("upgrade_label");
	upgradeButton.messagePosition = RelativePosition.TOP;
	upgradeButton.iconSize = MMOryButton.DEFAULT_ICON_SIZE;
	upgradeButton.addEventListener(Event.SELECT, upgradeButton_selectHandler);
	upgradeButton.addEventListener(Event.TRIGGERED, upgradeButton_triggeredHandler);
	upgradeButton.iconTexture = MMOryButton.getIcon(ResourceType.R3_CURRENCY_SOFT, 1);
	upgradeButton.label = MMOryButton.getLabel(0, upgradeCost);
	upgradeButton.layoutData = new AnchorLayoutData(NaN, padding + 300, padding - 10);
	upgradeButton.isEnabled = player.resources.get(cardType) >= Card.get_upgradeCards(card.level, card.rarity);
	var hasCoin:Boolean = player.resources.get(ResourceType.R3_CURRENCY_SOFT) >= upgradeCost;
	upgradeButton.labelFactory = function () : ITextRenderer
	{
		if( hasCoin )
			return new ShadowLabel(null, 1, 0, "center", null, false, null, 1);
		return new RTLLabel(null, 0xCC0000, "center", null, false, null, 1);
	}
	upgradeButton.defaultIcon.alpha = hasCoin ? 1 : 0.8;
	addChild(upgradeButton);
	Starling.juggler.tween(upgradeButton, 0.3, {delay:0.1, alpha:1, onComplete:upgradeButton_tweenCompleted});
	function upgradeButton_tweenCompleted () : void
	{
		if( player.inDeckTutorial() )
		{
			UserData.instance.prefs.setInt(PrefsTypes.TUTOR, PrefsTypes.T_017_CARD_OPENED );
			upgradeButton.showTutorHint();
		}
	}

	if( !inDeck )
	{
		var usingButton:MMOryButton = new MMOryButton();
		usingButton.styleName = MainTheme.STYLE_BUTTON_HILIGHT;
		usingButton.label = loc("usage_label");
		usingButton.isEnabled = player.cards.exists(cardType) && !player.getSelectedDeck().exists(cardType);
		usingButton.width = 270;
		usingButton.height = 160;
		usingButton.paddingBottom = 26;
		//usingButton.isEnabled = !
		usingButton.addEventListener(Event.TRIGGERED, usingButton_triggeredHandler);
		usingButton.layoutData = new AnchorLayoutData(NaN, padding, padding - 10);
		addChild(usingButton);
	}
}

override protected function transitionOutStarted():void
{
	removeChildren(2);
	super.transitionOutStarted();
}
private function usingButton_triggeredHandler():void
{
	dispatchEventWith(Event.SELECT, false, cardType);
	close();
}
private function upgradeButton_selectHandler(event:Event):void
{
	appModel.navigator.addLog(loc("popup_upgrade_building_error", [loc("card_title_" + cardType)]));
	cardDisplay.punchSlider()
}
private function upgradeButton_triggeredHandler():void
{
	dispatchEventWith(Event.UPDATE, false, cardType);
	close();
}
}
}