package com.deeperbeige.lib3as
{
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class Transition
   {
      
      private static var _inst:com.deeperbeige.lib3as.Transition;
       
      
      private var targetLabel:String;
      
      private var transitionClip:MovieClip;
      
      private var contentClip:MovieClip;
      
      private var callback:Function;
      
      private var transitioning:Boolean = false;
      
      private var curLabel:String;
      
      private var fastMode:Boolean;
      
      public function Transition(contentClip:MovieClip, transitionClip:MovieClip, fastMode:Boolean = false)
      {
         super();
         this.contentClip = contentClip;
         this.transitionClip = transitionClip;
         this.fastMode = fastMode;
         _inst = this;
         transitionClip.addEventListener(Event.ENTER_FRAME,this.evtEnterFrame);
      }
      
      public static function goto(label:String, callback:Function = null) : *
      {
         _inst.gotoLabel(label,callback);
      }
      
      public static function get inst() : com.deeperbeige.lib3as.Transition
      {
         return _inst;
      }
      
      private function evtEnterFrame(e:Event) : *
      {
         if(!this.transitioning)
         {
            return;
         }
         switch(this.transitionClip.currentFrameLabel)
         {
            case null:
               break;
            case "hidden":
               this.contentClip.gotoAndStop(this.targetLabel);
               if(this.fastMode)
               {
                  this.transitionClip.gotoAndStop("idle");
               }
               else
               {
                  this.transitionClip.gotoAndPlay("reveal");
               }
               break;
            case "idle":
               if(this.callback != null)
               {
                  this.callback();
               }
               this.callback = null;
               this.transitioning = false;
         }
      }
      
      public function isActive() : Boolean
      {
         return this.transitioning;
      }
      
      public function gotoLabel(label:String, callback:Function = null) : *
      {
         if(this.transitioning)
         {
            return;
         }
         if(label == this.curLabel)
         {
            return;
         }
         this.callback = callback;
         this.transitioning = true;
         this.targetLabel = label;
         if(this.fastMode)
         {
            this.transitionClip.gotoAndStop("hidden");
         }
         else
         {
            this.transitionClip.gotoAndPlay("hide");
         }
      }
   }
}
