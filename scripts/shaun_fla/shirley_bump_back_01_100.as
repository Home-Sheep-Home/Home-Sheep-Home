package shaun_fla
{
   import adobe.utils.*;
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
   
   public dynamic class shirley_bump_back_01_100 extends MovieClip
   {
       
      
      public function shirley_bump_back_01_100()
      {
         super();
         addFrameScript(59,this.frame60);
      }
      
      internal function frame60() : *
      {
         if(parent)
         {
            MovieClip(parent).gotoAndStop("idle_" + MovieClip(parent).obj.animDirection);
         }
         stop();
      }
   }
}
