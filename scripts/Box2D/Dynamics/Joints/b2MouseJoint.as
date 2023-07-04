package Box2D.Dynamics.Joints
{
   import Box2D.Common.Math.b2Mat22;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Common.b2Settings;
   import Box2D.Dynamics.b2Body;
   import Box2D.Dynamics.b2TimeStep;
   
   public class b2MouseJoint extends b2Joint
   {
       
      
      private var K1:b2Mat22;
      
      private var K:b2Mat22;
      
      public var m_beta:Number;
      
      public var m_mass:b2Mat22;
      
      private var K2:b2Mat22;
      
      public var m_target:b2Vec2;
      
      public var m_gamma:Number;
      
      public var m_impulse:b2Vec2;
      
      public var m_C:b2Vec2;
      
      public var m_localAnchor:b2Vec2;
      
      public var m_maxForce:Number;
      
      public function b2MouseJoint(def:b2MouseJointDef)
      {
         var tY:Number = NaN;
         this.K = new b2Mat22();
         this.K1 = new b2Mat22();
         this.K2 = new b2Mat22();
         this.m_localAnchor = new b2Vec2();
         this.m_target = new b2Vec2();
         this.m_impulse = new b2Vec2();
         this.m_mass = new b2Mat22();
         this.m_C = new b2Vec2();
         super(def);
         this.m_target.SetV(def.target);
         var tX:Number = this.m_target.x - m_body2.m_xf.position.x;
         tY = this.m_target.y - m_body2.m_xf.position.y;
         var tMat:b2Mat22 = m_body2.m_xf.R;
         this.m_localAnchor.x = tX * tMat.col1.x + tY * tMat.col1.y;
         this.m_localAnchor.y = tX * tMat.col2.x + tY * tMat.col2.y;
         this.m_maxForce = def.maxForce;
         this.m_impulse.SetZero();
         var mass:Number = m_body2.m_mass;
         var omega:Number = 2 * b2Settings.b2_pi * def.frequencyHz;
         var d:Number = 2 * mass * def.dampingRatio * omega;
         var k:Number = def.timeStep * mass * (omega * omega);
         this.m_gamma = 1 / (d + k);
         this.m_beta = k / (d + k);
      }
      
      public function SetTarget(target:b2Vec2) : void
      {
         if(m_body2.IsSleeping())
         {
            m_body2.WakeUp();
         }
         this.m_target = target;
      }
      
      override public function GetAnchor2() : b2Vec2
      {
         return m_body2.GetWorldPoint(this.m_localAnchor);
      }
      
      override public function InitVelocityConstraints(step:b2TimeStep) : void
      {
         var b:b2Body = null;
         var tMat:b2Mat22 = null;
         var rX:Number = NaN;
         var rY:Number = NaN;
         var invMass:Number = NaN;
         var invI:Number = NaN;
         b = m_body2;
         tMat = b.m_xf.R;
         rX = this.m_localAnchor.x - b.m_sweep.localCenter.x;
         rY = this.m_localAnchor.y - b.m_sweep.localCenter.y;
         var tX:Number = tMat.col1.x * rX + tMat.col2.x * rY;
         rY = tMat.col1.y * rX + tMat.col2.y * rY;
         rX = tX;
         invMass = b.m_invMass;
         invI = b.m_invI;
         this.K1.col1.x = invMass;
         this.K1.col2.x = 0;
         this.K1.col1.y = 0;
         this.K1.col2.y = invMass;
         this.K2.col1.x = invI * rY * rY;
         this.K2.col2.x = -invI * rX * rY;
         this.K2.col1.y = -invI * rX * rY;
         this.K2.col2.y = invI * rX * rX;
         this.K.SetM(this.K1);
         this.K.AddM(this.K2);
         this.K.col1.x += this.m_gamma;
         this.K.col2.y += this.m_gamma;
         this.K.Invert(this.m_mass);
         this.m_C.x = b.m_sweep.c.x + rX - this.m_target.x;
         this.m_C.y = b.m_sweep.c.y + rY - this.m_target.y;
         b.m_angularVelocity *= 0.98;
         var PX:Number = step.dt * this.m_impulse.x;
         var PY:Number = step.dt * this.m_impulse.y;
         b.m_linearVelocity.x += invMass * PX;
         b.m_linearVelocity.y += invMass * PY;
         b.m_angularVelocity += invI * (rX * PY - rY * PX);
      }
      
      override public function GetAnchor1() : b2Vec2
      {
         return this.m_target;
      }
      
      override public function GetReactionTorque() : Number
      {
         return 0;
      }
      
      override public function GetReactionForce() : b2Vec2
      {
         return this.m_impulse;
      }
      
      override public function SolvePositionConstraints() : Boolean
      {
         return true;
      }
      
      override public function SolveVelocityConstraints(step:b2TimeStep) : void
      {
         var tMat:b2Mat22 = null;
         var tX:Number = NaN;
         var tY:Number = NaN;
         var b:b2Body = m_body2;
         tMat = b.m_xf.R;
         var rX:Number = this.m_localAnchor.x - b.m_sweep.localCenter.x;
         var rY:Number = this.m_localAnchor.y - b.m_sweep.localCenter.y;
         tX = tMat.col1.x * rX + tMat.col2.x * rY;
         rY = tMat.col1.y * rX + tMat.col2.y * rY;
         rX = tX;
         var CdotX:Number = b.m_linearVelocity.x + -b.m_angularVelocity * rY;
         var CdotY:Number = b.m_linearVelocity.y + b.m_angularVelocity * rX;
         tMat = this.m_mass;
         tX = CdotX + this.m_beta * step.inv_dt * this.m_C.x + this.m_gamma * step.dt * this.m_impulse.x;
         tY = CdotY + this.m_beta * step.inv_dt * this.m_C.y + this.m_gamma * step.dt * this.m_impulse.y;
         var forceX:Number = -step.inv_dt * (tMat.col1.x * tX + tMat.col2.x * tY);
         var forceY:Number = -step.inv_dt * (tMat.col1.y * tX + tMat.col2.y * tY);
         var oldForceX:Number = this.m_impulse.x;
         var oldForceY:Number = this.m_impulse.y;
         this.m_impulse.x += forceX;
         this.m_impulse.y += forceY;
         var forceMagnitude:Number = this.m_impulse.Length();
         if(forceMagnitude > this.m_maxForce)
         {
            this.m_impulse.Multiply(this.m_maxForce / forceMagnitude);
         }
         forceX = this.m_impulse.x - oldForceX;
         forceY = this.m_impulse.y - oldForceY;
         var PX:Number = step.dt * forceX;
         var PY:Number = step.dt * forceY;
         b.m_linearVelocity.x += b.m_invMass * PX;
         b.m_linearVelocity.y += b.m_invMass * PY;
         b.m_angularVelocity += b.m_invI * (rX * PY - rY * PX);
      }
   }
}
