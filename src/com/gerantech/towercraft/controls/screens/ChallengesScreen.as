package com.gerantech.towercraft.controls.screens
{
import com.gerantech.mmory.core.constants.PrefsTypes;
import com.gerantech.towercraft.controls.items.challenges.ChallengeIndexItemRenderer;
import com.gerantech.towercraft.models.tutorials.TutorialData;
import com.gerantech.towercraft.models.tutorials.TutorialTask;
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

	if( player.getTutorStep() == PrefsTypes.T_72_NAME_SELECTED )
	{
		UserData.instance.prefs.setInt(PrefsTypes.TUTOR, PrefsTypes.T_201_CHALLENGES_SHOWN); 
		
		var tutorialData:TutorialData = new TutorialData("challenge_tutorial");
		tutorialData.addTask(new TutorialTask(TutorialTask.TYPE_MESSAGE, "tutor_challenge_1", null, 500, 1500, 0));
		tutorials.show(tutorialData);
	}
}

protected function list_triggeredHandler(event:Event) : void 
{
	var selectedIndex:int = event.data as int;
	if( player.getTutorStep() == PrefsTypes.T_201_CHALLENGES_SHOWN )
	{
		if( selectedIndex != 1 )
		{
			appModel.navigator.addLog(loc("!!!"))
			return;
		}
		UserData.instance.prefs.setInt(PrefsTypes.TUTOR, PrefsTypes.T_202_CHALLENGE_SELECTED); 
	}

	UserData.instance.challengeIndex = selectedIndex;
	UserData.instance.save();
	appModel.navigator.popScreen();
}
}
}