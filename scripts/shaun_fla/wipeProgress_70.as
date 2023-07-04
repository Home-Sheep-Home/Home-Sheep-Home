package shaun_fla
{
   import adobe.utils.*;
   import com.aardman.app.App;
   import com.aardman.app.Levels;
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
   
   public dynamic class wipeProgress_70 extends MovieClip
   {
       
      
      public var btnWipeProgress:SimpleButton;
      
      public var btnCancel:SimpleButton;
      
      public var btnOK:SimpleButton;
      
      public function wipeProgress_70()
      {
         super();
         addFrameScript(0,this.frame1,19,this.frame20,20,this.frame21);
      }
      
      internal function frame1() : *
      {
         stop();
         this.btnWipeProgress.addEventListener(MouseEvent.CLICK,this.evtWipe);
      }
      
      public function evtWipe(e:Event) : *
      {
         this.btnWipeProgress.removeEventListener(MouseEvent.CLICK,this.evtWipe);
         gotoAndPlay("confirm");
      }
      
      internal function frame20() : *
      {
         stop();
         getChildByName("btnOK").addEventListener(MouseEvent.CLICK,this.evtOK);
         getChildByName("btnCancel").addEventListener(MouseEvent.CLICK,this.evtCancel);
      }
      
      internal function frame21() : *
      {
         Levels.initialiseSO();
         App.inst.removeListeners();
         App.inst.initLevels();
         App.inst.setSelectedLevel(App.inst.levels.l0);
         this.btnOK.addEventListener(MouseEvent.CLICK,this.evtClose);
      }
      
      public function evtClose(e:Event) : *
      {
         this.btnOK.removeEventListener(MouseEvent.CLICK,this.evtClose);
         gotoAndStop("idle");
      }
      
      public function removeListeners() : *
      {
         this.btnOK.removeEventListener(MouseEvent.CLICK,this.evtOK);
         this.btnCancel.removeEventListener(MouseEvent.CLICK,this.evtCancel);
      }
      
      public function evtCancel(e:Event) : *
      {
         this.removeListeners();
         gotoAndStop("idle");
      }
      
      public function evtOK(e:Event) : *
      {
         this.removeListeners();
         gotoAndStop("wiped");
      }
   }
}
