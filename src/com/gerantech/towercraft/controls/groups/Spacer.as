package com.gerantech.towercraft.controls.groups
{
	import feathers.controls.LayoutGroup;
	import feathers.layout.HorizontalLayoutData;
	import feathers.layout.VerticalLayoutData;
	
	public class Spacer extends LayoutGroup
	{
		public function Spacer(isVertical:Boolean=true, height:Number=0)
		{
			super();
			if(height == 0)
				layoutData = isVertical ? new VerticalLayoutData(100,100) : new HorizontalLayoutData(100,100);
			else
				this.height = height;
		}
	}
}