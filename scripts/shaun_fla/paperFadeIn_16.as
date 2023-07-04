package shaun_fla
{
   import com.deeperbeige.lib3as.Transition;
   import flash.display.MovieClip;
   
   public dynamic class paperFadeIn_16 extends MovieClip
   {
       
      
      public var texture:MovieClip;
      
      public function paperFadeIn_16()
      {
         super();
         addFrameScript(13,this.frame14);
      }
      
      internal function frame14() : *
      {
         Transition.goto("intro");
         stop();
      }
   }
}
