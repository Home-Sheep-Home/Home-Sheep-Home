package Box2D.Dynamics
{
   import Box2D.Collision.*;
   import Box2D.Collision.Shapes.*;
   import Box2D.Common.*;
   import Box2D.Common.Math.*;
   import Box2D.Dynamics.Contacts.*;
   
   public class b2ContactManager extends b2PairCallback
   {
      
      private static const s_evalCP:b2ContactPoint = new b2ContactPoint();
       
      
      public var m_world:Box2D.Dynamics.b2World;
      
      public var m_destroyImmediate:Boolean;
      
      public var m_nullContact:b2NullContact;
      
      public function b2ContactManager()
      {
         this.m_nullContact = new b2NullContact();
         super();
         this.m_world = null;
         this.m_destroyImmediate = false;
      }
      
      override public function PairRemoved(proxyUserData1:*, proxyUserData2:*, pairUserData:*) : void
      {
         if(pairUserData == null)
         {
            return;
         }
         var c:b2Contact = pairUserData as b2Contact;
         if(c == this.m_nullContact)
         {
            return;
         }
         this.Destroy(c);
      }
      
      public function Destroy(c:b2Contact) : void
      {
         var b1:b2Body = null;
         var b2:b2Body = null;
         var manifolds:Array = null;
         var cp:b2ContactPoint = null;
         var i:int = 0;
         var manifold:b2Manifold = null;
         var j:int = 0;
         var mp:b2ManifoldPoint = null;
         var v1:b2Vec2 = null;
         var v2:b2Vec2 = null;
         var shape1:b2Shape = c.m_shape1;
         var shape2:b2Shape = c.m_shape2;
         var manifoldCount:int = c.m_manifoldCount;
         if(manifoldCount > 0 && Boolean(this.m_world.m_contactListener))
         {
            b1 = shape1.m_body;
            b2 = shape2.m_body;
            manifolds = c.GetManifolds();
            cp = s_evalCP;
            cp.shape1 = c.m_shape1;
            cp.shape2 = c.m_shape1;
            cp.friction = c.m_friction;
            cp.restitution = c.m_restitution;
            for(i = 0; i < manifoldCount; i++)
            {
               manifold = manifolds[i];
               cp.normal.SetV(manifold.normal);
               for(j = 0; j < manifold.pointCount; j++)
               {
                  mp = manifold.points[j];
                  cp.position = b1.GetWorldPoint(mp.localPoint1);
                  v1 = b1.GetLinearVelocityFromLocalPoint(mp.localPoint1);
                  v2 = b2.GetLinearVelocityFromLocalPoint(mp.localPoint2);
                  cp.velocity.Set(v2.x - v1.x,v2.y - v1.y);
                  cp.separation = mp.separation;
                  cp.id.key = mp.id._key;
                  this.m_world.m_contactListener.Remove(cp);
               }
            }
         }
         if(c.m_prev)
         {
            c.m_prev.m_next = c.m_next;
         }
         if(c.m_next)
         {
            c.m_next.m_prev = c.m_prev;
         }
         if(c == this.m_world.m_contactList)
         {
            this.m_world.m_contactList = c.m_next;
         }
         var body1:b2Body = shape1.m_body;
         var body2:b2Body = shape2.m_body;
         if(c.m_node1.prev)
         {
            c.m_node1.prev.next = c.m_node1.next;
         }
         if(c.m_node1.next)
         {
            c.m_node1.next.prev = c.m_node1.prev;
         }
         if(c.m_node1 == body1.m_contactList)
         {
            body1.m_contactList = c.m_node1.next;
         }
         if(c.m_node2.prev)
         {
            c.m_node2.prev.next = c.m_node2.next;
         }
         if(c.m_node2.next)
         {
            c.m_node2.next.prev = c.m_node2.prev;
         }
         if(c.m_node2 == body2.m_contactList)
         {
            body2.m_contactList = c.m_node2.next;
         }
         b2Contact.Destroy(c,this.m_world.m_blockAllocator);
         --this.m_world.m_contactCount;
      }
      
      override public function PairAdded(proxyUserData1:*, proxyUserData2:*) : *
      {
         var shape1:b2Shape = proxyUserData1 as b2Shape;
         var shape2:b2Shape = proxyUserData2 as b2Shape;
         var body1:b2Body = shape1.m_body;
         var body2:b2Body = shape2.m_body;
         if(body1.IsStatic() && body2.IsStatic())
         {
            return this.m_nullContact;
         }
         if(shape1.m_body == shape2.m_body)
         {
            return this.m_nullContact;
         }
         if(body2.IsConnected(body1))
         {
            return this.m_nullContact;
         }
         if(this.m_world.m_contactFilter != null && this.m_world.m_contactFilter.ShouldCollide(shape1,shape2) == false)
         {
            return this.m_nullContact;
         }
         var c:b2Contact = b2Contact.Create(shape1,shape2,this.m_world.m_blockAllocator);
         if(c == null)
         {
            return this.m_nullContact;
         }
         shape1 = c.m_shape1;
         shape2 = c.m_shape2;
         body1 = shape1.m_body;
         body2 = shape2.m_body;
         c.m_prev = null;
         c.m_next = this.m_world.m_contactList;
         if(this.m_world.m_contactList != null)
         {
            this.m_world.m_contactList.m_prev = c;
         }
         this.m_world.m_contactList = c;
         c.m_node1.contact = c;
         c.m_node1.other = body2;
         c.m_node1.prev = null;
         c.m_node1.next = body1.m_contactList;
         if(body1.m_contactList != null)
         {
            body1.m_contactList.prev = c.m_node1;
         }
         body1.m_contactList = c.m_node1;
         c.m_node2.contact = c;
         c.m_node2.other = body1;
         c.m_node2.prev = null;
         c.m_node2.next = body2.m_contactList;
         if(body2.m_contactList != null)
         {
            body2.m_contactList.prev = c.m_node2;
         }
         body2.m_contactList = c.m_node2;
         ++this.m_world.m_contactCount;
         return c;
      }
      
      public function Collide() : void
      {
         var body1:b2Body = null;
         var body2:b2Body = null;
         var c:b2Contact = this.m_world.m_contactList;
         while(c)
         {
            body1 = c.m_shape1.m_body;
            body2 = c.m_shape2.m_body;
            if(!(body1.IsSleeping() && body2.IsSleeping()))
            {
               c.Update(this.m_world.m_contactListener);
            }
            c = c.m_next;
         }
      }
   }
}
