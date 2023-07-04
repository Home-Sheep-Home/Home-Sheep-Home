package shaun_fla
{
   import com.deeperbeige.lib3as.Sounds;
   import flash.display.MovieClip;
   
   public dynamic class physicsGate_187 extends MovieClip
   {
       
      
      public var isWall:MovieClip;
      
      public function physicsGate_187()
      {
         super();
         addFrameScript(0,this.frame1,10,this.frame11,14,this.frame15,15,this.frame16,19,this.frame20);
      }
      
      internal function frame15() : *
      {
         stop();
      }
      
      internal function frame16() : *
      {
         Sounds.play("gateopen");
      }
      
      internal function frame1() : *
      {
         stop();
      }
      
      internal function frame20() : *
      {
         stop();
      }
      
      internal function frame11() : *
      {
         Sounds.play("gateopen");
      }
   }
}
