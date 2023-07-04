package Box2D.Collision
{
   import Box2D.Common.Math.b2Vec2;
   
   public class b2ManifoldPoint
   {
       
      
      public var separation:Number;
      
      public var localPoint2:b2Vec2;
      
      public var normalImpulse:Number;
      
      public var tangentImpulse:Number;
      
      public var localPoint1:b2Vec2;
      
      public var id:Box2D.Collision.b2ContactID;
      
      public function b2ManifoldPoint()
      {
         this.localPoint1 = new b2Vec2();
         this.localPoint2 = new b2Vec2();
         this.id = new Box2D.Collision.b2ContactID();
         super();
      }
      
      public function Set(m:b2ManifoldPoint) : void
      {
         this.localPoint1.SetV(m.localPoint1);
         this.localPoint2.SetV(m.localPoint2);
         this.separation = m.separation;
         this.normalImpulse = m.normalImpulse;
         this.tangentImpulse = m.tangentImpulse;
         this.id.key = m.id.key;
      }
      
      public function Reset() : void
      {
         this.localPoint1.SetZero();
         this.localPoint2.SetZero();
         this.separation = 0;
         this.normalImpulse = 0;
         this.tangentImpulse = 0;
         this.id.key = 0;
      }
   }
}
