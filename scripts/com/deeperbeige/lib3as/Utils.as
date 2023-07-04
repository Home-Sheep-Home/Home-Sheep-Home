package com.deeperbeige.lib3as
{
   import flash.display.MovieClip;
   import flash.media.Sound;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.utils.getDefinitionByName;
   
   public class Utils
   {
       
      
      public function Utils()
      {
         super();
      }
      
      public static function getURL(url:String) : *
      {
         try
         {
            navigateToURL(new URLRequest(url),"_blank");
         }
         catch(e:Error)
         {
         }
      }
      
      public static function createSound(linkage:String) : Sound
      {
         var libraryReference:Class = null;
         try
         {
            libraryReference = getDefinitionByName(linkage) as Class;
         }
         catch(error:ReferenceError)
         {
            trace(error);
            return null;
         }
         return new libraryReference();
      }
      
      public static function createMovieClip(linkage:String) : MovieClip
      {
         var libraryReference:Class = null;
         try
         {
            libraryReference = getDefinitionByName(linkage) as Class;
         }
         catch(error:ReferenceError)
         {
            trace(error);
            return null;
         }
         return new libraryReference();
      }
   }
}
