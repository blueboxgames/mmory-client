package com.gerantech.towercraft.controls.segments
{

import com.gerantech.towercraft.controls.TowersLayout;

public class Segment extends TowersLayout
{
public var initializeStarted:Boolean;
public var initializeCompleted:Boolean;

public function Segment()
{
	super();
}

public function init():void
{
	initializeStarted = true;
	focus();
}

public function updateData():void
{
}

public function focus():void
{
}
}
}