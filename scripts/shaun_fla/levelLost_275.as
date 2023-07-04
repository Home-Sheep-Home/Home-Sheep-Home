package shaun_fla
{
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   
   public dynamic class levelLost_275 extends MovieClip
   {
       
      
      public var btnTryAgain:SimpleButton;
      
      public var panelLose:MovieClip;
      
      public var btnMenu:SimpleButton;
      
      public function levelLost_275()
      {
         super();
         addFrameScript(0,this.frame1,30,this.frame31);
      }
      
      internal function frame31() : *
      {
         stop();
      }
      
      internal function frame1() : *
      {
         gotoAndStop("idle");
      }
   }
}
