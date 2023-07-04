package Box2D.Collision
{
   public class b2Bound
   {
       
      
      public var value:uint;
      
      public var proxyId:uint;
      
      public var stabbingCount:uint;
      
      public function b2Bound()
      {
         super();
      }
      
      public function Swap(b:b2Bound) : void
      {
         var tempValue:uint = this.value;
         var tempProxyId:uint = this.proxyId;
         var tempStabbingCount:uint = this.stabbingCount;
         this.value = b.value;
         this.proxyId = b.proxyId;
         this.stabbingCount = b.stabbingCount;
         b.value = tempValue;
         b.proxyId = tempProxyId;
         b.stabbingCount = tempStabbingCount;
      }
      
      public function IsLower() : Boolean
      {
         return (this.value & 1) == 0;
      }
      
      public function IsUpper() : Boolean
      {
         return (this.value & 1) == 1;
      }
   }
}
