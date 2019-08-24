package com.gerantech.towercraft.views 
{
import com.gerantech.towercraft.models.AppModel;
import starling.display.MovieClip;
import starling.textures.Texture;
import com.gerantech.towercraft.views.units.elements.MovieElement;
import com.gerantech.mmory.core.battle.units.Unit;

/**
* ...
* @author Mansour Djawadi
*/
public class UnitMC extends MovieElement
{
public var startFrame:Number;
private var baseTextureName:String;
private var animTextureName:String;

public function UnitMC(unit:Unit, baseTextureName:String, animTextureName:String, startFrame:Number) 
{
	super(unit, AppModel.instance.assets.getTextures(baseTextureName + animTextureName), 12);
	this.baseTextureName = baseTextureName;
	this.animTextureName = animTextureName;
	this.startFrame = startFrame;
}

public function updateTexture(anim:String, dir:String):void 
{
	if( this.animTextureName == anim + dir )
	{
		if( anim == "s_" )
			this.currentFrame = 0;
		return;
	}
	
	this.animTextureName = anim + dir;
	var _numFrames:int = this.numFrames - 1;// trace(textureType + direction, numFrames);
	while( _numFrames > 0 )
	{
		this.removeFrameAt(_numFrames);
		_numFrames --;
	}
	/*if( _numFrames <= 0 )
	{
		this.currentFrame = 0;
		return;
	}*/
	var textures:Vector.<Texture> = AppModel.instance.assets.getTextures(baseTextureName + animTextureName);
	this.setFrameTexture(0, textures[0]);
	for ( var i:int = 1; i < textures.length; i++ )
		this.addFrame(textures[i]);
	this.currentFrame = 0;
}
}
}