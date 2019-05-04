package com.gerantech.towercraft.managers
{
import com.gerantech.towercraft.managers.net.LoadingManager;
import com.gerantech.towercraft.models.AppModel;
import com.gt.towers.constants.PrefsTypes;
import flash.events.Event;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import flash.utils.Dictionary;
import starling.core.Starling;

public class SoundManager 
{
public static const CATE_THEME:int = 0;
static public const CATE_SFX:int = 1;

static public const SINGLE_NONE:int = 0;
static public const SINGLE_FORCE_THIS:int = 1;
static public const SINGLE_BYPASS_THIS:int = 2;

private var loadings:Dictionary;			// contains all the sounds loading with the Sound Manager
private var loadeds:Dictionary;				// contains all the sounds registered with the Sound Manager
private var playings:Dictionary;			// contains all the sounds that are currently playing
private var _isMuted:Boolean = false;		// When true, every change in volume for ALL sounds is ignored

public function SoundManager() 
{
	loadings = new Dictionary();
	loadeds = new Dictionary();
	playings = new Dictionary();
}

// -------------------------------------------------------------------------------------------------------------------------			
/** Add sounds to the sound dictionary */
public function addSound(id:String, sound:Sound = null, callback:Function = null, category:int = 1) : void 
{
	if( loadeds[id] != null )
	{
		if( callback != null )
			callback();
		return;
	}
	
	if( loadings[id] )
		return;
	
	if( sound == null )
	{
		loadings[id] = true;
		AppModel.instance.assets.enqueue("assets/sounds/" + id + ".mp3");
		AppModel.instance.assets.loadQueue(assets_loadCallback);
		return;
	}
	loadeds[id] = {s:sound, c:category};
	function assets_loadCallback(ratio:Number):void
	{
		if( ratio < 1 )
			return;
		delete loadings[id];
		sound = AppModel.instance.assets.getSound(id);
		loadeds[id] = {s:sound, c:category};
		if( callback != null )
			callback();
	}
}

// -------------------------------------------------------------------------------------------------------------------------		
/** add into sounds and play after loaded */
public function addAndPlayRandom(sounds:Array, category:int = 1, singlePlaying:int = 0) : void 
{
	if( sounds == null || sounds.length == 0 )
		return;
	addAndPlay(sounds[Math.floor(Math.random() * sounds.length)], null, category, singlePlaying);
}
public function addAndPlay(id:String, sound:Sound = null, category:int = 1, singlePlaying:int = 0, repeats:int = 1) : void 
{
	addSound(id, sound, soundAdded, category);
	function soundAdded():void{play(id, 1, repeats, 0, singlePlaying); }
}

// -------------------------------------------------------------------------------------------------------------------------		
/** Remove sounds from the sound manager */
public function remove(id:String) : void
{
	if( loadeds[id] )
	{
		delete loadeds[id];	
		
		if( isPlaying(id) )
			delete playings[id];
	}
	else
	{
		throw Error("The sound you are trying to remove is not in the sound manager");
	}
}

// -------------------------------------------------------------------------------------------------------------------------		
/** Check if a sound is playing */
public function isPlaying(id:String) : Boolean
{
	for( var playingId:String in playings )
		if( playingId == id )
			return true;
	return false;
}

// -------------------------------------------------------------------------------------------------------------------------		
/** Play a sound */
public function play(id:String, volume:Number = 1.0, repeats:int = 1, panning:Number = 0, singlePlaying:int = 0) : void
{
	// decide single playing
	if( isPlaying(id) )
	{
		if( singlePlaying == SINGLE_FORCE_THIS )
			stop(id);
		
		if( singlePlaying == SINGLE_BYPASS_THIS )
			return;
	}
	
	if( loadeds[id] != null )
	{
		if( AppModel.instance.loadingManager.state < LoadingManager.STATE_LOADED )
			return;
		var category:int = loadeds[id].c;
		if( category == CATE_SFX && !AppModel.instance.game.player.prefs.getAsBool(PrefsTypes.SETTINGS_2_SFX) )
			return;
		if( category == CATE_THEME && !AppModel.instance.game.player.prefs.getAsBool(PrefsTypes.SETTINGS_1_MUSIC) )
			return;
		
		var soundObject:Sound = loadeds[id].s;
		if( soundObject == null )
			return;
		var channel:SoundChannel = soundObject.play(0, repeats);
		
		if( channel == null )
			return;
		
		channel.addEventListener(Event.SOUND_COMPLETE, channel_soundCompleteHandler);
		
		// if the sound manager is muted, set the sound's volume to zero
		channel.soundTransform = new SoundTransform(_isMuted ? 0 : volume, panning);
		
		playings[id] = { channel:channel, sound:soundObject, volume:volume };
	}
	else
	{
		trace("The sound you are trying to play (" + id + ") is not in the Sound Manager. Try adding it to the Sound Manager first.");
	}
}

// -------------------------------------------------------------------------------------------------------------------------		
/** Remove a sound from the dictionary of the sounds that are currently playing */
private function channel_soundCompleteHandler(event:Event) : void
{			
	for (var id:String in playings) 
	{
		if( playings[id].channel == event.target )
			delete playings[id];
	}
	event.currentTarget.removeEventListener(Event.SOUND_COMPLETE, channel_soundCompleteHandler);
}

// -------------------------------------------------------------------------------------------------------------------------		
/** Stop a sound */
public function stop(id:String) : void
{
	if( loadeds[id] == null )
		return;
	
	if( isPlaying(id) )
	{
		SoundChannel(playings[id].channel).stop();				
		delete playings[id];				
	}
}

// -------------------------------------------------------------------------------------------------------------------------
/** Stop all sounds that are currently playing */
public function stopAll(category:int =-1) : void
{
	for( var playingId:String in playings ) 
		if( category == -1 || category == playings[playingId].c == category )
			stop(playingId);
}

// -------------------------------------------------------------------------------------------------------------------------		
/** Set a sound's volume */
public function setVolume(id:String, volume:Number):void
{			
	if( isPlaying(id) )
	{
		var s:SoundTransform = new SoundTransform(volume);
		SoundChannel(playings[id].channel).soundTransform = s;
		playings[id].volume = volume;
	}
	else
	{
		trace("This sound (id = " + id + " ) is not currently playing");
		//throw Error("This sound (id = " + id + " ) is not currently playing");
	}
}

// -------------------------------------------------------------------------------------------------------------------------
/** Tween a sound's volume */
public function tweenVolume(id:String, volume:Number = 0, tweenDuration:Number = 2):void 
{
	if( isPlaying(id) )
	{
		var s:SoundTransform = new SoundTransform();
		var soundObject:Object = playings[id];
		var c:SoundChannel = playings[id].channel;
		
		Starling.juggler.tween(soundObject, tweenDuration, {
			volume: volume,
			onUpdate: function():void {
				if (!_isMuted)
				{
					s.volume = soundObject.volume;
					c.soundTransform = s;
				}
			}
		});
	}
	else
	{
		throw Error("This sound (id = " + id + " ) is not currently playing");
	}
}

// -------------------------------------------------------------------------------------------------------------------------		
/** Cross fade two sounds. N.B. The sounds that fades out must be already playing */
public function crossFade(fadeOutId:String, fadeInId:String, tweenDuration:Number = 2, fadeInVolume:Number = 1, fadeInRepetitions:int = 1) : void
{			
	// If the fade-in sound is not already playing, start playing it
	if( !isPlaying(fadeInId) )
		play(fadeInId, 0, fadeInRepetitions);
	
	tweenVolume (fadeOutId, 0, tweenDuration);
	tweenVolume (fadeInId, fadeInVolume, tweenDuration);
	
	// If the fade-out sound is playing, stop it when its volume reaches zero
	if( isPlaying(fadeOutId) )
		Starling.juggler.delayCall(stop, tweenDuration, fadeOutId);
}

// -------------------------------------------------------------------------------------------------------------------------		
/** Sets a new volume for all the sounds currently playing 
 *  @param volume the new volume value 
 */
public function setGlobalVolume(volume:Number):void {
	var s:SoundTransform;
	for (var currID:String in playings) {
		s = new SoundTransform(volume);
		SoundChannel(playings[currID].channel).soundTransform = s;
		playings[currID].volume = volume;
	}
}

// -------------------------------------------------------------------------------------------------------------------------		
/** Mute all sounds currently playing.
 *  @param mute a Boolean dictating whether all the sounds in the sound manager should be silenced (true) or restored to their original volume (false). 
 */ 
public function muteAll(mute:Boolean = true):void
{
	if( mute != _isMuted )
	{
		var s:SoundTransform;
		for (var currID:String in playings) 
		{
			s = new SoundTransform(mute ? 0 : playings[currID].volume);
			SoundChannel(playings[currID].channel).soundTransform = s;
		}
		_isMuted = mute;
	}
}

// -------------------------------------------------------------------------------------------------------------------------		
public function getSoundChannel(id:String):SoundChannel
{
	if( isPlaying(id) )
		return SoundChannel(playings[id].channel);
	
	throw Error("You are trying to get a non-existent soundChannel. Play the sound first in order to assign a channel.");
}

// -------------------------------------------------------------------------------------------------------------------------		
public function getSoundTransform(id:String):SoundTransform
{
	if( isPlaying(id) )
		return SoundChannel(playings[id].channel).soundTransform;
	
	throw Error("You are trying to get a non-existent soundTransform. Play the sound first in order to assign a transform.");
}

// -------------------------------------------------------------------------------------------------------------------------		
public function getSoundVolume(id:String):Number
{			
	if( isPlaying(id) )
		return playings[id].volume;
	
	throw Error("You are trying to get a non-existent volume. Play the sound first in order to assign a volume.");
}		

// --------------------------------------------------------------------------------------------------------------------------------------
// SETTERS & GETTERS
public function get isMuted():Boolean { return _isMuted; }	

// -------------------------------------------------------------------------------------------------------------------------		
public function dispose():void
{
	loadings = null;
	loadeds = null;
	playings = null;
}
}
}