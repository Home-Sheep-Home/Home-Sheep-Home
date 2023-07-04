package shaun_fla
{
   import flash.display.MovieClip;
   
   public dynamic class SheepShaun_120 extends MovieClip
   {
       
      
      public var isSheep:MovieClip;
      
      public var highlight:MovieClip;
      
      public var isShaun:MovieClip;
      
      public function SheepShaun_120()
      {
         super();
         addFrameScript(0,this.frame1);
      }
      
      internal function frame1() : *
      {
         stop();
      }
   }
}
