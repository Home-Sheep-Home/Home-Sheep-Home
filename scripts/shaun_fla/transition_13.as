package shaun_fla
{
   import flash.display.MovieClip;
   
   public dynamic class transition_13 extends MovieClip
   {
       
      
      public function transition_13()
      {
         super();
         addFrameScript(0,this.frame1,49,this.frame50);
      }
      
      internal function frame50() : *
      {
         gotoAndStop("idle");
      }
      
      internal function frame1() : *
      {
         gotoAndStop("idle");
      }
   }
}
