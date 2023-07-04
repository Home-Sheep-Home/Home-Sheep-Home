package Box2D.Dynamics.Contacts
{
   import Box2D.Collision.*;
   import Box2D.Common.*;
   import Box2D.Common.Math.*;
   import Box2D.Dynamics.*;
   
   public class b2ContactSolver
   {
       
      
      public var m_constraintCount:int;
      
      public var m_constraints:Array;
      
      public var m_allocator;
      
      public var m_step:b2TimeStep;
      
      public function b2ContactSolver(step:b2TimeStep, contacts:Array, contactCount:int, allocator:*)
      {
         var contact:b2Contact = null;
         var i:int = 0;
         var tVec:b2Vec2 = null;
         var tMat:b2Mat22 = null;
         var b1:b2Body = null;
         var b2:b2Body = null;
         var manifoldCount:int = 0;
         var manifolds:Array = null;
         var friction:Number = NaN;
         var restitution:Number = NaN;
         var v1X:Number = NaN;
         var v1Y:Number = NaN;
         var v2X:Number = NaN;
         var v2Y:Number = NaN;
         var w1:Number = NaN;
         var w2:Number = NaN;
         var j:int = 0;
         var manifold:b2Manifold = null;
         var normalX:Number = NaN;
         var normalY:Number = NaN;
         var c:b2ContactConstraint = null;
         var k:uint = 0;
         var cp:b2ManifoldPoint = null;
         var ccp:b2ContactConstraintPoint = null;
         var tX:Number = NaN;
         var tY:Number = NaN;
         var r1X:Number = NaN;
         var r1Y:Number = NaN;
         var r2X:Number = NaN;
         var r2Y:Number = NaN;
         var r1Sqr:Number = NaN;
         var r2Sqr:Number = NaN;
         var rn1:Number = NaN;
         var rn2:Number = NaN;
         var kNormal:Number = NaN;
         var kEqualized:Number = NaN;
         var tangentX:Number = NaN;
         var tangentY:Number = NaN;
         var rt1:Number = NaN;
         var rt2:Number = NaN;
         var kTangent:Number = NaN;
         var vRel:Number = NaN;
         this.m_step = new b2TimeStep();
         this.m_constraints = new Array();
         super();
         this.m_step.dt = step.dt;
         this.m_step.inv_dt = step.inv_dt;
         this.m_step.maxIterations = step.maxIterations;
         this.m_allocator = allocator;
         this.m_constraintCount = 0;
         for(i = 0; i < contactCount; i++)
         {
            contact = contacts[i];
            this.m_constraintCount += contact.m_manifoldCount;
         }
         for(i = 0; i < this.m_constraintCount; i++)
         {
            this.m_constraints[i] = new b2ContactConstraint();
         }
         var count:int = 0;
         for(i = 0; i < contactCount; i++)
         {
            contact = contacts[i];
            b1 = contact.m_shape1.m_body;
            b2 = contact.m_shape2.m_body;
            manifoldCount = contact.m_manifoldCount;
            manifolds = contact.GetManifolds();
            friction = contact.m_friction;
            restitution = contact.m_restitution;
            v1X = b1.m_linearVelocity.x;
            v1Y = b1.m_linearVelocity.y;
            v2X = b2.m_linearVelocity.x;
            v2Y = b2.m_linearVelocity.y;
            w1 = b1.m_angularVelocity;
            w2 = b2.m_angularVelocity;
            for(j = 0; j < manifoldCount; j++)
            {
               manifold = manifolds[j];
               normalX = manifold.normal.x;
               normalY = manifold.normal.y;
               c = this.m_constraints[count];
               c.body1 = b1;
               c.body2 = b2;
               c.manifold = manifold;
               c.normal.x = normalX;
               c.normal.y = normalY;
               c.pointCount = manifold.pointCount;
               c.friction = friction;
               c.restitution = restitution;
               for(k = 0; k < c.pointCount; k++)
               {
                  cp = manifold.points[k];
                  ccp = c.points[k];
                  ccp.normalImpulse = cp.normalImpulse;
                  ccp.tangentImpulse = cp.tangentImpulse;
                  ccp.separation = cp.separation;
                  ccp.positionImpulse = 0;
                  ccp.localAnchor1.SetV(cp.localPoint1);
                  ccp.localAnchor2.SetV(cp.localPoint2);
                  tMat = b1.m_xf.R;
                  r1X = cp.localPoint1.x - b1.m_sweep.localCenter.x;
                  r1Y = cp.localPoint1.y - b1.m_sweep.localCenter.y;
                  tX = tMat.col1.x * r1X + tMat.col2.x * r1Y;
                  r1Y = tMat.col1.y * r1X + tMat.col2.y * r1Y;
                  r1X = tX;
                  ccp.r1.Set(r1X,r1Y);
                  tMat = b2.m_xf.R;
                  r2X = cp.localPoint2.x - b2.m_sweep.localCenter.x;
                  r2Y = cp.localPoint2.y - b2.m_sweep.localCenter.y;
                  tX = tMat.col1.x * r2X + tMat.col2.x * r2Y;
                  r2Y = tMat.col1.y * r2X + tMat.col2.y * r2Y;
                  r2X = tX;
                  ccp.r2.Set(r2X,r2Y);
                  r1Sqr = r1X * r1X + r1Y * r1Y;
                  r2Sqr = r2X * r2X + r2Y * r2Y;
                  rn1 = r1X * normalX + r1Y * normalY;
                  rn2 = r2X * normalX + r2Y * normalY;
                  kNormal = b1.m_invMass + b2.m_invMass;
                  kNormal += b1.m_invI * (r1Sqr - rn1 * rn1) + b2.m_invI * (r2Sqr - rn2 * rn2);
                  ccp.normalMass = 1 / kNormal;
                  kEqualized = b1.m_mass * b1.m_invMass + b2.m_mass * b2.m_invMass;
                  kEqualized += b1.m_mass * b1.m_invI * (r1Sqr - rn1 * rn1) + b2.m_mass * b2.m_invI * (r2Sqr - rn2 * rn2);
                  ccp.equalizedMass = 1 / kEqualized;
                  tangentX = normalY;
                  tangentY = -normalX;
                  rt1 = r1X * tangentX + r1Y * tangentY;
                  rt2 = r2X * tangentX + r2Y * tangentY;
                  kTangent = b1.m_invMass + b2.m_invMass;
                  kTangent += b1.m_invI * (r1Sqr - rt1 * rt1) + b2.m_invI * (r2Sqr - rt2 * rt2);
                  ccp.tangentMass = 1 / kTangent;
                  ccp.velocityBias = 0;
                  if(ccp.separation > 0)
                  {
                     ccp.velocityBias = -60 * ccp.separation;
                  }
                  tX = v2X + -w2 * r2Y - v1X - -w1 * r1Y;
                  tY = v2Y + w2 * r2X - v1Y - w1 * r1X;
                  vRel = c.normal.x * tX + c.normal.y * tY;
                  if(vRel < -b2Settings.b2_velocityThreshold)
                  {
                     ccp.velocityBias += -c.restitution * vRel;
                  }
               }
               count++;
            }
         }
      }
      
      public function InitVelocityConstraints(step:b2TimeStep) : void
      {
         var tVec:b2Vec2 = null;
         var tVec2:b2Vec2 = null;
         var tMat:b2Mat22 = null;
         var c:b2ContactConstraint = null;
         var b1:b2Body = null;
         var b2:b2Body = null;
         var invMass1:Number = NaN;
         var invI1:Number = NaN;
         var invMass2:Number = NaN;
         var invI2:Number = NaN;
         var normalX:Number = NaN;
         var normalY:Number = NaN;
         var tangentX:Number = NaN;
         var tangentY:Number = NaN;
         var tX:Number = NaN;
         var j:int = 0;
         var tCount:int = 0;
         var ccp:b2ContactConstraintPoint = null;
         var PX:Number = NaN;
         var PY:Number = NaN;
         var ccp2:b2ContactConstraintPoint = null;
         for(var i:int = 0; i < this.m_constraintCount; i++)
         {
            c = this.m_constraints[i];
            b1 = c.body1;
            b2 = c.body2;
            invMass1 = b1.m_invMass;
            invI1 = b1.m_invI;
            invMass2 = b2.m_invMass;
            invI2 = b2.m_invI;
            normalX = c.normal.x;
            normalY = c.normal.y;
            tangentX = normalY;
            tangentY = -normalX;
            if(step.warmStarting)
            {
               tCount = c.pointCount;
               for(j = 0; j < tCount; j++)
               {
                  ccp = c.points[j];
                  ccp.normalImpulse *= step.dtRatio;
                  ccp.tangentImpulse *= step.dtRatio;
                  PX = ccp.normalImpulse * normalX + ccp.tangentImpulse * tangentX;
                  PY = ccp.normalImpulse * normalY + ccp.tangentImpulse * tangentY;
                  b1.m_angularVelocity -= invI1 * (ccp.r1.x * PY - ccp.r1.y * PX);
                  b1.m_linearVelocity.x -= invMass1 * PX;
                  b1.m_linearVelocity.y -= invMass1 * PY;
                  b2.m_angularVelocity += invI2 * (ccp.r2.x * PY - ccp.r2.y * PX);
                  b2.m_linearVelocity.x += invMass2 * PX;
                  b2.m_linearVelocity.y += invMass2 * PY;
               }
            }
            else
            {
               tCount = c.pointCount;
               for(j = 0; j < tCount; j++)
               {
                  ccp2 = c.points[j];
                  ccp2.normalImpulse = 0;
                  ccp2.tangentImpulse = 0;
               }
            }
         }
      }
      
      public function SolvePositionConstraints(baumgarte:Number) : Boolean
      {
         var tMat:b2Mat22 = null;
         var tVec:b2Vec2 = null;
         var c:b2ContactConstraint = null;
         var b1:b2Body = null;
         var b2:b2Body = null;
         var b1_sweep_c:b2Vec2 = null;
         var b1_sweep_a:Number = NaN;
         var b2_sweep_c:b2Vec2 = null;
         var b2_sweep_a:Number = NaN;
         var invMass1:Number = NaN;
         var invI1:Number = NaN;
         var invMass2:Number = NaN;
         var invI2:Number = NaN;
         var normalX:Number = NaN;
         var normalY:Number = NaN;
         var tCount:int = 0;
         var j:int = 0;
         var ccp:b2ContactConstraintPoint = null;
         var r1X:Number = NaN;
         var r1Y:Number = NaN;
         var r2X:Number = NaN;
         var r2Y:Number = NaN;
         var tX:Number = NaN;
         var p1X:Number = NaN;
         var p1Y:Number = NaN;
         var p2X:Number = NaN;
         var p2Y:Number = NaN;
         var dpX:Number = NaN;
         var dpY:Number = NaN;
         var separation:Number = NaN;
         var C:Number = NaN;
         var dImpulse:Number = NaN;
         var impulse0:Number = NaN;
         var impulseX:Number = NaN;
         var impulseY:Number = NaN;
         var minSeparation:Number = 0;
         for(var i:int = 0; i < this.m_constraintCount; i++)
         {
            c = this.m_constraints[i];
            b1 = c.body1;
            b2 = c.body2;
            b1_sweep_c = b1.m_sweep.c;
            b1_sweep_a = b1.m_sweep.a;
            b2_sweep_c = b2.m_sweep.c;
            b2_sweep_a = b2.m_sweep.a;
            invMass1 = b1.m_mass * b1.m_invMass;
            invI1 = b1.m_mass * b1.m_invI;
            invMass2 = b2.m_mass * b2.m_invMass;
            invI2 = b2.m_mass * b2.m_invI;
            normalX = c.normal.x;
            normalY = c.normal.y;
            tCount = c.pointCount;
            for(j = 0; j < tCount; j++)
            {
               ccp = c.points[j];
               tMat = b1.m_xf.R;
               tVec = b1.m_sweep.localCenter;
               r1X = ccp.localAnchor1.x - tVec.x;
               r1Y = ccp.localAnchor1.y - tVec.y;
               tX = tMat.col1.x * r1X + tMat.col2.x * r1Y;
               r1Y = tMat.col1.y * r1X + tMat.col2.y * r1Y;
               r1X = tX;
               tMat = b2.m_xf.R;
               tVec = b2.m_sweep.localCenter;
               r2X = ccp.localAnchor2.x - tVec.x;
               r2Y = ccp.localAnchor2.y - tVec.y;
               tX = tMat.col1.x * r2X + tMat.col2.x * r2Y;
               r2Y = tMat.col1.y * r2X + tMat.col2.y * r2Y;
               r2X = tX;
               p1X = b1_sweep_c.x + r1X;
               p1Y = b1_sweep_c.y + r1Y;
               p2X = b2_sweep_c.x + r2X;
               p2Y = b2_sweep_c.y + r2Y;
               dpX = p2X - p1X;
               dpY = p2Y - p1Y;
               separation = dpX * normalX + dpY * normalY + ccp.separation;
               minSeparation = b2Math.b2Min(minSeparation,separation);
               C = baumgarte * b2Math.b2Clamp(separation + b2Settings.b2_linearSlop,-b2Settings.b2_maxLinearCorrection,0);
               dImpulse = -ccp.equalizedMass * C;
               impulse0 = ccp.positionImpulse;
               ccp.positionImpulse = b2Math.b2Max(impulse0 + dImpulse,0);
               dImpulse = ccp.positionImpulse - impulse0;
               impulseX = dImpulse * normalX;
               impulseY = dImpulse * normalY;
               b1_sweep_c.x -= invMass1 * impulseX;
               b1_sweep_c.y -= invMass1 * impulseY;
               b1_sweep_a -= invI1 * (r1X * impulseY - r1Y * impulseX);
               b1.m_sweep.a = b1_sweep_a;
               b1.SynchronizeTransform();
               b2_sweep_c.x += invMass2 * impulseX;
               b2_sweep_c.y += invMass2 * impulseY;
               b2_sweep_a += invI2 * (r2X * impulseY - r2Y * impulseX);
               b2.m_sweep.a = b2_sweep_a;
               b2.SynchronizeTransform();
            }
         }
         return minSeparation >= -1.5 * b2Settings.b2_linearSlop;
      }
      
      public function SolveVelocityConstraints() : void
      {
         var j:int = 0;
         var ccp:b2ContactConstraintPoint = null;
         var r1X:Number = NaN;
         var r1Y:Number = NaN;
         var r2X:Number = NaN;
         var r2Y:Number = NaN;
         var dvX:Number = NaN;
         var dvY:Number = NaN;
         var vn:Number = NaN;
         var vt:Number = NaN;
         var lambda_n:Number = NaN;
         var lambda_t:Number = NaN;
         var newImpulse_n:Number = NaN;
         var newImpulse_t:Number = NaN;
         var PX:Number = NaN;
         var PY:Number = NaN;
         var tMat:b2Mat22 = null;
         var tVec:b2Vec2 = null;
         var c:b2ContactConstraint = null;
         var b1:b2Body = null;
         var b2:b2Body = null;
         var w1:Number = NaN;
         var w2:Number = NaN;
         var v1:b2Vec2 = null;
         var v2:b2Vec2 = null;
         var invMass1:Number = NaN;
         var invI1:Number = NaN;
         var invMass2:Number = NaN;
         var invI2:Number = NaN;
         var normalX:Number = NaN;
         var normalY:Number = NaN;
         var tangentX:Number = NaN;
         var tangentY:Number = NaN;
         var friction:Number = NaN;
         var tX:Number = NaN;
         var tCount:int = 0;
         var maxFriction:Number = NaN;
         for(var i:int = 0; i < this.m_constraintCount; i++)
         {
            c = this.m_constraints[i];
            b1 = c.body1;
            b2 = c.body2;
            w1 = b1.m_angularVelocity;
            w2 = b2.m_angularVelocity;
            v1 = b1.m_linearVelocity;
            v2 = b2.m_linearVelocity;
            invMass1 = b1.m_invMass;
            invI1 = b1.m_invI;
            invMass2 = b2.m_invMass;
            invI2 = b2.m_invI;
            normalX = c.normal.x;
            normalY = c.normal.y;
            tangentX = normalY;
            tangentY = -normalX;
            friction = c.friction;
            tCount = c.pointCount;
            for(j = 0; j < tCount; j++)
            {
               ccp = c.points[j];
               dvX = v2.x + -w2 * ccp.r2.y - v1.x - -w1 * ccp.r1.y;
               dvY = v2.y + w2 * ccp.r2.x - v1.y - w1 * ccp.r1.x;
               vn = dvX * normalX + dvY * normalY;
               lambda_n = -ccp.normalMass * (vn - ccp.velocityBias);
               vt = dvX * tangentX + dvY * tangentY;
               lambda_t = ccp.tangentMass * -vt;
               newImpulse_n = b2Math.b2Max(ccp.normalImpulse + lambda_n,0);
               lambda_n = newImpulse_n - ccp.normalImpulse;
               maxFriction = friction * ccp.normalImpulse;
               newImpulse_t = b2Math.b2Clamp(ccp.tangentImpulse + lambda_t,-maxFriction,maxFriction);
               lambda_t = newImpulse_t - ccp.tangentImpulse;
               PX = lambda_n * normalX + lambda_t * tangentX;
               PY = lambda_n * normalY + lambda_t * tangentY;
               v1.x -= invMass1 * PX;
               v1.y -= invMass1 * PY;
               w1 -= invI1 * (ccp.r1.x * PY - ccp.r1.y * PX);
               v2.x += invMass2 * PX;
               v2.y += invMass2 * PY;
               w2 += invI2 * (ccp.r2.x * PY - ccp.r2.y * PX);
               ccp.normalImpulse = newImpulse_n;
               ccp.tangentImpulse = newImpulse_t;
            }
            b1.m_angularVelocity = w1;
            b2.m_angularVelocity = w2;
         }
      }
      
      public function FinalizeVelocityConstraints() : void
      {
         var c:b2ContactConstraint = null;
         var m:b2Manifold = null;
         var j:int = 0;
         var point1:b2ManifoldPoint = null;
         var point2:b2ContactConstraintPoint = null;
         for(var i:int = 0; i < this.m_constraintCount; i++)
         {
            c = this.m_constraints[i];
            m = c.manifold;
            for(j = 0; j < c.pointCount; j++)
            {
               point1 = m.points[j];
               point2 = c.points[j];
               point1.normalImpulse = point2.normalImpulse;
               point1.tangentImpulse = point2.tangentImpulse;
            }
         }
      }
   }
}
