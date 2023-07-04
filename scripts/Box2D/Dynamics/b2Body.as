package Box2D.Dynamics
{
   import Box2D.Collision.Shapes.b2MassData;
   import Box2D.Collision.Shapes.b2Shape;
   import Box2D.Collision.Shapes.b2ShapeDef;
   import Box2D.Common.Math.b2Mat22;
   import Box2D.Common.Math.b2Math;
   import Box2D.Common.Math.b2Sweep;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Common.Math.b2XForm;
   import Box2D.Dynamics.Contacts.b2ContactEdge;
   import Box2D.Dynamics.Joints.b2JointEdge;
   
   public class b2Body
   {
      
      public static var e_fixedRotationFlag:uint = 64;
      
      public static var e_frozenFlag:uint = 2;
      
      public static var e_maxTypes:uint = 3;
      
      public static var e_sleepFlag:uint = 8;
      
      private static var s_massData:b2MassData = new b2MassData();
      
      public static var e_bulletFlag:uint = 32;
      
      public static var e_staticType:uint = 1;
      
      public static var e_islandFlag:uint = 4;
      
      public static var e_allowSleepFlag:uint = 16;
      
      private static var s_xf1:b2XForm = new b2XForm();
      
      public static var e_dynamicType:uint = 2;
       
      
      public var m_next:Box2D.Dynamics.b2Body;
      
      public var m_xf:b2XForm;
      
      public var m_contactList:b2ContactEdge;
      
      public var m_angularVelocity:Number;
      
      public var m_shapeList:b2Shape;
      
      public var m_force:b2Vec2;
      
      public var m_mass:Number;
      
      public var m_sweep:b2Sweep;
      
      public var m_torque:Number;
      
      public var m_userData;
      
      public var m_flags:uint;
      
      public var m_world:Box2D.Dynamics.b2World;
      
      public var m_prev:Box2D.Dynamics.b2Body;
      
      public var m_invMass:Number;
      
      public var m_type:int;
      
      public var m_linearDamping:Number;
      
      public var m_shapeCount:int;
      
      public var m_angularDamping:Number;
      
      public var m_invI:Number;
      
      public var m_linearVelocity:b2Vec2;
      
      public var m_sleepTime:Number;
      
      public var m_jointList:b2JointEdge;
      
      public var m_I:Number;
      
      public function b2Body(bd:b2BodyDef, world:Box2D.Dynamics.b2World)
      {
         this.m_xf = new b2XForm();
         this.m_sweep = new b2Sweep();
         this.m_linearVelocity = new b2Vec2();
         this.m_force = new b2Vec2();
         super();
         this.m_flags = 0;
         if(bd.isBullet)
         {
            this.m_flags |= e_bulletFlag;
         }
         if(bd.fixedRotation)
         {
            this.m_flags |= e_fixedRotationFlag;
         }
         if(bd.allowSleep)
         {
            this.m_flags |= e_allowSleepFlag;
         }
         if(bd.isSleeping)
         {
            this.m_flags |= e_sleepFlag;
         }
         this.m_world = world;
         this.m_xf.position.SetV(bd.position);
         this.m_xf.R.Set(bd.angle);
         this.m_sweep.localCenter.SetV(bd.massData.center);
         this.m_sweep.t0 = 1;
         this.m_sweep.a0 = this.m_sweep.a = bd.angle;
         var tMat:b2Mat22 = this.m_xf.R;
         var tVec:b2Vec2 = this.m_sweep.localCenter;
         this.m_sweep.c.x = tMat.col1.x * tVec.x + tMat.col2.x * tVec.y;
         this.m_sweep.c.y = tMat.col1.y * tVec.x + tMat.col2.y * tVec.y;
         this.m_sweep.c.x += this.m_xf.position.x;
         this.m_sweep.c.y += this.m_xf.position.y;
         this.m_sweep.c0.SetV(this.m_sweep.c);
         this.m_jointList = null;
         this.m_contactList = null;
         this.m_prev = null;
         this.m_next = null;
         this.m_linearDamping = bd.linearDamping;
         this.m_angularDamping = bd.angularDamping;
         this.m_force.Set(0,0);
         this.m_torque = 0;
         this.m_linearVelocity.SetZero();
         this.m_angularVelocity = 0;
         this.m_sleepTime = 0;
         this.m_invMass = 0;
         this.m_I = 0;
         this.m_invI = 0;
         this.m_mass = bd.massData.mass;
         if(this.m_mass > 0)
         {
            this.m_invMass = 1 / this.m_mass;
         }
         if((this.m_flags & Box2D.Dynamics.b2Body.e_fixedRotationFlag) == 0)
         {
            this.m_I = bd.massData.I;
         }
         if(this.m_I > 0)
         {
            this.m_invI = 1 / this.m_I;
         }
         if(this.m_invMass == 0 && this.m_invI == 0)
         {
            this.m_type = e_staticType;
         }
         else
         {
            this.m_type = e_dynamicType;
         }
         this.m_userData = bd.userData;
         this.m_shapeList = null;
         this.m_shapeCount = 0;
      }
      
      public function GetLinearVelocityFromWorldPoint(worldPoint:b2Vec2) : b2Vec2
      {
         return new b2Vec2(this.m_linearVelocity.x + this.m_angularVelocity * (worldPoint.y - this.m_sweep.c.y),this.m_linearVelocity.x - this.m_angularVelocity * (worldPoint.x - this.m_sweep.c.x));
      }
      
      public function SetLinearVelocity(v:b2Vec2) : void
      {
         this.m_linearVelocity.SetV(v);
      }
      
      public function WakeUp() : void
      {
         this.m_flags &= ~e_sleepFlag;
         this.m_sleepTime = 0;
      }
      
      public function GetLocalCenter() : b2Vec2
      {
         return this.m_sweep.localCenter;
      }
      
      public function ApplyTorque(torque:Number) : void
      {
         if(this.IsSleeping())
         {
            this.WakeUp();
         }
         this.m_torque += torque;
      }
      
      public function IsFrozen() : Boolean
      {
         return (this.m_flags & e_frozenFlag) == e_frozenFlag;
      }
      
      public function IsDynamic() : Boolean
      {
         return this.m_type == e_dynamicType;
      }
      
      public function GetLinearVelocity() : b2Vec2
      {
         return this.m_linearVelocity;
      }
      
      public function SynchronizeTransform() : void
      {
         this.m_xf.R.Set(this.m_sweep.a);
         var tMat:b2Mat22 = this.m_xf.R;
         var tVec:b2Vec2 = this.m_sweep.localCenter;
         this.m_xf.position.x = this.m_sweep.c.x - (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y);
         this.m_xf.position.y = this.m_sweep.c.y - (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y);
      }
      
      public function GetInertia() : Number
      {
         return this.m_I;
      }
      
      public function IsSleeping() : Boolean
      {
         return (this.m_flags & e_sleepFlag) == e_sleepFlag;
      }
      
      public function SetMassFromShapes() : void
      {
         var s:b2Shape = null;
         if(this.m_world.m_lock == true)
         {
            return;
         }
         this.m_mass = 0;
         this.m_invMass = 0;
         this.m_I = 0;
         this.m_invI = 0;
         var centerX:Number = 0;
         var centerY:Number = 0;
         var massData:b2MassData = s_massData;
         s = this.m_shapeList;
         while(s)
         {
            s.ComputeMass(massData);
            this.m_mass += massData.mass;
            centerX += massData.mass * massData.center.x;
            centerY += massData.mass * massData.center.y;
            this.m_I += massData.I;
            s = s.m_next;
         }
         if(this.m_mass > 0)
         {
            this.m_invMass = 1 / this.m_mass;
            centerX *= this.m_invMass;
            centerY *= this.m_invMass;
         }
         if(this.m_I > 0 && (this.m_flags & e_fixedRotationFlag) == 0)
         {
            this.m_I -= this.m_mass * (centerX * centerX + centerY * centerY);
            this.m_invI = 1 / this.m_I;
         }
         else
         {
            this.m_I = 0;
            this.m_invI = 0;
         }
         this.m_sweep.localCenter.Set(centerX,centerY);
         var tMat:b2Mat22 = this.m_xf.R;
         var tVec:b2Vec2 = this.m_sweep.localCenter;
         this.m_sweep.c.x = tMat.col1.x * tVec.x + tMat.col2.x * tVec.y;
         this.m_sweep.c.y = tMat.col1.y * tVec.x + tMat.col2.y * tVec.y;
         this.m_sweep.c.x += this.m_xf.position.x;
         this.m_sweep.c.y += this.m_xf.position.y;
         this.m_sweep.c0.SetV(this.m_sweep.c);
         s = this.m_shapeList;
         while(s)
         {
            s.UpdateSweepRadius(this.m_sweep.localCenter);
            s = s.m_next;
         }
         var oldType:int = this.m_type;
         if(this.m_invMass == 0 && this.m_invI == 0)
         {
            this.m_type = e_staticType;
         }
         else
         {
            this.m_type = e_dynamicType;
         }
         if(oldType != this.m_type)
         {
            s = this.m_shapeList;
            while(s)
            {
               s.RefilterProxy(this.m_world.m_broadPhase,this.m_xf);
               s = s.m_next;
            }
         }
      }
      
      public function PutToSleep() : void
      {
         this.m_flags |= e_sleepFlag;
         this.m_sleepTime = 0;
         this.m_linearVelocity.SetZero();
         this.m_angularVelocity = 0;
         this.m_force.SetZero();
         this.m_torque = 0;
      }
      
      public function GetJointList() : b2JointEdge
      {
         return this.m_jointList;
      }
      
      public function SetXForm(position:b2Vec2, angle:Number) : Boolean
      {
         var s:b2Shape = null;
         var inRange:Boolean = false;
         if(this.m_world.m_lock == true)
         {
            return true;
         }
         if(this.IsFrozen())
         {
            return false;
         }
         this.m_xf.R.Set(angle);
         this.m_xf.position.SetV(position);
         var tMat:b2Mat22 = this.m_xf.R;
         var tVec:b2Vec2 = this.m_sweep.localCenter;
         this.m_sweep.c.x = tMat.col1.x * tVec.x + tMat.col2.x * tVec.y;
         this.m_sweep.c.y = tMat.col1.y * tVec.x + tMat.col2.y * tVec.y;
         this.m_sweep.c.x += this.m_xf.position.x;
         this.m_sweep.c.y += this.m_xf.position.y;
         this.m_sweep.c0.SetV(this.m_sweep.c);
         this.m_sweep.a0 = this.m_sweep.a = angle;
         var freeze:Boolean = false;
         s = this.m_shapeList;
         while(s)
         {
            inRange = s.Synchronize(this.m_world.m_broadPhase,this.m_xf,this.m_xf);
            if(inRange == false)
            {
               freeze = true;
               break;
            }
            s = s.m_next;
         }
         if(freeze == true)
         {
            this.m_flags |= e_frozenFlag;
            this.m_linearVelocity.SetZero();
            this.m_angularVelocity = 0;
            s = this.m_shapeList;
            while(s)
            {
               s.DestroyProxy(this.m_world.m_broadPhase);
               s = s.m_next;
            }
            return false;
         }
         this.m_world.m_broadPhase.Commit();
         return true;
      }
      
      public function GetLocalPoint(worldPoint:b2Vec2) : b2Vec2
      {
         return b2Math.b2MulXT(this.m_xf,worldPoint);
      }
      
      public function ApplyForce(force:b2Vec2, point:b2Vec2) : void
      {
         if(this.IsSleeping())
         {
            this.WakeUp();
         }
         this.m_force.x += force.x;
         this.m_force.y += force.y;
         this.m_torque += (point.x - this.m_sweep.c.x) * force.y - (point.y - this.m_sweep.c.y) * force.x;
      }
      
      public function SynchronizeShapes() : Boolean
      {
         var s:b2Shape = null;
         var xf1:b2XForm = s_xf1;
         xf1.R.Set(this.m_sweep.a0);
         var tMat:b2Mat22 = xf1.R;
         var tVec:b2Vec2 = this.m_sweep.localCenter;
         xf1.position.x = this.m_sweep.c0.x - (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y);
         xf1.position.y = this.m_sweep.c0.y - (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y);
         var inRange:Boolean = true;
         s = this.m_shapeList;
         while(s)
         {
            inRange = s.Synchronize(this.m_world.m_broadPhase,xf1,this.m_xf);
            if(inRange == false)
            {
               break;
            }
            s = s.m_next;
         }
         if(inRange == false)
         {
            this.m_flags |= e_frozenFlag;
            this.m_linearVelocity.SetZero();
            this.m_angularVelocity = 0;
            s = this.m_shapeList;
            while(s)
            {
               s.DestroyProxy(this.m_world.m_broadPhase);
               s = s.m_next;
            }
            return false;
         }
         return true;
      }
      
      public function GetAngle() : Number
      {
         return this.m_sweep.a;
      }
      
      public function GetXForm() : b2XForm
      {
         return this.m_xf;
      }
      
      public function GetLinearVelocityFromLocalPoint(localPoint:b2Vec2) : b2Vec2
      {
         var A:b2Mat22 = this.m_xf.R;
         var worldPoint:b2Vec2 = new b2Vec2(A.col1.x * localPoint.x + A.col2.x * localPoint.y,A.col1.y * localPoint.x + A.col2.y * localPoint.y);
         worldPoint.x += this.m_xf.position.x;
         worldPoint.y += this.m_xf.position.y;
         return new b2Vec2(this.m_linearVelocity.x + this.m_angularVelocity * (worldPoint.y - this.m_sweep.c.y),this.m_linearVelocity.x - this.m_angularVelocity * (worldPoint.x - this.m_sweep.c.x));
      }
      
      public function GetNext() : Box2D.Dynamics.b2Body
      {
         return this.m_next;
      }
      
      public function GetMass() : Number
      {
         return this.m_mass;
      }
      
      public function ApplyImpulse(impulse:b2Vec2, point:b2Vec2) : void
      {
         if(this.IsSleeping())
         {
            this.WakeUp();
         }
         this.m_linearVelocity.x += this.m_invMass * impulse.x;
         this.m_linearVelocity.y += this.m_invMass * impulse.y;
         this.m_angularVelocity += this.m_invI * ((point.x - this.m_sweep.c.x) * impulse.y - (point.y - this.m_sweep.c.y) * impulse.x);
      }
      
      public function GetAngularVelocity() : Number
      {
         return this.m_angularVelocity;
      }
      
      public function SetAngularVelocity(omega:Number) : void
      {
         this.m_angularVelocity = omega;
      }
      
      public function SetMass(massData:b2MassData) : void
      {
         var s:b2Shape = null;
         if(this.m_world.m_lock == true)
         {
            return;
         }
         this.m_invMass = 0;
         this.m_I = 0;
         this.m_invI = 0;
         this.m_mass = massData.mass;
         if(this.m_mass > 0)
         {
            this.m_invMass = 1 / this.m_mass;
         }
         if((this.m_flags & Box2D.Dynamics.b2Body.e_fixedRotationFlag) == 0)
         {
            this.m_I = massData.I;
         }
         if(this.m_I > 0)
         {
            this.m_invI = 1 / this.m_I;
         }
         this.m_sweep.localCenter.SetV(massData.center);
         var tMat:b2Mat22 = this.m_xf.R;
         var tVec:b2Vec2 = this.m_sweep.localCenter;
         this.m_sweep.c.x = tMat.col1.x * tVec.x + tMat.col2.x * tVec.y;
         this.m_sweep.c.y = tMat.col1.y * tVec.x + tMat.col2.y * tVec.y;
         this.m_sweep.c.x += this.m_xf.position.x;
         this.m_sweep.c.y += this.m_xf.position.y;
         this.m_sweep.c0.SetV(this.m_sweep.c);
         s = this.m_shapeList;
         while(s)
         {
            s.UpdateSweepRadius(this.m_sweep.localCenter);
            s = s.m_next;
         }
         var oldType:int = this.m_type;
         if(this.m_invMass == 0 && this.m_invI == 0)
         {
            this.m_type = e_staticType;
         }
         else
         {
            this.m_type = e_dynamicType;
         }
         if(oldType != this.m_type)
         {
            s = this.m_shapeList;
            while(s)
            {
               s.RefilterProxy(this.m_world.m_broadPhase,this.m_xf);
               s = s.m_next;
            }
         }
      }
      
      public function IsStatic() : Boolean
      {
         return this.m_type == e_staticType;
      }
      
      public function GetWorldVector(localVector:b2Vec2) : b2Vec2
      {
         return b2Math.b2MulMV(this.m_xf.R,localVector);
      }
      
      public function GetShapeList() : b2Shape
      {
         return this.m_shapeList;
      }
      
      public function Advance(t:Number) : void
      {
         this.m_sweep.Advance(t);
         this.m_sweep.c.SetV(this.m_sweep.c0);
         this.m_sweep.a = this.m_sweep.a0;
         this.SynchronizeTransform();
      }
      
      public function SetBullet(flag:Boolean) : void
      {
         if(flag)
         {
            this.m_flags |= e_bulletFlag;
         }
         else
         {
            this.m_flags &= ~e_bulletFlag;
         }
      }
      
      public function CreateShape(def:b2ShapeDef) : b2Shape
      {
         var s:b2Shape = null;
         if(this.m_world.m_lock == true)
         {
            return null;
         }
         s = b2Shape.Create(def,this.m_world.m_blockAllocator);
         s.m_next = this.m_shapeList;
         this.m_shapeList = s;
         ++this.m_shapeCount;
         s.m_body = this;
         s.CreateProxy(this.m_world.m_broadPhase,this.m_xf);
         s.UpdateSweepRadius(this.m_sweep.localCenter);
         return s;
      }
      
      public function IsConnected(other:Box2D.Dynamics.b2Body) : Boolean
      {
         var jn:b2JointEdge = this.m_jointList;
         while(jn)
         {
            if(jn.other == other)
            {
               return jn.joint.m_collideConnected == false;
            }
            jn = jn.next;
         }
         return false;
      }
      
      public function DestroyShape(s:b2Shape) : void
      {
         if(this.m_world.m_lock == true)
         {
            return;
         }
         s.DestroyProxy(this.m_world.m_broadPhase);
         var node:b2Shape = this.m_shapeList;
         var ppS:b2Shape = null;
         var found:Boolean = false;
         while(node != null)
         {
            if(node == s)
            {
               if(ppS)
               {
                  ppS.m_next = s.m_next;
               }
               else
               {
                  this.m_shapeList = s.m_next;
               }
               found = true;
               break;
            }
            ppS = node;
            node = node.m_next;
         }
         s.m_body = null;
         s.m_next = null;
         --this.m_shapeCount;
         b2Shape.Destroy(s,this.m_world.m_blockAllocator);
      }
      
      public function GetUserData() : *
      {
         return this.m_userData;
      }
      
      public function IsBullet() : Boolean
      {
         return (this.m_flags & e_bulletFlag) == e_bulletFlag;
      }
      
      public function GetWorldCenter() : b2Vec2
      {
         return this.m_sweep.c;
      }
      
      public function AllowSleeping(flag:Boolean) : void
      {
         if(flag)
         {
            this.m_flags |= e_allowSleepFlag;
         }
         else
         {
            this.m_flags &= ~e_allowSleepFlag;
            this.WakeUp();
         }
      }
      
      public function SetUserData(data:*) : void
      {
         this.m_userData = data;
      }
      
      public function GetLocalVector(worldVector:b2Vec2) : b2Vec2
      {
         return b2Math.b2MulTMV(this.m_xf.R,worldVector);
      }
      
      public function GetWorldPoint(localPoint:b2Vec2) : b2Vec2
      {
         var A:b2Mat22 = this.m_xf.R;
         var u:b2Vec2 = new b2Vec2(A.col1.x * localPoint.x + A.col2.x * localPoint.y,A.col1.y * localPoint.x + A.col2.y * localPoint.y);
         u.x += this.m_xf.position.x;
         u.y += this.m_xf.position.y;
         return u;
      }
      
      public function GetWorld() : Box2D.Dynamics.b2World
      {
         return this.m_world;
      }
      
      public function GetPosition() : b2Vec2
      {
         return this.m_xf.position;
      }
   }
}
