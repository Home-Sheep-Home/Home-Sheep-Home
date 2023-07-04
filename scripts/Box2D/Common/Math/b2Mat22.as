package Box2D.Common.Math
{
   public class b2Mat22
   {
       
      
      public var col1:Box2D.Common.Math.b2Vec2;
      
      public var col2:Box2D.Common.Math.b2Vec2;
      
      public function b2Mat22(angle:Number = 0, c1:Box2D.Common.Math.b2Vec2 = null, c2:Box2D.Common.Math.b2Vec2 = null)
      {
         var c:Number = NaN;
         var s:Number = NaN;
         this.col1 = new Box2D.Common.Math.b2Vec2();
         this.col2 = new Box2D.Common.Math.b2Vec2();
         super();
         if(c1 != null && c2 != null)
         {
            this.col1.SetV(c1);
            this.col2.SetV(c2);
         }
         else
         {
            c = Math.cos(angle);
            s = Math.sin(angle);
            this.col1.x = c;
            this.col2.x = -s;
            this.col1.y = s;
            this.col2.y = c;
         }
      }
      
      public function SetIdentity() : void
      {
         this.col1.x = 1;
         this.col2.x = 0;
         this.col1.y = 0;
         this.col2.y = 1;
      }
      
      public function SetVV(c1:Box2D.Common.Math.b2Vec2, c2:Box2D.Common.Math.b2Vec2) : void
      {
         this.col1.SetV(c1);
         this.col2.SetV(c2);
      }
      
      public function Set(angle:Number) : void
      {
         var c:Number = NaN;
         c = Math.cos(angle);
         var s:Number = Math.sin(angle);
         this.col1.x = c;
         this.col2.x = -s;
         this.col1.y = s;
         this.col2.y = c;
      }
      
      public function SetZero() : void
      {
         this.col1.x = 0;
         this.col2.x = 0;
         this.col1.y = 0;
         this.col2.y = 0;
      }
      
      public function SetM(m:b2Mat22) : void
      {
         this.col1.SetV(m.col1);
         this.col2.SetV(m.col2);
      }
      
      public function AddM(m:b2Mat22) : void
      {
         this.col1.x += m.col1.x;
         this.col1.y += m.col1.y;
         this.col2.x += m.col2.x;
         this.col2.y += m.col2.y;
      }
      
      public function Abs() : void
      {
         this.col1.Abs();
         this.col2.Abs();
      }
      
      public function Copy() : b2Mat22
      {
         return new b2Mat22(0,this.col1,this.col2);
      }
      
      public function Invert(out:b2Mat22) : b2Mat22
      {
         var a:Number = NaN;
         var c:Number = NaN;
         var det:Number = NaN;
         a = this.col1.x;
         var b:Number = this.col2.x;
         c = this.col1.y;
         var d:Number = this.col2.y;
         det = a * d - b * c;
         det = 1 / det;
         out.col1.x = det * d;
         out.col2.x = -det * b;
         out.col1.y = -det * c;
         out.col2.y = det * a;
         return out;
      }
      
      public function GetAngle() : Number
      {
         return Math.atan2(this.col1.y,this.col1.x);
      }
      
      public function Solve(out:Box2D.Common.Math.b2Vec2, bX:Number, bY:Number) : Box2D.Common.Math.b2Vec2
      {
         var a11:Number = this.col1.x;
         var a12:Number = this.col2.x;
         var a21:Number = this.col1.y;
         var a22:Number = this.col2.y;
         var det:Number = a11 * a22 - a12 * a21;
         det = 1 / det;
         out.x = det * (a22 * bX - a12 * bY);
         out.y = det * (a11 * bY - a21 * bX);
         return out;
      }
   }
}
