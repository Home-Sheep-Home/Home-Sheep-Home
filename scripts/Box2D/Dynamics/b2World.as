package Box2D.Dynamics
{
   import Box2D.Collision.*;
   import Box2D.Collision.Shapes.*;
   import Box2D.Common.*;
   import Box2D.Common.Math.*;
   import Box2D.Dynamics.Contacts.*;
   import Box2D.Dynamics.Joints.*;
   
   public class b2World
   {
      
      private static var s_jointColor:b2Color = new b2Color(0.5,0.8,0.8);
      
      public static var m_continuousPhysics:Boolean;
      
      public static var m_warmStarting:Boolean;
      
      private static var s_coreColor:b2Color = new b2Color(0.9,0.6,0.6);
      
      public static var m_positionCorrection:Boolean;
      
      private static var s_xf:b2XForm = new b2XForm();
       
      
      public var m_inv_dt0:Number;
      
      public var m_boundaryListener:Box2D.Dynamics.b2BoundaryListener;
      
      public var m_contactList:b2Contact;
      
      public var m_blockAllocator;
      
      public var m_contactListener:Box2D.Dynamics.b2ContactListener;
      
      public var m_allowSleep:Boolean;
      
      public var m_broadPhase:b2BroadPhase;
      
      public var m_destructionListener:Box2D.Dynamics.b2DestructionListener;
      
      public var m_jointCount:int;
      
      public var m_bodyCount:int;
      
      public var m_lock:Boolean;
      
      public var m_positionIterationCount:int;
      
      public var m_groundBody:Box2D.Dynamics.b2Body;
      
      public var m_contactCount:int;
      
      public var m_debugDraw:Box2D.Dynamics.b2DebugDraw;
      
      public var m_contactFilter:Box2D.Dynamics.b2ContactFilter;
      
      public var m_bodyList:Box2D.Dynamics.b2Body;
      
      public var m_stackAllocator;
      
      public var m_jointList:b2Joint;
      
      public var m_gravity:b2Vec2;
      
      public var m_contactManager:Box2D.Dynamics.b2ContactManager;
      
      public function b2World(worldAABB:b2AABB, gravity:b2Vec2, doSleep:Boolean)
      {
         this.m_contactManager = new Box2D.Dynamics.b2ContactManager();
         super();
         this.m_destructionListener = null;
         this.m_boundaryListener = null;
         this.m_contactFilter = Box2D.Dynamics.b2ContactFilter.b2_defaultFilter;
         this.m_contactListener = null;
         this.m_debugDraw = null;
         this.m_bodyList = null;
         this.m_contactList = null;
         this.m_jointList = null;
         this.m_bodyCount = 0;
         this.m_contactCount = 0;
         this.m_jointCount = 0;
         m_positionCorrection = true;
         m_warmStarting = true;
         m_continuousPhysics = true;
         this.m_allowSleep = doSleep;
         this.m_gravity = gravity;
         this.m_lock = false;
         this.m_inv_dt0 = 0;
         this.m_contactManager.m_world = this;
         this.m_broadPhase = new b2BroadPhase(worldAABB,this.m_contactManager);
         var bd:b2BodyDef = new b2BodyDef();
         this.m_groundBody = this.CreateBody(bd);
      }
      
      public function DrawJoint(joint:b2Joint) : void
      {
         var pulley:b2PulleyJoint = null;
         var s1:b2Vec2 = null;
         var s2:b2Vec2 = null;
         var b1:Box2D.Dynamics.b2Body = joint.m_body1;
         var b2:Box2D.Dynamics.b2Body = joint.m_body2;
         var xf1:b2XForm = b1.m_xf;
         var xf2:b2XForm = b2.m_xf;
         var x1:b2Vec2 = xf1.position;
         var x2:b2Vec2 = xf2.position;
         var p1:b2Vec2 = joint.GetAnchor1();
         var p2:b2Vec2 = joint.GetAnchor2();
         var color:b2Color = s_jointColor;
         switch(joint.m_type)
         {
            case b2Joint.e_distanceJoint:
               this.m_debugDraw.DrawSegment(p1,p2,color);
               break;
            case b2Joint.e_pulleyJoint:
               pulley = joint as b2PulleyJoint;
               s1 = pulley.GetGroundAnchor1();
               s2 = pulley.GetGroundAnchor2();
               this.m_debugDraw.DrawSegment(s1,p1,color);
               this.m_debugDraw.DrawSegment(s2,p2,color);
               this.m_debugDraw.DrawSegment(s1,s2,color);
               break;
            case b2Joint.e_mouseJoint:
               this.m_debugDraw.DrawSegment(p1,p2,color);
               break;
            default:
               if(b1 != this.m_groundBody)
               {
                  this.m_debugDraw.DrawSegment(x1,p1,color);
               }
               this.m_debugDraw.DrawSegment(p1,p2,color);
               if(b2 != this.m_groundBody)
               {
                  this.m_debugDraw.DrawSegment(x2,p2,color);
               }
         }
      }
      
      public function Refilter(shape:b2Shape) : void
      {
         shape.RefilterProxy(this.m_broadPhase,shape.m_body.m_xf);
      }
      
      public function SetDebugDraw(debugDraw:Box2D.Dynamics.b2DebugDraw) : void
      {
         this.m_debugDraw = debugDraw;
      }
      
      public function SetContinuousPhysics(flag:Boolean) : void
      {
         m_continuousPhysics = flag;
      }
      
      public function GetProxyCount() : int
      {
         return this.m_broadPhase.m_proxyCount;
      }
      
      public function DrawDebugData() : void
      {
         var i:int = 0;
         var b:Box2D.Dynamics.b2Body = null;
         var s:b2Shape = null;
         var j:b2Joint = null;
         var bp:b2BroadPhase = null;
         var xf:b2XForm = null;
         var core:* = false;
         var index:uint = 0;
         var pair:b2Pair = null;
         var p1:b2Proxy = null;
         var p2:b2Proxy = null;
         var worldLower:b2Vec2 = null;
         var worldUpper:b2Vec2 = null;
         var p:b2Proxy = null;
         var poly:b2PolygonShape = null;
         var obb:b2OBB = null;
         var h:b2Vec2 = null;
         var tMat:b2Mat22 = null;
         var tVec:b2Vec2 = null;
         var tX:Number = NaN;
         if(this.m_debugDraw == null)
         {
            return;
         }
         this.m_debugDraw.m_sprite.graphics.clear();
         var flags:uint = this.m_debugDraw.GetFlags();
         var invQ:b2Vec2 = new b2Vec2();
         var x1:b2Vec2 = new b2Vec2();
         var x2:b2Vec2 = new b2Vec2();
         var color:b2Color = new b2Color(0,0,0);
         var b1:b2AABB = new b2AABB();
         var b2:b2AABB = new b2AABB();
         var vs:Array = [new b2Vec2(),new b2Vec2(),new b2Vec2(),new b2Vec2()];
         if(flags & Box2D.Dynamics.b2DebugDraw.e_shapeBit)
         {
            core = (flags & Box2D.Dynamics.b2DebugDraw.e_coreShapeBit) == Box2D.Dynamics.b2DebugDraw.e_coreShapeBit;
            b = this.m_bodyList;
            while(b)
            {
               xf = b.m_xf;
               s = b.GetShapeList();
               while(s)
               {
                  if(b.IsStatic())
                  {
                     this.DrawShape(s,xf,new b2Color(0.5,0.9,0.5),core);
                  }
                  else if(b.IsSleeping())
                  {
                     this.DrawShape(s,xf,new b2Color(0.5,0.5,0.9),core);
                  }
                  else
                  {
                     this.DrawShape(s,xf,new b2Color(0.9,0.9,0.9),core);
                  }
                  s = s.m_next;
               }
               b = b.m_next;
            }
         }
         if(flags & Box2D.Dynamics.b2DebugDraw.e_jointBit)
         {
            j = this.m_jointList;
            while(j)
            {
               this.DrawJoint(j);
               j = j.m_next;
            }
         }
         if(flags & Box2D.Dynamics.b2DebugDraw.e_pairBit)
         {
            bp = this.m_broadPhase;
            invQ.Set(1 / bp.m_quantizationFactor.x,1 / bp.m_quantizationFactor.y);
            color.Set(0.9,0.9,0.3);
            for(i = 0; i < b2Pair.b2_tableCapacity; i++)
            {
               index = uint(bp.m_pairManager.m_hashTable[i]);
               while(index != b2Pair.b2_nullPair)
               {
                  pair = bp.m_pairManager.m_pairs[index];
                  p1 = bp.m_proxyPool[pair.proxyId1];
                  p2 = bp.m_proxyPool[pair.proxyId2];
                  b1.lowerBound.x = bp.m_worldAABB.lowerBound.x + invQ.x * bp.m_bounds[0][p1.lowerBounds[0]].value;
                  b1.lowerBound.y = bp.m_worldAABB.lowerBound.y + invQ.y * bp.m_bounds[1][p1.lowerBounds[1]].value;
                  b1.upperBound.x = bp.m_worldAABB.lowerBound.x + invQ.x * bp.m_bounds[0][p1.upperBounds[0]].value;
                  b1.upperBound.y = bp.m_worldAABB.lowerBound.y + invQ.y * bp.m_bounds[1][p1.upperBounds[1]].value;
                  b2.lowerBound.x = bp.m_worldAABB.lowerBound.x + invQ.x * bp.m_bounds[0][p2.lowerBounds[0]].value;
                  b2.lowerBound.y = bp.m_worldAABB.lowerBound.y + invQ.y * bp.m_bounds[1][p2.lowerBounds[1]].value;
                  b2.upperBound.x = bp.m_worldAABB.lowerBound.x + invQ.x * bp.m_bounds[0][p2.upperBounds[0]].value;
                  b2.upperBound.y = bp.m_worldAABB.lowerBound.y + invQ.y * bp.m_bounds[1][p2.upperBounds[1]].value;
                  x1.x = 0.5 * (b1.lowerBound.x + b1.upperBound.x);
                  x1.y = 0.5 * (b1.lowerBound.y + b1.upperBound.y);
                  x2.x = 0.5 * (b2.lowerBound.x + b2.upperBound.x);
                  x2.y = 0.5 * (b2.lowerBound.y + b2.upperBound.y);
                  this.m_debugDraw.DrawSegment(x1,x2,color);
                  index = pair.next;
               }
            }
         }
         if(flags & Box2D.Dynamics.b2DebugDraw.e_aabbBit)
         {
            bp = this.m_broadPhase;
            worldLower = bp.m_worldAABB.lowerBound;
            worldUpper = bp.m_worldAABB.upperBound;
            invQ.Set(1 / bp.m_quantizationFactor.x,1 / bp.m_quantizationFactor.y);
            color.Set(0.9,0.3,0.9);
            for(i = 0; i < b2Settings.b2_maxProxies; i++)
            {
               p = bp.m_proxyPool[i];
               if(p.IsValid() != false)
               {
                  b1.lowerBound.x = worldLower.x + invQ.x * bp.m_bounds[0][p.lowerBounds[0]].value;
                  b1.lowerBound.y = worldLower.y + invQ.y * bp.m_bounds[1][p.lowerBounds[1]].value;
                  b1.upperBound.x = worldLower.x + invQ.x * bp.m_bounds[0][p.upperBounds[0]].value;
                  b1.upperBound.y = worldLower.y + invQ.y * bp.m_bounds[1][p.upperBounds[1]].value;
                  vs[0].Set(b1.lowerBound.x,b1.lowerBound.y);
                  vs[1].Set(b1.upperBound.x,b1.lowerBound.y);
                  vs[2].Set(b1.upperBound.x,b1.upperBound.y);
                  vs[3].Set(b1.lowerBound.x,b1.upperBound.y);
                  this.m_debugDraw.DrawPolygon(vs,4,color);
               }
            }
            vs[0].Set(worldLower.x,worldLower.y);
            vs[1].Set(worldUpper.x,worldLower.y);
            vs[2].Set(worldUpper.x,worldUpper.y);
            vs[3].Set(worldLower.x,worldUpper.y);
            this.m_debugDraw.DrawPolygon(vs,4,new b2Color(0.3,0.9,0.9));
         }
         if(flags & Box2D.Dynamics.b2DebugDraw.e_obbBit)
         {
            color.Set(0.5,0.3,0.5);
            b = this.m_bodyList;
            while(b)
            {
               xf = b.m_xf;
               s = b.GetShapeList();
               while(s)
               {
                  if(s.m_type == b2Shape.e_polygonShape)
                  {
                     poly = s as b2PolygonShape;
                     obb = poly.GetOBB();
                     h = obb.extents;
                     vs[0].Set(-h.x,-h.y);
                     vs[1].Set(h.x,-h.y);
                     vs[2].Set(h.x,h.y);
                     vs[3].Set(-h.x,h.y);
                     for(i = 0; i < 4; i++)
                     {
                        tMat = obb.R;
                        tVec = vs[i];
                        tX = obb.center.x + (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y);
                        vs[i].y = obb.center.y + (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y);
                        vs[i].x = tX;
                        tMat = xf.R;
                        tX = xf.position.x + (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y);
                        vs[i].y = xf.position.y + (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y);
                        vs[i].x = tX;
                     }
                     this.m_debugDraw.DrawPolygon(vs,4,color);
                  }
                  s = s.m_next;
               }
               b = b.m_next;
            }
         }
         if(flags & Box2D.Dynamics.b2DebugDraw.e_centerOfMassBit)
         {
            b = this.m_bodyList;
            while(b)
            {
               xf = s_xf;
               xf.R = b.m_xf.R;
               xf.position = b.GetWorldCenter();
               this.m_debugDraw.DrawXForm(xf);
               b = b.m_next;
            }
         }
      }
      
      public function DestroyBody(b:Box2D.Dynamics.b2Body) : void
      {
         var jn0:b2JointEdge = null;
         var s0:b2Shape = null;
         if(this.m_lock == true)
         {
            return;
         }
         var jn:b2JointEdge = b.m_jointList;
         while(jn)
         {
            jn0 = jn;
            jn = jn.next;
            if(this.m_destructionListener)
            {
               this.m_destructionListener.SayGoodbyeJoint(jn0.joint);
            }
            this.DestroyJoint(jn0.joint);
         }
         var s:b2Shape = b.m_shapeList;
         while(s)
         {
            s0 = s;
            s = s.m_next;
            if(this.m_destructionListener)
            {
               this.m_destructionListener.SayGoodbyeShape(s0);
            }
            s0.DestroyProxy(this.m_broadPhase);
            b2Shape.Destroy(s0,this.m_blockAllocator);
         }
         if(b.m_prev)
         {
            b.m_prev.m_next = b.m_next;
         }
         if(b.m_next)
         {
            b.m_next.m_prev = b.m_prev;
         }
         if(b == this.m_bodyList)
         {
            this.m_bodyList = b.m_next;
         }
         --this.m_bodyCount;
      }
      
      public function SetContactFilter(filter:Box2D.Dynamics.b2ContactFilter) : void
      {
         this.m_contactFilter = filter;
      }
      
      public function GetGroundBody() : Box2D.Dynamics.b2Body
      {
         return this.m_groundBody;
      }
      
      public function DrawShape(shape:b2Shape, xf:b2XForm, color:b2Color, core:Boolean) : void
      {
         var circle:b2CircleShape = null;
         var center:b2Vec2 = null;
         var radius:Number = NaN;
         var axis:b2Vec2 = null;
         var i:int = 0;
         var poly:b2PolygonShape = null;
         var vertexCount:int = 0;
         var localVertices:Array = null;
         var vertices:Array = null;
         var localCoreVertices:Array = null;
         var coreColor:b2Color = s_coreColor;
         switch(shape.m_type)
         {
            case b2Shape.e_circleShape:
               circle = shape as b2CircleShape;
               center = b2Math.b2MulX(xf,circle.m_localPosition);
               radius = circle.m_radius;
               axis = xf.R.col1;
               this.m_debugDraw.DrawSolidCircle(center,radius,axis,color);
               if(core)
               {
                  this.m_debugDraw.DrawCircle(center,radius - b2Settings.b2_toiSlop,coreColor);
               }
               break;
            case b2Shape.e_polygonShape:
               poly = shape as b2PolygonShape;
               vertexCount = poly.GetVertexCount();
               localVertices = poly.GetVertices();
               vertices = new Array(b2Settings.b2_maxPolygonVertices);
               for(i = 0; i < vertexCount; i++)
               {
                  vertices[i] = b2Math.b2MulX(xf,localVertices[i]);
               }
               this.m_debugDraw.DrawSolidPolygon(vertices,vertexCount,color);
               if(core)
               {
                  localCoreVertices = poly.GetCoreVertices();
                  for(i = 0; i < vertexCount; i++)
                  {
                     vertices[i] = b2Math.b2MulX(xf,localCoreVertices[i]);
                  }
                  this.m_debugDraw.DrawPolygon(vertices,vertexCount,coreColor);
               }
         }
      }
      
      public function GetContactCount() : int
      {
         return this.m_contactCount;
      }
      
      public function Solve(step:b2TimeStep) : void
      {
         var b:Box2D.Dynamics.b2Body = null;
         var stackCount:int = 0;
         var i:int = 0;
         var other:Box2D.Dynamics.b2Body = null;
         var cn:b2ContactEdge = null;
         var jn:b2JointEdge = null;
         var inRange:Boolean = false;
         this.m_positionIterationCount = 0;
         var island:b2Island = new b2Island(this.m_bodyCount,this.m_contactCount,this.m_jointCount,this.m_stackAllocator,this.m_contactListener);
         b = this.m_bodyList;
         while(b)
         {
            b.m_flags &= ~Box2D.Dynamics.b2Body.e_islandFlag;
            b = b.m_next;
         }
         var c:b2Contact = this.m_contactList;
         while(c)
         {
            c.m_flags &= ~b2Contact.e_islandFlag;
            c = c.m_next;
         }
         var j:b2Joint = this.m_jointList;
         while(j)
         {
            j.m_islandFlag = false;
            j = j.m_next;
         }
         var stackSize:int = this.m_bodyCount;
         var stack:Array = new Array(stackSize);
         var seed:Box2D.Dynamics.b2Body = this.m_bodyList;
         while(seed)
         {
            if(!(seed.m_flags & (Box2D.Dynamics.b2Body.e_islandFlag | Box2D.Dynamics.b2Body.e_sleepFlag | Box2D.Dynamics.b2Body.e_frozenFlag)))
            {
               if(!seed.IsStatic())
               {
                  island.Clear();
                  stackCount = 0;
                  var _loc15_:*;
                  stack[_loc15_ = stackCount++] = seed;
                  seed.m_flags |= Box2D.Dynamics.b2Body.e_islandFlag;
                  while(stackCount > 0)
                  {
                     b = stack[--stackCount];
                     island.AddBody(b);
                     b.m_flags &= ~Box2D.Dynamics.b2Body.e_sleepFlag;
                     if(!b.IsStatic())
                     {
                        cn = b.m_contactList;
                        while(cn)
                        {
                           if(!(cn.contact.m_flags & (b2Contact.e_islandFlag | b2Contact.e_nonSolidFlag)))
                           {
                              if(cn.contact.m_manifoldCount != 0)
                              {
                                 island.AddContact(cn.contact);
                                 cn.contact.m_flags |= b2Contact.e_islandFlag;
                                 other = cn.other;
                                 if(!(other.m_flags & Box2D.Dynamics.b2Body.e_islandFlag))
                                 {
                                    var _loc16_:*;
                                    stack[_loc16_ = stackCount++] = other;
                                    other.m_flags |= Box2D.Dynamics.b2Body.e_islandFlag;
                                 }
                              }
                           }
                           cn = cn.next;
                        }
                        jn = b.m_jointList;
                        while(jn)
                        {
                           if(jn.joint.m_islandFlag != true)
                           {
                              island.AddJoint(jn.joint);
                              jn.joint.m_islandFlag = true;
                              other = jn.other;
                              if(!(other.m_flags & Box2D.Dynamics.b2Body.e_islandFlag))
                              {
                                 stack[_loc16_ = stackCount++] = other;
                                 other.m_flags |= Box2D.Dynamics.b2Body.e_islandFlag;
                              }
                           }
                           jn = jn.next;
                        }
                     }
                  }
                  island.Solve(step,this.m_gravity,m_positionCorrection,this.m_allowSleep);
                  if(island.m_positionIterationCount > this.m_positionIterationCount)
                  {
                     this.m_positionIterationCount = island.m_positionIterationCount;
                  }
                  for(i = 0; i < island.m_bodyCount; i++)
                  {
                     b = island.m_bodies[i];
                     if(b.IsStatic())
                     {
                        b.m_flags &= ~Box2D.Dynamics.b2Body.e_islandFlag;
                     }
                  }
               }
            }
            seed = seed.m_next;
         }
         b = this.m_bodyList;
         while(b)
         {
            if(!(b.m_flags & (Box2D.Dynamics.b2Body.e_sleepFlag | Box2D.Dynamics.b2Body.e_frozenFlag)))
            {
               if(!b.IsStatic())
               {
                  inRange = b.SynchronizeShapes();
                  if(inRange == false && this.m_boundaryListener != null)
                  {
                     this.m_boundaryListener.Violation(b);
                  }
               }
            }
            b = b.m_next;
         }
         this.m_broadPhase.Commit();
      }
      
      public function Query(aabb:b2AABB, shapes:Array, maxCount:int) : int
      {
         var results:Array = new Array(maxCount);
         var count:int = this.m_broadPhase.QueryAABB(aabb,results,maxCount);
         for(var i:int = 0; i < count; i++)
         {
            shapes[i] = results[i];
         }
         return count;
      }
      
      public function SetGravity(gravity:b2Vec2) : void
      {
         this.m_gravity = gravity;
      }
      
      public function SolveTOI(step:b2TimeStep) : void
      {
         var b:Box2D.Dynamics.b2Body = null;
         var s1:b2Shape = null;
         var s2:b2Shape = null;
         var b1:Box2D.Dynamics.b2Body = null;
         var b2:Box2D.Dynamics.b2Body = null;
         var cn:b2ContactEdge = null;
         var c:b2Contact = null;
         var minContact:b2Contact = null;
         var minTOI:Number = NaN;
         var seed:Box2D.Dynamics.b2Body = null;
         var stackCount:int = 0;
         var subStep:b2TimeStep = null;
         var i:int = 0;
         var toi:Number = NaN;
         var t0:Number = NaN;
         var other:Box2D.Dynamics.b2Body = null;
         var inRange:Boolean = false;
         var island:b2Island = new b2Island(this.m_bodyCount,b2Settings.b2_maxTOIContactsPerIsland,0,this.m_stackAllocator,this.m_contactListener);
         var stackSize:int = this.m_bodyCount;
         var stack:Array = new Array(stackSize);
         b = this.m_bodyList;
         while(b)
         {
            b.m_flags &= ~Box2D.Dynamics.b2Body.e_islandFlag;
            b.m_sweep.t0 = 0;
            b = b.m_next;
         }
         c = this.m_contactList;
         while(c)
         {
            c.m_flags &= ~(b2Contact.e_toiFlag | b2Contact.e_islandFlag);
            c = c.m_next;
         }
         while(true)
         {
            minContact = null;
            minTOI = 1;
            c = this.m_contactList;
            for(; c; c = c.m_next)
            {
               if(!(c.m_flags & (b2Contact.e_slowFlag | b2Contact.e_nonSolidFlag)))
               {
                  toi = 1;
                  if(c.m_flags & b2Contact.e_toiFlag)
                  {
                     toi = c.m_toi;
                  }
                  else
                  {
                     s1 = c.m_shape1;
                     s2 = c.m_shape2;
                     b1 = s1.m_body;
                     b2 = s2.m_body;
                     if((b1.IsStatic() || b1.IsSleeping()) && (b2.IsStatic() || b2.IsSleeping()))
                     {
                        continue;
                     }
                     t0 = b1.m_sweep.t0;
                     if(b1.m_sweep.t0 < b2.m_sweep.t0)
                     {
                        t0 = b2.m_sweep.t0;
                        b1.m_sweep.Advance(t0);
                     }
                     else if(b2.m_sweep.t0 < b1.m_sweep.t0)
                     {
                        t0 = b1.m_sweep.t0;
                        b2.m_sweep.Advance(t0);
                     }
                     toi = b2TimeOfImpact.TimeOfImpact(c.m_shape1,b1.m_sweep,c.m_shape2,b2.m_sweep);
                     if(toi > 0 && toi < 1)
                     {
                        toi = (1 - toi) * t0 + toi;
                        if(toi > 1)
                        {
                           toi = 1;
                        }
                     }
                     c.m_toi = toi;
                     c.m_flags |= b2Contact.e_toiFlag;
                  }
                  if(Number.MIN_VALUE < toi && toi < minTOI)
                  {
                     minContact = c;
                     minTOI = toi;
                  }
               }
            }
            if(minContact == null || 1 - 100 * Number.MIN_VALUE < minTOI)
            {
               break;
            }
            s1 = minContact.m_shape1;
            s2 = minContact.m_shape2;
            b1 = s1.m_body;
            b2 = s2.m_body;
            b1.Advance(minTOI);
            b2.Advance(minTOI);
            minContact.Update(this.m_contactListener);
            minContact.m_flags &= ~b2Contact.e_toiFlag;
            if(minContact.m_manifoldCount != 0)
            {
               seed = b1;
               if(seed.IsStatic())
               {
                  seed = b2;
               }
               island.Clear();
               stackCount = 0;
               var _loc22_:*;
               stack[_loc22_ = stackCount++] = seed;
               seed.m_flags |= Box2D.Dynamics.b2Body.e_islandFlag;
               while(stackCount > 0)
               {
                  b = stack[--stackCount];
                  island.AddBody(b);
                  b.m_flags &= ~Box2D.Dynamics.b2Body.e_sleepFlag;
                  if(!b.IsStatic())
                  {
                     cn = b.m_contactList;
                     while(cn)
                     {
                        if(island.m_contactCount != island.m_contactCapacity)
                        {
                           if(!(cn.contact.m_flags & (b2Contact.e_islandFlag | b2Contact.e_slowFlag | b2Contact.e_nonSolidFlag)))
                           {
                              if(cn.contact.m_manifoldCount != 0)
                              {
                                 island.AddContact(cn.contact);
                                 cn.contact.m_flags |= b2Contact.e_islandFlag;
                                 other = cn.other;
                                 if(!(other.m_flags & Box2D.Dynamics.b2Body.e_islandFlag))
                                 {
                                    if(other.IsStatic() == false)
                                    {
                                       other.Advance(minTOI);
                                       other.WakeUp();
                                    }
                                    var _loc23_:*;
                                    stack[_loc23_ = stackCount++] = other;
                                    other.m_flags |= Box2D.Dynamics.b2Body.e_islandFlag;
                                 }
                              }
                           }
                        }
                        cn = cn.next;
                     }
                  }
               }
               subStep = new b2TimeStep();
               subStep.dt = (1 - minTOI) * step.dt;
               subStep.inv_dt = 1 / subStep.dt;
               subStep.maxIterations = step.maxIterations;
               island.SolveTOI(subStep);
               for(i = 0; i < island.m_bodyCount; i++)
               {
                  b = island.m_bodies[i];
                  b.m_flags &= ~Box2D.Dynamics.b2Body.e_islandFlag;
                  if(!(b.m_flags & (Box2D.Dynamics.b2Body.e_sleepFlag | Box2D.Dynamics.b2Body.e_frozenFlag)))
                  {
                     if(!b.IsStatic())
                     {
                        inRange = b.SynchronizeShapes();
                        if(inRange == false && this.m_boundaryListener != null)
                        {
                           this.m_boundaryListener.Violation(b);
                        }
                        cn = b.m_contactList;
                        while(cn)
                        {
                           cn.contact.m_flags &= ~b2Contact.e_toiFlag;
                           cn = cn.next;
                        }
                     }
                  }
               }
               for(i = 0; i < island.m_contactCount; i++)
               {
                  c = island.m_contacts[i];
                  c.m_flags &= ~(b2Contact.e_toiFlag | b2Contact.e_islandFlag);
               }
               this.m_broadPhase.Commit();
            }
         }
      }
      
      public function GetJointList() : b2Joint
      {
         return this.m_jointList;
      }
      
      public function GetBodyList() : Box2D.Dynamics.b2Body
      {
         return this.m_bodyList;
      }
      
      public function GetPairCount() : int
      {
         return this.m_broadPhase.m_pairManager.m_pairCount;
      }
      
      public function Validate() : void
      {
         this.m_broadPhase.Validate();
      }
      
      public function SetWarmStarting(flag:Boolean) : void
      {
         m_warmStarting = flag;
      }
      
      public function SetPositionCorrection(flag:Boolean) : void
      {
         m_positionCorrection = flag;
      }
      
      public function CreateJoint(def:b2JointDef) : b2Joint
      {
         var b:Box2D.Dynamics.b2Body = null;
         var s:b2Shape = null;
         var j:b2Joint = b2Joint.Create(def,this.m_blockAllocator);
         j.m_prev = null;
         j.m_next = this.m_jointList;
         if(this.m_jointList)
         {
            this.m_jointList.m_prev = j;
         }
         this.m_jointList = j;
         ++this.m_jointCount;
         j.m_node1.joint = j;
         j.m_node1.other = j.m_body2;
         j.m_node1.prev = null;
         j.m_node1.next = j.m_body1.m_jointList;
         if(j.m_body1.m_jointList)
         {
            j.m_body1.m_jointList.prev = j.m_node1;
         }
         j.m_body1.m_jointList = j.m_node1;
         j.m_node2.joint = j;
         j.m_node2.other = j.m_body1;
         j.m_node2.prev = null;
         j.m_node2.next = j.m_body2.m_jointList;
         if(j.m_body2.m_jointList)
         {
            j.m_body2.m_jointList.prev = j.m_node2;
         }
         j.m_body2.m_jointList = j.m_node2;
         if(def.collideConnected == false)
         {
            b = def.body1.m_shapeCount < def.body2.m_shapeCount ? def.body1 : def.body2;
            s = b.m_shapeList;
            while(s)
            {
               s.RefilterProxy(this.m_broadPhase,b.m_xf);
               s = s.m_next;
            }
         }
         return j;
      }
      
      public function DestroyJoint(j:b2Joint) : void
      {
         var b:Box2D.Dynamics.b2Body = null;
         var s:b2Shape = null;
         var collideConnected:Boolean = j.m_collideConnected;
         if(j.m_prev)
         {
            j.m_prev.m_next = j.m_next;
         }
         if(j.m_next)
         {
            j.m_next.m_prev = j.m_prev;
         }
         if(j == this.m_jointList)
         {
            this.m_jointList = j.m_next;
         }
         var body1:Box2D.Dynamics.b2Body = j.m_body1;
         var body2:Box2D.Dynamics.b2Body = j.m_body2;
         body1.WakeUp();
         body2.WakeUp();
         if(j.m_node1.prev)
         {
            j.m_node1.prev.next = j.m_node1.next;
         }
         if(j.m_node1.next)
         {
            j.m_node1.next.prev = j.m_node1.prev;
         }
         if(j.m_node1 == body1.m_jointList)
         {
            body1.m_jointList = j.m_node1.next;
         }
         j.m_node1.prev = null;
         j.m_node1.next = null;
         if(j.m_node2.prev)
         {
            j.m_node2.prev.next = j.m_node2.next;
         }
         if(j.m_node2.next)
         {
            j.m_node2.next.prev = j.m_node2.prev;
         }
         if(j.m_node2 == body2.m_jointList)
         {
            body2.m_jointList = j.m_node2.next;
         }
         j.m_node2.prev = null;
         j.m_node2.next = null;
         b2Joint.Destroy(j,this.m_blockAllocator);
         --this.m_jointCount;
         if(collideConnected == false)
         {
            b = body1.m_shapeCount < body2.m_shapeCount ? body1 : body2;
            s = b.m_shapeList;
            while(s)
            {
               s.RefilterProxy(this.m_broadPhase,b.m_xf);
               s = s.m_next;
            }
         }
      }
      
      public function SetContactListener(listener:Box2D.Dynamics.b2ContactListener) : void
      {
         this.m_contactListener = listener;
      }
      
      public function CreateBody(def:b2BodyDef) : Box2D.Dynamics.b2Body
      {
         if(this.m_lock == true)
         {
            return null;
         }
         var b:Box2D.Dynamics.b2Body = new Box2D.Dynamics.b2Body(def,this);
         b.m_prev = null;
         b.m_next = this.m_bodyList;
         if(this.m_bodyList)
         {
            this.m_bodyList.m_prev = b;
         }
         this.m_bodyList = b;
         ++this.m_bodyCount;
         return b;
      }
      
      public function SetBoundaryListener(listener:Box2D.Dynamics.b2BoundaryListener) : void
      {
         this.m_boundaryListener = listener;
      }
      
      public function SetDestructionListener(listener:Box2D.Dynamics.b2DestructionListener) : void
      {
         this.m_destructionListener = listener;
      }
      
      public function Step(dt:Number, iterations:int) : void
      {
         this.m_lock = true;
         var step:b2TimeStep = new b2TimeStep();
         step.dt = dt;
         step.maxIterations = iterations;
         if(dt > 0)
         {
            step.inv_dt = 1 / dt;
         }
         else
         {
            step.inv_dt = 0;
         }
         step.dtRatio = this.m_inv_dt0 * dt;
         step.positionCorrection = m_positionCorrection;
         step.warmStarting = m_warmStarting;
         this.m_contactManager.Collide();
         if(step.dt > 0)
         {
            this.Solve(step);
         }
         if(m_continuousPhysics && step.dt > 0)
         {
            this.SolveTOI(step);
         }
         this.DrawDebugData();
         this.m_inv_dt0 = step.inv_dt;
         this.m_lock = false;
      }
      
      public function GetBodyCount() : int
      {
         return this.m_bodyCount;
      }
      
      public function GetJointCount() : int
      {
         return this.m_jointCount;
      }
   }
}
