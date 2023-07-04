package shaun_fla
{
   import flash.display.MovieClip;
   
   public dynamic class sheepHighlight_94 extends MovieClip
   {
       
      
      public function sheepHighlight_94()
      {
         super();
         addFrameScript(0,this.frame1,39,this.frame40);
      }
      
      internal function frame40() : *
      {
         gotoAndPlay("active");
      }
      
      internal function frame1() : *
      {
         gotoAndStop("idle");
      }
   }
}
