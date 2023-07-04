package shaun_fla
{
   import com.deeperbeige.lib3as.Sounds;
   import flash.display.MovieClip;
   
   public dynamic class physicsSwitch_190 extends MovieClip
   {
       
      
      public var isSwitch:MovieClip;
      
      public function physicsSwitch_190()
      {
         super();
         addFrameScript(0,this.frame1,10,this.frame11);
      }
      
      internal function frame1() : *
      {
         stop();
      }
      
      internal function frame11() : *
      {
         Sounds.play("switch");
      }
   }
}
