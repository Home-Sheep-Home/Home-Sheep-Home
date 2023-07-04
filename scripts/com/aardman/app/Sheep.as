package com.aardman.app
{
   import Box2D.Collision.*;
   import Box2D.Collision.Shapes.*;
   import Box2D.Common.Math.*;
   import Box2D.Dynamics.*;
   import Box2D.Dynamics.Joints.*;
   import com.deeperbeige.lib3as.Sounds;
   import flash.display.*;
   import flash.events.*;
   import flash.geom.*;
   import flash.net.*;
   import gs.easing.*;
   
   public class Sheep
   {
       
      
      public var animState:String = "idle";
      
      private var animPrevState:String = "";
      
      private var state:String = "init";
      
      public var impulseAir:Number = 0.05;
      
      public var id:String = "";
      
      public var animPrevHitL:Boolean = false;
      
      public var canJump:Boolean = false;
      
      public var selected:Boolean = false;
      
      public var animPrevHitR:Boolean = false;
      
      public var animPrevHitT:Boolean = false;
      
      public var impulseJump:Number = 5;
      
      public var animHitL:Boolean = false;
      
      public var maxAir:Number = 1;
      
      private var clip:MovieClip;
      
      public var animHitT:Boolean = false;
      
      public var contacts:Number = 0;
      
      public var maxWalk:Number = 2;
      
      public var animHitR:Boolean = false;
      
      public var footOffsetY:Number = -5;
      
      public var impulseWalk:Number = 0.1;
      
      public var animDirection:String = "r";
      
      private var haventPushedSince:int = 10;
      
      public var jumpDelay:int = 0;
      
      public var footWidth:Number = 39;
      
      private var animPrevDirection:String = "r";
      
      private var prevSelected:Boolean = false;
      
      public function Sheep(sheepClip:MovieClip, sheepID:String)
      {
         super();
         this.clip = sheepClip;
         this.id = sheepID;
         this.clip.id = sheepID;
         switch(this.id)
         {
            case "shirley":
               this.impulseJump = 5;
               this.impulseWalk = 1;
               this.impulseAir = 0.5;
               this.maxWalk = 3.2;
               this.maxAir = 3;
               this.footWidth = 39;
               this.footOffsetY = -5;
               break;
            case "shaun":
               this.impulseJump = 6.3;
               this.impulseWalk = 0.3;
               this.impulseAir = 0.2;
               this.maxWalk = 4;
               this.maxAir = 4;
               this.footWidth = 29;
               this.footOffsetY = -5;
               break;
            case "timmy":
               this.impulseJump = 5;
               this.impulseWalk = 0.1;
               this.impulseAir = 0.1;
               this.maxWalk = 3.5;
               this.maxAir = 3;
               this.footWidth = 12;
               this.footOffsetY = -5;
         }
         this.state = "active";
      }
      
      public function tryJump() : *
      {
         if(!this.canJump)
         {
            return;
         }
         if(this.jumpDelay > 0)
         {
            return;
         }
         this.jumpDelay = 10;
      }
      
      public function walkForce(dir:Number) : *
      {
         var impulse:Number = this.canJump ? this.impulseWalk : this.impulseAir;
         var maxSpeed:Number = this.canJump ? this.maxWalk : this.maxAir;
         var dx:Number = 0;
         var v:b2Vec2 = this.clip.body.GetLinearVelocity();
         if(dir < 0 && v.x > -maxSpeed)
         {
            dx = -impulse;
         }
         if(dir > 0 && v.x < maxSpeed)
         {
            dx = impulse;
         }
         this.animDirection = dir > 0 ? "r" : "l";
         if(this.animState != "jump_up" && this.animState != "jump_apex" && this.animState != "jump_down" && this.animState != "jump_land")
         {
            if(this.haventPushedSince >= 2)
            {
               this.animState = "walk";
            }
            if(this.animDirection == "l" && this.animHitL)
            {
               this.animState = "push";
               this.haventPushedSince = 0;
            }
            if(this.animDirection == "r" && this.animHitR)
            {
               this.animState = "push";
               this.haventPushedSince = 0;
            }
         }
         this.clip.body.ApplyImpulse(new b2Vec2(dx,0),this.clip.body.GetWorldCenter());
      }
      
      public function evtEnterFrame() : *
      {
         var v:b2Vec2 = null;
         if(this.canJump && this.jumpDelay <= 0)
         {
            if(this.animState == "victory" || this.animState == "shocked")
            {
               return;
            }
            if(this.animState == "jump_down")
            {
               this.animState = "jump_land";
            }
            else if(this.selected)
            {
               if(this.haventPushedSince >= 2)
               {
                  this.animState = "alert";
               }
            }
            else
            {
               if(this.animState != "bump_face" && this.animState != "bump_tail" && this.animState != "bump_back")
               {
                  this.animState = "idle";
               }
               if(this.animHitL && !this.animPrevHitL)
               {
                  this.animState = this.animDirection == "r" ? "bump_tail" : "bump_face";
               }
               if(this.animHitR && !this.animPrevHitR)
               {
                  this.animState = this.animDirection == "r" ? "bump_face" : "bump_tail";
               }
               if(this.animHitT && !this.animPrevHitT)
               {
                  this.animState = "bump_back";
               }
            }
         }
         else
         {
            v = this.clip.body.GetLinearVelocity();
            if(v.y < -0.5)
            {
               this.animState = "jump_up";
            }
            if(v.y >= -0.5 && v.y <= 0.5)
            {
               this.animState = "jump_apex";
            }
            if(v.y > 0.5)
            {
               this.animState = "jump_down";
            }
         }
      }
      
      public function evtCheckJump() : *
      {
         this.canJump = false;
         if(this.jumpDelay == 9)
         {
            this.doJump();
         }
         --this.jumpDelay;
         ++this.haventPushedSince;
      }
      
      private function doJump() : *
      {
         var v:b2Vec2 = this.clip.body.GetLinearVelocity();
         v.y = Math.max(Math.min(v.y,0) - this.impulseJump,-17);
         this.clip.body.SetLinearVelocity(v);
         Sounds.play("jump" + this.id);
         this.animState = "jump_up";
      }
      
      public function paint() : *
      {
         var combinedState:String = this.animState + "_" + this.animDirection;
         if(this.animPrevState == combinedState)
         {
            return;
         }
         switch(this.animState)
         {
            case "idle":
               Sounds.stop(this.id + "walkloop");
               this.clip.gotoAndStop(combinedState);
               break;
            case "alert":
               Sounds.stop(this.id + "walkloop");
               if(this.prevSelected == true)
               {
                  this.clip.gotoAndStop("alert_static_" + this.animDirection);
               }
               else
               {
                  this.clip.gotoAndStop(combinedState);
               }
               break;
            case "walk":
            case "push":
               if(!this.canJump)
               {
                  return;
               }
               Sounds.stop(this.id + "walkloop");
               Sounds.play(this.id + "walkloop",true);
               if(this.animPrevDirection != this.animDirection)
               {
                  this.clip.gotoAndStop("turn_" + this.animPrevDirection);
               }
               else
               {
                  this.clip.gotoAndStop(combinedState);
               }
               break;
            case "jump_land":
               Sounds.play(this.id + "land");
            case "jump_up":
            case "jump_apex":
            case "jump_down":
               Sounds.stop(this.id + "walkloop");
               this.clip.gotoAndStop(combinedState);
               break;
            case "bump_face":
            case "bump_tail":
            case "bump_back":
               Sounds.stop(this.id + "walkloop");
               if(this.clip.currentFrameLabel == "idle_l" || this.clip.currentFrameLabel == "idle_r")
               {
                  this.clip.gotoAndStop(combinedState);
               }
               if(!Sounds.inst.isPlaying(this.id + "voice"))
               {
                  Sounds.play(this.id + "bump");
               }
               break;
            case "victory":
            case "shocked":
               Sounds.stop(this.id + "walkloop");
               this.clip.gotoAndStop("alert_" + this.animDirection);
               break;
            default:
               trace(this.id + ": unhandled animState " + combinedState);
         }
         this.animPrevState = combinedState;
         this.animPrevDirection = this.animDirection;
         this.prevSelected = this.selected;
         this.animPrevHitL = this.animHitL;
         this.animPrevHitR = this.animHitR;
         this.animPrevHitT = this.animHitT;
         this.animHitL = false;
         this.animHitR = false;
         this.animHitT = false;
      }
   }
}
