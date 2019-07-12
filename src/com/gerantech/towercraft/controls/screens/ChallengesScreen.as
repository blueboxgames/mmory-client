package com.gerantech.towercraft.controls.screens
{
import com.gerantech.mmory.core.constants.PrefsTypes;
import com.gerantech.towercraft.controls.items.challenges.ChallengeIndexItemRenderer;
import com.gerantech.towercraft.models.vo.UserData;

import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.layout.VerticalAlign;

import starling.core.Starling;
import starling.events.Event;

public class ChallengesScreen extends ListScreen
{
public function ChallengesScreen()
{
	super();
	title = loc("challenges_page");
}

override protected function initialize():void
{
	super.initialize();
	
	ChallengeIndexItemRenderer.IN_HOME = false;
	ChallengeIndexItemRenderer.IS_FRIENDLY = false;
	ChallengeIndexItemRenderer.SHOW_INFO = true;
	
	listLayout.verticalAlign = VerticalAlign.MIDDLE;
	listLayout.typicalItemHeight = 410;
	listLayout.paddingTop = 200;
	listLayout.padding = 150;
	
	list.dataProvider = new ListCollection([0,1,2,3]);
	list.itemRendererFactory = function () : IListItemRenderer { return new ChallengeIndexItemRenderer(); };
	list.addEventListener(Event.TRIGGERED, list_triggeredHandler);
	
	closeButton.alpha = 0;
	Starling.juggler.tween(closeButton, 0.3, {delay:0.4, alpha:1});
}

protected function list_triggeredHandler(event:Event) : void 
{
	var selectedIndex:int = event.data as int;
	if( player.getTutorStep() == PrefsTypes.T_210_CHALLENGES_FOCUS || player.getTutorStep() == PrefsTypes.T_220_CHALLENGES_FOCUS || player.getTutorStep() == PrefsTypes.T_230_CHALLENGES_FOCUS )
	{
		var stepIndex:int = (player.getTutorStep() - 200) / 10;
		if( selectedIndex != stepIndex )
		{
			appModel.navigator.addLog(loc("!!!"))
			return;
		}
		UserData.instance.prefs.setInt(PrefsTypes.TUTOR, stepIndex * 10 + 201); 
	}

	UserData.instance.challengeIndex = selectedIndex;
	UserData.instance.save();
	appModel.navigator.popScreen();
}
}
}