package Box2D.Common.Math
{
   public class b2XForm
   {
       
      
      public var position:Box2D.Common.Math.b2Vec2;
      
      public var R:Box2D.Common.Math.b2Mat22;
      
      public function b2XForm(pos:Box2D.Common.Math.b2Vec2 = null, r:Box2D.Common.Math.b2Mat22 = null)
      {
         this.position = new Box2D.Common.Math.b2Vec2();
         this.R = new Box2D.Common.Math.b2Mat22();
         super();
         if(pos)
         {
            this.position.SetV(pos);
            this.R.SetM(r);
         }
      }
      
      public function Initialize(pos:Box2D.Common.Math.b2Vec2, r:Box2D.Common.Math.b2Mat22) : void
      {
         this.position.SetV(pos);
         this.R.SetM(r);
      }
      
      public function Set(x:b2XForm) : void
      {
         this.position.SetV(x.position);
         this.R.SetM(x.R);
      }
      
      public function SetIdentity() : void
      {
         this.position.SetZero();
         this.R.SetIdentity();
      }
   }
}
