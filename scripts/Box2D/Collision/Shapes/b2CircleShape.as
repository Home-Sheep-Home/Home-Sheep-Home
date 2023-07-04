package Box2D.Collision.Shapes
{
   import Box2D.Collision.*;
   import Box2D.Common.*;
   import Box2D.Common.Math.*;
   import Box2D.Dynamics.*;
   
   public class b2CircleShape extends b2Shape
   {
       
      
      public var m_localPosition:b2Vec2;
      
      public var m_radius:Number;
      
      public function b2CircleShape(def:b2ShapeDef)
      {
         this.m_localPosition = new b2Vec2();
         super(def);
         var circleDef:b2CircleDef = def as b2CircleDef;
         m_type = e_circleShape;
         this.m_localPosition.SetV(circleDef.localPosition);
         this.m_radius = circleDef.radius;
      }
      
      override public function TestSegment(transform:b2XForm, lambda:Array, normal:b2Vec2, segment:b2Segment, maxLambda:Number) : Boolean
      {
         var sY:Number = NaN;
         var tMat:b2Mat22 = transform.R;
         var positionX:Number = transform.position.x + (tMat.col1.x * this.m_localPosition.x + tMat.col2.x * this.m_localPosition.y);
         var positionY:Number = transform.position.x + (tMat.col1.y * this.m_localPosition.x + tMat.col2.y * this.m_localPosition.y);
         var sX:Number = segment.p1.x - positionX;
         sY = segment.p1.y - positionY;
         var b:Number = sX * sX + sY * sY - this.m_radius * this.m_radius;
         if(b < 0)
         {
            return false;
         }
         var rX:Number = segment.p2.x - segment.p1.x;
         var rY:Number = segment.p2.y - segment.p1.y;
         var c:Number = sX * rX + sY * rY;
         var rr:Number = rX * rX + rY * rY;
         var sigma:Number = c * c - rr * b;
         if(sigma < 0 || rr < Number.MIN_VALUE)
         {
            return false;
         }
         var a:Number = -(c + Math.sqrt(sigma));
         if(0 <= a && a <= maxLambda * rr)
         {
            a /= rr;
            lambda[0] = a;
            normal.x = sX + a * rX;
            normal.y = sY + a * rY;
            normal.Normalize();
            return true;
         }
         return false;
      }
      
      public function GetLocalPosition() : b2Vec2
      {
         return this.m_localPosition;
      }
      
      public function GetRadius() : Number
      {
         return this.m_radius;
      }
      
      override public function ComputeSweptAABB(aabb:b2AABB, transform1:b2XForm, transform2:b2XForm) : void
      {
         var tMat:b2Mat22 = null;
         tMat = transform1.R;
         var p1X:Number = transform1.position.x + (tMat.col1.x * this.m_localPosition.x + tMat.col2.x * this.m_localPosition.y);
         var p1Y:Number = transform1.position.y + (tMat.col1.y * this.m_localPosition.x + tMat.col2.y * this.m_localPosition.y);
         tMat = transform2.R;
         var p2X:Number = transform2.position.x + (tMat.col1.x * this.m_localPosition.x + tMat.col2.x * this.m_localPosition.y);
         var p2Y:Number = transform2.position.y + (tMat.col1.y * this.m_localPosition.x + tMat.col2.y * this.m_localPosition.y);
         aabb.lowerBound.Set((p1X < p2X ? p1X : p2X) - this.m_radius,(p1Y < p2Y ? p1Y : p2Y) - this.m_radius);
         aabb.upperBound.Set((p1X > p2X ? p1X : p2X) + this.m_radius,(p1Y > p2Y ? p1Y : p2Y) + this.m_radius);
      }
      
      override public function ComputeMass(massData:b2MassData) : void
      {
         massData.mass = m_density * b2Settings.b2_pi * this.m_radius * this.m_radius;
         massData.center.SetV(this.m_localPosition);
         massData.I = massData.mass * (0.5 * this.m_radius * this.m_radius + (this.m_localPosition.x * this.m_localPosition.x + this.m_localPosition.y * this.m_localPosition.y));
      }
      
      override public function UpdateSweepRadius(center:b2Vec2) : void
      {
         var dX:Number = this.m_localPosition.x - center.x;
         var dY:Number = this.m_localPosition.y - center.y;
         dX = Math.sqrt(dX * dX + dY * dY);
         m_sweepRadius = dX + this.m_radius - b2Settings.b2_toiSlop;
      }
      
      override public function ComputeAABB(aabb:b2AABB, transform:b2XForm) : void
      {
         var tMat:b2Mat22 = transform.R;
         var pX:Number = transform.position.x + (tMat.col1.x * this.m_localPosition.x + tMat.col2.x * this.m_localPosition.y);
         var pY:Number = transform.position.y + (tMat.col1.y * this.m_localPosition.x + tMat.col2.y * this.m_localPosition.y);
         aabb.lowerBound.Set(pX - this.m_radius,pY - this.m_radius);
         aabb.upperBound.Set(pX + this.m_radius,pY + this.m_radius);
      }
      
      override public function TestPoint(transform:b2XForm, p:b2Vec2) : Boolean
      {
         var tMat:b2Mat22 = transform.R;
         var dX:Number = transform.position.x + (tMat.col1.x * this.m_localPosition.x + tMat.col2.x * this.m_localPosition.y);
         var dY:Number = transform.position.y + (tMat.col1.y * this.m_localPosition.x + tMat.col2.y * this.m_localPosition.y);
         dX = p.x - dX;
         dY = p.y - dY;
         return dX * dX + dY * dY <= this.m_radius * this.m_radius;
      }
   }
}
