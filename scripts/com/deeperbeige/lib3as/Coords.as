package com.deeperbeige.lib3as
{
   import flash.display.DisplayObject;
   import flash.geom.Point;
   
   public class Coords
   {
       
      
      public function Coords()
      {
         super();
      }
      
      public static function getGlobal(holder:DisplayObject) : Point
      {
         return holder.localToGlobal(new Point(0,0));
      }
      
      public static function getLocal(holder:DisplayObject, scope:DisplayObject) : Point
      {
         return scope.globalToLocal(holder.localToGlobal(new Point(0,0)));
      }
   }
}
