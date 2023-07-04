package shaun_fla
{
   import flash.display.MovieClip;
   
   public dynamic class shaun_turn_01_r_143 extends MovieClip
   {
       
      
      public function shaun_turn_01_r_143()
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
