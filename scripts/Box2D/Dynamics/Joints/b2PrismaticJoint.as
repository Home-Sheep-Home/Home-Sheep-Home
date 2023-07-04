package Box2D.Dynamics.Joints
{
   import Box2D.Common.Math.b2Mat22;
   import Box2D.Common.Math.b2Math;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Common.b2Settings;
   import Box2D.Dynamics.b2Body;
   import Box2D.Dynamics.b2TimeStep;
   
   public class b2PrismaticJoint extends b2Joint
   {
       
      
      public var m_limitForce:Number;
      
      public var m_lowerTranslation:Number;
      
      public var m_localXAxis1:b2Vec2;
      
      public var m_refAngle:Number;
      
      public var m_torque:Number;
      
      public var m_motorForce:Number;
      
      public var m_enableLimit:Boolean;
      
      public var m_angularMass:Number;
      
      public var m_maxMotorForce:Number;
      
      public var m_localYAxis1:b2Vec2;
      
      public var m_force:Number;
      
      public var m_motorMass:Number;
      
      public var m_upperTranslation:Number;
      
      public var m_localAnchor1:b2Vec2;
      
      public var m_localAnchor2:b2Vec2;
      
      public var m_limitState:int;
      
      public var m_linearMass:Number;
      
      public var m_motorJacobian:Box2D.Dynamics.Joints.b2Jacobian;
      
      public var m_limitPositionImpulse:Number;
      
      public var m_motorSpeed:Number;
      
      public var m_enableMotor:Boolean;
      
      public var m_linearJacobian:Box2D.Dynamics.Joints.b2Jacobian;
      
      public function b2PrismaticJoint(def:b2PrismaticJointDef)
      {
         var tMat:b2Mat22 = null;
         var tX:Number = NaN;
         var tY:Number = NaN;
         this.m_localAnchor1 = new b2Vec2();
         this.m_localAnchor2 = new b2Vec2();
         this.m_localXAxis1 = new b2Vec2();
         this.m_localYAxis1 = new b2Vec2();
         this.m_linearJacobian = new Box2D.Dynamics.Joints.b2Jacobian();
         this.m_motorJacobian = new Box2D.Dynamics.Joints.b2Jacobian();
         super(def);
         this.m_localAnchor1.SetV(def.localAnchor1);
         this.m_localAnchor2.SetV(def.localAnchor2);
         this.m_localXAxis1.SetV(def.localAxis1);
         this.m_localYAxis1.x = -this.m_localXAxis1.y;
         this.m_localYAxis1.y = this.m_localXAxis1.x;
         this.m_refAngle = def.referenceAngle;
         this.m_linearJacobian.SetZero();
         this.m_linearMass = 0;
         this.m_force = 0;
         this.m_angularMass = 0;
         this.m_torque = 0;
         this.m_motorJacobian.SetZero();
         this.m_motorMass = 0;
         this.m_motorForce = 0;
         this.m_limitForce = 0;
         this.m_limitPositionImpulse = 0;
         this.m_lowerTranslation = def.lowerTranslation;
         this.m_upperTranslation = def.upperTranslation;
         this.m_maxMotorForce = def.maxMotorForce;
         this.m_motorSpeed = def.motorSpeed;
         this.m_enableLimit = def.enableLimit;
         this.m_enableMotor = def.enableMotor;
      }
      
      override public function SolveVelocityConstraints(step:b2TimeStep) : void
      {
         var oldLimitForce:Number = NaN;
         var motorCdot:Number = NaN;
         var motorForce:Number = NaN;
         var oldMotorForce:Number = NaN;
         var limitCdot:Number = NaN;
         var limitForce:Number = NaN;
         var b1:b2Body = m_body1;
         var b2:b2Body = m_body2;
         var invMass1:Number = b1.m_invMass;
         var invMass2:Number = b2.m_invMass;
         var invI1:Number = b1.m_invI;
         var invI2:Number = b2.m_invI;
         var linearCdot:Number = this.m_linearJacobian.Compute(b1.m_linearVelocity,b1.m_angularVelocity,b2.m_linearVelocity,b2.m_angularVelocity);
         var force:Number = -step.inv_dt * this.m_linearMass * linearCdot;
         this.m_force += force;
         var P:Number = step.dt * force;
         b1.m_linearVelocity.x += invMass1 * P * this.m_linearJacobian.linear1.x;
         b1.m_linearVelocity.y += invMass1 * P * this.m_linearJacobian.linear1.y;
         b1.m_angularVelocity += invI1 * P * this.m_linearJacobian.angular1;
         b2.m_linearVelocity.x += invMass2 * P * this.m_linearJacobian.linear2.x;
         b2.m_linearVelocity.y += invMass2 * P * this.m_linearJacobian.linear2.y;
         b2.m_angularVelocity += invI2 * P * this.m_linearJacobian.angular2;
         var angularCdot:Number = b2.m_angularVelocity - b1.m_angularVelocity;
         var torque:Number = -step.inv_dt * this.m_angularMass * angularCdot;
         this.m_torque += torque;
         var L:Number = step.dt * torque;
         b1.m_angularVelocity -= invI1 * L;
         b2.m_angularVelocity += invI2 * L;
         if(this.m_enableMotor && this.m_limitState != e_equalLimits)
         {
            motorCdot = this.m_motorJacobian.Compute(b1.m_linearVelocity,b1.m_angularVelocity,b2.m_linearVelocity,b2.m_angularVelocity) - this.m_motorSpeed;
            motorForce = -step.inv_dt * this.m_motorMass * motorCdot;
            oldMotorForce = this.m_motorForce;
            this.m_motorForce = b2Math.b2Clamp(this.m_motorForce + motorForce,-this.m_maxMotorForce,this.m_maxMotorForce);
            motorForce = this.m_motorForce - oldMotorForce;
            P = step.dt * motorForce;
            b1.m_linearVelocity.x += invMass1 * P * this.m_motorJacobian.linear1.x;
            b1.m_linearVelocity.y += invMass1 * P * this.m_motorJacobian.linear1.y;
            b1.m_angularVelocity += invI1 * P * this.m_motorJacobian.angular1;
            b2.m_linearVelocity.x += invMass2 * P * this.m_motorJacobian.linear2.x;
            b2.m_linearVelocity.y += invMass2 * P * this.m_motorJacobian.linear2.y;
            b2.m_angularVelocity += invI2 * P * this.m_motorJacobian.angular2;
         }
         if(this.m_enableLimit && this.m_limitState != e_inactiveLimit)
         {
            limitCdot = this.m_motorJacobian.Compute(b1.m_linearVelocity,b1.m_angularVelocity,b2.m_linearVelocity,b2.m_angularVelocity);
            limitForce = -step.inv_dt * this.m_motorMass * limitCdot;
            if(this.m_limitState == e_equalLimits)
            {
               this.m_limitForce += limitForce;
            }
            else if(this.m_limitState == e_atLowerLimit)
            {
               oldLimitForce = this.m_limitForce;
               this.m_limitForce = b2Math.b2Max(this.m_limitForce + limitForce,0);
               limitForce = this.m_limitForce - oldLimitForce;
            }
            else if(this.m_limitState == e_atUpperLimit)
            {
               oldLimitForce = this.m_limitForce;
               this.m_limitForce = b2Math.b2Min(this.m_limitForce + limitForce,0);
               limitForce = this.m_limitForce - oldLimitForce;
            }
            P = step.dt * limitForce;
            b1.m_linearVelocity.x += invMass1 * P * this.m_motorJacobian.linear1.x;
            b1.m_linearVelocity.y += invMass1 * P * this.m_motorJacobian.linear1.y;
            b1.m_angularVelocity += invI1 * P * this.m_motorJacobian.angular1;
            b2.m_linearVelocity.x += invMass2 * P * this.m_motorJacobian.linear2.x;
            b2.m_linearVelocity.y += invMass2 * P * this.m_motorJacobian.linear2.y;
            b2.m_angularVelocity += invI2 * P * this.m_motorJacobian.angular2;
         }
      }
      
      override public function GetAnchor1() : b2Vec2
      {
         return m_body1.GetWorldPoint(this.m_localAnchor1);
      }
      
      override public function GetAnchor2() : b2Vec2
      {
         return m_body2.GetWorldPoint(this.m_localAnchor2);
      }
      
      public function GetUpperLimit() : Number
      {
         return this.m_upperTranslation;
      }
      
      public function GetLowerLimit() : Number
      {
         return this.m_lowerTranslation;
      }
      
      public function EnableMotor(flag:Boolean) : void
      {
         this.m_enableMotor = flag;
      }
      
      public function GetJointTranslation() : Number
      {
         var tMat:b2Mat22 = null;
         var b1:b2Body = m_body1;
         var b2:b2Body = m_body2;
         var p1:b2Vec2 = b1.GetWorldPoint(this.m_localAnchor1);
         var p2:b2Vec2 = b2.GetWorldPoint(this.m_localAnchor2);
         var dX:Number = p2.x - p1.x;
         var dY:Number = p2.y - p1.y;
         var axis:b2Vec2 = b1.GetWorldVector(this.m_localXAxis1);
         return axis.x * dX + axis.y * dY;
      }
      
      public function GetMotorSpeed() : Number
      {
         return this.m_motorSpeed;
      }
      
      override public function GetReactionForce() : b2Vec2
      {
         var tMat:b2Mat22 = m_body1.m_xf.R;
         var ax1X:Number = this.m_limitForce * (tMat.col1.x * this.m_localXAxis1.x + tMat.col2.x * this.m_localXAxis1.y);
         var ax1Y:Number = this.m_limitForce * (tMat.col1.y * this.m_localXAxis1.x + tMat.col2.y * this.m_localXAxis1.y);
         var ay1X:Number = this.m_force * (tMat.col1.x * this.m_localYAxis1.x + tMat.col2.x * this.m_localYAxis1.y);
         var ay1Y:Number = this.m_force * (tMat.col1.y * this.m_localYAxis1.x + tMat.col2.y * this.m_localYAxis1.y);
         return new b2Vec2(this.m_limitForce * ax1X + this.m_force * ay1X,this.m_limitForce * ax1Y + this.m_force * ay1Y);
      }
      
      override public function SolvePositionConstraints() : Boolean
      {
         var limitC:Number = NaN;
         var oldLimitImpulse:Number = NaN;
         var tMat:b2Mat22 = null;
         var tX:Number = NaN;
         var ax1X:Number = NaN;
         var ax1Y:Number = NaN;
         var translation:Number = NaN;
         var limitImpulse:Number = NaN;
         var b1:b2Body = m_body1;
         var b2:b2Body = m_body2;
         var invMass1:Number = b1.m_invMass;
         var invMass2:Number = b2.m_invMass;
         var invI1:Number = b1.m_invI;
         var invI2:Number = b2.m_invI;
         tMat = b1.m_xf.R;
         var r1X:Number = this.m_localAnchor1.x - b1.m_sweep.localCenter.x;
         var r1Y:Number = this.m_localAnchor1.y - b1.m_sweep.localCenter.y;
         tX = tMat.col1.x * r1X + tMat.col2.x * r1Y;
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
         var dX:Number = p2X - p1X;
         var dY:Number = p2Y - p1Y;
         tMat = b1.m_xf.R;
         var ay1X:Number = tMat.col1.x * this.m_localYAxis1.x + tMat.col2.x * this.m_localYAxis1.y;
         var ay1Y:Number = tMat.col1.y * this.m_localYAxis1.x + tMat.col2.y * this.m_localYAxis1.y;
         var linearC:Number = ay1X * dX + ay1Y * dY;
         linearC = b2Math.b2Clamp(linearC,-b2Settings.b2_maxLinearCorrection,b2Settings.b2_maxLinearCorrection);
         var linearImpulse:Number = -this.m_linearMass * linearC;
         b1.m_sweep.c.x += invMass1 * linearImpulse * this.m_linearJacobian.linear1.x;
         b1.m_sweep.c.y += invMass1 * linearImpulse * this.m_linearJacobian.linear1.y;
         b1.m_sweep.a += invI1 * linearImpulse * this.m_linearJacobian.angular1;
         b2.m_sweep.c.x += invMass2 * linearImpulse * this.m_linearJacobian.linear2.x;
         b2.m_sweep.c.y += invMass2 * linearImpulse * this.m_linearJacobian.linear2.y;
         b2.m_sweep.a += invI2 * linearImpulse * this.m_linearJacobian.angular2;
         var positionError:Number = b2Math.b2Abs(linearC);
         var angularC:Number = b2.m_sweep.a - b1.m_sweep.a - this.m_refAngle;
         angularC = b2Math.b2Clamp(angularC,-b2Settings.b2_maxAngularCorrection,b2Settings.b2_maxAngularCorrection);
         var angularImpulse:Number = -this.m_angularMass * angularC;
         b1.m_sweep.a -= b1.m_invI * angularImpulse;
         b2.m_sweep.a += b2.m_invI * angularImpulse;
         b1.SynchronizeTransform();
         b2.SynchronizeTransform();
         var angularError:Number = b2Math.b2Abs(angularC);
         if(this.m_enableLimit && this.m_limitState != e_inactiveLimit)
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
            dX = p2X - p1X;
            dY = p2Y - p1Y;
            tMat = b1.m_xf.R;
            ax1X = tMat.col1.x * this.m_localXAxis1.x + tMat.col2.x * this.m_localXAxis1.y;
            ax1Y = tMat.col1.y * this.m_localXAxis1.x + tMat.col2.y * this.m_localXAxis1.y;
            translation = ax1X * dX + ax1Y * dY;
            limitImpulse = 0;
            if(this.m_limitState == e_equalLimits)
            {
               limitC = b2Math.b2Clamp(translation,-b2Settings.b2_maxLinearCorrection,b2Settings.b2_maxLinearCorrection);
               limitImpulse = -this.m_motorMass * limitC;
               positionError = b2Math.b2Max(positionError,b2Math.b2Abs(angularC));
            }
            else if(this.m_limitState == e_atLowerLimit)
            {
               limitC = translation - this.m_lowerTranslation;
               positionError = b2Math.b2Max(positionError,-limitC);
               limitC = b2Math.b2Clamp(limitC + b2Settings.b2_linearSlop,-b2Settings.b2_maxLinearCorrection,0);
               limitImpulse = -this.m_motorMass * limitC;
               oldLimitImpulse = this.m_limitPositionImpulse;
               this.m_limitPositionImpulse = b2Math.b2Max(this.m_limitPositionImpulse + limitImpulse,0);
               limitImpulse = this.m_limitPositionImpulse - oldLimitImpulse;
            }
            else if(this.m_limitState == e_atUpperLimit)
            {
               limitC = translation - this.m_upperTranslation;
               positionError = b2Math.b2Max(positionError,limitC);
               limitC = b2Math.b2Clamp(limitC - b2Settings.b2_linearSlop,0,b2Settings.b2_maxLinearCorrection);
               limitImpulse = -this.m_motorMass * limitC;
               oldLimitImpulse = this.m_limitPositionImpulse;
               this.m_limitPositionImpulse = b2Math.b2Min(this.m_limitPositionImpulse + limitImpulse,0);
               limitImpulse = this.m_limitPositionImpulse - oldLimitImpulse;
            }
            b1.m_sweep.c.x += invMass1 * limitImpulse * this.m_motorJacobian.linear1.x;
            b1.m_sweep.c.y += invMass1 * limitImpulse * this.m_motorJacobian.linear1.y;
            b1.m_sweep.a += invI1 * limitImpulse * this.m_motorJacobian.angular1;
            b2.m_sweep.c.x += invMass2 * limitImpulse * this.m_motorJacobian.linear2.x;
            b2.m_sweep.c.y += invMass2 * limitImpulse * this.m_motorJacobian.linear2.y;
            b2.m_sweep.a += invI2 * limitImpulse * this.m_motorJacobian.angular2;
            b1.SynchronizeTransform();
            b2.SynchronizeTransform();
         }
         return positionError <= b2Settings.b2_linearSlop && angularError <= b2Settings.b2_angularSlop;
      }
      
      public function SetMotorSpeed(speed:Number) : void
      {
         this.m_motorSpeed = speed;
      }
      
      public function GetJointSpeed() : Number
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
         var p1X:Number = b1.m_sweep.c.x + r1X;
         var p1Y:Number = b1.m_sweep.c.y + r1Y;
         var p2X:Number = b2.m_sweep.c.x + r2X;
         var p2Y:Number = b2.m_sweep.c.y + r2Y;
         var dX:Number = p2X - p1X;
         var dY:Number = p2Y - p1Y;
         var axis:b2Vec2 = b1.GetWorldVector(this.m_localXAxis1);
         var v1:b2Vec2 = b1.m_linearVelocity;
         var v2:b2Vec2 = b2.m_linearVelocity;
         var w1:Number = b1.m_angularVelocity;
         var w2:Number = b2.m_angularVelocity;
         return dX * (-w1 * axis.y) + dY * (w1 * axis.x) + (axis.x * (v2.x + -w2 * r2Y - v1.x - -w1 * r1Y) + axis.y * (v2.y + w2 * r2X - v1.y - w1 * r1X));
      }
      
      override public function InitVelocityConstraints(step:b2TimeStep) : void
      {
         var tMat:b2Mat22 = null;
         var tX:Number = NaN;
         var ax1X:Number = NaN;
         var ax1Y:Number = NaN;
         var dX:Number = NaN;
         var dY:Number = NaN;
         var jointTranslation:Number = NaN;
         var P1X:Number = NaN;
         var P1Y:Number = NaN;
         var P2X:Number = NaN;
         var P2Y:Number = NaN;
         var L1:Number = NaN;
         var L2:Number = NaN;
         var b1:b2Body = m_body1;
         var b2:b2Body = m_body2;
         tMat = b1.m_xf.R;
         var r1X:Number = this.m_localAnchor1.x - b1.m_sweep.localCenter.x;
         var r1Y:Number = this.m_localAnchor1.y - b1.m_sweep.localCenter.y;
         tX = tMat.col1.x * r1X + tMat.col2.x * r1Y;
         r1Y = tMat.col1.y * r1X + tMat.col2.y * r1Y;
         r1X = tX;
         tMat = b2.m_xf.R;
         var r2X:Number = this.m_localAnchor2.x - b2.m_sweep.localCenter.x;
         var r2Y:Number = this.m_localAnchor2.y - b2.m_sweep.localCenter.y;
         tX = tMat.col1.x * r2X + tMat.col2.x * r2Y;
         r2Y = tMat.col1.y * r2X + tMat.col2.y * r2Y;
         r2X = tX;
         var invMass1:Number = b1.m_invMass;
         var invMass2:Number = b2.m_invMass;
         var invI1:Number = b1.m_invI;
         var invI2:Number = b2.m_invI;
         tMat = b1.m_xf.R;
         var ay1X:Number = tMat.col1.x * this.m_localYAxis1.x + tMat.col2.x * this.m_localYAxis1.y;
         var ay1Y:Number = tMat.col1.y * this.m_localYAxis1.x + tMat.col2.y * this.m_localYAxis1.y;
         var eX:Number = b2.m_sweep.c.x + r2X - b1.m_sweep.c.x;
         var eY:Number = b2.m_sweep.c.y + r2Y - b1.m_sweep.c.y;
         this.m_linearJacobian.linear1.x = -ay1X;
         this.m_linearJacobian.linear1.y = -ay1Y;
         this.m_linearJacobian.linear2.x = ay1X;
         this.m_linearJacobian.linear2.y = ay1Y;
         this.m_linearJacobian.angular1 = -(eX * ay1Y - eY * ay1X);
         this.m_linearJacobian.angular2 = r2X * ay1Y - r2Y * ay1X;
         this.m_linearMass = invMass1 + invI1 * this.m_linearJacobian.angular1 * this.m_linearJacobian.angular1 + invMass2 + invI2 * this.m_linearJacobian.angular2 * this.m_linearJacobian.angular2;
         this.m_linearMass = 1 / this.m_linearMass;
         this.m_angularMass = invI1 + invI2;
         if(this.m_angularMass > Number.MIN_VALUE)
         {
            this.m_angularMass = 1 / this.m_angularMass;
         }
         if(this.m_enableLimit || this.m_enableMotor)
         {
            tMat = b1.m_xf.R;
            ax1X = tMat.col1.x * this.m_localXAxis1.x + tMat.col2.x * this.m_localXAxis1.y;
            ax1Y = tMat.col1.y * this.m_localXAxis1.x + tMat.col2.y * this.m_localXAxis1.y;
            this.m_motorJacobian.linear1.x = -ax1X;
            this.m_motorJacobian.linear1.y = -ax1Y;
            this.m_motorJacobian.linear2.x = ax1X;
            this.m_motorJacobian.linear2.y = ax1Y;
            this.m_motorJacobian.angular1 = -(eX * ax1Y - eY * ax1X);
            this.m_motorJacobian.angular2 = r2X * ax1Y - r2Y * ax1X;
            this.m_motorMass = invMass1 + invI1 * this.m_motorJacobian.angular1 * this.m_motorJacobian.angular1 + invMass2 + invI2 * this.m_motorJacobian.angular2 * this.m_motorJacobian.angular2;
            this.m_motorMass = 1 / this.m_motorMass;
            if(this.m_enableLimit)
            {
               dX = eX - r1X;
               dY = eY - r1Y;
               jointTranslation = ax1X * dX + ax1Y * dY;
               if(b2Math.b2Abs(this.m_upperTranslation - this.m_lowerTranslation) < 2 * b2Settings.b2_linearSlop)
               {
                  this.m_limitState = e_equalLimits;
               }
               else if(jointTranslation <= this.m_lowerTranslation)
               {
                  if(this.m_limitState != e_atLowerLimit)
                  {
                     this.m_limitForce = 0;
                  }
                  this.m_limitState = e_atLowerLimit;
               }
               else if(jointTranslation >= this.m_upperTranslation)
               {
                  if(this.m_limitState != e_atUpperLimit)
                  {
                     this.m_limitForce = 0;
                  }
                  this.m_limitState = e_atUpperLimit;
               }
               else
               {
                  this.m_limitState = e_inactiveLimit;
                  this.m_limitForce = 0;
               }
            }
         }
         if(this.m_enableMotor == false)
         {
            this.m_motorForce = 0;
         }
         if(this.m_enableLimit == false)
         {
            this.m_limitForce = 0;
         }
         if(step.warmStarting)
         {
            P1X = step.dt * (this.m_force * this.m_linearJacobian.linear1.x + (this.m_motorForce + this.m_limitForce) * this.m_motorJacobian.linear1.x);
            P1Y = step.dt * (this.m_force * this.m_linearJacobian.linear1.y + (this.m_motorForce + this.m_limitForce) * this.m_motorJacobian.linear1.y);
            P2X = step.dt * (this.m_force * this.m_linearJacobian.linear2.x + (this.m_motorForce + this.m_limitForce) * this.m_motorJacobian.linear2.x);
            P2Y = step.dt * (this.m_force * this.m_linearJacobian.linear2.y + (this.m_motorForce + this.m_limitForce) * this.m_motorJacobian.linear2.y);
            L1 = step.dt * (this.m_force * this.m_linearJacobian.angular1 - this.m_torque + (this.m_motorForce + this.m_limitForce) * this.m_motorJacobian.angular1);
            L2 = step.dt * (this.m_force * this.m_linearJacobian.angular2 + this.m_torque + (this.m_motorForce + this.m_limitForce) * this.m_motorJacobian.angular2);
            b1.m_linearVelocity.x += invMass1 * P1X;
            b1.m_linearVelocity.y += invMass1 * P1Y;
            b1.m_angularVelocity += invI1 * L1;
            b2.m_linearVelocity.x += invMass2 * P2X;
            b2.m_linearVelocity.y += invMass2 * P2Y;
            b2.m_angularVelocity += invI2 * L2;
         }
         else
         {
            this.m_force = 0;
            this.m_torque = 0;
            this.m_limitForce = 0;
            this.m_motorForce = 0;
         }
         this.m_limitPositionImpulse = 0;
      }
      
      public function GetMotorForce() : Number
      {
         return this.m_motorForce;
      }
      
      public function EnableLimit(flag:Boolean) : void
      {
         this.m_enableLimit = flag;
      }
      
      public function SetMaxMotorForce(force:Number) : void
      {
         this.m_maxMotorForce = force;
      }
      
      override public function GetReactionTorque() : Number
      {
         return this.m_torque;
      }
      
      public function IsLimitEnabled() : Boolean
      {
         return this.m_enableLimit;
      }
      
      public function IsMotorEnabled() : Boolean
      {
         return this.m_enableMotor;
      }
      
      public function SetLimits(lower:Number, upper:Number) : void
      {
         this.m_lowerTranslation = lower;
         this.m_upperTranslation = upper;
      }
   }
}
