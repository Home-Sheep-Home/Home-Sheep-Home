package mochi.as3
{
   public class MochiCoins
   {
      
      public static const STORE_HIDE:String = "StoreHide";
      
      public static const LOGGED_IN:String = "LoggedIn";
      
      public static const STORE_ITEMS:String = "StoreItems";
      
      private static var _dispatcher:mochi.as3.MochiEventDispatcher = new mochi.as3.MochiEventDispatcher();
      
      public static const NO_USER:String = "NoUser";
      
      public static const PROPERTIES_SIZE:String = "PropertiesSize";
      
      public static const ITEM_NEW:String = "ItemNew";
      
      public static const USER_INFO:String = "UserInfo";
      
      public static const IO_ERROR:String = "IOError";
      
      public static const ITEM_OWNED:String = "ItemOwned";
      
      public static const PROPERTIES_SAVED:String = "PropertySaved";
      
      public static const WIDGET_LOADED:String = "WidgetLoaded";
      
      public static const ERROR:String = "Error";
      
      public static const LOGGED_OUT:String = "LoggedOut";
      
      public static const PROFILE_SHOW:String = "ProfileShow";
      
      public static const LOGIN_HIDE:String = "LoginHide";
      
      public static const LOGIN_SHOW:String = "LoginShow";
      
      public static const STORE_SHOW:String = "StoreShow";
      
      public static const PROFILE_HIDE:String = "ProfileHide";
       
      
      public function MochiCoins()
      {
         super();
      }
      
      public static function showItem(options:Object = null) : void
      {
         if(!options || typeof options.item != "string")
         {
            trace("ERROR: showItem call must pass an Object with an item key");
            return;
         }
         MochiServices.bringToTop();
         MochiServices.send("coins_showItem",{"options":options},null,null);
      }
      
      public static function saveUserProperties(properties:Object) : void
      {
         MochiServices.send("coins_saveUserProperties",properties);
      }
      
      public static function triggerEvent(eventType:String, args:Object) : void
      {
         _dispatcher.triggerEvent(eventType,args);
      }
      
      public static function showLoginWidget(options:Object = null) : void
      {
         MochiServices.setContainer();
         MochiServices.bringToTop();
         MochiServices.send("coins_showLoginWidget",{"options":options});
      }
      
      public static function getStoreItems() : void
      {
         MochiServices.send("coins_getStoreItems");
      }
      
      public static function getVersion() : String
      {
         return MochiServices.getVersion();
      }
      
      public static function showStore(options:Object = null) : void
      {
         MochiServices.bringToTop();
         MochiServices.send("coins_showStore",{"options":options},null,null);
      }
      
      public static function addEventListener(eventType:String, delegate:Function) : void
      {
         _dispatcher.addEventListener(eventType,delegate);
      }
      
      public static function getUserInfo() : void
      {
         MochiServices.send("coins_getUserInfo");
      }
      
      public static function hideLoginWidget() : void
      {
         MochiServices.send("coins_hideLoginWidget");
      }
      
      public static function removeEventListener(eventType:String, delegate:Function) : void
      {
         _dispatcher.removeEventListener(eventType,delegate);
      }
      
      public static function showVideo(options:Object = null) : void
      {
         if(!options || typeof options.item != "string")
         {
            trace("ERROR: showVideo call must pass an Object with an item key");
            return;
         }
         MochiServices.bringToTop();
         MochiServices.send("coins_showVideo",{"options":options},null,null);
      }
   }
}
