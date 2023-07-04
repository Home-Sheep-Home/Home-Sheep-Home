package com.aardman.app
{
   import Box2D.Common.Math.b2Vec2;
   import flash.display.MovieClip;
   
   public class Contact
   {
       
      
      public var item1:MovieClip;
      
      public var velocity:b2Vec2;
      
      public var item2:MovieClip;
      
      public function Contact(s1:MovieClip, s2:MovieClip, v:b2Vec2)
      {
         super();
         this.item1 = s1;
         this.item2 = s2;
         this.velocity = v;
      }
   }
}
