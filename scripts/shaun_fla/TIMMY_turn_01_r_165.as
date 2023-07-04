package shaun_fla
{
   import flash.display.MovieClip;
   
   public dynamic class TIMMY_turn_01_r_165 extends MovieClip
   {
       
      
      public function TIMMY_turn_01_r_165()
      {
         super();
         addFrameScript(3,this.frame4);
      }
      
      internal function frame4() : *
      {
         if(parent != null)
         {
            MovieClip(parent).gotoAndStop("walk_r");
         }
         stop();
      }
   }
}
