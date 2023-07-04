package mochi.as3
{
   import flash.utils.Proxy;
   import flash.utils.flash_proxy;
   
   public dynamic class MochiSync extends Proxy
   {
      
      public static var SYNC_PROPERTY:String = "UpdateProperty";
      
      public static var SYNC_REQUEST:String = "SyncRequest";
       
      
      private var _syncContainer:Object;
      
      public function MochiSync()
      {
         super();
         this._syncContainer = {};
      }
      
      override flash_proxy function setProperty(name:*, value:*) : void
      {
         if(this._syncContainer[name] == value)
         {
            return;
         }
         var n:String = String(name.toString());
         this._syncContainer[n] = value;
         MochiServices.send("sync_propUpdate",{
            "name":n,
            "value":value
         });
      }
      
      override flash_proxy function getProperty(name:*) : *
      {
         return this._syncContainer[name];
      }
      
      public function triggerEvent(eventType:String, args:Object) : void
      {
         switch(eventType)
         {
            case SYNC_REQUEST:
               MochiServices.send("sync_syncronize",this._syncContainer);
               break;
            case SYNC_PROPERTY:
               this._syncContainer[args.name] = args.value;
         }
      }
   }
}
