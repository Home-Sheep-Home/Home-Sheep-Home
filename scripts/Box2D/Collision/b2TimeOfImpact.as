package Box2D.Collision
{
   import Box2D.Collision.Shapes.b2Shape;
   import Box2D.Common.Math.b2Sweep;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Common.Math.b2XForm;
   import Box2D.Common.b2Settings;
   
   public class b2TimeOfImpact
   {
      
      public static var s_xf1:b2XForm = new b2XForm();
      
      public static var s_xf2:b2XForm = new b2XForm();
      
      public static var s_p1:b2Vec2 = new b2Vec2();
      
      public static var s_p2:b2Vec2 = new b2Vec2();
       
      
      public function b2TimeOfImpact()
      {
         super();
      }
      
      public static function TimeOfImpact(shape1:b2Shape, sweep1:b2Sweep, shape2:b2Shape, sweep2:b2Sweep) : Number
      {
         var math1:Number = NaN;
         var math2:Number = NaN;
         var t:Number = NaN;
         var xf1:b2XForm = null;
         var xf2:b2XForm = null;
         var nLen:Number = NaN;
         var approachVelocityBound:Number = NaN;
         var dAlpha:Number = NaN;
         var newAlpha:Number = NaN;
         var r1:Number = shape1.m_sweepRadius;
         var r2:Number = shape2.m_sweepRadius;
         var t0:Number = sweep1.t0;
         var v1X:Number = sweep1.c.x - sweep1.c0.x;
         var v1Y:Number = sweep1.c.y - sweep1.c0.y;
         var v2X:Number = sweep2.c.x - sweep2.c0.x;
         var v2Y:Number = sweep2.c.y - sweep2.c0.y;
         var omega1:Number = sweep1.a - sweep1.a0;
         var omega2:Number = sweep2.a - sweep2.a0;
         var alpha:Number = 0;
         var p1:b2Vec2 = s_p1;
         var p2:b2Vec2 = s_p2;
         var k_maxIterations:int = 20;
         var iter:int = 0;
         var normalX:Number = 0;
         var normalY:Number = 0;
         var distance:Number = 0;
         var targetDistance:Number = 0;
         while(true)
         {
            t = (1 - alpha) * t0 + alpha;
            xf1 = s_xf1;
            xf2 = s_xf2;
            sweep1.GetXForm(xf1,t);
            sweep2.GetXForm(xf2,t);
            distance = b2Distance.Distance(p1,p2,shape1,xf1,shape2,xf2);
            if(iter == 0)
            {
               if(distance > 2 * b2Settings.b2_toiSlop)
               {
                  targetDistance = 1.5 * b2Settings.b2_toiSlop;
               }
               else
               {
                  math1 = 0.05 * b2Settings.b2_toiSlop;
                  math2 = distance - 0.5 * b2Settings.b2_toiSlop;
                  targetDistance = math1 > math2 ? math1 : math2;
               }
            }
            if(distance - targetDistance < 0.05 * b2Settings.b2_toiSlop || iter == k_maxIterations)
            {
               break;
            }
            normalX = p2.x - p1.x;
            normalY = p2.y - p1.y;
            nLen = Math.sqrt(normalX * normalX + normalY * normalY);
            normalX /= nLen;
            normalY /= nLen;
            approachVelocityBound = normalX * (v1X - v2X) + normalY * (v1Y - v2Y) + (omega1 < 0 ? -omega1 : omega1) * r1 + (omega2 < 0 ? -omega2 : omega2) * r2;
            if(approachVelocityBound == 0)
            {
               alpha = 1;
               break;
            }
            dAlpha = (distance - targetDistance) / approachVelocityBound;
            newAlpha = alpha + dAlpha;
            if(newAlpha < 0 || 1 < newAlpha)
            {
               alpha = 1;
               break;
            }
            if(newAlpha < (1 + 100 * Number.MIN_VALUE) * alpha)
            {
               break;
            }
            alpha = newAlpha;
            iter++;
         }
         return alpha;
      }
   }
}
