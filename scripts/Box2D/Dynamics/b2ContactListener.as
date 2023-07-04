package Box2D.Dynamics
{
   import Box2D.Collision.b2ContactPoint;
   import Box2D.Dynamics.Contacts.b2ContactResult;
   
   public class b2ContactListener
   {
       
      
      public function b2ContactListener()
      {
         super();
      }
      
      public function Add(point:b2ContactPoint) : void
      {
      }
      
      public function Remove(point:b2ContactPoint) : void
      {
      }
      
      public function Persist(point:b2ContactPoint) : void
      {
      }
      
      public function Result(point:b2ContactResult) : void
      {
      }
   }
}
