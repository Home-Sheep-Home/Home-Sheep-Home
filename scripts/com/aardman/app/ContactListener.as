package com.aardman.app
{
   import Box2D.Collision.b2ContactPoint;
   import Box2D.Dynamics.b2ContactListener;
   import flash.display.MovieClip;
   
   public class ContactListener extends b2ContactListener
   {
       
      
      public var removals:Array;
      
      public var contacts:Array;
      
      public function ContactListener()
      {
         this.contacts = new Array();
         this.removals = new Array();
         super();
      }
      
      override public function Add(point:b2ContactPoint) : void
      {
         var item1:MovieClip = MovieClip(point.shape1.GetBody().GetUserData());
         var item2:MovieClip = MovieClip(point.shape2.GetBody().GetUserData());
         if(!item1)
         {
            return;
         }
         if(!item2)
         {
            return;
         }
         if(point.shape1.IsSensor())
         {
            return;
         }
         if(point.shape2.IsSensor())
         {
            return;
         }
         this.contacts.push(new Contact(item1,item2,point.velocity.Copy()));
      }
   }
}
