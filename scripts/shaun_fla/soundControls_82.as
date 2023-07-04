package shaun_fla
{
   import com.deeperbeige.lib3as.Btn;
   import com.deeperbeige.lib3as.Sounds;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.Event;
   
   public dynamic class soundControls_82 extends MovieClip
   {
       
      
      public var btnSound:SimpleButton;
      
      public function soundControls_82()
      {
         super();
         addFrameScript(0,this.frame1);
      }
      
      public function updateStatus() : *
      {
         gotoAndStop(Sounds.inst.isMuted() ? "off" : "on");
      }
      
      internal function frame1() : *
      {
         stop();
         Btn.init(this.btnSound,this.evtToggleSounds);
         this.updateStatus();
      }
      
      public function evtToggleSounds(e:Event) : *
      {
         Sounds.inst.toggleMute();
         this.updateStatus();
      }
   }
}
