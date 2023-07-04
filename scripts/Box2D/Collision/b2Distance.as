package Box2D.Collision
{
   import Box2D.Collision.Shapes.*;
   import Box2D.Common.*;
   import Box2D.Common.Math.*;
   
   public class b2Distance
   {
      
      private static var s_p2s:Array = [new b2Vec2(),new b2Vec2(),new b2Vec2()];
      
      private static var s_p1s:Array = [new b2Vec2(),new b2Vec2(),new b2Vec2()];
      
      private static var s_points:Array = [new b2Vec2(),new b2Vec2(),new b2Vec2()];
      
      private static var gPoint:Box2D.Collision.b2Point = new Box2D.Collision.b2Point();
      
      public static var g_GJK_Iterations:int = 0;
       
      
      public function b2Distance()
      {
         super();
      }
      
      public static function InPoints(w:b2Vec2, points:Array, pointCount:int) : Boolean
      {
         var points_i:b2Vec2 = null;
         var dX:Number = NaN;
         var dY:Number = NaN;
         var mX:Number = NaN;
         var mY:Number = NaN;
         var k_tolerance:Number = 100 * Number.MIN_VALUE;
         for(var i:int = 0; i < pointCount; i++)
         {
            points_i = points[i];
            dX = Math.abs(w.x - points_i.x);
            dY = Math.abs(w.y - points_i.y);
            mX = Math.max(Math.abs(w.x),Math.abs(points_i.x));
            mY = Math.max(Math.abs(w.y),Math.abs(points_i.y));
            if(dX < k_tolerance * (mX + 1) && dY < k_tolerance * (mY + 1))
            {
               return true;
            }
         }
         return false;
      }
      
      public static function DistanceGeneric(x1:b2Vec2, x2:b2Vec2, shape1:*, xf1:b2XForm, shape2:*, xf2:b2XForm) : Number
      {
         var tVec:b2Vec2 = null;
         var vX:Number = NaN;
         var vY:Number = NaN;
         var w1:b2Vec2 = null;
         var w2:b2Vec2 = null;
         var wX:Number = NaN;
         var wY:Number = NaN;
         var vw:Number = NaN;
         var maxSqr:Number = NaN;
         var i:int = 0;
         var p1s:Array = s_p1s;
         var p2s:Array = s_p2s;
         var points:Array = s_points;
         var pointCount:int = 0;
         x1.SetV(shape1.GetFirstVertex(xf1));
         x2.SetV(shape2.GetFirstVertex(xf2));
         var vSqr:Number = 0;
         var maxIterations:int = 20;
         for(var iter:int = 0; iter < maxIterations; iter++)
         {
            vX = x2.x - x1.x;
            vY = x2.y - x1.y;
            w1 = shape1.Support(xf1,vX,vY);
            w2 = shape2.Support(xf2,-vX,-vY);
            vSqr = vX * vX + vY * vY;
            wX = w2.x - w1.x;
            wY = w2.y - w1.y;
            vw = vX * wX + vY * wY;
            if(vSqr - (vX * wX + vY * wY) <= 0.01 * vSqr)
            {
               if(pointCount == 0)
               {
                  x1.SetV(w1);
                  x2.SetV(w2);
               }
               g_GJK_Iterations = iter;
               return Math.sqrt(vSqr);
            }
            switch(pointCount)
            {
               case 0:
                  tVec = p1s[0];
                  tVec.SetV(w1);
                  tVec = p2s[0];
                  tVec.SetV(w2);
                  tVec = points[0];
                  tVec.x = wX;
                  tVec.y = wY;
                  x1.SetV(p1s[0]);
                  x2.SetV(p2s[0]);
                  pointCount++;
                  break;
               case 1:
                  tVec = p1s[1];
                  tVec.SetV(w1);
                  tVec = p2s[1];
                  tVec.SetV(w2);
                  tVec = points[1];
                  tVec.x = wX;
                  tVec.y = wY;
                  pointCount = ProcessTwo(x1,x2,p1s,p2s,points);
                  break;
               case 2:
                  tVec = p1s[2];
                  tVec.SetV(w1);
                  tVec = p2s[2];
                  tVec.SetV(w2);
                  tVec = points[2];
                  tVec.x = wX;
                  tVec.y = wY;
                  pointCount = ProcessThree(x1,x2,p1s,p2s,points);
            }
            if(pointCount == 3)
            {
               g_GJK_Iterations = iter;
               return 0;
            }
            maxSqr = -Number.MAX_VALUE;
            for(i = 0; i < pointCount; i++)
            {
               tVec = points[i];
               maxSqr = b2Math.b2Max(maxSqr,tVec.x * tVec.x + tVec.y * tVec.y);
            }
            if(pointCount == 3 || vSqr <= 100 * Number.MIN_VALUE * maxSqr)
            {
               g_GJK_Iterations = iter;
               vX = x2.x - x1.x;
               vY = x2.y - x1.y;
               vSqr = vX * vX + vY * vY;
               return Math.sqrt(vSqr);
            }
         }
         g_GJK_Iterations = maxIterations;
         return Math.sqrt(vSqr);
      }
      
      public static function DistanceCC(x1:b2Vec2, x2:b2Vec2, circle1:b2CircleShape, xf1:b2XForm, circle2:b2CircleShape, xf2:b2XForm) : Number
      {
         var tMat:b2Mat22 = null;
         var tVec:b2Vec2 = null;
         var dLen:Number = NaN;
         var distance:Number = NaN;
         tMat = xf1.R;
         tVec = circle1.m_localPosition;
         var p1X:Number = xf1.position.x + (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y);
         var p1Y:Number = xf1.position.y + (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y);
         tMat = xf2.R;
         tVec = circle2.m_localPosition;
         var p2X:Number = xf2.position.x + (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y);
         var p2Y:Number = xf2.position.y + (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y);
         var dX:Number = p2X - p1X;
         var dY:Number = p2Y - p1Y;
         var dSqr:Number = dX * dX + dY * dY;
         var r1:Number = circle1.m_radius - b2Settings.b2_toiSlop;
         var r2:Number = circle2.m_radius - b2Settings.b2_toiSlop;
         var r:Number = r1 + r2;
         if(dSqr > r * r)
         {
            dLen = Math.sqrt(dX * dX + dY * dY);
            dX /= dLen;
            dY /= dLen;
            distance = dLen - r;
            x1.x = p1X + r1 * dX;
            x1.y = p1Y + r1 * dY;
            x2.x = p2X - r2 * dX;
            x2.y = p2Y - r2 * dY;
            return distance;
         }
         if(dSqr > Number.MIN_VALUE * Number.MIN_VALUE)
         {
            dLen = Math.sqrt(dX * dX + dY * dY);
            dX /= dLen;
            dY /= dLen;
            x1.x = p1X + r1 * dX;
            x1.y = p1Y + r1 * dY;
            x2.x = x1.x;
            x2.y = x1.y;
            return 0;
         }
         x1.x = p1X;
         x1.y = p1Y;
         x2.x = x1.x;
         x2.y = x1.y;
         return 0;
      }
      
      public static function ProcessThree(x1:b2Vec2, x2:b2Vec2, p1s:Array, p2s:Array, points:Array) : int
      {
         var points_0:b2Vec2 = null;
         var points_1:b2Vec2 = null;
         var points_2:b2Vec2 = null;
         var p1s_0:b2Vec2 = null;
         var p1s_1:b2Vec2 = null;
         var p1s_2:b2Vec2 = null;
         var p2s_0:b2Vec2 = null;
         var p2s_1:b2Vec2 = null;
         var lambda:Number = NaN;
         points_0 = points[0];
         points_1 = points[1];
         points_2 = points[2];
         p1s_0 = p1s[0];
         p1s_1 = p1s[1];
         p1s_2 = p1s[2];
         p2s_0 = p2s[0];
         p2s_1 = p2s[1];
         var p2s_2:b2Vec2 = p2s[2];
         var aX:Number = points_0.x;
         var aY:Number = points_0.y;
         var bX:Number = points_1.x;
         var bY:Number = points_1.y;
         var cX:Number = points_2.x;
         var cY:Number = points_2.y;
         var abX:Number = bX - aX;
         var abY:Number = bY - aY;
         var acX:Number = cX - aX;
         var acY:Number = cY - aY;
         var bcX:Number = cX - bX;
         var bcY:Number = cY - bY;
         var sn:Number = -(aX * abX + aY * abY);
         var sd:Number = bX * abX + bY * abY;
         var tn:Number = -(aX * acX + aY * acY);
         var td:Number = cX * acX + cY * acY;
         var un:Number = -(bX * bcX + bY * bcY);
         var ud:Number = cX * bcX + cY * bcY;
         if(td <= 0 && ud <= 0)
         {
            x1.SetV(p1s_2);
            x2.SetV(p2s_2);
            p1s_0.SetV(p1s_2);
            p2s_0.SetV(p2s_2);
            points_0.SetV(points_2);
            return 1;
         }
         var n:Number = abX * acY - abY * acX;
         var vc:Number = n * (aX * bY - aY * bX);
         var va:Number = n * (bX * cY - bY * cX);
         if(va <= 0 && un >= 0 && ud >= 0 && un + ud > 0)
         {
            lambda = un / (un + ud);
            x1.x = p1s_1.x + lambda * (p1s_2.x - p1s_1.x);
            x1.y = p1s_1.y + lambda * (p1s_2.y - p1s_1.y);
            x2.x = p2s_1.x + lambda * (p2s_2.x - p2s_1.x);
            x2.y = p2s_1.y + lambda * (p2s_2.y - p2s_1.y);
            p1s_0.SetV(p1s_2);
            p2s_0.SetV(p2s_2);
            points_0.SetV(points_2);
            return 2;
         }
         var vb:Number = n * (cX * aY - cY * aX);
         if(vb <= 0 && tn >= 0 && td >= 0 && tn + td > 0)
         {
            lambda = tn / (tn + td);
            x1.x = p1s_0.x + lambda * (p1s_2.x - p1s_0.x);
            x1.y = p1s_0.y + lambda * (p1s_2.y - p1s_0.y);
            x2.x = p2s_0.x + lambda * (p2s_2.x - p2s_0.x);
            x2.y = p2s_0.y + lambda * (p2s_2.y - p2s_0.y);
            p1s_1.SetV(p1s_2);
            p2s_1.SetV(p2s_2);
            points_1.SetV(points_2);
            return 2;
         }
         var denom:Number = va + vb + vc;
         denom = 1 / denom;
         var u:Number = va * denom;
         var v:Number = vb * denom;
         var w:Number = 1 - u - v;
         x1.x = u * p1s_0.x + v * p1s_1.x + w * p1s_2.x;
         x1.y = u * p1s_0.y + v * p1s_1.y + w * p1s_2.y;
         x2.x = u * p2s_0.x + v * p2s_1.x + w * p2s_2.x;
         x2.y = u * p2s_0.y + v * p2s_1.y + w * p2s_2.y;
         return 3;
      }
      
      public static function DistancePC(x1:b2Vec2, x2:b2Vec2, polygon:b2PolygonShape, xf1:b2XForm, circle:b2CircleShape, xf2:b2XForm) : Number
      {
         var tMat:b2Mat22 = null;
         var tVec:b2Vec2 = null;
         var dX:Number = NaN;
         var dY:Number = NaN;
         var dLen:Number = NaN;
         var point:Box2D.Collision.b2Point = gPoint;
         tVec = circle.m_localPosition;
         tMat = xf2.R;
         point.p.x = xf2.position.x + (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y);
         point.p.y = xf2.position.y + (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y);
         var distance:Number = DistanceGeneric(x1,x2,polygon,xf1,point,b2Math.b2XForm_identity);
         var r:Number = circle.m_radius - b2Settings.b2_toiSlop;
         if(distance > r)
         {
            distance -= r;
            dX = x2.x - x1.x;
            dY = x2.y - x1.y;
            dLen = Math.sqrt(dX * dX + dY * dY);
            dX /= dLen;
            dY /= dLen;
            x2.x -= r * dX;
            x2.y -= r * dY;
         }
         else
         {
            distance = 0;
            x2.x = x1.x;
            x2.y = x1.y;
         }
         return distance;
      }
      
      public static function Distance(x1:b2Vec2, x2:b2Vec2, shape1:b2Shape, xf1:b2XForm, shape2:b2Shape, xf2:b2XForm) : Number
      {
         var type1:int = shape1.m_type;
         var type2:int = shape2.m_type;
         if(type1 == b2Shape.e_circleShape && type2 == b2Shape.e_circleShape)
         {
            return DistanceCC(x1,x2,shape1 as b2CircleShape,xf1,shape2 as b2CircleShape,xf2);
         }
         if(type1 == b2Shape.e_polygonShape && type2 == b2Shape.e_circleShape)
         {
            return DistancePC(x1,x2,shape1 as b2PolygonShape,xf1,shape2 as b2CircleShape,xf2);
         }
         if(type1 == b2Shape.e_circleShape && type2 == b2Shape.e_polygonShape)
         {
            return DistancePC(x2,x1,shape2 as b2PolygonShape,xf2,shape1 as b2CircleShape,xf1);
         }
         if(type1 == b2Shape.e_polygonShape && type2 == b2Shape.e_polygonShape)
         {
            return DistanceGeneric(x1,x2,shape1 as b2PolygonShape,xf1,shape2 as b2PolygonShape,xf2);
         }
         return 0;
      }
      
      public static function ProcessTwo(x1:b2Vec2, x2:b2Vec2, p1s:Array, p2s:Array, points:Array) : int
      {
         var p1s_1:b2Vec2 = null;
         var p2s_0:b2Vec2 = null;
         var p2s_1:b2Vec2 = null;
         var lambda:Number = NaN;
         var points_0:b2Vec2 = points[0];
         var points_1:b2Vec2 = points[1];
         var p1s_0:b2Vec2 = p1s[0];
         p1s_1 = p1s[1];
         p2s_0 = p2s[0];
         p2s_1 = p2s[1];
         var rX:Number = -points_1.x;
         var rY:Number = -points_1.y;
         var dX:Number = points_0.x - points_1.x;
         var dY:Number = points_0.y - points_1.y;
         var length:Number = Math.sqrt(dX * dX + dY * dY);
         dX /= length;
         dY /= length;
         lambda = rX * dX + rY * dY;
         if(lambda <= 0 || length < Number.MIN_VALUE)
         {
            x1.SetV(p1s_1);
            x2.SetV(p2s_1);
            p1s_0.SetV(p1s_1);
            p2s_0.SetV(p2s_1);
            points_0.SetV(points_1);
            return 1;
         }
         lambda /= length;
         x1.x = p1s_1.x + lambda * (p1s_0.x - p1s_1.x);
         x1.y = p1s_1.y + lambda * (p1s_0.y - p1s_1.y);
         x2.x = p2s_1.x + lambda * (p2s_0.x - p2s_1.x);
         x2.y = p2s_1.y + lambda * (p2s_0.y - p2s_1.y);
         return 2;
      }
   }
}
