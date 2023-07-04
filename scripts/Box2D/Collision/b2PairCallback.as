package Box2D.Collision
{
   public class b2PairCallback
   {
       
      
      public function b2PairCallback()
      {
         super();
      }
      
      public function PairRemoved(proxyUserData1:*, proxyUserData2:*, pairUserData:*) : void
      {
      }
      
      public function PairAdded(proxyUserData1:*, proxyUserData2:*) : *
      {
         return null;
      }
   }
}
