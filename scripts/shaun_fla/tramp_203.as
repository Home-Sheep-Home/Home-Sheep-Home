package shaun_fla
{
   import adobe.utils.*;
   import com.deeperbeige.lib3as.Sounds;
   import flash.accessibility.*;
   import flash.desktop.*;
   import flash.display.*;
   import flash.errors.*;
   import flash.events.*;
   import flash.external.*;
   import flash.filters.*;
   import flash.geom.*;
   import flash.media.*;
   import flash.net.*;
   import flash.printing.*;
   import flash.profiler.*;
   import flash.sampler.*;
   import flash.system.*;
   import flash.text.*;
   import flash.text.engine.*;
   import flash.ui.*;
   import flash.utils.*;
   import flash.xml.*;
   
   public dynamic class tramp_203 extends MovieClip
   {
       
      
      public function tramp_203()
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
         Sounds.stop(this.soundID);
         Sounds.play(this.soundID);
      }
   }
}
