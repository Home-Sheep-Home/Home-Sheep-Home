package shaun_fla
{
   import flash.display.MovieClip;
   
   public dynamic class physicsSpringSwitch_212 extends MovieClip
   {
       
      
      public var isSwitch:MovieClip;
      
      public function physicsSpringSwitch_212()
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
