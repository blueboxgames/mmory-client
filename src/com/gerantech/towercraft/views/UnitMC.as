package com.gerantech.towercraft.views 
{
import com.gerantech.towercraft.models.AppModel;
import starling.display.MovieClip;
import starling.textures.Texture;

/**
* ...
* @author Mansour Djawadi
*/
public class UnitMC extends MovieClip 
{
private var baseTextureName:String;
private var animTextureName:String;

public function UnitMC(baseTextureName:String, animTextureName:String) 
{
	this.baseTextureName = baseTextureName;
	this.animTextureName = animTextureName;
	super(AppModel.instance.assets.getTextures(baseTextureName + animTextureName), 15);
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