package shaun_fla
{
   import flash.display.MovieClip;
   import mochi.as3.MochiServices;
   
   public dynamic class badgepop_57 extends MovieClip
   {
       
      
      public var badge:MovieClip;
      
      public function badgepop_57()
      {
         super();
         addFrameScript(37,this.frame38);
      }
      
      internal function frame38() : *
      {
         stop();
         MochiServices.addLinkEvent("http://x.mochiads.com/link/b3762cace8ee2c9d","http://www.shaunthesheep.com/games/homesheephome/",this.badge);
      }
   }
}
