package shaun_fla
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   public dynamic class preloader_shaun_3 extends MovieClip
   {
       
      
      public var txtLoaded:TextField;
      
      public function preloader_shaun_3()
      {
         super();
         addFrameScript(0,this.frame1,19,this.frame20,40,this.frame41);
      }
      
      internal function frame1() : *
      {
         gotoAndPlay("intro");
      }
      
      internal function frame41() : *
      {
         stop();
      }
      
      internal function frame20() : *
      {
         stop();
      }
   }
}
