package Box2D.Dynamics.Contacts
{
   import Box2D.Collision.*;
   import Box2D.Collision.Shapes.*;
   import Box2D.Common.*;
   import Box2D.Common.Math.*;
   import Box2D.Dynamics.*;
   
   public class b2Contact
   {
      
      public static var e_toiFlag:uint = 8;
      
      public static var e_nonSolidFlag:uint = 1;
      
      public static var e_slowFlag:uint = 2;
      
      public static var e_islandFlag:uint = 4;
      
      public static var s_registers:Array;
      
      public static var s_initialized:Boolean = false;
       
      
      public var m_shape1:b2Shape;
      
      public var m_shape2:b2Shape;
      
      public var m_prev:Box2D.Dynamics.Contacts.b2Contact;
      
      public var m_toi:Number;
      
      public var m_next:Box2D.Dynamics.Contacts.b2Contact;
      
      public var m_friction:Number;
      
      public var m_manifoldCount:int;
      
      public var m_node1:Box2D.Dynamics.Contacts.b2ContactEdge;
      
      public var m_node2:Box2D.Dynamics.Contacts.b2ContactEdge;
      
      public var m_restitution:Number;
      
      public var m_flags:uint;
      
      public function b2Contact(s1:b2Shape = null, s2:b2Shape = null)
      {
         this.m_node1 = new Box2D.Dynamics.Contacts.b2ContactEdge();
         this.m_node2 = new Box2D.Dynamics.Contacts.b2ContactEdge();
         super();
         this.m_flags = 0;
         if(!s1 || !s2)
         {
            this.m_shape1 = null;
            this.m_shape2 = null;
            return;
         }
         if(s1.IsSensor() || s2.IsSensor())
         {
            this.m_flags |= e_nonSolidFlag;
         }
         this.m_shape1 = s1;
         this.m_shape2 = s2;
         this.m_manifoldCount = 0;
         this.m_friction = Math.sqrt(this.m_shape1.m_friction * this.m_shape2.m_friction);
         this.m_restitution = b2Math.b2Max(this.m_shape1.m_restitution,this.m_shape2.m_restitution);
         this.m_prev = null;
         this.m_next = null;
         this.m_node1.contact = null;
         this.m_node1.prev = null;
         this.m_node1.next = null;
         this.m_node1.other = null;
         this.m_node2.contact = null;
         this.m_node2.prev = null;
         this.m_node2.next = null;
         this.m_node2.other = null;
      }
      
      public static function InitializeRegisters() : void
      {
         var j:int = 0;
         s_registers = new Array(b2Shape.e_shapeTypeCount);
         for(var i:int = 0; i < b2Shape.e_shapeTypeCount; i++)
         {
            s_registers[i] = new Array(b2Shape.e_shapeTypeCount);
            for(j = 0; j < b2Shape.e_shapeTypeCount; j++)
            {
               s_registers[i][j] = new b2ContactRegister();
            }
         }
         AddType(b2CircleContact.Create,b2CircleContact.Destroy,b2Shape.e_circleShape,b2Shape.e_circleShape);
         AddType(b2PolyAndCircleContact.Create,b2PolyAndCircleContact.Destroy,b2Shape.e_polygonShape,b2Shape.e_circleShape);
         AddType(b2PolygonContact.Create,b2PolygonContact.Destroy,b2Shape.e_polygonShape,b2Shape.e_polygonShape);
      }
      
      public static function Destroy(contact:Box2D.Dynamics.Contacts.b2Contact, allocator:*) : void
      {
         if(contact.m_manifoldCount > 0)
         {
            contact.m_shape1.m_body.WakeUp();
            contact.m_shape2.m_body.WakeUp();
         }
         var type1:int = contact.m_shape1.m_type;
         var type2:int = contact.m_shape2.m_type;
         var reg:b2ContactRegister = s_registers[type1][type2];
         var destroyFcn:Function = reg.destroyFcn;
         destroyFcn(contact,allocator);
      }
      
      public static function AddType(createFcn:Function, destroyFcn:Function, type1:int, type2:int) : void
      {
         s_registers[type1][type2].createFcn = createFcn;
         s_registers[type1][type2].destroyFcn = destroyFcn;
         s_registers[type1][type2].primary = true;
         if(type1 != type2)
         {
            s_registers[type2][type1].createFcn = createFcn;
            s_registers[type2][type1].destroyFcn = destroyFcn;
            s_registers[type2][type1].primary = false;
         }
      }
      
      public static function Create(shape1:b2Shape, shape2:b2Shape, allocator:*) : Box2D.Dynamics.Contacts.b2Contact
      {
         var c:Box2D.Dynamics.Contacts.b2Contact = null;
         var i:int = 0;
         var m:b2Manifold = null;
         if(s_initialized == false)
         {
            InitializeRegisters();
            s_initialized = true;
         }
         var type1:int = shape1.m_type;
         var type2:int = shape2.m_type;
         var reg:b2ContactRegister = s_registers[type1][type2];
         var createFcn:Function = reg.createFcn;
         if(createFcn != null)
         {
            if(reg.primary)
            {
               return createFcn(shape1,shape2,allocator);
            }
            c = createFcn(shape2,shape1,allocator);
            for(i = 0; i < c.m_manifoldCount; i++)
            {
               m = c.GetManifolds()[i];
               m.normal = m.normal.Negative();
            }
            return c;
         }
         return null;
      }
      
      public function IsSolid() : Boolean
      {
         return (this.m_flags & e_nonSolidFlag) == 0;
      }
      
      public function GetShape1() : b2Shape
      {
         return this.m_shape1;
      }
      
      public function GetShape2() : b2Shape
      {
         return this.m_shape2;
      }
      
      public function GetNext() : Box2D.Dynamics.Contacts.b2Contact
      {
         return this.m_next;
      }
      
      public function GetManifoldCount() : int
      {
         return this.m_manifoldCount;
      }
      
      public function GetManifolds() : Array
      {
         return null;
      }
      
      public function Update(listener:b2ContactListener) : void
      {
         var oldCount:int = this.m_manifoldCount;
         this.Evaluate(listener);
         var newCount:int = this.m_manifoldCount;
         var body1:b2Body = this.m_shape1.m_body;
         var body2:b2Body = this.m_shape2.m_body;
         if(newCount == 0 && oldCount > 0)
         {
            body1.WakeUp();
            body2.WakeUp();
         }
         if(body1.IsStatic() || body1.IsBullet() || body2.IsStatic() || body2.IsBullet())
         {
            this.m_flags &= ~e_slowFlag;
         }
         else
         {
            this.m_flags |= e_slowFlag;
         }
      }
      
      public function Evaluate(listener:b2ContactListener) : void
      {
      }
   }
}
