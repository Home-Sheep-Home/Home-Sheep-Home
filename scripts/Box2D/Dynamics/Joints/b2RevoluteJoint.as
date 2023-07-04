package Box2D.Dynamics.Joints
{
   import Box2D.Common.Math.b2Mat22;
   import Box2D.Common.Math.b2Math;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Common.b2Settings;
   import Box2D.Dynamics.b2Body;
   import Box2D.Dynamics.b2TimeStep;
   
   public class b2RevoluteJoint extends b2Joint
   {
      
      public static var tImpulse:b2Vec2 = new b2Vec2();
       
      
      public var m_limitForce:Number;
      
      public var m_pivotMass:b2Mat22;
      
      public var m_motorForce:Number;
      
      public var m_enableLimit:Boolean;
      
      public var m_limitState:int;
      
      public var m_motorMass:Number;
      
      public var m_localAnchor1:b2Vec2;
      
      public var m_localAnchor2:b2Vec2;
      
      private var K1:b2Mat22;
      
      private var K2:b2Mat22;
      
      private var K3:b2Mat22;
      
      private var K:b2Mat22;
      
      public var m_pivotForce:b2Vec2;
      
      public var m_enableMotor:Boolean;
      
      public var m_referenceAngle:Number;
      
      public var m_limitPositionImpulse:Number;
      
      public var m_motorSpeed:Number;
      
      public var m_upperAngle:Number;
      
      public var m_lowerAngle:Number;
      
      public var m_maxMotorTorque:Number;
      
      public function b2RevoluteJoint(def:b2RevoluteJointDef)
      {
         this.K = new b2Mat22();
         this.K1 = new b2Mat22();
         this.K2 = new b2Mat22();
         this.K3 = new b2Mat22();
         this.m_localAnchor1 = new b2Vec2();
         this.m_localAnchor2 = new b2Vec2();
         this.m_pivotForce = new b2Vec2();
         this.m_pivotMass = new b2Mat22();
         super(def);
         this.m_localAnchor1.SetV(def.localAnchor1);
         this.m_localAnchor2.SetV(def.localAnchor2);
         this.m_referenceAngle = def.referenceAngle;
         this.m_pivotForce.Set(0,0);
         this.m_motorForce = 0;
         this.m_limitForce = 0;
         this.m_limitPositionImpulse = 0;
         this.m_lowerAngle = def.lowerAngle;
         this.m_upperAngle = def.upperAngle;
         this.m_maxMotorTorque = def.maxMotorTorque;
         this.m_motorSpeed = def.motorSpeed;
         this.m_enableLimit = def.enableLimit;
         this.m_enableMotor = def.enableMotor;
      }
      
      override public function SolveVelocityConstraints(step:b2TimeStep) : void
      {
         var tMat:b2Mat22 = null;
         var tX:Number = NaN;
         var oldLimitForce:Number = NaN;
         var PY:Number = NaN;
         var motorCdot:Number = NaN;
         var motorForce:Number = NaN;
         var oldMotorForce:Number = NaN;
         var limitCdot:Number = NaN;
         var limitForce:Number = NaN;
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
         var pivotCdotX:Number = b2.m_linearVelocity.x + -b2.m_angularVelocity * r2Y - b1.m_linearVelocity.x - -b1.m_angularVelocity * r1Y;
         var pivotCdotY:Number = b2.m_linearVelocity.y + b2.m_angularVelocity * r2X - b1.m_linearVelocity.y - b1.m_angularVelocity * r1X;
         var pivotForceX:Number = -step.inv_dt * (this.m_pivotMass.col1.x * pivotCdotX + this.m_pivotMass.col2.x * pivotCdotY);
         var pivotForceY:Number = -step.inv_dt * (this.m_pivotMass.col1.y * pivotCdotX + this.m_pivotMass.col2.y * pivotCdotY);
         this.m_pivotForce.x += pivotForceX;
         this.m_pivotForce.y += pivotForceY;
         var PX:Number = step.dt * pivotForceX;
         PY = step.dt * pivotForceY;
         b1.m_linearVelocity.x -= b1.m_invMass * PX;
         b1.m_linearVelocity.y -= b1.m_invMass * PY;
         b1.m_angularVelocity -= b1.m_invI * (r1X * PY - r1Y * PX);
         b2.m_linearVelocity.x += b2.m_invMass * PX;
         b2.m_linearVelocity.y += b2.m_invMass * PY;
         b2.m_angularVelocity += b2.m_invI * (r2X * PY - r2Y * PX);
         if(this.m_enableMotor && this.m_limitState != e_equalLimits)
         {
            motorCdot = b2.m_angularVelocity - b1.m_angularVelocity - this.m_motorSpeed;
            motorForce = -step.inv_dt * this.m_motorMass * motorCdot;
            oldMotorForce = this.m_motorForce;
            this.m_motorForce = b2Math.b2Clamp(this.m_motorForce + motorForce,-this.m_maxMotorTorque,this.m_maxMotorTorque);
            motorForce = this.m_motorForce - oldMotorForce;
            b1.m_angularVelocity -= b1.m_invI * step.dt * motorForce;
            b2.m_angularVelocity += b2.m_invI * step.dt * motorForce;
         }
         if(this.m_enableLimit && this.m_limitState != e_inactiveLimit)
         {
            limitCdot = b2.m_angularVelocity - b1.m_angularVelocity;
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
            b1.m_angularVelocity -= b1.m_invI * step.dt * limitForce;
            b2.m_angularVelocity += b2.m_invI * step.dt * limitForce;
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
         return this.m_upperAngle;
      }
      
      public function GetLowerLimit() : Number
      {
         return this.m_lowerAngle;
      }
      
      public function EnableMotor(flag:Boolean) : void
      {
         this.m_enableMotor = flag;
      }
      
      public function GetMotorSpeed() : Number
      {
         return this.m_motorSpeed;
      }
      
      override public function GetReactionForce() : b2Vec2
      {
         return this.m_pivotForce;
      }
      
      override public function SolvePositionConstraints() : Boolean
      {
         var oldLimitImpulse:Number = NaN;
         var limitC:Number = NaN;
         var tMat:b2Mat22 = null;
         var angle:Number = NaN;
         var limitImpulse:Number = NaN;
         var b1:b2Body = m_body1;
         var b2:b2Body = m_body2;
         var positionError:Number = 0;
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
         var ptpCX:Number = p2X - p1X;
         var ptpCY:Number = p2Y - p1Y;
         positionError = Math.sqrt(ptpCX * ptpCX + ptpCY * ptpCY);
         var invMass1:Number = b1.m_invMass;
         var invMass2:Number = b2.m_invMass;
         var invI1:Number = b1.m_invI;
         var invI2:Number = b2.m_invI;
         this.K1.col1.x = invMass1 + invMass2;
         this.K1.col2.x = 0;
         this.K1.col1.y = 0;
         this.K1.col2.y = invMass1 + invMass2;
         this.K2.col1.x = invI1 * r1Y * r1Y;
         this.K2.col2.x = -invI1 * r1X * r1Y;
         this.K2.col1.y = -invI1 * r1X * r1Y;
         this.K2.col2.y = invI1 * r1X * r1X;
         this.K3.col1.x = invI2 * r2Y * r2Y;
         this.K3.col2.x = -invI2 * r2X * r2Y;
         this.K3.col1.y = -invI2 * r2X * r2Y;
         this.K3.col2.y = invI2 * r2X * r2X;
         this.K.SetM(this.K1);
         this.K.AddM(this.K2);
         this.K.AddM(this.K3);
         this.K.Solve(tImpulse,-ptpCX,-ptpCY);
         var impulseX:Number = tImpulse.x;
         var impulseY:Number = tImpulse.y;
         b1.m_sweep.c.x -= b1.m_invMass * impulseX;
         b1.m_sweep.c.y -= b1.m_invMass * impulseY;
         b1.m_sweep.a -= b1.m_invI * (r1X * impulseY - r1Y * impulseX);
         b2.m_sweep.c.x += b2.m_invMass * impulseX;
         b2.m_sweep.c.y += b2.m_invMass * impulseY;
         b2.m_sweep.a += b2.m_invI * (r2X * impulseY - r2Y * impulseX);
         b1.SynchronizeTransform();
         b2.SynchronizeTransform();
         var angularError:Number = 0;
         if(this.m_enableLimit && this.m_limitState != e_inactiveLimit)
         {
            angle = b2.m_sweep.a - b1.m_sweep.a - this.m_referenceAngle;
            limitImpulse = 0;
            if(this.m_limitState == e_equalLimits)
            {
               limitC = b2Math.b2Clamp(angle,-b2Settings.b2_maxAngularCorrection,b2Settings.b2_maxAngularCorrection);
               limitImpulse = -this.m_motorMass * limitC;
               angularError = b2Math.b2Abs(limitC);
            }
            else if(this.m_limitState == e_atLowerLimit)
            {
               limitC = angle - this.m_lowerAngle;
               angularError = b2Math.b2Max(0,-limitC);
               limitC = b2Math.b2Clamp(limitC + b2Settings.b2_angularSlop,-b2Settings.b2_maxAngularCorrection,0);
               limitImpulse = -this.m_motorMass * limitC;
               oldLimitImpulse = this.m_limitPositionImpulse;
               this.m_limitPositionImpulse = b2Math.b2Max(this.m_limitPositionImpulse + limitImpulse,0);
               limitImpulse = this.m_limitPositionImpulse - oldLimitImpulse;
            }
            else if(this.m_limitState == e_atUpperLimit)
            {
               limitC = angle - this.m_upperAngle;
               angularError = b2Math.b2Max(0,limitC);
               limitC = b2Math.b2Clamp(limitC - b2Settings.b2_angularSlop,0,b2Settings.b2_maxAngularCorrection);
               limitImpulse = -this.m_motorMass * limitC;
               oldLimitImpulse = this.m_limitPositionImpulse;
               this.m_limitPositionImpulse = b2Math.b2Min(this.m_limitPositionImpulse + limitImpulse,0);
               limitImpulse = this.m_limitPositionImpulse - oldLimitImpulse;
            }
            b1.m_sweep.a -= b1.m_invI * limitImpulse;
            b2.m_sweep.a += b2.m_invI * limitImpulse;
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
         return m_body2.m_angularVelocity - m_body1.m_angularVelocity;
      }
      
      public function SetMaxMotorTorque(torque:Number) : void
      {
         this.m_maxMotorTorque = torque;
      }
      
      public function GetJointAngle() : Number
      {
         return m_body2.m_sweep.a - m_body1.m_sweep.a - this.m_referenceAngle;
      }
      
      public function GetMotorTorque() : Number
      {
         return this.m_motorForce;
      }
      
      override public function InitVelocityConstraints(step:b2TimeStep) : void
      {
         var b1:b2Body = null;
         var b2:b2Body = null;
         var tMat:b2Mat22 = null;
         var tX:Number = NaN;
         var r1Y:Number = NaN;
         var jointAngle:Number = NaN;
         b1 = m_body1;
         b2 = m_body2;
         tMat = b1.m_xf.R;
         var r1X:Number = this.m_localAnchor1.x - b1.m_sweep.localCenter.x;
         r1Y = this.m_localAnchor1.y - b1.m_sweep.localCenter.y;
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
         this.K1.col1.x = invMass1 + invMass2;
         this.K1.col2.x = 0;
         this.K1.col1.y = 0;
         this.K1.col2.y = invMass1 + invMass2;
         this.K2.col1.x = invI1 * r1Y * r1Y;
         this.K2.col2.x = -invI1 * r1X * r1Y;
         this.K2.col1.y = -invI1 * r1X * r1Y;
         this.K2.col2.y = invI1 * r1X * r1X;
         this.K3.col1.x = invI2 * r2Y * r2Y;
         this.K3.col2.x = -invI2 * r2X * r2Y;
         this.K3.col1.y = -invI2 * r2X * r2Y;
         this.K3.col2.y = invI2 * r2X * r2X;
         this.K.SetM(this.K1);
         this.K.AddM(this.K2);
         this.K.AddM(this.K3);
         this.K.Invert(this.m_pivotMass);
         this.m_motorMass = 1 / (invI1 + invI2);
         if(this.m_enableMotor == false)
         {
            this.m_motorForce = 0;
         }
         if(this.m_enableLimit)
         {
            jointAngle = b2.m_sweep.a - b1.m_sweep.a - this.m_referenceAngle;
            if(b2Math.b2Abs(this.m_upperAngle - this.m_lowerAngle) < 2 * b2Settings.b2_angularSlop)
            {
               this.m_limitState = e_equalLimits;
            }
            else if(jointAngle <= this.m_lowerAngle)
            {
               if(this.m_limitState != e_atLowerLimit)
               {
                  this.m_limitForce = 0;
               }
               this.m_limitState = e_atLowerLimit;
            }
            else if(jointAngle >= this.m_upperAngle)
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
         else
         {
            this.m_limitForce = 0;
         }
         if(step.warmStarting)
         {
            b1.m_linearVelocity.x -= step.dt * invMass1 * this.m_pivotForce.x;
            b1.m_linearVelocity.y -= step.dt * invMass1 * this.m_pivotForce.y;
            b1.m_angularVelocity -= step.dt * invI1 * (r1X * this.m_pivotForce.y - r1Y * this.m_pivotForce.x + this.m_motorForce + this.m_limitForce);
            b2.m_linearVelocity.x += step.dt * invMass2 * this.m_pivotForce.x;
            b2.m_linearVelocity.y += step.dt * invMass2 * this.m_pivotForce.y;
            b2.m_angularVelocity += step.dt * invI2 * (r2X * this.m_pivotForce.y - r2Y * this.m_pivotForce.x + this.m_motorForce + this.m_limitForce);
         }
         else
         {
            this.m_pivotForce.SetZero();
            this.m_motorForce = 0;
            this.m_limitForce = 0;
         }
         this.m_limitPositionImpulse = 0;
      }
      
      public function EnableLimit(flag:Boolean) : void
      {
         this.m_enableLimit = flag;
      }
      
      override public function GetReactionTorque() : Number
      {
         return this.m_limitForce;
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
         this.m_lowerAngle = lower;
         this.m_upperAngle = upper;
      }
   }
}
