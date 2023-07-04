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
   
   public dynamic class TIMMY_bump_back_149 extends MovieClip
   {
       
      
      public function TIMMY_bump_back_149()
      {
         super();
         addFrameScript(14,this.frame15);
      }
      
      internal function frame15() : *
      {
         if(parent)
         {
            MovieClip(parent).gotoAndStop("idle_" + MovieClip(parent).obj.animDirection);
         }
         stop();
      }
   }
}
