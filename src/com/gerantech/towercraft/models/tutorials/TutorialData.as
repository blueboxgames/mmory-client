package com.gerantech.towercraft.models.tutorials
{
	public class TutorialData
	{
		public var name:String;
		public var data:Object;
		private var tasks:Vector.<TutorialTask>;
		
		public function TutorialData(name:String)
		{
			this.name = name;
			tasks = new Vector.<TutorialTask>;
		}
		
		public function get numTasks():int
		{
			return tasks.length;
		}
		public function addTask(task:TutorialTask):void
		{
			task.index = tasks.length;
			task.parent = this;
			tasks.push(task);
		}
		public function shiftTask():TutorialTask
		{
			return tasks.shift();
		}
	}
}