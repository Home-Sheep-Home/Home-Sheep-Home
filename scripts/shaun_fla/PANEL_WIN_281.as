package shaun_fla
{
   import com.aardman.app.Game;
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   public dynamic class PANEL_WIN_281 extends MovieClip
   {
       
      
      public var txtBestTime:TextField;
      
      public var txtScore:TextField;
      
      public var txtBonus:TextField;
      
      public var txtMessage:TextField;
      
      public var txtTime:TextField;
      
      public function PANEL_WIN_281()
      {
         super();
         addFrameScript(1,this.frame2);
      }
      
      internal function frame2() : *
      {
         Game.inst.setupLevelWon();
         stop();
      }
   }
}
