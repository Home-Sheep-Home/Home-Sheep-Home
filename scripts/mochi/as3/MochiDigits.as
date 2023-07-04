package mochi.as3
{
   public final class MochiDigits
   {
       
      
      private var Sibling:mochi.as3.MochiDigits;
      
      private var Fragment:Number;
      
      private var Encoder:Number;
      
      public function MochiDigits(digit:Number = 0, index:uint = 0)
      {
         super();
         this.Encoder = 0;
         this.setValue(digit,index);
      }
      
      public function reencode() : void
      {
         var newEncode:uint = uint(int(2147483647 * Math.random()));
         this.Fragment ^= newEncode ^ this.Encoder;
         this.Encoder = newEncode;
      }
      
      public function set value(v:Number) : void
      {
         this.setValue(v);
      }
      
      public function toString() : String
      {
         var s:String = String.fromCharCode(this.Fragment ^ this.Encoder);
         if(this.Sibling != null)
         {
            s += this.Sibling.toString();
         }
         return s;
      }
      
      public function setValue(digit:Number = 0, index:uint = 0) : void
      {
         var s:String = digit.toString();
         this.Fragment = s.charCodeAt(index++) ^ this.Encoder;
         if(index < s.length)
         {
            this.Sibling = new mochi.as3.MochiDigits(digit,index);
         }
         else
         {
            this.Sibling = null;
         }
         this.reencode();
      }
      
      public function get value() : Number
      {
         return Number(this.toString());
      }
      
      public function addValue(inc:Number) : void
      {
         this.value += inc;
      }
   }
}
