package Box2D.Dynamics.Joints
{
   import Box2D.Common.Math.b2Mat22;
   import Box2D.Common.Math.b2Math;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Common.b2Settings;
   import Box2D.Dynamics.b2Body;
   import Box2D.Dynamics.b2TimeStep;
   
   public class b2PulleyJoint extends b2Joint
   {
      
      public static const b2_minPulleyLength:Number = 2;
       
      
      public var m_limitState1:int;
      
      public var m_limitState2:int;
      
      public var m_ground:b2Body;
      
      public var m_maxLength2:Number;
      
      public var m_maxLength1:Number;
      
      public var m_limitPositionImpulse1:Number;
      
      public var m_limitPositionImpulse2:Number;
      
      public var m_force:Number;
      
      public var m_constant:Number;
      
      public var m_positionImpulse:Number;
      
      public var m_state:int;
      
      public var m_ratio:Number;
      
      public var m_groundAnchor1:b2Vec2;
      
      public var m_groundAnchor2:b2Vec2;
      
      public var m_localAnchor1:b2Vec2;
      
      public var m_localAnchor2:b2Vec2;
      
      public var m_limitMass1:Number;
      
      public var m_limitMass2:Number;
      
      public var m_pulleyMass:Number;
      
      public var m_u1:b2Vec2;
      
      public var m_limitForce1:Number;
      
      public var m_limitForce2:Number;
      
      public var m_u2:b2Vec2;
      
      public function b2PulleyJoint(def:b2PulleyJointDef)
      {
         var tMat:b2Mat22 = null;
         var tX:Number = NaN;
         var tY:Number = NaN;
         this.m_groundAnchor1 = new b2Vec2();
         this.m_groundAnchor2 = new b2Vec2();
         this.m_localAnchor1 = new b2Vec2();
         this.m_localAnchor2 = new b2Vec2();
         this.m_u1 = new b2Vec2();
         this.m_u2 = new b2Vec2();
         super(def);
         this.m_ground = m_body1.m_world.m_groundBody;
         this.m_groundAnchor1.x = def.groundAnchor1.x - this.m_ground.m_xf.position.x;
         this.m_groundAnchor1.y = def.groundAnchor1.y - this.m_ground.m_xf.position.y;
         this.m_groundAnchor2.x = def.groundAnchor2.x - this.m_ground.m_xf.position.x;
         this.m_groundAnchor2.y = def.groundAnchor2.y - this.m_ground.m_xf.position.y;
         this.m_localAnchor1.SetV(def.localAnchor1);
         this.m_localAnchor2.SetV(def.localAnchor2);
         this.m_ratio = def.ratio;
         this.m_constant = def.length1 + this.m_ratio * def.length2;
         this.m_maxLength1 = b2Math.b2Min(def.maxLength1,this.m_constant - this.m_ratio * b2_minPulleyLength);
         this.m_maxLength2 = b2Math.b2Min(def.maxLength2,(this.m_constant - b2_minPulleyLength) / this.m_ratio);
         this.m_force = 0;
         this.m_limitForce1 = 0;
         this.m_limitForce2 = 0;
      }
      
      public function GetGroundAnchor2() : b2Vec2
      {
         var a:b2Vec2 = this.m_ground.m_xf.position.Copy();
         a.Add(this.m_groundAnchor2);
         return a;
      }
      
      override public function GetAnchor1() : b2Vec2
      {
         return m_body1.GetWorldPoint(this.m_localAnchor1);
      }
      
      override public function GetAnchor2() : b2Vec2
      {
         return m_body2.GetWorldPoint(this.m_localAnchor2);
      }
      
      override public function GetReactionForce() : b2Vec2
      {
         var F:b2Vec2 = this.m_u2.Copy();
         F.Multiply(this.m_force);
         return F;
      }
      
      override public function SolvePositionConstraints() : Boolean
      {
         var tMat:b2Mat22 = null;
         var r1X:Number = NaN;
         var r1Y:Number = NaN;
         var r2X:Number = NaN;
         var r2Y:Number = NaN;
         var p1X:Number = NaN;
         var p1Y:Number = NaN;
         var p2X:Number = NaN;
         var p2Y:Number = NaN;
         var length1:Number = NaN;
         var length2:Number = NaN;
         var C:Number = NaN;
         var impulse:Number = NaN;
         var oldImpulse:Number = NaN;
         var oldLimitPositionImpulse:Number = NaN;
         var tX:Number = NaN;
         var b1:b2Body = m_body1;
         var b2:b2Body = m_body2;
         var s1X:Number = this.m_ground.m_xf.position.x + this.m_groundAnchor1.x;
         var s1Y:Number = this.m_ground.m_xf.position.y + this.m_groundAnchor1.y;
         var s2X:Number = this.m_ground.m_xf.position.x + this.m_groundAnchor2.x;
         var s2Y:Number = this.m_ground.m_xf.position.y + this.m_groundAnchor2.y;
         var linearError:Number = 0;
         if(this.m_state == e_atUpperLimit)
         {
            tMat = b1.m_xf.R;
            r1X = this.m_localAnchor1.x - b1.m_sweep.localCenter.x;
            r1Y = this.m_localAnchor1.y - b1.m_sweep.localCenter.y;
            tX = tMat.col1.x * r1X + tMat.col2.x * r1Y;
            r1Y = tMat.col1.y * r1X + tMat.col2.y * r1Y;
            r1X = tX;
            tMat = b2.m_xf.R;
            r2X = this.m_localAnchor2.x - b2.m_sweep.localCenter.x;
            r2Y = this.m_localAnchor2.y - b2.m_sweep.localCenter.y;
            tX = tMat.col1.x * r2X + tMat.col2.x * r2Y;
            r2Y = tMat.col1.y * r2X + tMat.col2.y * r2Y;
            r2X = tX;
            p1X = b1.m_sweep.c.x + r1X;
            p1Y = b1.m_sweep.c.y + r1Y;
            p2X = b2.m_sweep.c.x + r2X;
            p2Y = b2.m_sweep.c.y + r2Y;
            this.m_u1.Set(p1X - s1X,p1Y - s1Y);
            this.m_u2.Set(p2X - s2X,p2Y - s2Y);
            length1 = this.m_u1.Length();
            length2 = this.m_u2.Length();
            if(length1 > b2Settings.b2_linearSlop)
            {
               this.m_u1.Multiply(1 / length1);
            }
            else
            {
               this.m_u1.SetZero();
            }
            if(length2 > b2Settings.b2_linearSlop)
            {
               this.m_u2.Multiply(1 / length2);
            }
            else
            {
               this.m_u2.SetZero();
            }
            C = this.m_constant - length1 - this.m_ratio * length2;
            linearError = b2Math.b2Max(linearError,-C);
            C = b2Math.b2Clamp(C + b2Settings.b2_linearSlop,-b2Settings.b2_maxLinearCorrection,0);
            impulse = -this.m_pulleyMass * C;
            oldImpulse = this.m_positionImpulse;
            this.m_positionImpulse = b2Math.b2Max(0,this.m_positionImpulse + impulse);
            impulse = this.m_positionImpulse - oldImpulse;
            p1X = -impulse * this.m_u1.x;
            p1Y = -impulse * this.m_u1.y;
            p2X = -this.m_ratio * impulse * this.m_u2.x;
            p2Y = -this.m_ratio * impulse * this.m_u2.y;
            b1.m_sweep.c.x += b1.m_invMass * p1X;
            b1.m_sweep.c.y += b1.m_invMass * p1Y;
            b1.m_sweep.a += b1.m_invI * (r1X * p1Y - r1Y * p1X);
            b2.m_sweep.c.x += b2.m_invMass * p2X;
            b2.m_sweep.c.y += b2.m_invMass * p2Y;
            b2.m_sweep.a += b2.m_invI * (r2X * p2Y - r2Y * p2X);
            b1.SynchronizeTransform();
            b2.SynchronizeTransform();
         }
         if(this.m_limitState1 == e_atUpperLimit)
         {
            tMat = b1.m_xf.R;
            r1X = this.m_localAnchor1.x - b1.m_sweep.localCenter.x;
            r1Y = this.m_localAnchor1.y - b1.m_sweep.localCenter.y;
            tX = tMat.col1.x * r1X + tMat.col2.x * r1Y;
            r1Y = tMat.col1.y * r1X + tMat.col2.y * r1Y;
            r1X = tX;
            p1X = b1.m_sweep.c.x + r1X;
            p1Y = b1.m_sweep.c.y + r1Y;
            this.m_u1.Set(p1X - s1X,p1Y - s1Y);
            length1 = this.m_u1.Length();
            if(length1 > b2Settings.b2_linearSlop)
            {
               this.m_u1.x *= 1 / length1;
               this.m_u1.y *= 1 / length1;
            }
            else
            {
               this.m_u1.SetZero();
            }
            C = this.m_maxLength1 - length1;
            linearError = b2Math.b2Max(linearError,-C);
            C = b2Math.b2Clamp(C + b2Settings.b2_linearSlop,-b2Settings.b2_maxLinearCorrection,0);
            impulse = -this.m_limitMass1 * C;
            oldLimitPositionImpulse = this.m_limitPositionImpulse1;
            this.m_limitPositionImpulse1 = b2Math.b2Max(0,this.m_limitPositionImpulse1 + impulse);
            impulse = this.m_limitPositionImpulse1 - oldLimitPositionImpulse;
            p1X = -impulse * this.m_u1.x;
            p1Y = -impulse * this.m_u1.y;
            b1.m_sweep.c.x += b1.m_invMass * p1X;
            b1.m_sweep.c.y += b1.m_invMass * p1Y;
            b1.m_sweep.a += b1.m_invI * (r1X * p1Y - r1Y * p1X);
            b1.SynchronizeTransform();
         }
         if(this.m_limitState2 == e_atUpperLimit)
         {
            tMat = b2.m_xf.R;
            r2X = this.m_localAnchor2.x - b2.m_sweep.localCenter.x;
            r2Y = this.m_localAnchor2.y - b2.m_sweep.localCenter.y;
            tX = tMat.col1.x * r2X + tMat.col2.x * r2Y;
            r2Y = tMat.col1.y * r2X + tMat.col2.y * r2Y;
            r2X = tX;
            p2X = b2.m_sweep.c.x + r2X;
            p2Y = b2.m_sweep.c.y + r2Y;
            this.m_u2.Set(p2X - s2X,p2Y - s2Y);
            length2 = this.m_u2.Length();
            if(length2 > b2Settings.b2_linearSlop)
            {
               this.m_u2.x *= 1 / length2;
               this.m_u2.y *= 1 / length2;
            }
            else
            {
               this.m_u2.SetZero();
            }
            C = this.m_maxLength2 - length2;
            linearError = b2Math.b2Max(linearError,-C);
            C = b2Math.b2Clamp(C + b2Settings.b2_linearSlop,-b2Settings.b2_maxLinearCorrection,0);
            impulse = -this.m_limitMass2 * C;
            oldLimitPositionImpulse = this.m_limitPositionImpulse2;
            this.m_limitPositionImpulse2 = b2Math.b2Max(0,this.m_limitPositionImpulse2 + impulse);
            impulse = this.m_limitPositionImpulse2 - oldLimitPositionImpulse;
            p2X = -impulse * this.m_u2.x;
            p2Y = -impulse * this.m_u2.y;
            b2.m_sweep.c.x += b2.m_invMass * p2X;
            b2.m_sweep.c.y += b2.m_invMass * p2Y;
            b2.m_sweep.a += b2.m_invI * (r2X * p2Y - r2Y * p2X);
            b2.SynchronizeTransform();
         }
         return linearError < b2Settings.b2_linearSlop;
      }
      
      override public function InitVelocityConstraints(step:b2TimeStep) : void
      {
         var tMat:b2Mat22 = null;
         var P1X:Number = NaN;
         var P1Y:Number = NaN;
         var P2X:Number = NaN;
         var P2Y:Number = NaN;
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
         var p1X:Number = b1.m_sweep.c.x + r1X;
         var p1Y:Number = b1.m_sweep.c.y + r1Y;
         var p2X:Number = b2.m_sweep.c.x + r2X;
         var p2Y:Number = b2.m_sweep.c.y + r2Y;
         var s1X:Number = this.m_ground.m_xf.position.x + this.m_groundAnchor1.x;
         var s1Y:Number = this.m_ground.m_xf.position.y + this.m_groundAnchor1.y;
         var s2X:Number = this.m_ground.m_xf.position.x + this.m_groundAnchor2.x;
         var s2Y:Number = this.m_ground.m_xf.position.y + this.m_groundAnchor2.y;
         this.m_u1.Set(p1X - s1X,p1Y - s1Y);
         this.m_u2.Set(p2X - s2X,p2Y - s2Y);
         var length1:Number = this.m_u1.Length();
         var length2:Number = this.m_u2.Length();
         if(length1 > b2Settings.b2_linearSlop)
         {
            this.m_u1.Multiply(1 / length1);
         }
         else
         {
            this.m_u1.SetZero();
         }
         if(length2 > b2Settings.b2_linearSlop)
         {
            this.m_u2.Multiply(1 / length2);
         }
         else
         {
            this.m_u2.SetZero();
         }
         var C:Number = this.m_constant - length1 - this.m_ratio * length2;
         if(C > 0)
         {
            this.m_state = e_inactiveLimit;
            this.m_force = 0;
         }
         else
         {
            this.m_state = e_atUpperLimit;
            this.m_positionImpulse = 0;
         }
         if(length1 < this.m_maxLength1)
         {
            this.m_limitState1 = e_inactiveLimit;
            this.m_limitForce1 = 0;
         }
         else
         {
            this.m_limitState1 = e_atUpperLimit;
            this.m_limitPositionImpulse1 = 0;
         }
         if(length2 < this.m_maxLength2)
         {
            this.m_limitState2 = e_inactiveLimit;
            this.m_limitForce2 = 0;
         }
         else
         {
            this.m_limitState2 = e_atUpperLimit;
            this.m_limitPositionImpulse2 = 0;
         }
         var cr1u1:Number = r1X * this.m_u1.y - r1Y * this.m_u1.x;
         var cr2u2:Number = r2X * this.m_u2.y - r2Y * this.m_u2.x;
         this.m_limitMass1 = b1.m_invMass + b1.m_invI * cr1u1 * cr1u1;
         this.m_limitMass2 = b2.m_invMass + b2.m_invI * cr2u2 * cr2u2;
         this.m_pulleyMass = this.m_limitMass1 + this.m_ratio * this.m_ratio * this.m_limitMass2;
         this.m_limitMass1 = 1 / this.m_limitMass1;
         this.m_limitMass2 = 1 / this.m_limitMass2;
         this.m_pulleyMass = 1 / this.m_pulleyMass;
         if(step.warmStarting)
         {
            P1X = step.dt * (-this.m_force - this.m_limitForce1) * this.m_u1.x;
            P1Y = step.dt * (-this.m_force - this.m_limitForce1) * this.m_u1.y;
            P2X = step.dt * (-this.m_ratio * this.m_force - this.m_limitForce2) * this.m_u2.x;
            P2Y = step.dt * (-this.m_ratio * this.m_force - this.m_limitForce2) * this.m_u2.y;
            b1.m_linearVelocity.x += b1.m_invMass * P1X;
            b1.m_linearVelocity.y += b1.m_invMass * P1Y;
            b1.m_angularVelocity += b1.m_invI * (r1X * P1Y - r1Y * P1X);
            b2.m_linearVelocity.x += b2.m_invMass * P2X;
            b2.m_linearVelocity.y += b2.m_invMass * P2Y;
            b2.m_angularVelocity += b2.m_invI * (r2X * P2Y - r2Y * P2X);
         }
         else
         {
            this.m_force = 0;
            this.m_limitForce1 = 0;
            this.m_limitForce2 = 0;
         }
      }
      
      override public function GetReactionTorque() : Number
      {
         return 0;
      }
      
      public function GetRatio() : Number
      {
         return this.m_ratio;
      }
      
      override public function SolveVelocityConstraints(step:b2TimeStep) : void
      {
         var tMat:b2Mat22 = null;
         var v1X:Number = NaN;
         var v1Y:Number = NaN;
         var v2X:Number = NaN;
         var v2Y:Number = NaN;
         var P1X:Number = NaN;
         var P1Y:Number = NaN;
         var P2X:Number = NaN;
         var P2Y:Number = NaN;
         var Cdot:Number = NaN;
         var force:Number = NaN;
         var oldForce:Number = NaN;
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
         if(this.m_state == e_atUpperLimit)
         {
            v1X = b1.m_linearVelocity.x + -b1.m_angularVelocity * r1Y;
            v1Y = b1.m_linearVelocity.y + b1.m_angularVelocity * r1X;
            v2X = b2.m_linearVelocity.x + -b2.m_angularVelocity * r2Y;
            v2Y = b2.m_linearVelocity.y + b2.m_angularVelocity * r2X;
            Cdot = -(this.m_u1.x * v1X + this.m_u1.y * v1Y) - this.m_ratio * (this.m_u2.x * v2X + this.m_u2.y * v2Y);
            force = -step.inv_dt * this.m_pulleyMass * Cdot;
            oldForce = this.m_force;
            this.m_force = b2Math.b2Max(0,this.m_force + force);
            force = this.m_force - oldForce;
            P1X = -step.dt * force * this.m_u1.x;
            P1Y = -step.dt * force * this.m_u1.y;
            P2X = -step.dt * this.m_ratio * force * this.m_u2.x;
            P2Y = -step.dt * this.m_ratio * force * this.m_u2.y;
            b1.m_linearVelocity.x += b1.m_invMass * P1X;
            b1.m_linearVelocity.y += b1.m_invMass * P1Y;
            b1.m_angularVelocity += b1.m_invI * (r1X * P1Y - r1Y * P1X);
            b2.m_linearVelocity.x += b2.m_invMass * P2X;
            b2.m_linearVelocity.y += b2.m_invMass * P2Y;
            b2.m_angularVelocity += b2.m_invI * (r2X * P2Y - r2Y * P2X);
         }
         if(this.m_limitState1 == e_atUpperLimit)
         {
            v1X = b1.m_linearVelocity.x + -b1.m_angularVelocity * r1Y;
            v1Y = b1.m_linearVelocity.y + b1.m_angularVelocity * r1X;
            Cdot = -(this.m_u1.x * v1X + this.m_u1.y * v1Y);
            force = -step.inv_dt * this.m_limitMass1 * Cdot;
            oldForce = this.m_limitForce1;
            this.m_limitForce1 = b2Math.b2Max(0,this.m_limitForce1 + force);
            force = this.m_limitForce1 - oldForce;
            P1X = -step.dt * force * this.m_u1.x;
            P1Y = -step.dt * force * this.m_u1.y;
            b1.m_linearVelocity.x += b1.m_invMass * P1X;
            b1.m_linearVelocity.y += b1.m_invMass * P1Y;
            b1.m_angularVelocity += b1.m_invI * (r1X * P1Y - r1Y * P1X);
         }
         if(this.m_limitState2 == e_atUpperLimit)
         {
            v2X = b2.m_linearVelocity.x + -b2.m_angularVelocity * r2Y;
            v2Y = b2.m_linearVelocity.y + b2.m_angularVelocity * r2X;
            Cdot = -(this.m_u2.x * v2X + this.m_u2.y * v2Y);
            force = -step.inv_dt * this.m_limitMass2 * Cdot;
            oldForce = this.m_limitForce2;
            this.m_limitForce2 = b2Math.b2Max(0,this.m_limitForce2 + force);
            force = this.m_limitForce2 - oldForce;
            P2X = -step.dt * force * this.m_u2.x;
            P2Y = -step.dt * force * this.m_u2.y;
            b2.m_linearVelocity.x += b2.m_invMass * P2X;
            b2.m_linearVelocity.y += b2.m_invMass * P2Y;
            b2.m_angularVelocity += b2.m_invI * (r2X * P2Y - r2Y * P2X);
         }
      }
      
      public function GetLength1() : Number
      {
         var p:b2Vec2 = m_body1.GetWorldPoint(this.m_localAnchor1);
         var sX:Number = this.m_ground.m_xf.position.x + this.m_groundAnchor1.x;
         var sY:Number = this.m_ground.m_xf.position.y + this.m_groundAnchor1.y;
         var dX:Number = p.x - sX;
         var dY:Number = p.y - sY;
         return Math.sqrt(dX * dX + dY * dY);
      }
      
      public function GetLength2() : Number
      {
         var p:b2Vec2 = m_body2.GetWorldPoint(this.m_localAnchor2);
         var sX:Number = this.m_ground.m_xf.position.x + this.m_groundAnchor2.x;
         var sY:Number = this.m_ground.m_xf.position.y + this.m_groundAnchor2.y;
         var dX:Number = p.x - sX;
         var dY:Number = p.y - sY;
         return Math.sqrt(dX * dX + dY * dY);
      }
      
      public function GetGroundAnchor1() : b2Vec2
      {
         var a:b2Vec2 = this.m_ground.m_xf.position.Copy();
         a.Add(this.m_groundAnchor1);
         return a;
      }
   }
}
