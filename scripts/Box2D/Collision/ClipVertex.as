package Box2D.Collision
{
   import Box2D.Common.Math.b2Vec2;
   
   public class ClipVertex
   {
       
      
      public var id:Box2D.Collision.b2ContactID;
      
      public var v:b2Vec2;
      
      public function ClipVertex()
      {
         this.v = new b2Vec2();
         this.id = new Box2D.Collision.b2ContactID();
         super();
      }
   }
}
