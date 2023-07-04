package Box2D.Collision.Shapes
{
   public class b2FilterData
   {
       
      
      public var maskBits:uint = 65535;
      
      public var groupIndex:int = 0;
      
      public var categoryBits:uint = 1;
      
      public function b2FilterData()
      {
         super();
      }
      
      public function Copy() : b2FilterData
      {
         var copy:b2FilterData = new b2FilterData();
         copy.categoryBits = this.categoryBits;
         copy.maskBits = this.maskBits;
         copy.groupIndex = this.groupIndex;
         return copy;
      }
   }
}
