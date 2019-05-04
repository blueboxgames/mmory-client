package com.gerantech.towercraft.controls.items.offers 
{
import com.gerantech.towercraft.controls.TowersLayout;
import com.gerantech.towercraft.controls.groups.OfferView;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.models.Assets;
import com.gt.towers.socials.Lobby;
import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

/**
* ...
* @author Mansour Djawadi
*/
public class BuddyOfferItem extends TowersLayout 
{
private var titleDisplay:com.gerantech.towercraft.controls.texts.RTLLabel;

public var type:String;
public function BuddyOfferItem(data:Object) 
{
	super();
	type = OfferView.INVITE_BUDDY;
	var padding:int = 20;
	layout = new AnchorLayout();
	
	var iconDisplay:ImageLoader = new ImageLoader();
	iconDisplay.width = 360;
	iconDisplay.alignPivot();
	iconDisplay.source = Assets.getTexture("currency-1");
	iconDisplay.layoutData = new AnchorLayoutData(NaN, NaN, -padding * 2, -padding * 2);
	addChild(iconDisplay);
	
	var titleDisplay:RTLLabel = new RTLLabel(loc("offer_invite_buddy_title", [Lobby.buddyInviteeReward, Lobby.buddyInviterReward]));
	titleDisplay.layoutData = new AnchorLayoutData(padding, padding, NaN, padding);
	addChild(titleDisplay);
	
	var messageDisplay:RTLLabel = new RTLLabel(loc("offer_invite_buddy_message"), 1, null, null, false, null, 0.8);
	messageDisplay.layoutData = new AnchorLayoutData(NaN, padding, padding, padding);
	addChild(messageDisplay);
}
}
}