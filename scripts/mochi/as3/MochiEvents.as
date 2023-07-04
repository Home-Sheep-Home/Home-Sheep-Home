package mochi.as3
{
   import flash.display.MovieClip;
   
   public class MochiEvents
   {
      
      public static const ALIGN_BOTTOM_LEFT:String = "ALIGN_BL";
      
      public static const FORMAT_LONG:String = "LongForm";
      
      public static const ALIGN_BOTTOM:String = "ALIGN_B";
      
      private static var _dispatcher:mochi.as3.MochiEventDispatcher = new mochi.as3.MochiEventDispatcher();
      
      private static var gameStart:Number;
      
      public static const ACHIEVEMENT_RECEIVED:String = "AchievementReceived";
      
      public static const FORMAT_SHORT:String = "ShortForm";
      
      public static const ALIGN_TOP_RIGHT:String = "ALIGN_TR";
      
      public static const ALIGN_BOTTOM_RIGHT:String = "ALIGN_BR";
      
      public static const ALIGN_TOP:String = "ALIGN_T";
      
      public static const ALIGN_LEFT:String = "ALIGN_L";
      
      public static const ALIGN_RIGHT:String = "ALIGN_R";
      
      public static const ALIGN_TOP_LEFT:String = "ALIGN_TL";
      
      public static const ALIGN_CENTER:String = "ALIGN_C";
      
      private static var levelStart:Number;
       
      
      public function MochiEvents()
      {
         super();
      }
      
      public static function addEventListener(eventType:String, delegate:Function) : void
      {
         _dispatcher.addEventListener(eventType,delegate);
      }
      
      public static function removeEventListener(eventType:String, delegate:Function) : void
      {
         _dispatcher.removeEventListener(eventType,delegate);
      }
      
      public static function startSession(achievementID:String) : void
      {
         MochiServices.send("events_beginSession",{"achievementID":achievementID},null,null);
      }
      
      public static function triggerEvent(eventType:String, args:Object) : void
      {
         _dispatcher.triggerEvent(eventType,args);
      }
      
      public static function setNotifications(clip:MovieClip, style:Object) : void
      {
         var s:Object = null;
         var args:Object = {};
         for(s in style)
         {
            args[s] = style[s];
         }
         args.clip = clip;
         MochiServices.send("events_setNotifications",args,null,null);
      }
      
      public static function endGame() : void
      {
         var delta:Number = new Date().time - gameStart;
         trigger("end_game",{"time":delta});
      }
      
      public static function startGame() : void
      {
         gameStart = new Date().time;
         trigger("start_game");
      }
      
      public static function trigger(kind:String, obj:Object = null) : void
      {
         if(obj == null)
         {
            obj = {};
         }
         else if(obj["kind"] != undefined)
         {
            trace("WARNING: optional arguements package contains key \'id\', it will be overwritten");
            obj["kind"] = kind;
         }
         MochiServices.send("events_triggerEvent",{"eventObject":obj},null,null);
      }
      
      public static function getVersion() : String
      {
         return MochiServices.getVersion();
      }
      
      public static function startLevel() : void
      {
         levelStart = new Date().time;
         trigger("start_level");
      }
      
      public static function endLevel() : void
      {
         var delta:Number = new Date().time - levelStart;
         trigger("end_level",{"time":delta});
      }
   }
}
