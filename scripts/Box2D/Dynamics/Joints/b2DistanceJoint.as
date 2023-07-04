package Box2D.Dynamics.Joints
{
   import Box2D.Common.Math.b2Mat22;
   import Box2D.Common.Math.b2Math;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Common.b2Settings;
   import Box2D.Dynamics.b2Body;
   import Box2D.Dynamics.b2TimeStep;
   
   public class b2DistanceJoint extends b2Joint
   {
       
      
      public var m_localAnchor1:b2Vec2;
      
      public var m_localAnchor2:b2Vec2;
      
      public var m_bias:Number;
      
      public var m_gamma:Number;
      
      public var m_u:b2Vec2;
      
      public var m_mass:Number;
      
      public var m_impulse:Number;
      
      public var m_dampingRatio:Number;
      
      public var m_frequencyHz:Number;
      
      public var m_length:Number;
      
      public function b2DistanceJoint(def:b2DistanceJointDef)
      {
         var tMat:b2Mat22 = null;
         var tX:Number = NaN;
         var tY:Number = NaN;
         this.m_localAnchor1 = new b2Vec2();
         this.m_localAnchor2 = new b2Vec2();
         this.m_u = new b2Vec2();
         super(def);
         this.m_localAnchor1.SetV(def.localAnchor1);
         this.m_localAnchor2.SetV(def.localAnchor2);
         this.m_length = def.length;
         this.m_frequencyHz = def.frequencyHz;
         this.m_dampingRatio = def.dampingRatio;
         this.m_impulse = 0;
         this.m_gamma = 0;
         this.m_bias = 0;
         m_inv_dt = 0;
      }
      
      override public function GetAnchor1() : b2Vec2
      {
         return m_body1.GetWorldPoint(this.m_localAnchor1);
      }
      
      override public function GetAnchor2() : b2Vec2
      {
         return m_body2.GetWorldPoint(this.m_localAnchor2);
      }
      
      override public function InitVelocityConstraints(step:b2TimeStep) : void
      {
         var tMat:b2Mat22 = null;
         var tX:Number = NaN;
         var b1:b2Body = null;
         var b2:b2Body = null;
         var r1X:Number = NaN;
         var r2X:Number = NaN;
         var C:Number = NaN;
         var omega:Number = NaN;
         var d:Number = NaN;
         var k:Number = NaN;
         var PX:Number = NaN;
         var PY:Number = NaN;
         m_inv_dt = step.inv_dt;
         b1 = m_body1;
         b2 = m_body2;
         tMat = b1.m_xf.R;
         r1X = this.m_localAnchor1.x - b1.m_sweep.localCenter.x;
         var r1Y:Number = this.m_localAnchor1.y - b1.m_sweep.localCenter.y;
         tX = tMat.col1.x * r1X + tMat.col2.x * r1Y;
         r1Y = tMat.col1.y * r1X + tMat.col2.y * r1Y;
         r1X = tX;
         tMat = b2.m_xf.R;
         r2X = this.m_localAnchor2.x - b2.m_sweep.localCenter.x;
         var r2Y:Number = this.m_localAnchor2.y - b2.m_sweep.localCenter.y;
         tX = tMat.col1.x * r2X + tMat.col2.x * r2Y;
         r2Y = tMat.col1.y * r2X + tMat.col2.y * r2Y;
         r2X = tX;
         this.m_u.x = b2.m_sweep.c.x + r2X - b1.m_sweep.c.x - r1X;
         this.m_u.y = b2.m_sweep.c.y + r2Y - b1.m_sweep.c.y - r1Y;
         var length:Number = Math.sqrt(this.m_u.x * this.m_u.x + this.m_u.y * this.m_u.y);
         if(length > b2Settings.b2_linearSlop)
         {
            this.m_u.Multiply(1 / length);
         }
         else
         {
            this.m_u.SetZero();
         }
         var cr1u:Number = r1X * this.m_u.y - r1Y * this.m_u.x;
         var cr2u:Number = r2X * this.m_u.y - r2Y * this.m_u.x;
         var invMass:Number = b1.m_invMass + b1.m_invI * cr1u * cr1u + b2.m_invMass + b2.m_invI * cr2u * cr2u;
         this.m_mass = 1 / invMass;
         if(this.m_frequencyHz > 0)
         {
            C = length - this.m_length;
            omega = 2 * Math.PI * this.m_frequencyHz;
            d = 2 * this.m_mass * this.m_dampingRatio * omega;
            k = this.m_mass * omega * omega;
            this.m_gamma = 1 / (step.dt * (d + step.dt * k));
            this.m_bias = C * step.dt * k * this.m_gamma;
            this.m_mass = 1 / (invMass + this.m_gamma);
         }
         if(step.warmStarting)
         {
            this.m_impulse *= step.dtRatio;
            PX = this.m_impulse * this.m_u.x;
            PY = this.m_impulse * this.m_u.y;
            b1.m_linearVelocity.x -= b1.m_invMass * PX;
            b1.m_linearVelocity.y -= b1.m_invMass * PY;
            b1.m_angularVelocity -= b1.m_invI * (r1X * PY - r1Y * PX);
            b2.m_linearVelocity.x += b2.m_invMass * PX;
            b2.m_linearVelocity.y += b2.m_invMass * PY;
            b2.m_angularVelocity += b2.m_invI * (r2X * PY - r2Y * PX);
         }
         else
         {
            this.m_impulse = 0;
         }
      }
      
      override public function GetReactionTorque() : Number
      {
         return 0;
      }
      
      override public function GetReactionForce() : b2Vec2
      {
         var F:b2Vec2 = new b2Vec2();
         F.SetV(this.m_u);
         F.Multiply(m_inv_dt * this.m_impulse);
         return F;
      }
      
      override public function SolvePositionConstraints() : Boolean
      {
         var tMat:b2Mat22 = null;
         if(this.m_frequencyHz > 0)
         {
            return true;
         }
         var b1:b2Body = m_body1;
         var b2:b2Body = m_body2;
         tMat = b1.m_xf.R;
         var r1X:Number = this.m_localAnchor1.x - b1.m_sweep.localCenter.x;
         var r1Y:Number = this.m_localAnchor1.y - b1.m_sweep.localCenter.y;
         var tX:Number = tMat.col1.x * r1X + tMat.col2.x * r1Y;
         r1Y = tMat.col1.y * r1X + tMat.col2.y * r1Y;
         r1X = tX;
         tMat = b2.m_xf.R;
         var r2X:Number = this.m_localAnchor2.x - b2.m_sweep.localCenter.x;
         var r2Y:Number = this.m_localAnchor2.y - b2.m_sweep.localCenter.y;
         tX = tMat.col1.x * r2X + tMat.col2.x * r2Y;
         r2Y = tMat.col1.y * r2X + tMat.col2.y * r2Y;
         r2X = tX;
         var dX:Number = b2.m_sweep.c.x + r2X - b1.m_sweep.c.x - r1X;
         var dY:Number = b2.m_sweep.c.y + r2Y - b1.m_sweep.c.y - r1Y;
         var length:Number = Math.sqrt(dX * dX + dY * dY);
         dX /= length;
         dY /= length;
         var C:Number = length - this.m_length;
         C = b2Math.b2Clamp(C,-b2Settings.b2_maxLinearCorrection,b2Settings.b2_maxLinearCorrection);
         var impulse:Number = -this.m_mass * C;
         this.m_u.Set(dX,dY);
         var PX:Number = impulse * this.m_u.x;
         var PY:Number = impulse * this.m_u.y;
         b1.m_sweep.c.x -= b1.m_invMass * PX;
         b1.m_sweep.c.y -= b1.m_invMass * PY;
         b1.m_sweep.a -= b1.m_invI * (r1X * PY - r1Y * PX);
         b2.m_sweep.c.x += b2.m_invMass * PX;
         b2.m_sweep.c.y += b2.m_invMass * PY;
         b2.m_sweep.a += b2.m_invI * (r2X * PY - r2Y * PX);
         b1.SynchronizeTransform();
         b2.SynchronizeTransform();
         return b2Math.b2Abs(C) < b2Settings.b2_linearSlop;
      }
      
      override public function SolveVelocityConstraints(step:b2TimeStep) : void
      {
         var tMat:b2Mat22 = null;
         var b1:b2Body = m_body1;
         var b2:b2Body = m_body2;
         tMat = b1.m_xf.R;
         var r1X:Number = this.m_localAnchor1.x - b1.m_sweep.localCenter.x;
         var r1Y:Number = this.m_localAnchor1.y - b1.m_sweep.localCenter.y;
         var tX:Number = tMat.col1.x * r1X + tMat.col2.x * r1Y;
         r1Y = tMat.col1.y * r1X + tMat.col2.y * r1Y;
         r1X = tX;
         tMat = b2.m_xf.R;
         var r2X:Number = this.m_localAnchor2.x - b2.m_sweep.localCenter.x;
         var r2Y:Number = this.m_localAnchor2.y - b2.m_sweep.localCenter.y;
         tX = tMat.col1.x * r2X + tMat.col2.x * r2Y;
         r2Y = tMat.col1.y * r2X + tMat.col2.y * r2Y;
         r2X = tX;
         var v1X:Number = b1.m_linearVelocity.x + -b1.m_angularVelocity * r1Y;
         var v1Y:Number = b1.m_linearVelocity.y + b1.m_angularVelocity * r1X;
         var v2X:Number = b2.m_linearVelocity.x + -b2.m_angularVelocity * r2Y;
         var v2Y:Number = b2.m_linearVelocity.y + b2.m_angularVelocity * r2X;
         var Cdot:Number = this.m_u.x * (v2X - v1X) + this.m_u.y * (v2Y - v1Y);
         var impulse:Number = -this.m_mass * (Cdot + this.m_bias + this.m_gamma * this.m_impulse);
         this.m_impulse += impulse;
         var PX:Number = impulse * this.m_u.x;
         var PY:Number = impulse * this.m_u.y;
         b1.m_linearVelocity.x -= b1.m_invMass * PX;
         b1.m_linearVelocity.y -= b1.m_invMass * PY;
         b1.m_angularVelocity -= b1.m_invI * (r1X * PY - r1Y * PX);
         b2.m_linearVelocity.x += b2.m_invMass * PX;
         b2.m_linearVelocity.y += b2.m_invMass * PY;
         b2.m_angularVelocity += b2.m_invI * (r2X * PY - r2Y * PX);
      }
   }
}
