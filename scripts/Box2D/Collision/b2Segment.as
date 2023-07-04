package Box2D.Collision
{
   import Box2D.Common.*;
   import Box2D.Common.Math.*;
   
   public class b2Segment
   {
       
      
      public var p1:b2Vec2;
      
      public var p2:b2Vec2;
      
      public function b2Segment()
      {
         this.p1 = new b2Vec2();
         this.p2 = new b2Vec2();
         super();
      }
      
      public function TestSegment(lambda:Array, normal:b2Vec2, segment:b2Segment, maxLambda:Number) : Boolean
      {
         var bX:Number = NaN;
         var bY:Number = NaN;
         var a:Number = NaN;
         var mu2:Number = NaN;
         var nLen:Number = NaN;
         var s:b2Vec2 = segment.p1;
         var rX:Number = segment.p2.x - s.x;
         var rY:Number = segment.p2.y - s.y;
         var dX:Number = this.p2.x - this.p1.x;
         var dY:Number = this.p2.y - this.p1.y;
         var nX:Number = dY;
         var nY:Number = -dX;
         var k_slop:Number = 100 * Number.MIN_VALUE;
         var denom:Number = -(rX * nX + rY * nY);
         if(denom > k_slop)
         {
            bX = s.x - this.p1.x;
            bY = s.y - this.p1.y;
            a = bX * nX + bY * nY;
            if(0 <= a && a <= maxLambda * denom)
            {
               mu2 = -rY * bY + rY * bX;
               if(-k_slop * denom <= mu2 && mu2 <= denom * (1 + k_slop))
               {
                  a /= denom;
                  nLen = Math.sqrt(nX * nX + nY * nY);
                  nX /= nLen;
                  nY /= nLen;
                  lambda[0] = a;
                  normal.Set(nX,nY);
                  return true;
               }
            }
         }
         return false;
      }
   }
}
