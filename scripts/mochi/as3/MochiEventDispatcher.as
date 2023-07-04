package mochi.as3
{
   public class MochiEventDispatcher
   {
       
      
      private var eventTable:Object;
      
      public function MochiEventDispatcher()
      {
         super();
         this.eventTable = {};
      }
      
      public function triggerEvent(event:String, args:Object) : void
      {
         var i:Object = null;
         if(this.eventTable[event] == undefined)
         {
            return;
         }
         for(i in this.eventTable[event])
         {
            this.eventTable[event][i](args);
         }
      }
      
      public function removeEventListener(event:String, delegate:Function) : void
      {
         var s:Object = null;
         if(this.eventTable[event] == undefined)
         {
            this.eventTable[event] = [];
            return;
         }
         for(s in this.eventTable[event])
         {
            if(this.eventTable[event][s] == delegate)
            {
               this.eventTable[event].splice(Number(s),1);
            }
         }
      }
      
      public function addEventListener(event:String, delegate:Function) : void
      {
         this.removeEventListener(event,delegate);
         this.eventTable[event].push(delegate);
      }
   }
}
