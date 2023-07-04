package Box2D.Dynamics
{
   import Box2D.Collision.Shapes.b2FilterData;
   import Box2D.Collision.Shapes.b2Shape;
   
   public class b2ContactFilter
   {
      
      public static var b2_defaultFilter:Box2D.Dynamics.b2ContactFilter = new Box2D.Dynamics.b2ContactFilter();
       
      
      public function b2ContactFilter()
      {
         super();
      }
      
      public function ShouldCollide(shape1:b2Shape, shape2:b2Shape) : Boolean
      {
         var filter1:b2FilterData = shape1.GetFilterData();
         var filter2:b2FilterData = shape2.GetFilterData();
         if(filter1.groupIndex == filter2.groupIndex && filter1.groupIndex != 0)
         {
            return filter1.groupIndex > 0;
         }
         return (filter1.maskBits & filter2.categoryBits) != 0 && (filter1.categoryBits & filter2.maskBits) != 0;
      }
   }
}
