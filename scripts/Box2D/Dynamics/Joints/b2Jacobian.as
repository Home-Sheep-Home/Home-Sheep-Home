package Box2D.Dynamics.Joints
{
   import Box2D.Common.Math.b2Vec2;
   
   public class b2Jacobian
   {
       
      
      public var linear1:b2Vec2;
      
      public var linear2:b2Vec2;
      
      public var angular1:Number;
      
      public var angular2:Number;
      
      public function b2Jacobian()
      {
         this.linear1 = new b2Vec2();
         this.linear2 = new b2Vec2();
         super();
      }
      
      public function Set(x1:b2Vec2, a1:Number, x2:b2Vec2, a2:Number) : void
      {
         this.linear1.SetV(x1);
         this.angular1 = a1;
         this.linear2.SetV(x2);
         this.angular2 = a2;
      }
      
      public function SetZero() : void
      {
         this.linear1.SetZero();
         this.angular1 = 0;
         this.linear2.SetZero();
         this.angular2 = 0;
      }
      
      public function Compute(x1:b2Vec2, a1:Number, x2:b2Vec2, a2:Number) : Number
      {
         return this.linear1.x * x1.x + this.linear1.y * x1.y + this.angular1 * a1 + (this.linear2.x * x2.x + this.linear2.y * x2.y) + this.angular2 * a2;
      }
   }
}
