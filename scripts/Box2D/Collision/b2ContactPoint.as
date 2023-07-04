package Box2D.Collision
{
   import Box2D.Collision.Shapes.b2Shape;
   import Box2D.Common.Math.b2Vec2;
   
   public class b2ContactPoint
   {
       
      
      public var friction:Number;
      
      public var separation:Number;
      
      public var normal:b2Vec2;
      
      public var position:b2Vec2;
      
      public var restitution:Number;
      
      public var shape1:b2Shape;
      
      public var shape2:b2Shape;
      
      public var id:Box2D.Collision.b2ContactID;
      
      public var velocity:b2Vec2;
      
      public function b2ContactPoint()
      {
         this.position = new b2Vec2();
         this.velocity = new b2Vec2();
         this.normal = new b2Vec2();
         this.id = new Box2D.Collision.b2ContactID();
         super();
      }
   }
}
