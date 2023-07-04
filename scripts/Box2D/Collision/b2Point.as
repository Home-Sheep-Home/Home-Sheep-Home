package Box2D.Collision
{
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Common.Math.b2XForm;
   
   public class b2Point
   {
       
      
      public var p:b2Vec2;
      
      public function b2Point()
      {
         this.p = new b2Vec2();
         super();
      }
      
      public function GetFirstVertex(xf:b2XForm) : b2Vec2
      {
         return this.p;
      }
      
      public function Support(xf:b2XForm, vX:Number, vY:Number) : b2Vec2
      {
         return this.p;
      }
   }
}
