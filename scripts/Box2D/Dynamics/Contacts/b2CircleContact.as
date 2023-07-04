package Box2D.Dynamics.Contacts
{
   import Box2D.Collision.*;
   import Box2D.Collision.Shapes.*;
   import Box2D.Common.*;
   import Box2D.Common.Math.*;
   import Box2D.Dynamics.*;
   
   public class b2CircleContact extends b2Contact
   {
      
      private static const s_evalCP:b2ContactPoint = new b2ContactPoint();
       
      
      private var m_manifolds:Array;
      
      public var m_manifold:b2Manifold;
      
      private var m0:b2Manifold;
      
      public function b2CircleContact(shape1:b2Shape, shape2:b2Shape)
      {
         this.m_manifolds = [new b2Manifold()];
         this.m0 = new b2Manifold();
         super(shape1,shape2);
         this.m_manifold = this.m_manifolds[0];
         this.m_manifold.pointCount = 0;
         var point:b2ManifoldPoint = this.m_manifold.points[0];
         point.normalImpulse = 0;
         point.tangentImpulse = 0;
      }
      
      public static function Destroy(contact:b2Contact, allocator:*) : void
      {
      }
      
      public static function Create(shape1:b2Shape, shape2:b2Shape, allocator:*) : b2Contact
      {
         return new b2CircleContact(shape1,shape2);
      }
      
      override public function Evaluate(listener:b2ContactListener) : void
      {
         var v1:b2Vec2 = null;
         var v2:b2Vec2 = null;
         var mp0:b2ManifoldPoint = null;
         var mp:b2ManifoldPoint = null;
         var b1:b2Body = m_shape1.m_body;
         var b2:b2Body = m_shape2.m_body;
         this.m0.Set(this.m_manifold);
         b2Collision.b2CollideCircles(this.m_manifold,m_shape1 as b2CircleShape,b1.m_xf,m_shape2 as b2CircleShape,b2.m_xf);
         var cp:b2ContactPoint = s_evalCP;
         cp.shape1 = m_shape1;
         cp.shape2 = m_shape2;
         cp.friction = m_friction;
         cp.restitution = m_restitution;
         if(this.m_manifold.pointCount > 0)
         {
            m_manifoldCount = 1;
            mp = this.m_manifold.points[0];
            if(this.m0.pointCount == 0)
            {
               mp.normalImpulse = 0;
               mp.tangentImpulse = 0;
               if(listener)
               {
                  cp.position = b1.GetWorldPoint(mp.localPoint1);
                  v1 = b1.GetLinearVelocityFromLocalPoint(mp.localPoint1);
                  v2 = b2.GetLinearVelocityFromLocalPoint(mp.localPoint2);
                  cp.velocity.Set(v2.x - v1.x,v2.y - v1.y);
                  cp.normal.SetV(this.m_manifold.normal);
                  cp.separation = mp.separation;
                  cp.id.key = mp.id._key;
                  listener.Add(cp);
               }
            }
            else
            {
               mp0 = this.m0.points[0];
               mp.normalImpulse = mp0.normalImpulse;
               mp.tangentImpulse = mp0.tangentImpulse;
               if(listener)
               {
                  cp.position = b1.GetWorldPoint(mp.localPoint1);
                  v1 = b1.GetLinearVelocityFromLocalPoint(mp.localPoint1);
                  v2 = b2.GetLinearVelocityFromLocalPoint(mp.localPoint2);
                  cp.velocity.Set(v2.x - v1.x,v2.y - v1.y);
                  cp.normal.SetV(this.m_manifold.normal);
                  cp.separation = mp.separation;
                  cp.id.key = mp.id._key;
                  listener.Persist(cp);
               }
            }
         }
         else
         {
            m_manifoldCount = 0;
            if(this.m0.pointCount > 0 && Boolean(listener))
            {
               mp0 = this.m0.points[0];
               cp.position = b1.GetWorldPoint(mp0.localPoint1);
               v1 = b1.GetLinearVelocityFromLocalPoint(mp0.localPoint1);
               v2 = b2.GetLinearVelocityFromLocalPoint(mp0.localPoint2);
               cp.velocity.Set(v2.x - v1.x,v2.y - v1.y);
               cp.normal.SetV(this.m0.normal);
               cp.separation = mp0.separation;
               cp.id.key = mp0.id._key;
               listener.Remove(cp);
            }
         }
      }
      
      override public function GetManifolds() : Array
      {
         return this.m_manifolds;
      }
   }
}
