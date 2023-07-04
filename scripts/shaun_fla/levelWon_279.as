package shaun_fla
{
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   
   public dynamic class levelWon_279 extends MovieClip
   {
       
      
      public var btnTryAgain:SimpleButton;
      
      public var btnNextLevel:SimpleButton;
      
      public var panelWin:MovieClip;
      
      public var btnMenu:SimpleButton;
      
      public function levelWon_279()
      {
         super();
         addFrameScript(0,this.frame1,51,this.frame52);
      }
      
      internal function frame1() : *
      {
         gotoAndStop("idle");
      }
      
      internal function frame52() : *
      {
         stop();
      }
   }
}
