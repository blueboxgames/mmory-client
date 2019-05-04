package com.gerantech.towercraft.managers
{
import com.gerantech.towercraft.controls.overlays.BaseOverlay;
import com.gerantech.towercraft.controls.overlays.TutorialMessageOverlay;
import com.gerantech.towercraft.controls.overlays.TutorialOverlay;
import com.gerantech.towercraft.controls.overlays.TutorialSwipeOverlay;
import com.gerantech.towercraft.controls.overlays.TutorialTouchOverlay;
import com.gerantech.towercraft.events.GameEvent;
import com.gerantech.towercraft.models.tutorials.TutorialData;
import com.gerantech.towercraft.models.tutorials.TutorialTask;
import flash.geom.Point;
import starling.events.Event;


public class TutorialManager extends BaseManager
{
private static var _instance:TutorialManager;
private var tutorialData:TutorialData;
private var catchedPlaces:Vector.<Point>;

public function TutorialManager(){}
public function show(data:TutorialData):void
{
	tutorialData = data;
	dispatchEventWith(GameEvent.TUTORIAL_TASKS_STARTED, false, data);
	processTasks();
}

private function processTasks():void
{
	var task:TutorialTask = tutorialData.shiftTask();
	if( task == null || player.tutorialMode == -1 )
	{
		dispatchEventWith(GameEvent.TUTORIAL_TASKS_FINISH, false, tutorialData);
		return;
	}
	dispatchEventWith(GameEvent.TUTORIAL_TASK_SHOWN, false, task);

	switch(task.type)
	{
		case TutorialTask.TYPE_MESSAGE:
			var messageoverlay:TutorialMessageOverlay = new TutorialMessageOverlay(task);
			messageoverlay.addEventListener(Event.CLOSE, overlay_closeHandler);
			appModel.navigator.addOverlay(messageoverlay);					
			break;
		
		case TutorialTask.TYPE_SWIPE:
/*			catchedPlaces = new Vector.<Point>();
			for each(var pd:Point in task.points)
				catchedPlaces.push(pd);
*/			var swipeoverlay:TutorialSwipeOverlay = new TutorialSwipeOverlay(task);
			swipeoverlay.addEventListener(Event.CLOSE, overlay_closeHandler);
			appModel.navigator.addOverlay(swipeoverlay);
			break;
		
		case TutorialTask.TYPE_TOUCH:
			var touchoverlay:TutorialTouchOverlay = new TutorialTouchOverlay(task);
			touchoverlay.addEventListener(Event.CLOSE, overlay_closeHandler);
			appModel.navigator.addOverlay(touchoverlay);					
			break;
	}
}		

private function overlay_closeHandler(event:Event):void
{
	processTasks();
}

/*public function showMidSwipe(target:PlaceView):void
{
	var tutorialData:TutorialData = new TutorialData("occupy_" + appModel.battleFieldView.battleData.battleField.field.index + "_" + target.place.index);
	if( appModel.battleFieldView.battleData.battleField.field.index == 2 && target.place.index == 1 )
	{
		tutorialData.addTask(new TutorialTask(TutorialTask.TYPE_MESSAGE, "tutor_battle_2_mid_2", null, 500, 1500, 2));
		tutorialData.addTask(new TutorialTask(TutorialTask.TYPE_MESSAGE, "tutor_battle_2_mid_4", null, 500, 1500, 4));
	}
	var places:PlaceDataList = new PlaceDataList();
	if( appModel.battleFieldView.battleData.battleField.field.index <= 2 )
	{
		for (var i:int = 0; i < target.place.index + 2; i++)
			places.push(target.getData(i));
	}
	
	if( places.size() > 0 )
		tutorialData.addTask(new TutorialTask(TutorialTask.TYPE_SWIPE, null, places, 0, 800 * places.size()));
	show(tutorialData);
}

public function forceAggregateSwipe( sourcePlaces:Vector.<PlaceView>, target:PlaceView ) : Boolean 
{
	var ret:Boolean = needToForceAggregation(sourcePlaces, target);
	if( ret )
	{
		removeAll();
		var tutorialData:TutorialData = new TutorialData("occupy_" + appModel.battleFieldView.battleData.battleField.field.index + "_" + catchedPlaces.get(catchedPlaces.size() - 2).index);
		tutorialData.addTask(new TutorialTask(TutorialTask.TYPE_SWIPE, null, catchedPlaces, 0, 800 * catchedPlaces.size()));
		show(tutorialData);
	}
	return ret;
}
private function needToForceAggregation(sourcePlaces:Vector.<PlaceView>, target:PlaceView) : Boolean 
{
	if( !player.inTutorial() || player.tutorialMode == 0 )
		return false;
	if( catchedPlaces == null || catchedPlaces.size() < 2 )
		return false;
	
	var numPlaces:int = catchedPlaces.size() - 1;
	if( target.place.index != catchedPlaces.get(numPlaces).index || sourcePlaces.length != numPlaces )
		return true;
	removeAll();
	numPlaces --;
	while ( numPlaces >= 0 )
	{
		//trace("pv:" + sourcePlaces[numPlaces].place.index, "pd:" + catchedPlaces.get(numPlaces).index);
		if( sourcePlaces[numPlaces].place.index != catchedPlaces.get(numPlaces).index )
			return true;
		numPlaces --;
	}
	return false;
}

public function forceImprove() : Boolean 
{
	if( player.get_battleswins() != 2 )
		return false;
	
	var improvable:PlaceData = appModel.battleFieldView.battleData.battleField.field.getImprovableTutorPlace();
	if( improvable == null || appModel.battleFieldView.battleData.battleField.places.get(improvable.index).building.type != CardTypes.B01_CAMP )
		return false;
		
	appModel.battleFieldView.places[improvable.index].decorator.improvablePanel.enabled = false;
	setTimeout(function():void{ appModel.battleFieldView.places[improvable.index].decorator.improvablePanel.enabled = true}, 500);
	return true;
}*/

public function removeAll():void
{
	if( tutorialData != null )
		while( tutorialData.numTasks > 0 )
			tutorialData.shiftTask();
	
	for(var i:uint=0; i<appModel.navigator.overlays.length; i++)
	{
		var overlay:BaseOverlay = appModel.navigator.overlays[i];
		if( overlay is TutorialOverlay )
		{
			overlay.removeEventListeners(Event.CLOSE);
			overlay.close();
			appModel.navigator.overlays.removeAt(i);
		}
	}
}

public static function get instance():TutorialManager
{
	if( _instance == null )
		_instance = new TutorialManager();
	return _instance;
}
}
}