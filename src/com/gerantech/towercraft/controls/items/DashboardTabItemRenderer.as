package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.controls.buttons.IndicatorButton;
import com.gerantech.towercraft.controls.overlays.HandPoint;
import com.gerantech.towercraft.controls.screens.DashboardScreen;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.vo.TabItemData;
import com.gerantech.towercraft.themes.MainTheme;
import com.gerantech.towercraft.utils.StrUtils;
import com.gt.towers.constants.PrefsTypes;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;
import starling.events.Event;

public class DashboardTabItemRenderer extends AbstractTouchableListItemRenderer
{
protected var itemWidth:Number;
protected var _firstCommit:Boolean = true;
protected var titleDisplay:ShadowLabel;
protected var iconDisplay:Image;
protected var badgeNumber:IndicatorButton;
protected var dashboardData:TabItemData;
private var handPoint:HandPoint;

public function DashboardTabItemRenderer(width:Number)
{
	super();
	layout = new AnchorLayout();
	itemWidth = width;
}

override protected function commitData():void
{
	if( _firstCommit )
	{
		width = itemWidth;
		height = _owner.height;
		_firstCommit = false;
		
		appModel.navigator.addEventListener("dashboardTabChanged", navigator_dashboardTabChanged);
	}
	super.commitData();
	dashboardData = _data as TabItemData;
	
	// show focus in tutorial 
	if( DashboardScreen.TAB_INDEX != index && player.inTutorial() )
	{
		if( index == 1 && player.inDeckTutorial() )
			showTutorHint();
		else if( index == 2 && player.getTutorStep() == PrefsTypes.T_018_CARD_UPGRADED )
			showTutorHint();
	}

	titleFactory();
	iconFactory();
	badgeFactory();
}

protected function iconFactory() : Image 
{
	if( iconDisplay != null )
	{
		iconDisplay.alpha = player.dashboadTabEnabled(index) ? 1 : 0.5;
		return null;
	}

	iconDisplay = new Image(Assets.getTexture("home/dash-tab-" + dashboardData.index, "gui"));
	iconDisplay.alignPivot();
	iconDisplay.x = width * 0.5;
	iconDisplay.y = height * 0.54;
	iconDisplay.pixelSnapping = false;
	iconDisplay.alpha = player.dashboadTabEnabled(index) ? 1 : 0.5;
	addChild(iconDisplay); 
	return iconDisplay;
}

protected function titleFactory() : ShadowLabel
{
	if( titleDisplay != null )
	{
		titleDisplay.text = loc("tab-" + dashboardData.index) ;
		return null;
	}

	titleDisplay = new ShadowLabel(loc("tab-" + dashboardData.index), 0xC6DDDB, 0, null, null, false, null, 0.8, null, "bold");
	titleDisplay.visible = false;
	titleDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, 60);
	addChild(titleDisplay);
	return titleDisplay;
}

protected function badgeFactory() : IndicatorButton
{
	if( dashboardData.badgeNumber <= 0 )
	{
		if( badgeNumber != null )
			badgeNumber.removeFromParent();
		return null;
	}

	if( badgeNumber == null )
	{
		badgeNumber = new IndicatorButton();
		badgeNumber.width = badgeNumber.height = 64;
		badgeNumber.layoutData = new AnchorLayoutData(18, 18);
	}
	badgeNumber.fixed = index == 0;
	badgeNumber.label = StrUtils.getNumber(dashboardData.newBadgeNumber > 0 ? dashboardData.newBadgeNumber : dashboardData.badgeNumber);
	badgeNumber.styleName = dashboardData.newBadgeNumber > 0 ? MainTheme.STYLE_BUTTON_SMALL_DANGER : MainTheme.STYLE_BUTTON_SMALL_NEUTRAL;
	addChild(badgeNumber);
	return null;
}

private function navigator_dashboardTabChanged(event:Event):void
{
	updateSelection(index == DashboardScreen.TAB_INDEX, event.data as Number ); 
}

override protected function setSelection(value:Boolean):void
{
	super.setSelection(value);
	if( value && _owner != null )
		_owner.dispatchEventWith(Event.SELECT, false, data);
	
	if( !player.dashboadTabEnabled(index) && value )
		return;
	
	if( dashboardData != null && value )
	{
		dashboardData.newBadgeNumber = dashboardData.badgeNumber = 0;
		badgeFactory();
	}
	
	if( handPoint != null )
		handPoint.removeFromParent(true);
}

protected function updateSelection(value:Boolean, time:Number = -1):void
{
	if( titleDisplay.visible == value )
		return;
	
	//width = itemWidth * (value ? 2 : 1);
	titleDisplay.visible = value;
	
	// icon animation
	if( iconDisplay != null )
	{
		Starling.juggler.removeTweens(iconDisplay);
		
		if( value )
		{
			titleDisplay.alpha = 0;
			Starling.juggler.tween(titleDisplay, time, {alpha:1});
			Starling.juggler.tween(iconDisplay, time ==-1?0.5:time, {delay:0.2, y:height * 0.4, transition:Transitions.EASE_OUT_BACK});
		}
		else
		{
			iconDisplay.y = height * 0.5;
		}
	}
}


private function showTutorHint () : void
{
	if( handPoint != null )
		handPoint.removeFromParent(true);
	if( isSelected )
		return;
	handPoint = new HandPoint(width * 0.5, 0);
//	handPoint.layoutData = new AnchorLayoutData(isUp ? NaN : 0, NaN, isUp ? -handPoint._height : NaN, NaN, 0);
	addChild(handPoint);
}
}
}