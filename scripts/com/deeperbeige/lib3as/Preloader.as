package com.deeperbeige.lib3as
{
   import flash.display.MovieClip;
   import flash.events.*;
   import flash.system.Capabilities;
   
   public class Preloader
   {
       
      
      private var requiredVersionMajor:int;
      
      private var loadedFrame:String;
      
      private var evtUpdate:Function;
      
      private var clip:MovieClip;
      
      public var fracLoaded:Number;
      
      public var strLoaded:String;
      
      private var versionFailFrame:String;
      
      public function Preloader(clip:MovieClip, loadedFrame:String, evtUpdate:Function)
      {
         super();
         this.clip = clip;
         this.loadedFrame = loadedFrame;
         this.evtUpdate = evtUpdate;
         this.versionFailFrame = null;
         this.strLoaded = "0%";
         MovieClip(clip.root).stop();
         clip.root.loaderInfo.addEventListener(ProgressEvent.PROGRESS,this.evtProgress);
         clip.root.loaderInfo.addEventListener(Event.COMPLETE,this.evtComplete);
      }
      
      public function requiredVersion(verMajor:int, failFrame:String) : *
      {
         this.requiredVersionMajor = verMajor;
         this.versionFailFrame = failFrame;
      }
      
      private function evtComplete(e:Event) : *
      {
         var bits:Array = null;
         if(this.versionFailFrame != null)
         {
            bits = Capabilities.version.split(" ");
            bits = bits[1].split(",");
            if(int(bits[0]) < this.requiredVersionMajor)
            {
               this.clip.gotoAndStop(this.versionFailFrame);
               return;
            }
         }
         this.clip.gotoAndStop(this.loadedFrame);
      }
      
      private function evtProgress(e:ProgressEvent) : *
      {
         this.fracLoaded = e.bytesLoaded / e.bytesTotal;
         this.strLoaded = Math.floor(this.fracLoaded * 100) + "%";
         this.evtUpdate();
      }
   }
}
