package com.aardman.app
{
   import flash.net.SharedObject;
   
   public class Levels
   {
      
      public static const ver:int = 10;
      
      public static const FRAME_BONUS = 1;
      
      public static var defs:Array = [];
      
      public static const levels:Array = [{
         "title":"",
         "locked":false,
         "complete":false,
         "par":1000,
         "best":0,
         "attempts":0
      },{
         "title":"",
         "locked":true,
         "complete":false,
         "par":1000,
         "best":0,
         "attempts":0
      },{
         "title":"",
         "locked":true,
         "complete":false,
         "par":1000,
         "best":0,
         "attempts":0
      },{
         "title":"",
         "locked":true,
         "complete":false,
         "par":1200,
         "best":0,
         "attempts":0
      },{
         "title":"",
         "locked":true,
         "complete":false,
         "par":1000,
         "best":0,
         "attempts":0
      },{
         "title":"",
         "locked":true,
         "complete":false,
         "par":2500,
         "best":0,
         "attempts":0
      },{
         "title":"",
         "locked":true,
         "complete":false,
         "par":1500,
         "best":0,
         "attempts":0
      },{
         "title":"",
         "locked":true,
         "complete":false,
         "par":1500,
         "best":0,
         "attempts":0
      },{
         "title":"",
         "locked":true,
         "complete":false,
         "par":2000,
         "best":0,
         "attempts":0
      },{
         "title":"",
         "locked":true,
         "complete":false,
         "par":1000,
         "best":0,
         "attempts":0
      },{
         "title":"",
         "locked":true,
         "complete":false,
         "par":2000,
         "best":0,
         "attempts":0
      },{
         "title":"",
         "locked":true,
         "complete":false,
         "par":2500,
         "best":0,
         "attempts":0
      },{
         "title":"",
         "locked":true,
         "complete":false,
         "par":3000,
         "best":0,
         "attempts":0
      },{
         "title":"",
         "locked":true,
         "complete":false,
         "par":2000,
         "best":0,
         "attempts":0
      },{
         "title":"",
         "locked":true,
         "complete":false,
         "par":4000,
         "best":0,
         "attempts":0
      }];
      
      public static const COMPLETE_BONUS = 1000;
       
      
      public function Levels()
      {
         super();
      }
      
      public static function processUnlocks() : *
      {
         var k:int = 0;
         for(var j:int = int(defs.length - 1); j >= 0; j--)
         {
            if(defs[j].complete)
            {
               for(k = 0; k < Math.min(j + 3,defs.length); k++)
               {
                  defs[k].locked = false;
               }
               saveToSO();
               return;
            }
         }
      }
      
      public static function score() : int
      {
         var levelDef:Object = null;
         var underPar:int = 0;
         var points:int = 0;
         for(var j:int = 0; j < defs.length; j++)
         {
            levelDef = defs[j];
            if(levelDef.complete)
            {
               points += COMPLETE_BONUS;
               underPar = levelDef.par - levelDef.best;
               points += Math.max(underPar * FRAME_BONUS,0);
            }
         }
         return points;
      }
      
      public static function allCompleted() : Boolean
      {
         var levelDef:Object = null;
         for(var j:int = 0; j < defs.length; j++)
         {
            levelDef = defs[j];
            if(!levelDef.complete)
            {
               return false;
            }
         }
         return true;
      }
      
      public static function loadFromSO() : *
      {
         var so:SharedObject = SharedObject.getLocal("sts_platformer");
         if(so.data.ver != ver)
         {
            initialiseSO();
         }
         defs = so.data.defs;
      }
      
      public static function initialiseSO() : *
      {
         trace("Wiped progress from SO");
         defs = levels.slice();
         var so:SharedObject = SharedObject.getLocal("sts_platformer");
         so.clear();
         so.data.ver = ver;
         so.data.defs = defs;
         so.flush();
      }
      
      public static function saveToSO() : *
      {
         var so:SharedObject = SharedObject.getLocal("sts_platformer");
         so.data.defs = defs;
         so.flush();
      }
   }
}
