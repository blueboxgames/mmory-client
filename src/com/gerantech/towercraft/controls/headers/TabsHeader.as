package com.gerantech.towercraft.controls.headers 
{
import com.gerantech.towercraft.controls.items.TabsHeaderItemRenderer;
import feathers.controls.List;
import feathers.controls.ScrollBarDisplayMode;
import feathers.controls.ScrollPolicy;
import feathers.controls.renderers.IListItemRenderer;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;

/**
* ...
* @author Mansour Djawadi
*/
public class TabsHeader extends List 
{

public function TabsHeader() 
{
	super();
	
	var hlayout:HorizontalLayout = new HorizontalLayout();
	hlayout.hasVariableItemDimensions = true;
	hlayout.verticalAlign = VerticalAlign.JUSTIFY;
	hlayout.gap = 6;
	
	layout = hlayout;
	scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
	horizontalScrollPolicy = verticalScrollPolicy = ScrollPolicy.OFF;
	itemRendererFactory = function ():IListItemRenderer { return new TabsHeaderItemRenderer(); }
}
}
}