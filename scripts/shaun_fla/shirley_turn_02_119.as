package shaun_fla
{
   import flash.display.MovieClip;
   
   public dynamic class shirley_turn_02_119 extends MovieClip
   {
       
      
      public function shirley_turn_02_119()
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
