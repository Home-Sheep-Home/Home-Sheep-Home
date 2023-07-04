package Box2D.Dynamics
{
   import Box2D.Collision.*;
   import Box2D.Common.*;
   import Box2D.Common.Math.*;
   import Box2D.Dynamics.Contacts.*;
   import Box2D.Dynamics.Joints.*;
   
   public class b2Island
   {
      
      private static var s_reportCR:b2ContactResult = new b2ContactResult();
       
      
      public var m_listener:Box2D.Dynamics.b2ContactListener;
      
      public var m_positionIterationCount:int;
      
      public var m_bodyCapacity:int;
      
      public var m_bodies:Array;
      
      public var m_joints:Array;
      
      public var m_jointCapacity:int;
      
      public var m_contactCount:int;
      
      public var m_contacts:Array;
      
      public var m_contactCapacity:int;
      
      public var m_jointCount:int;
      
      public var m_allocator;
      
      public var m_bodyCount:int;
      
      public function b2Island(bodyCapacity:int, contactCapacity:int, jointCapacity:int, allocator:*, listener:Box2D.Dynamics.b2ContactListener)
      {
         var i:int = 0;
         super();
         this.m_bodyCapacity = bodyCapacity;
         this.m_contactCapacity = contactCapacity;
         this.m_jointCapacity = jointCapacity;
         this.m_bodyCount = 0;
         this.m_contactCount = 0;
         this.m_jointCount = 0;
         this.m_allocator = allocator;
         this.m_listener = listener;
         this.m_bodies = new Array(bodyCapacity);
         for(i = 0; i < bodyCapacity; i++)
         {
            this.m_bodies[i] = null;
         }
         this.m_contacts = new Array(contactCapacity);
         for(i = 0; i < contactCapacity; i++)
         {
            this.m_contacts[i] = null;
         }
         this.m_joints = new Array(jointCapacity);
         for(i = 0; i < jointCapacity; i++)
         {
            this.m_joints[i] = null;
         }
         this.m_positionIterationCount = 0;
      }
      
      public function AddBody(body:b2Body) : void
      {
         var _loc2_:* = this.m_bodyCount++;
         this.m_bodies[_loc2_] = body;
      }
      
      public function AddJoint(joint:b2Joint) : void
      {
         var _loc2_:* = this.m_jointCount++;
         this.m_joints[_loc2_] = joint;
      }
      
      public function Report(constraints:Array) : void
      {
         var tMat:b2Mat22 = null;
         var tVec:b2Vec2 = null;
         var c:b2Contact = null;
         var cc:b2ContactConstraint = null;
         var cr:b2ContactResult = null;
         var b1:b2Body = null;
         var manifoldCount:int = 0;
         var manifolds:Array = null;
         var j:int = 0;
         var manifold:b2Manifold = null;
         var k:int = 0;
         var point:b2ManifoldPoint = null;
         var ccp:b2ContactConstraintPoint = null;
         if(this.m_listener == null)
         {
            return;
         }
         for(var i:int = 0; i < this.m_contactCount; i++)
         {
            c = this.m_contacts[i];
            cc = constraints[i];
            cr = s_reportCR;
            cr.shape1 = c.m_shape1;
            cr.shape2 = c.m_shape2;
            b1 = cr.shape1.m_body;
            manifoldCount = c.m_manifoldCount;
            manifolds = c.GetManifolds();
            for(j = 0; j < manifoldCount; j++)
            {
               manifold = manifolds[j];
               cr.normal.SetV(manifold.normal);
               for(k = 0; k < manifold.pointCount; k++)
               {
                  point = manifold.points[k];
                  ccp = cc.points[k];
                  cr.position = b1.GetWorldPoint(point.localPoint1);
                  cr.normalImpulse = ccp.normalImpulse;
                  cr.tangentImpulse = ccp.tangentImpulse;
                  cr.id.key = point.id.key;
                  this.m_listener.Result(cr);
               }
            }
         }
      }
      
      public function AddContact(contact:b2Contact) : void
      {
         var _loc2_:* = this.m_contactCount++;
         this.m_contacts[_loc2_] = contact;
      }
      
      public function Solve(step:b2TimeStep, gravity:b2Vec2, correctPositions:Boolean, allowSleep:Boolean) : void
      {
         var i:int = 0;
         var b:b2Body = null;
         var joint:b2Joint = null;
         var j:int = 0;
         var contactsOkay:Boolean = false;
         var jointsOkay:Boolean = false;
         var jointOkay:Boolean = false;
         var minSleepTime:Number = NaN;
         var linTolSqr:Number = NaN;
         var angTolSqr:Number = NaN;
         for(i = 0; i < this.m_bodyCount; i++)
         {
            b = this.m_bodies[i];
            if(!b.IsStatic())
            {
               b.m_linearVelocity.x += step.dt * (gravity.x + b.m_invMass * b.m_force.x);
               b.m_linearVelocity.y += step.dt * (gravity.y + b.m_invMass * b.m_force.y);
               b.m_angularVelocity += step.dt * b.m_invI * b.m_torque;
               b.m_force.SetZero();
               b.m_torque = 0;
               b.m_linearVelocity.Multiply(b2Math.b2Clamp(1 - step.dt * b.m_linearDamping,0,1));
               b.m_angularVelocity *= b2Math.b2Clamp(1 - step.dt * b.m_angularDamping,0,1);
               if(b.m_linearVelocity.LengthSquared() > b2Settings.b2_maxLinearVelocitySquared)
               {
                  b.m_linearVelocity.Normalize();
                  b.m_linearVelocity.x *= b2Settings.b2_maxLinearVelocity;
                  b.m_linearVelocity.y *= b2Settings.b2_maxLinearVelocity;
               }
               if(b.m_angularVelocity * b.m_angularVelocity > b2Settings.b2_maxAngularVelocitySquared)
               {
                  if(b.m_angularVelocity < 0)
                  {
                     b.m_angularVelocity = -b2Settings.b2_maxAngularVelocity;
                  }
                  else
                  {
                     b.m_angularVelocity = b2Settings.b2_maxAngularVelocity;
                  }
               }
            }
         }
         var contactSolver:b2ContactSolver = new b2ContactSolver(step,this.m_contacts,this.m_contactCount,this.m_allocator);
         contactSolver.InitVelocityConstraints(step);
         for(i = 0; i < this.m_jointCount; i++)
         {
            joint = this.m_joints[i];
            joint.InitVelocityConstraints(step);
         }
         for(i = 0; i < step.maxIterations; i++)
         {
            contactSolver.SolveVelocityConstraints();
            for(j = 0; j < this.m_jointCount; j++)
            {
               joint = this.m_joints[j];
               joint.SolveVelocityConstraints(step);
            }
         }
         contactSolver.FinalizeVelocityConstraints();
         for(i = 0; i < this.m_bodyCount; i++)
         {
            b = this.m_bodies[i];
            if(!b.IsStatic())
            {
               b.m_sweep.c0.SetV(b.m_sweep.c);
               b.m_sweep.a0 = b.m_sweep.a;
               b.m_sweep.c.x += step.dt * b.m_linearVelocity.x;
               b.m_sweep.c.y += step.dt * b.m_linearVelocity.y;
               b.m_sweep.a += step.dt * b.m_angularVelocity;
               b.SynchronizeTransform();
            }
         }
         if(correctPositions)
         {
            for(i = 0; i < this.m_jointCount; i++)
            {
               joint = this.m_joints[i];
               joint.InitPositionConstraints();
            }
            for(this.m_positionIterationCount = 0; this.m_positionIterationCount < step.maxIterations; ++this.m_positionIterationCount)
            {
               contactsOkay = contactSolver.SolvePositionConstraints(b2Settings.b2_contactBaumgarte);
               jointsOkay = true;
               for(i = 0; i < this.m_jointCount; i++)
               {
                  joint = this.m_joints[i];
                  jointOkay = joint.SolvePositionConstraints();
                  jointsOkay &&= jointOkay;
               }
               if(contactsOkay && jointsOkay)
               {
                  break;
               }
            }
         }
         this.Report(contactSolver.m_constraints);
         if(allowSleep)
         {
            minSleepTime = Number.MAX_VALUE;
            linTolSqr = b2Settings.b2_linearSleepTolerance * b2Settings.b2_linearSleepTolerance;
            angTolSqr = b2Settings.b2_angularSleepTolerance * b2Settings.b2_angularSleepTolerance;
            for(i = 0; i < this.m_bodyCount; i++)
            {
               b = this.m_bodies[i];
               if(b.m_invMass != 0)
               {
                  if((b.m_flags & b2Body.e_allowSleepFlag) == 0)
                  {
                     b.m_sleepTime = 0;
                     minSleepTime = 0;
                  }
                  if((b.m_flags & b2Body.e_allowSleepFlag) == 0 || b.m_angularVelocity * b.m_angularVelocity > angTolSqr || b2Math.b2Dot(b.m_linearVelocity,b.m_linearVelocity) > linTolSqr)
                  {
                     b.m_sleepTime = 0;
                     minSleepTime = 0;
                  }
                  else
                  {
                     b.m_sleepTime += step.dt;
                     minSleepTime = b2Math.b2Min(minSleepTime,b.m_sleepTime);
                  }
               }
            }
            if(minSleepTime >= b2Settings.b2_timeToSleep)
            {
               for(i = 0; i < this.m_bodyCount; i++)
               {
                  b = this.m_bodies[i];
                  b.m_flags |= b2Body.e_sleepFlag;
                  b.m_linearVelocity.SetZero();
                  b.m_angularVelocity = 0;
               }
            }
         }
      }
      
      public function Clear() : void
      {
         this.m_bodyCount = 0;
         this.m_contactCount = 0;
         this.m_jointCount = 0;
      }
      
      public function SolveTOI(subStep:b2TimeStep) : void
      {
         var i:int = 0;
         var b:b2Body = null;
         var contactsOkay:Boolean = false;
         var contactSolver:b2ContactSolver = new b2ContactSolver(subStep,this.m_contacts,this.m_contactCount,this.m_allocator);
         for(i = 0; i < subStep.maxIterations; i++)
         {
            contactSolver.SolveVelocityConstraints();
         }
         for(i = 0; i < this.m_bodyCount; i++)
         {
            b = this.m_bodies[i];
            if(!b.IsStatic())
            {
               b.m_sweep.c0.SetV(b.m_sweep.c);
               b.m_sweep.a0 = b.m_sweep.a;
               b.m_sweep.c.x += subStep.dt * b.m_linearVelocity.x;
               b.m_sweep.c.y += subStep.dt * b.m_linearVelocity.y;
               b.m_sweep.a += subStep.dt * b.m_angularVelocity;
               b.SynchronizeTransform();
            }
         }
         var k_toiBaumgarte:Number = 0.75;
         for(i = 0; i < subStep.maxIterations; i++)
         {
            contactsOkay = contactSolver.SolvePositionConstraints(k_toiBaumgarte);
            if(contactsOkay)
            {
               break;
            }
         }
         this.Report(contactSolver.m_constraints);
      }
   }
}
