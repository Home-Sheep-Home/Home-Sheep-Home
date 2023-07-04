package Box2D.Collision.Shapes
{
   public class b2ShapeDef
   {
       
      
      public var friction:Number = 0.2;
      
      public var isSensor:Boolean = false;
      
      public var density:Number = 0;
      
      public var restitution:Number = 0;
      
      public var userData = null;
      
      public var filter:Box2D.Collision.Shapes.b2FilterData;
      
      public var type:int = -1;
      
      public function b2ShapeDef()
      {
         this.filter = new Box2D.Collision.Shapes.b2FilterData();
         super();
      }
   }
}
