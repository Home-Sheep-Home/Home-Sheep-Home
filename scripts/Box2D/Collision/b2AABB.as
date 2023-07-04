package Box2D.Collision
{
   import Box2D.Common.Math.b2Vec2;
   
   public class b2AABB
   {
       
      
      public var upperBound:b2Vec2;
      
      public var lowerBound:b2Vec2;
      
      public function b2AABB()
      {
         this.lowerBound = new b2Vec2();
         this.upperBound = new b2Vec2();
         super();
      }
      
      public function IsValid() : Boolean
      {
         var dX:Number = this.upperBound.x - this.lowerBound.x;
         var dY:Number = this.upperBound.y - this.lowerBound.y;
         var valid:Boolean = dX >= 0 && dY >= 0;
         return valid && this.lowerBound.IsValid() && this.upperBound.IsValid();
      }
   }
}
