package Box2D.Collision.Shapes
{
   import Box2D.Collision.b2AABB;
   import Box2D.Collision.b2BroadPhase;
   import Box2D.Collision.b2Pair;
   import Box2D.Collision.b2Segment;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Common.Math.b2XForm;
   import Box2D.Dynamics.b2Body;
   
   public class b2Shape
   {
      
      public static const e_polygonShape:int = 1;
      
      private static var s_resetAABB:b2AABB = new b2AABB();
      
      private static var s_syncAABB:b2AABB = new b2AABB();
      
      private static var s_proxyAABB:b2AABB = new b2AABB();
      
      public static const e_unknownShape:int = -1;
      
      public static const e_circleShape:int = 0;
      
      public static const e_shapeTypeCount:int = 2;
       
      
      public var m_next:Box2D.Collision.Shapes.b2Shape;
      
      public var m_type:int;
      
      public var m_sweepRadius:Number;
      
      public var m_density:Number;
      
      public var m_filter:Box2D.Collision.Shapes.b2FilterData;
      
      public var m_friction:Number;
      
      public var m_isSensor:Boolean;
      
      public var m_restitution:Number;
      
      public var m_userData;
      
      public var m_proxyId:uint;
      
      public var m_body:b2Body;
      
      public function b2Shape(def:b2ShapeDef)
      {
         super();
         this.m_userData = def.userData;
         this.m_friction = def.friction;
         this.m_restitution = def.restitution;
         this.m_density = def.density;
         this.m_body = null;
         this.m_sweepRadius = 0;
         this.m_next = null;
         this.m_proxyId = b2Pair.b2_nullProxy;
         this.m_filter = def.filter.Copy();
         this.m_isSensor = def.isSensor;
      }
      
      public static function Destroy(shape:Box2D.Collision.Shapes.b2Shape, allocator:*) : void
      {
      }
      
      public static function Create(def:b2ShapeDef, allocator:*) : Box2D.Collision.Shapes.b2Shape
      {
         switch(def.type)
         {
            case e_circleShape:
               return new b2CircleShape(def);
            case e_polygonShape:
               return new b2PolygonShape(def);
            default:
               return null;
         }
      }
      
      public function SetUserData(data:*) : void
      {
         this.m_userData = data;
      }
      
      public function GetSweepRadius() : Number
      {
         return this.m_sweepRadius;
      }
      
      public function GetNext() : Box2D.Collision.Shapes.b2Shape
      {
         return this.m_next;
      }
      
      public function ComputeSweptAABB(aabb:b2AABB, xf1:b2XForm, xf2:b2XForm) : void
      {
      }
      
      public function GetType() : int
      {
         return this.m_type;
      }
      
      public function GetRestitution() : Number
      {
         return this.m_restitution;
      }
      
      public function GetFriction() : Number
      {
         return this.m_friction;
      }
      
      public function GetFilterData() : Box2D.Collision.Shapes.b2FilterData
      {
         return this.m_filter.Copy();
      }
      
      public function TestSegment(xf:b2XForm, lambda:Array, normal:b2Vec2, segment:b2Segment, maxLambda:Number) : Boolean
      {
         return false;
      }
      
      public function RefilterProxy(broadPhase:b2BroadPhase, transform:b2XForm) : void
      {
         if(this.m_proxyId == b2Pair.b2_nullProxy)
         {
            return;
         }
         broadPhase.DestroyProxy(this.m_proxyId);
         var aabb:b2AABB = s_resetAABB;
         this.ComputeAABB(aabb,transform);
         var inRange:Boolean = broadPhase.InRange(aabb);
         if(inRange)
         {
            this.m_proxyId = broadPhase.CreateProxy(aabb,this);
         }
         else
         {
            this.m_proxyId = b2Pair.b2_nullProxy;
         }
      }
      
      public function SetFilterData(filter:Box2D.Collision.Shapes.b2FilterData) : void
      {
         this.m_filter = filter.Copy();
      }
      
      public function GetUserData() : *
      {
         return this.m_userData;
      }
      
      public function Synchronize(broadPhase:b2BroadPhase, transform1:b2XForm, transform2:b2XForm) : Boolean
      {
         if(this.m_proxyId == b2Pair.b2_nullProxy)
         {
            return false;
         }
         var aabb:b2AABB = s_syncAABB;
         this.ComputeSweptAABB(aabb,transform1,transform2);
         if(broadPhase.InRange(aabb))
         {
            broadPhase.MoveProxy(this.m_proxyId,aabb);
            return true;
         }
         return false;
      }
      
      public function ComputeMass(massData:b2MassData) : void
      {
      }
      
      public function IsSensor() : Boolean
      {
         return this.m_isSensor;
      }
      
      public function DestroyProxy(broadPhase:b2BroadPhase) : void
      {
         if(this.m_proxyId != b2Pair.b2_nullProxy)
         {
            broadPhase.DestroyProxy(this.m_proxyId);
            this.m_proxyId = b2Pair.b2_nullProxy;
         }
      }
      
      public function UpdateSweepRadius(center:b2Vec2) : void
      {
      }
      
      public function ComputeAABB(aabb:b2AABB, xf:b2XForm) : void
      {
      }
      
      public function GetBody() : b2Body
      {
         return this.m_body;
      }
      
      public function CreateProxy(broadPhase:b2BroadPhase, transform:b2XForm) : void
      {
         var aabb:b2AABB = s_proxyAABB;
         this.ComputeAABB(aabb,transform);
         var inRange:Boolean = broadPhase.InRange(aabb);
         if(inRange)
         {
            this.m_proxyId = broadPhase.CreateProxy(aabb,this);
         }
         else
         {
            this.m_proxyId = b2Pair.b2_nullProxy;
         }
      }
      
      public function TestPoint(xf:b2XForm, p:b2Vec2) : Boolean
      {
         return false;
      }
   }
}
