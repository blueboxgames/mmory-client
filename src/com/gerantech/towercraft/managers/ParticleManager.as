package com.gerantech.towercraft.managers 
{
import flash.utils.ByteArray;
import flash.utils.Dictionary;
import starling.extensions.PDParticleSystem;
import starling.textures.Texture;

/**
* ...
* @author Mansour Djawadi
*/
public class ParticleManager
{
	
[Embed(source="../../../../assets/particles/fire/particle.pex", mimeType="application/octet-stream")]
private static const fireConfig:Class;
[Embed(source="../../../../assets/particles/fire/texture.atf", mimeType="application/octet-stream")]
private static const fireParticle:Class;

[Embed(source="../../../../assets/particles/scrap/particle.pex", mimeType="application/octet-stream")]
private static const scrapConfig:Class;
[Embed(source="../../../../assets/particles/scrap/texture.atf", mimeType="application/octet-stream")]
private static const scrapParticle:Class;

[Embed(source="../../../../assets/particles/explode/particle.pex", mimeType="application/octet-stream")]
private static const explodeConfig:Class;
[Embed(source="../../../../assets/particles/explode/texture.atf", mimeType="application/octet-stream")]
private static const explodeParticle:Class;

[Embed(source="../../../../assets/particles/kira/particle_texture.json", mimeType="application/octet-stream")]
private static const kiraConfig:Class;
[Embed(source="../../../../assets/particles/kira/particle_texture.atf", mimeType="application/octet-stream")]
private static const kiraParticle:Class;

private static var _TEXTURES:Dictionary = new Dictionary();
private static var _CONFIGS:Dictionary = new Dictionary();
public function ParticleManager() {}

/**
 * Returns a texture from this class based on a string key.
 * @param name A key that matches a static constant of Bitmap type.
 * @return a starling texture.
 */
public static function getTextureByBitmap(name:String) : Texture
{
	if( _TEXTURES[name] == undefined )
		_TEXTURES[name] = Texture.fromEmbeddedAsset(ParticleManager[name + "Particle"]);
		//allTextures[name] = Texture.fromAtfData(new ParticleManager[name + "Particle"], 1, false);
	return _TEXTURES[name];
}

/**
 * Returns a xml from this class based on a string key.
 * @param name A key that matches a static constant of XML type.
 * @return a particle config.
 */
public static function getParticleData(name:String) : Object
{
	if( _CONFIGS[name] == undefined )
	{
		var text:ByteArray = new ParticleManager[name + "Config"]();
		if( text.readUTFBytes(1) == "<" )
			_CONFIGS[name] = XML(text);
		else
			_CONFIGS[name] = JSON.parse(text.toString());
	}
	return _CONFIGS[name];
}

public static function getParticle(name:String) : PDParticleSystem
{
	return new PDParticleSystem(getParticleData(name), getTextureByBitmap(name));
}
}
}