package Box2D.Common.Math
{
   public class b2Math
   {
      
      public static const b2Mat22_identity:Box2D.Common.Math.b2Mat22 = new Box2D.Common.Math.b2Mat22(0,new Box2D.Common.Math.b2Vec2(1,0),new Box2D.Common.Math.b2Vec2(0,1));
      
      public static const b2Vec2_zero:Box2D.Common.Math.b2Vec2 = new Box2D.Common.Math.b2Vec2(0,0);
      
      public static const b2XForm_identity:Box2D.Common.Math.b2XForm = new Box2D.Common.Math.b2XForm(b2Vec2_zero,b2Mat22_identity);
       
      
      public function b2Math()
      {
         super();
      }
      
      public static function b2CrossVF(a:Box2D.Common.Math.b2Vec2, s:Number) : Box2D.Common.Math.b2Vec2
      {
         return new Box2D.Common.Math.b2Vec2(s * a.y,-s * a.x);
      }
      
      public static function AddVV(a:Box2D.Common.Math.b2Vec2, b:Box2D.Common.Math.b2Vec2) : Box2D.Common.Math.b2Vec2
      {
         return new Box2D.Common.Math.b2Vec2(a.x + b.x,a.y + b.y);
      }
      
      public static function b2IsValid(x:Number) : Boolean
      {
         return isFinite(x);
      }
      
      public static function b2MinV(a:Box2D.Common.Math.b2Vec2, b:Box2D.Common.Math.b2Vec2) : Box2D.Common.Math.b2Vec2
      {
         return new Box2D.Common.Math.b2Vec2(b2Min(a.x,b.x),b2Min(a.y,b.y));
      }
      
      public static function b2MulX(T:Box2D.Common.Math.b2XForm, v:Box2D.Common.Math.b2Vec2) : Box2D.Common.Math.b2Vec2
      {
         var a:Box2D.Common.Math.b2Vec2 = null;
         a = b2MulMV(T.R,v);
         a.x += T.position.x;
         a.y += T.position.y;
         return a;
      }
      
      public static function b2DistanceSquared(a:Box2D.Common.Math.b2Vec2, b:Box2D.Common.Math.b2Vec2) : Number
      {
         var cX:Number = a.x - b.x;
         var cY:Number = a.y - b.y;
         return cX * cX + cY * cY;
      }
      
      public static function b2Swap(a:Array, b:Array) : void
      {
         var tmp:* = a[0];
         a[0] = b[0];
         b[0] = tmp;
      }
      
      public static function b2AbsM(A:Box2D.Common.Math.b2Mat22) : Box2D.Common.Math.b2Mat22
      {
         return new Box2D.Common.Math.b2Mat22(0,b2AbsV(A.col1),b2AbsV(A.col2));
      }
      
      public static function SubtractVV(a:Box2D.Common.Math.b2Vec2, b:Box2D.Common.Math.b2Vec2) : Box2D.Common.Math.b2Vec2
      {
         return new Box2D.Common.Math.b2Vec2(a.x - b.x,a.y - b.y);
      }
      
      public static function b2MulXT(T:Box2D.Common.Math.b2XForm, v:Box2D.Common.Math.b2Vec2) : Box2D.Common.Math.b2Vec2
      {
         var a:Box2D.Common.Math.b2Vec2 = null;
         var tX:Number = NaN;
         a = SubtractVV(v,T.position);
         tX = a.x * T.R.col1.x + a.y * T.R.col1.y;
         a.y = a.x * T.R.col2.x + a.y * T.R.col2.y;
         a.x = tX;
         return a;
      }
      
      public static function b2Abs(a:Number) : Number
      {
         return a > 0 ? a : -a;
      }
      
      public static function b2Clamp(a:Number, low:Number, high:Number) : Number
      {
         return b2Max(low,b2Min(a,high));
      }
      
      public static function b2AbsV(a:Box2D.Common.Math.b2Vec2) : Box2D.Common.Math.b2Vec2
      {
         return new Box2D.Common.Math.b2Vec2(b2Abs(a.x),b2Abs(a.y));
      }
      
      public static function MulFV(s:Number, a:Box2D.Common.Math.b2Vec2) : Box2D.Common.Math.b2Vec2
      {
         return new Box2D.Common.Math.b2Vec2(s * a.x,s * a.y);
      }
      
      public static function b2CrossVV(a:Box2D.Common.Math.b2Vec2, b:Box2D.Common.Math.b2Vec2) : Number
      {
         return a.x * b.y - a.y * b.x;
      }
      
      public static function b2Dot(a:Box2D.Common.Math.b2Vec2, b:Box2D.Common.Math.b2Vec2) : Number
      {
         return a.x * b.x + a.y * b.y;
      }
      
      public static function b2CrossFV(s:Number, a:Box2D.Common.Math.b2Vec2) : Box2D.Common.Math.b2Vec2
      {
         return new Box2D.Common.Math.b2Vec2(-s * a.y,s * a.x);
      }
      
      public static function AddMM(A:Box2D.Common.Math.b2Mat22, B:Box2D.Common.Math.b2Mat22) : Box2D.Common.Math.b2Mat22
      {
         return new Box2D.Common.Math.b2Mat22(0,AddVV(A.col1,B.col1),AddVV(A.col2,B.col2));
      }
      
      public static function b2Distance(a:Box2D.Common.Math.b2Vec2, b:Box2D.Common.Math.b2Vec2) : Number
      {
         var cX:Number = a.x - b.x;
         var cY:Number = a.y - b.y;
         return Math.sqrt(cX * cX + cY * cY);
      }
      
      public static function b2MulTMM(A:Box2D.Common.Math.b2Mat22, B:Box2D.Common.Math.b2Mat22) : Box2D.Common.Math.b2Mat22
      {
         var c1:Box2D.Common.Math.b2Vec2 = new Box2D.Common.Math.b2Vec2(b2Dot(A.col1,B.col1),b2Dot(A.col2,B.col1));
         var c2:Box2D.Common.Math.b2Vec2 = new Box2D.Common.Math.b2Vec2(b2Dot(A.col1,B.col2),b2Dot(A.col2,B.col2));
         return new Box2D.Common.Math.b2Mat22(0,c1,c2);
      }
      
      public static function b2MaxV(a:Box2D.Common.Math.b2Vec2, b:Box2D.Common.Math.b2Vec2) : Box2D.Common.Math.b2Vec2
      {
         return new Box2D.Common.Math.b2Vec2(b2Max(a.x,b.x),b2Max(a.y,b.y));
      }
      
      public static function b2IsPowerOfTwo(x:uint) : Boolean
      {
         return x > 0 && (x & x - 1) == 0;
      }
      
      public static function b2ClampV(a:Box2D.Common.Math.b2Vec2, low:Box2D.Common.Math.b2Vec2, high:Box2D.Common.Math.b2Vec2) : Box2D.Common.Math.b2Vec2
      {
         return b2MaxV(low,b2MinV(a,high));
      }
      
      public static function b2RandomRange(lo:Number, hi:Number) : Number
      {
         var r:Number = Math.random();
         return (hi - lo) * r + lo;
      }
      
      public static function b2MulTMV(A:Box2D.Common.Math.b2Mat22, v:Box2D.Common.Math.b2Vec2) : Box2D.Common.Math.b2Vec2
      {
         return new Box2D.Common.Math.b2Vec2(b2Dot(v,A.col1),b2Dot(v,A.col2));
      }
      
      public static function b2Min(a:Number, b:Number) : Number
      {
         return a < b ? a : b;
      }
      
      public static function b2Random() : Number
      {
         return Math.random() * 2 - 1;
      }
      
      public static function b2MulMM(A:Box2D.Common.Math.b2Mat22, B:Box2D.Common.Math.b2Mat22) : Box2D.Common.Math.b2Mat22
      {
         return new Box2D.Common.Math.b2Mat22(0,b2MulMV(A,B.col1),b2MulMV(A,B.col2));
      }
      
      public static function b2NextPowerOfTwo(x:uint) : uint
      {
         x |= x >> 1 & 2147483647;
         x |= x >> 2 & 1073741823;
         x |= x >> 4 & 268435455;
         x |= x >> 8 & 16777215;
         x |= x >> 16 & 65535;
         return x + 1;
      }
      
      public static function b2Max(a:Number, b:Number) : Number
      {
         return a > b ? a : b;
      }
      
      public static function b2MulMV(A:Box2D.Common.Math.b2Mat22, v:Box2D.Common.Math.b2Vec2) : Box2D.Common.Math.b2Vec2
      {
         return new Box2D.Common.Math.b2Vec2(A.col1.x * v.x + A.col2.x * v.y,A.col1.y * v.x + A.col2.y * v.y);
      }
   }
}
