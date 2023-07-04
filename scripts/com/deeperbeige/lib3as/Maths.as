package com.deeperbeige.lib3as
{
   import flash.geom.Point;
   
   public class Maths
   {
       
      
      public function Maths()
      {
         super();
      }
      
      public static function randomSign() : Number
      {
         return Math.random() > 0.5 ? 1 : -1;
      }
      
      public static function randomNum(min:Number, max:Number) : Number
      {
         return Math.random() * (max - min) + min;
      }
      
      public static function dotProduct(ax:Number, ay:Number, bx:Number, by:Number) : Number
      {
         return ax * bx + ay * by;
      }
      
      public static function vectorLength(dx:Number, dy:Number) : Number
      {
         return Math.sqrt(dx * dx + dy * dy);
      }
      
      public static function unitNormal(x:Number, y:Number) : Point
      {
         var nx:Number = -y;
         var ny:Number = x;
         var len:Number = Maths.vectorLength(nx,ny);
         nx /= len;
         ny /= len;
         return new Point(nx,ny);
      }
      
      public static function randomInt(min:int, max:int) : int
      {
         return Math.round(Math.random() * (max - min) + min);
      }
      
      public static function formatNum(num:Number, leadingDigits:int, decimalDigits:int = -1) : String
      {
         var frac:Number = NaN;
         var fracStr:* = null;
         for(var result:String = "" + Math.floor(num); result.length < leadingDigits; )
         {
            result = "0" + result;
         }
         if(decimalDigits >= 0)
         {
            frac = Math.abs(num) - Math.floor(Math.abs(num));
            frac *= Math.pow(10,decimalDigits);
            frac = Math.floor(frac);
            for(fracStr = "" + frac; fracStr.length < decimalDigits; )
            {
               fracStr += "0";
            }
            result = result + "." + fracStr;
         }
         return result;
      }
      
      public static function distanceSquared(x1:Number, y1:Number, x2:Number, y2:Number) : Number
      {
         var dx:Number = x1 - x2;
         var dy:Number = y1 - y2;
         return Maths.vectorLengthSquared(dx,dy);
      }
      
      public static function degToRad(degs:Number) : Number
      {
         return degs * 0.017453292519943295;
      }
      
      public static function angleBetween(x1:Number, y1:Number, x2:Number, y2:Number) : Number
      {
         var topLine:Number = x1 * x2 + y1 * y2;
         var bottomLine:Number = Maths.vectorLength(x1,y1) * Maths.vectorLength(x2,y2);
         return Math.acos(topLine / bottomLine);
      }
      
      public static function radToDeg(rads:Number) : Number
      {
         return rads * 57.29577951308232;
      }
      
      public static function distance(x1:Number, y1:Number, x2:Number, y2:Number) : Number
      {
         var dx:Number = x1 - x2;
         var dy:Number = y1 - y2;
         return Maths.vectorLength(dx,dy);
      }
      
      public static function vectorLengthSquared(dx:Number, dy:Number) : Number
      {
         return dx * dx + dy * dy;
      }
   }
}
