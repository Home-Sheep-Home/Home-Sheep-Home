package com.deeperbeige.lib3as
{
   import flash.display.*;
   import flash.events.*;
   import flash.media.*;
   
   public class Sounds
   {
      
      private static var _inst:com.deeperbeige.lib3as.Sounds;
       
      
      private var _muted:Boolean;
      
      private var _aSounds:Array;
      
      private var _currentMusic:String;
      
      private var _aGroups:Array;
      
      private var _musicMuted:Boolean;
      
      private var _clip:MovieClip;
      
      private var _isFinalMusic:Boolean;
      
      private var _musicStarted:Boolean;
      
      public function Sounds()
      {
         super();
         this._aSounds = [];
         this._aGroups = [];
         this._muted = false;
         this._musicMuted = false;
         this._currentMusic = null;
         this._musicStarted = false;
         this._isFinalMusic = false;
         _inst = this;
      }
      
      public static function setNextMusic(id:String, isFinal:Boolean = false) : *
      {
         if(!_inst._aSounds[id].isMusic)
         {
            trace("Sounds: Trying to set next music to ID \"" + id + "\" but sample is not registered as music");
            return;
         }
         _inst._currentMusic = id;
         _inst._isFinalMusic = isFinal;
         if(!_inst._musicStarted)
         {
            _inst.playSound(id);
         }
      }
      
      public static function volume(id:String, newVolume:Number) : *
      {
         _inst.setVolume(id,newVolume);
      }
      
      public static function stopMusic() : *
      {
         _inst.stopAllMusic();
      }
      
      public static function play(id:String, loop:Boolean = false, soundPosition:Number = 0, onCompleteSingleCallback:Function = undefined, volume:Number = -1) : *
      {
         _inst.playSound(id,loop,soundPosition,onCompleteSingleCallback,volume);
      }
      
      public static function get inst() : com.deeperbeige.lib3as.Sounds
      {
         return _inst;
      }
      
      public static function stop(id:String) : *
      {
         _inst.stopSound(id);
      }
      
      public function playSound(id:String, loop:Boolean = false, soundPosition:Number = 0, onCompleteSingleCallback:Function = undefined, volume:* = -1) : *
      {
         if(this._muted)
         {
            if(onCompleteSingleCallback != null)
            {
               onCompleteSingleCallback();
            }
            return;
         }
         if(this._aGroups[id] != undefined)
         {
            id = String(this._aGroups[id][Math.floor(Math.random() * this._aGroups[id].length)]);
         }
         if(this._aSounds[id] == undefined)
         {
            trace("Sounds: Trying to play unregistered sound \'" + id + "\'");
            onCompleteSingleCallback();
            return;
         }
         if(this._aSounds[id].isMusic)
         {
            this._currentMusic = id;
            if(this._musicMuted)
            {
               return;
            }
            this._musicStarted = true;
            loop = true;
         }
         this._aSounds[id].looping = loop;
         this._aSounds[id].onCompleteSingleCallback = onCompleteSingleCallback;
         var vol:Number = Number(this._aSounds[id].defaultVolume);
         if(volume >= 0)
         {
            vol = volume;
         }
         this._aSounds[id].soundChannel = this._aSounds[id].sound.play(soundPosition);
         this._aSounds[id].soundChannel.addEventListener(Event.SOUND_COMPLETE,this.evtSoundComplete);
         this._aSounds[id].soundChannel.soundTransform = new SoundTransform(vol);
         this._aSounds[id].playing = true;
      }
      
      private function evtSoundComplete(e:Event) : *
      {
         var id:String = null;
         for(id in this._aSounds)
         {
            if(this._aSounds[id].soundChannel == e.target)
            {
               if(this._aSounds[id].looping)
               {
                  if(this._aSounds[id].isMusic)
                  {
                     if(this._currentMusic != null)
                     {
                        this.playSound(this._currentMusic,true);
                        this._musicStarted = true;
                        if(this._isFinalMusic)
                        {
                           this._currentMusic = null;
                        }
                     }
                     else
                     {
                        this._musicStarted = false;
                     }
                  }
                  else
                  {
                     this.playSound(id,true);
                  }
               }
               else
               {
                  this._aSounds[id].playing = false;
                  if(this._aSounds[id].onCompleteCallback)
                  {
                     this._aSounds[id].onCompleteCallback();
                  }
                  if(this._aSounds[id].onCompleteSingleCallback)
                  {
                     this._aSounds[id].onCompleteSingleCallback();
                  }
                  this._aSounds[id].onCompleteSingleCallback = null;
               }
            }
         }
      }
      
      public function registerMusic(linkage:String, defaultVolume:Number = 1) : *
      {
         this.register(linkage,undefined,defaultVolume);
         this._aSounds[linkage].isMusic = true;
      }
      
      public function toggleMute() : Boolean
      {
         switch(this._muted)
         {
            case true:
               this.unMute();
               break;
            case false:
               this.mute();
         }
         return this._muted;
      }
      
      public function isMusicMuted() : Boolean
      {
         return this._musicMuted;
      }
      
      public function unMute() : *
      {
         this._muted = false;
      }
      
      public function muteMusic() : *
      {
         this._musicMuted = true;
         this.stopAllMusic();
      }
      
      private function idExists(id:String) : Boolean
      {
         if(this._aSounds[id] != undefined)
         {
            return true;
         }
         if(this._aGroups[id] != undefined)
         {
            return true;
         }
         return false;
      }
      
      public function mute() : *
      {
         this._muted = true;
         this.stopAll();
      }
      
      public function setVolume(id:String, newVolume:Number) : *
      {
         if(this._aSounds[id].soundChannel == null)
         {
            return;
         }
         this._aSounds[id].soundChannel.soundTransform = new SoundTransform(newVolume);
      }
      
      public function isMuted() : Boolean
      {
         return this._muted;
      }
      
      public function register(linkage:String, onCompleteCallback:Function = undefined, defaultVolume:Number = 1) : Sound
      {
         if(this.idExists(linkage))
         {
            trace("Sounds: Registering sound \'" + linkage + "\', but ID is already in use");
         }
         var container:Object = {};
         container.looping = false;
         container.playing = false;
         container.onCompleteCallBack = onCompleteCallback;
         container.sound = Utils.createSound(linkage);
         container.isMusic = false;
         container.soundChannel = null;
         container.defaultVolume = defaultVolume;
         this._aSounds[linkage] = container;
         return Sound(container.sound);
      }
      
      public function isPlaying(id:String) : Boolean
      {
         var j:int = 0;
         if(this._aGroups[id] != undefined)
         {
            for(j = 0; j < this._aGroups[id].length; j++)
            {
               if(this.isPlaying(this._aGroups[id][j]))
               {
                  return true;
               }
            }
            return false;
         }
         return this._aSounds[id].playing;
      }
      
      public function stopAllMusic() : *
      {
         var id:String = null;
         for(id in this._aSounds)
         {
            if(this._aSounds[id].isMusic)
            {
               this.stopSound(id);
            }
         }
      }
      
      public function toggleMusicMute() : Boolean
      {
         switch(this._musicMuted)
         {
            case true:
               this.unMuteMusic();
               break;
            case false:
               this.muteMusic();
         }
         return this._musicMuted;
      }
      
      public function registerGroup(groupID:String, aGroupIDs:Array) : *
      {
         if(this.idExists(groupID))
         {
            trace("Sounds: Registering group \'" + groupID + "\', but ID is already in use");
         }
         for(var j:int = 0; j < aGroupIDs.length; j++)
         {
            if(this._aSounds[aGroupIDs[j]] == undefined)
            {
               trace("Sounds: Group \'" + groupID + "\' contains non-registered sound ID \'" + aGroupIDs[j] + "\'");
            }
         }
         this._aGroups[groupID] = aGroupIDs;
      }
      
      public function stopSound(id:String) : *
      {
         var j:int = 0;
         if(this._aGroups[id] != undefined)
         {
            for(j = 0; j < this._aGroups[id].length; this.stopSound(this._aGroups[id][j]),j++)
            {
            }
            return;
         }
         if(this._aSounds[id] == undefined)
         {
            trace("Sounds: Trying to stop unregistered sound \'" + id + "\'");
         }
         this._aSounds[id].looping = false;
         if(this._aSounds[id].isMusic)
         {
            this._currentMusic = null;
            this._musicStarted = false;
         }
         if(this._aSounds[id].playing)
         {
            this._aSounds[id].soundChannel.stop();
         }
         this._aSounds[id].playing = false;
      }
      
      public function unMuteMusic() : *
      {
         this._musicMuted = false;
         if(this._currentMusic != null)
         {
            this.playSound(this._currentMusic);
         }
      }
      
      public function stopAll() : *
      {
         var id:String = null;
         for(id in this._aSounds)
         {
            this.stopSound(id);
         }
      }
   }
}
