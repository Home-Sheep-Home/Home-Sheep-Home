package Box2D.Dynamics.Joints
{
   import Box2D.Common.Math.b2Mat22;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Common.b2Settings;
   import Box2D.Dynamics.b2Body;
   import Box2D.Dynamics.b2TimeStep;
   
   public class b2GearJoint extends b2Joint
   {
       
      
      public var m_ground2:b2Body;
      
      public var m_groundAnchor1:b2Vec2;
      
      public var m_groundAnchor2:b2Vec2;
      
      public var m_localAnchor1:b2Vec2;
      
      public var m_localAnchor2:b2Vec2;
      
      public var m_ratio:Number;
      
      public var m_revolute2:Box2D.Dynamics.Joints.b2RevoluteJoint;
      
      public var m_force:Number;
      
      public var m_mass:Number;
      
      public var m_prismatic2:Box2D.Dynamics.Joints.b2PrismaticJoint;
      
      public var m_ground1:b2Body;
      
      public var m_revolute1:Box2D.Dynamics.Joints.b2RevoluteJoint;
      
      public var m_prismatic1:Box2D.Dynamics.Joints.b2PrismaticJoint;
      
      public var m_constant:Number;
      
      public var m_J:Box2D.Dynamics.Joints.b2Jacobian;
      
      public function b2GearJoint(def:b2GearJointDef)
      {
         var coordinate1:Number = NaN;
         var coordinate2:Number = NaN;
         this.m_groundAnchor1 = new b2Vec2();
         this.m_groundAnchor2 = new b2Vec2();
         this.m_localAnchor1 = new b2Vec2();
         this.m_localAnchor2 = new b2Vec2();
         this.m_J = new Box2D.Dynamics.Joints.b2Jacobian();
         super(def);
         var type1:int = def.joint1.m_type;
         var type2:int = def.joint2.m_type;
         this.m_revolute1 = null;
         this.m_prismatic1 = null;
         this.m_revolute2 = null;
         this.m_prismatic2 = null;
         this.m_ground1 = def.joint1.m_body1;
         m_body1 = def.joint1.m_body2;
         if(type1 == b2Joint.e_revoluteJoint)
         {
            this.m_revolute1 = def.joint1 as Box2D.Dynamics.Joints.b2RevoluteJoint;
            this.m_groundAnchor1.SetV(this.m_revolute1.m_localAnchor1);
            this.m_localAnchor1.SetV(this.m_revolute1.m_localAnchor2);
            coordinate1 = this.m_revolute1.GetJointAngle();
         }
         else
         {
            this.m_prismatic1 = def.joint1 as Box2D.Dynamics.Joints.b2PrismaticJoint;
            this.m_groundAnchor1.SetV(this.m_prismatic1.m_localAnchor1);
            this.m_localAnchor1.SetV(this.m_prismatic1.m_localAnchor2);
            coordinate1 = this.m_prismatic1.GetJointTranslation();
         }
         this.m_ground2 = def.joint2.m_body1;
         m_body2 = def.joint2.m_body2;
         if(type2 == b2Joint.e_revoluteJoint)
         {
            this.m_revolute2 = def.joint2 as Box2D.Dynamics.Joints.b2RevoluteJoint;
            this.m_groundAnchor2.SetV(this.m_revolute2.m_localAnchor1);
            this.m_localAnchor2.SetV(this.m_revolute2.m_localAnchor2);
            coordinate2 = this.m_revolute2.GetJointAngle();
         }
         else
         {
            this.m_prismatic2 = def.joint2 as Box2D.Dynamics.Joints.b2PrismaticJoint;
            this.m_groundAnchor2.SetV(this.m_prismatic2.m_localAnchor1);
            this.m_localAnchor2.SetV(this.m_prismatic2.m_localAnchor2);
            coordinate2 = this.m_prismatic2.GetJointTranslation();
         }
         this.m_ratio = def.ratio;
         this.m_constant = coordinate1 + this.m_ratio * coordinate2;
         this.m_force = 0;
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
         var ugX:Number = NaN;
         var ugY:Number = NaN;
         var rX:Number = NaN;
         var rY:Number = NaN;
         var tMat:b2Mat22 = null;
         var tVec:b2Vec2 = null;
         var crug:Number = NaN;
         var tX:Number = NaN;
         var P:Number = NaN;
         var g1:b2Body = this.m_ground1;
         var g2:b2Body = this.m_ground2;
         var b1:b2Body = m_body1;
         var b2:b2Body = m_body2;
         var K:Number = 0;
         this.m_J.SetZero();
         if(this.m_revolute1)
         {
            this.m_J.angular1 = -1;
            K += b1.m_invI;
         }
         else
         {
            tMat = g1.m_xf.R;
            tVec = this.m_prismatic1.m_localXAxis1;
            ugX = tMat.col1.x * tVec.x + tMat.col2.x * tVec.y;
            ugY = tMat.col1.y * tVec.x + tMat.col2.y * tVec.y;
            tMat = b1.m_xf.R;
            rX = this.m_localAnchor1.x - b1.m_sweep.localCenter.x;
            rY = this.m_localAnchor1.y - b1.m_sweep.localCenter.y;
            tX = tMat.col1.x * rX + tMat.col2.x * rY;
            rY = tMat.col1.y * rX + tMat.col2.y * rY;
            rX = tX;
            crug = rX * ugY - rY * ugX;
            this.m_J.linear1.Set(-ugX,-ugY);
            this.m_J.angular1 = -crug;
            K += b1.m_invMass + b1.m_invI * crug * crug;
         }
         if(this.m_revolute2)
         {
            this.m_J.angular2 = -this.m_ratio;
            K += this.m_ratio * this.m_ratio * b2.m_invI;
         }
         else
         {
            tMat = g2.m_xf.R;
            tVec = this.m_prismatic2.m_localXAxis1;
            ugX = tMat.col1.x * tVec.x + tMat.col2.x * tVec.y;
            ugY = tMat.col1.y * tVec.x + tMat.col2.y * tVec.y;
            tMat = b2.m_xf.R;
            rX = this.m_localAnchor2.x - b2.m_sweep.localCenter.x;
            rY = this.m_localAnchor2.y - b2.m_sweep.localCenter.y;
            tX = tMat.col1.x * rX + tMat.col2.x * rY;
            rY = tMat.col1.y * rX + tMat.col2.y * rY;
            rX = tX;
            crug = rX * ugY - rY * ugX;
            this.m_J.linear2.Set(-this.m_ratio * ugX,-this.m_ratio * ugY);
            this.m_J.angular2 = -this.m_ratio * crug;
            K += this.m_ratio * this.m_ratio * (b2.m_invMass + b2.m_invI * crug * crug);
         }
         this.m_mass = 1 / K;
         if(step.warmStarting)
         {
            P = step.dt * this.m_force;
            b1.m_linearVelocity.x += b1.m_invMass * P * this.m_J.linear1.x;
            b1.m_linearVelocity.y += b1.m_invMass * P * this.m_J.linear1.y;
            b1.m_angularVelocity += b1.m_invI * P * this.m_J.angular1;
            b2.m_linearVelocity.x += b2.m_invMass * P * this.m_J.linear2.x;
            b2.m_linearVelocity.y += b2.m_invMass * P * this.m_J.linear2.y;
            b2.m_angularVelocity += b2.m_invI * P * this.m_J.angular2;
         }
         else
         {
            this.m_force = 0;
         }
      }
      
      override public function GetReactionTorque() : Number
      {
         var tMat:b2Mat22 = m_body2.m_xf.R;
         var rX:Number = this.m_localAnchor1.x - m_body2.m_sweep.localCenter.x;
         var rY:Number = this.m_localAnchor1.y - m_body2.m_sweep.localCenter.y;
         var tX:Number = tMat.col1.x * rX + tMat.col2.x * rY;
         rY = tMat.col1.y * rX + tMat.col2.y * rY;
         rX = tX;
         return this.m_force * this.m_J.angular2 - (rX * (this.m_force * this.m_J.linear2.y) - rY * (this.m_force * this.m_J.linear2.x));
      }
      
      override public function GetReactionForce() : b2Vec2
      {
         return new b2Vec2(this.m_force * this.m_J.linear2.x,this.m_force * this.m_J.linear2.y);
      }
      
      override public function SolvePositionConstraints() : Boolean
      {
         var coordinate1:Number = NaN;
         var coordinate2:Number = NaN;
         var linearError:Number = 0;
         var b1:b2Body = m_body1;
         var b2:b2Body = m_body2;
         if(this.m_revolute1)
         {
            coordinate1 = this.m_revolute1.GetJointAngle();
         }
         else
         {
            coordinate1 = this.m_prismatic1.GetJointTranslation();
         }
         if(this.m_revolute2)
         {
            coordinate2 = this.m_revolute2.GetJointAngle();
         }
         else
         {
            coordinate2 = this.m_prismatic2.GetJointTranslation();
         }
         var C:Number = this.m_constant - (coordinate1 + this.m_ratio * coordinate2);
         var impulse:Number = -this.m_mass * C;
         b1.m_sweep.c.x += b1.m_invMass * impulse * this.m_J.linear1.x;
         b1.m_sweep.c.y += b1.m_invMass * impulse * this.m_J.linear1.y;
         b1.m_sweep.a += b1.m_invI * impulse * this.m_J.angular1;
         b2.m_sweep.c.x += b2.m_invMass * impulse * this.m_J.linear2.x;
         b2.m_sweep.c.y += b2.m_invMass * impulse * this.m_J.linear2.y;
         b2.m_sweep.a += b2.m_invI * impulse * this.m_J.angular2;
         b1.SynchronizeTransform();
         b2.SynchronizeTransform();
         return linearError < b2Settings.b2_linearSlop;
      }
      
      public function GetRatio() : Number
      {
         return this.m_ratio;
      }
      
      override public function SolveVelocityConstraints(step:b2TimeStep) : void
      {
         var b1:b2Body = m_body1;
         var b2:b2Body = m_body2;
         var Cdot:Number = this.m_J.Compute(b1.m_linearVelocity,b1.m_angularVelocity,b2.m_linearVelocity,b2.m_angularVelocity);
         var force:Number = -step.inv_dt * this.m_mass * Cdot;
         this.m_force += force;
         var P:Number = step.dt * force;
         b1.m_linearVelocity.x += b1.m_invMass * P * this.m_J.linear1.x;
         b1.m_linearVelocity.y += b1.m_invMass * P * this.m_J.linear1.y;
         b1.m_angularVelocity += b1.m_invI * P * this.m_J.angular1;
         b2.m_linearVelocity.x += b2.m_invMass * P * this.m_J.linear2.x;
         b2.m_linearVelocity.y += b2.m_invMass * P * this.m_J.linear2.y;
         b2.m_angularVelocity += b2.m_invI * P * this.m_J.angular2;
      }
   }
}
