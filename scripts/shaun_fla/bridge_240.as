package shaun_fla
{
   import com.deeperbeige.lib3as.Sounds;
   import flash.display.MovieClip;
   
   public dynamic class bridge_240 extends MovieClip
   {
       
      
      public function bridge_240()
      {
         super();
         addFrameScript(0,this.frame1,10,this.frame11,15,this.frame16);
      }
      
      internal function frame16() : *
      {
         stop();
      }
      
      internal function frame1() : *
      {
         stop();
      }
      
      internal function frame11() : *
      {
         Sounds.play("rustysqueak");
      }
   }
}
