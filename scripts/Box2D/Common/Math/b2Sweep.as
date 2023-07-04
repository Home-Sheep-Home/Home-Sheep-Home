package Box2D.Common.Math
{
   public class b2Sweep
   {
       
      
      public var localCenter:Box2D.Common.Math.b2Vec2;
      
      public var a:Number;
      
      public var c:Box2D.Common.Math.b2Vec2;
      
      public var a0:Number;
      
      public var c0:Box2D.Common.Math.b2Vec2;
      
      public var t0:Number;
      
      public function b2Sweep()
      {
         this.localCenter = new Box2D.Common.Math.b2Vec2();
         this.c0 = new Box2D.Common.Math.b2Vec2();
         this.c = new Box2D.Common.Math.b2Vec2();
         super();
      }
      
      public function Advance(t:Number) : void
      {
         var alpha:Number = NaN;
         if(this.t0 < t && 1 - this.t0 > Number.MIN_VALUE)
         {
            alpha = (t - this.t0) / (1 - this.t0);
            this.c0.x = (1 - alpha) * this.c0.x + alpha * this.c.x;
            this.c0.y = (1 - alpha) * this.c0.y + alpha * this.c.y;
            this.a0 = (1 - alpha) * this.a0 + alpha * this.a;
            this.t0 = t;
         }
      }
      
      public function GetXForm(xf:b2XForm, t:Number) : void
      {
         var alpha:Number = NaN;
         var angle:Number = NaN;
         if(1 - this.t0 > Number.MIN_VALUE)
         {
            alpha = (t - this.t0) / (1 - this.t0);
            xf.position.x = (1 - alpha) * this.c0.x + alpha * this.c.x;
            xf.position.y = (1 - alpha) * this.c0.y + alpha * this.c.y;
            angle = (1 - alpha) * this.a0 + alpha * this.a;
            xf.R.Set(angle);
         }
         else
         {
            xf.position.SetV(this.c);
            xf.R.Set(this.a);
         }
         var tMat:b2Mat22 = xf.R;
         xf.position.x -= tMat.col1.x * this.localCenter.x + tMat.col2.x * this.localCenter.y;
         xf.position.y -= tMat.col1.y * this.localCenter.x + tMat.col2.y * this.localCenter.y;
      }
   }
}
