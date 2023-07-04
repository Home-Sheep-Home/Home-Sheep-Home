package com.deeperbeige.lib3as
{
   import flash.display.InteractiveObject;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   
   public class Btn
   {
       
      
      public function Btn()
      {
         super();
      }
      
      public static function init(button:InteractiveObject, onRelease:Function = null, onRollOver:Function = null, onRollOut:Function = null) : *
      {
         if(button is MovieClip)
         {
            initClip(MovieClip(button),onRelease,onRollOver,onRollOut);
         }
         if(button is SimpleButton)
         {
            initBtn(SimpleButton(button),onRelease,onRollOver,onRollOut);
         }
      }
      
      private static function wipeBtn(button:SimpleButton, onRelease:Function = null, onRollOver:Function = null, onRollOut:Function = null) : *
      {
         if(onRelease != null)
         {
            button.removeEventListener(MouseEvent.CLICK,onRelease);
         }
         if(onRollOver != null)
         {
            button.removeEventListener(MouseEvent.ROLL_OVER,onRollOver);
         }
         if(onRollOut != null)
         {
            button.removeEventListener(MouseEvent.ROLL_OUT,onRollOut);
         }
      }
      
      public static function wipe(button:InteractiveObject, onRelease:Function = null, onRollOver:Function = null, onRollOut:Function = null) : *
      {
         if(button is MovieClip)
         {
            wipeClip(MovieClip(button),onRelease,onRollOver,onRollOut);
         }
         if(button is SimpleButton)
         {
            wipeBtn(SimpleButton(button),onRelease,onRollOver,onRollOut);
         }
      }
      
      private static function initBtn(button:SimpleButton, onRelease:Function = null, onRollOver:Function = null, onRollOut:Function = null) : *
      {
         if(onRelease != null)
         {
            button.addEventListener(MouseEvent.CLICK,onRelease,false,0,true);
         }
         if(onRollOver != null)
         {
            button.addEventListener(MouseEvent.ROLL_OVER,onRollOver,false,0,true);
         }
         if(onRollOut != null)
         {
            button.addEventListener(MouseEvent.ROLL_OUT,onRollOut,false,0,true);
         }
      }
      
      public static function wipeClip(button:MovieClip, onRelease:Function = null, onRollOver:Function = null, onRollOut:Function = null) : *
      {
         if(onRelease != null)
         {
            button.removeEventListener(MouseEvent.CLICK,onRelease);
         }
         if(onRollOver != null)
         {
            button.removeEventListener(MouseEvent.ROLL_OVER,onRollOver);
         }
         if(onRollOut != null)
         {
            button.removeEventListener(MouseEvent.ROLL_OUT,onRollOut);
         }
         button.buttonMode = false;
      }
      
      public static function initClip(button:MovieClip, onRelease:Function = null, onRollOver:Function = null, onRollOut:Function = null) : *
      {
         if(onRelease != null)
         {
            button.addEventListener(MouseEvent.CLICK,onRelease,false,0,true);
         }
         if(onRollOver != null)
         {
            button.addEventListener(MouseEvent.ROLL_OVER,onRollOver,false,0,true);
         }
         if(onRollOut != null)
         {
            button.addEventListener(MouseEvent.ROLL_OUT,onRollOut,false,0,true);
         }
         button.mouseChildren = false;
         button.buttonMode = true;
      }
   }
}
