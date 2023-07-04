package shaun_fla
{
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public dynamic class checkbox_76 extends MovieClip
   {
       
      
      public var selected:Boolean;
      
      public var btn:SimpleButton;
      
      public function checkbox_76()
      {
         super();
         addFrameScript(0,this.frame1,10,this.frame11,20,this.frame21);
      }
      
      internal function frame21() : *
      {
         this.selected = false;
      }
      
      internal function frame1() : *
      {
         this.btn.addEventListener(MouseEvent.CLICK,this.evtToggle);
         gotoAndStop(this.selected ? "on" : "off");
      }
      
      public function evtToggle(e:Event) : *
      {
         gotoAndStop(this.selected ? "off" : "on");
      }
      
      internal function frame11() : *
      {
         this.selected = true;
      }
   }
}
