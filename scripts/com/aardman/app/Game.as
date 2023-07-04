package com.aardman.app
{
   import Box2D.Collision.*;
   import Box2D.Collision.Shapes.*;
   import Box2D.Common.Math.*;
   import Box2D.Dynamics.*;
   import Box2D.Dynamics.Contacts.*;
   import Box2D.Dynamics.Joints.*;
   import com.deeperbeige.lib3as.Coords;
   import com.deeperbeige.lib3as.Keys;
   import com.deeperbeige.lib3as.Maths;
   import com.deeperbeige.lib3as.Sounds;
   import com.deeperbeige.lib3as.Stats;
   import com.deeperbeige.lib3as.Transition;
   import flash.display.*;
   import flash.events.*;
   import flash.geom.*;
   import flash.net.*;
   import gs.easing.*;
   
   public class Game
   {
      
      private static var _inst:com.aardman.app.Game;
       
      
      private var level:MovieClip;
      
      private var scrapeFollow:Number = 0;
      
      private var lastPlayed:Object;
      
      private var scrapeMax:Number;
      
      private var state:String;
      
      private var handledExitFrame:Boolean;
      
      private var debugDown:Boolean = false;
      
      private var alreadySetupWin:Boolean = false;
      
      public var world:b2World;
      
      private var levelID:int;
      
      private var endMessage:String = "";
      
      private var shirley:MovieClip;
      
      private var userInterface:MovieClip;
      
      private var scratchMax:Number;
      
      private var nextDown:Boolean = false;
      
      public var resetting:Boolean = false;
      
      private var shaun:MovieClip;
      
      private var spaceDown:Boolean = false;
      
      private var timmy:MovieClip;
      
      private var clip:MovieClip;
      
      private var atmosphereVol:Number;
      
      private var endFrame:int;
      
      private var atmosphereTarget:Number;
      
      private const px_per_m:Number = 0.024651162790697675;
      
      private var atmosphereChoose:int;
      
      private const debug:Boolean = true;
      
      private var scratchFollow:Number = 0;
      
      private var frame:int;
      
      public var contactListener:com.aardman.app.ContactListener;
      
      private var curSheep:MovieClip;
      
      private const m_per_px:Number = 40.56603773584906;
      
      public function Game(mainClip:MovieClip, interfaceClip:MovieClip, levelNum:int)
      {
         this.lastPlayed = {};
         super();
         _inst = this;
         this.state = "init";
         this.clip = mainClip;
         this.userInterface = interfaceClip;
         this.initLevel(levelNum);
         if(App.inst.debug)
         {
            this.clip.addChild(new Stats());
         }
         this.clip.stage.focus = this.clip.stage;
      }
      
      public static function get inst() : com.aardman.app.Game
      {
         return _inst;
      }
      
      public function px2m(px:Number) : Number
      {
         return px * this.px_per_m;
      }
      
      public function updateStatus() : *
      {
      }
      
      public function setupLevelWon() : *
      {
         var levelDef:Object = Levels.defs[this.levelID - 1];
         var underPar:int = levelDef.par - levelDef.best;
         var bonusPoints:int = Math.max(underPar * Levels.FRAME_BONUS,0);
         this.userInterface.levelWon.panelWin.txtTime.text = App.neatTime(this.endFrame);
         this.userInterface.levelWon.panelWin.txtBestTime.text = App.neatTime(levelDef.best);
         this.userInterface.levelWon.panelWin.txtBonus.text = Maths.formatNum(bonusPoints,6);
         this.userInterface.levelWon.panelWin.txtScore.text = Maths.formatNum(Levels.COMPLETE_BONUS + bonusPoints,6);
         this.userInterface.levelWon.panelWin.txtMessage.text = this.endMessage;
      }
      
      private function checkInterfaceKeys() : *
      {
         if(Keys.isDown(Keys.ESCAPE))
         {
            this.evtMenu();
         }
         if(Keys.isDown(Keys.R))
         {
            this.resetting = true;
         }
         else if(this.resetting)
         {
            this.resetLevel();
         }
         if(Keys.isDown(Keys.T) && Keys.isDown(Keys.CONTROL))
         {
            this.debugDown = true;
         }
         else if(this.debugDown)
         {
            this.level.physicsHolder.visible = !this.level.physicsHolder.visible;
            this.debugDown = false;
         }
         if(this.state == "complete" && this.userInterface.levelWon.btnNextLevel.visible == true)
         {
            if(Keys.isDown(Keys.SPACE) || Keys.isDown(Keys.N))
            {
               this.nextDown = true;
            }
            else if(this.nextDown)
            {
               this.nextLevel();
            }
         }
      }
      
      public function m2px(m:Number) : Number
      {
         return m * this.m_per_px;
      }
      
      private function evtEnterFrame(evt:Event) : *
      {
         var p:Point = null;
         var p1:Point = null;
         var p2:Point = null;
         var p3:Point = null;
         var h1:Boolean = false;
         var h2:Boolean = false;
         var h3:Boolean = false;
         ++this.frame;
         this.handledExitFrame = false;
         switch(this.state)
         {
            case "init":
            case "start":
            case "pause":
            case "start":
               break;
            case "transitioning":
               this.world.Step(1 / 30,10);
               this.handleCollisions();
               this.paint();
               if(!Transition.inst.isActive())
               {
                  this.state = "play";
               }
               break;
            case "play":
               this.shirley.obj.evtEnterFrame();
               this.shaun.obj.evtEnterFrame();
               this.timmy.obj.evtEnterFrame();
               this.checkMovementKeys();
               this.checkInterfaceKeys();
               if(this.state != "play")
               {
                  return;
               }
               this.shirley.obj.evtCheckJump();
               this.shaun.obj.evtCheckJump();
               this.timmy.obj.evtCheckJump();
               if(this.level.springSwitch)
               {
                  this.level.springSwitch.touched = false;
               }
               this.world.Step(1 / 30,10);
               this.handleCollisions();
               this.paint();
               if(Boolean(this.level.springSwitch) && Boolean(this.level.springSwitch.active) && !this.level.springSwitch.touched)
               {
                  this.switchInactive(this.level.springSwitch);
               }
               p1 = Coords.getGlobal(this.level.shirley);
               p2 = Coords.getGlobal(this.level.shaun);
               p3 = Coords.getGlobal(this.level.timmy);
               h1 = Boolean(this.level.goal.hitTestPoint(p1.x,p1.y));
               h2 = Boolean(this.level.goal.hitTestPoint(p2.x,p2.y));
               h3 = Boolean(this.level.goal.hitTestPoint(p3.x,p3.y));
               if(h1 && h2 && h3)
               {
                  this.levelComplete();
               }
               break;
            case "complete":
               this.checkInterfaceKeys();
               if(this.state != "complete")
               {
                  return;
               }
               this.world.Step(1 / 30,10);
               this.handleCollisions();
               this.paint();
               break;
            case "failed":
               this.checkInterfaceKeys();
               if(this.state != "failed")
               {
                  return;
               }
               this.world.Step(1 / 30,10);
               this.handleCollisions();
               this.paint();
               break;
            case "ending":
               break;
            default:
               trace("Unknown state: " + this.state);
         }
         this.atmosphereVol += (this.atmosphereTarget - this.atmosphereVol) / 60;
         if(this.frame >= this.atmosphereChoose)
         {
            this.fadeAtmosphere();
         }
         Sounds.volume("atmosphere",this.atmosphereVol);
      }
      
      private function updateScratchMax(item:MovieClip) : *
      {
         var v:b2Vec2 = item.body.GetLinearVelocity();
         var s:Number = v.Length();
         if(s > this.scratchMax)
         {
            this.scratchMax = s;
         }
      }
      
      private function switchInactive(switchClip:MovieClip) : *
      {
         if(!switchClip.active)
         {
            return;
         }
         switchClip.gotoAndStop("off");
         switchClip.active = false;
         switch(this.levelID)
         {
            case 8:
            case 9:
               this.level.gate.gotoAndPlay("closed");
               this.level.gate.bodyRef.SetXForm(new b2Vec2(this.level.gate.origX,this.level.gate.origY),this.level.gate.bodyRef.GetAngle());
         }
      }
      
      public function dispose() : *
      {
         var node:b2Body = null;
         this.clip.removeEventListener(Event.ENTER_FRAME,this.evtEnterFrame);
         this.clip.removeEventListener(Event.EXIT_FRAME,this.evtExitFrame);
         this.userInterface.btnMenu.removeEventListener(MouseEvent.CLICK,this.evtMenu);
         this.userInterface.btnRetry.removeEventListener(MouseEvent.CLICK,this.resetLevel);
         this.userInterface.btn_shirley.removeEventListener(MouseEvent.CLICK,this.evtSelectSheep);
         this.userInterface.btn_shaun.removeEventListener(MouseEvent.CLICK,this.evtSelectSheep);
         this.userInterface.btn_timmy.removeEventListener(MouseEvent.CLICK,this.evtSelectSheep);
         this.level.shirley.removeEventListener(MouseEvent.CLICK,this.evtSelectSheep);
         this.level.shaun.removeEventListener(MouseEvent.CLICK,this.evtSelectSheep);
         this.level.timmy.removeEventListener(MouseEvent.CLICK,this.evtSelectSheep);
         if(this.userInterface.levelLost.panelwin)
         {
            this.userInterface.levelWon.panelWin.btnMenu.removeEventListener(MouseEvent.CLICK,this.evtMenu);
         }
         if(this.userInterface.levelLost.panelwin)
         {
            this.userInterface.levelWon.panelWin.btnTryAgain.removeEventListener(MouseEvent.CLICK,this.resetLevel);
         }
         if(this.userInterface.levelLost.panelwin)
         {
            this.userInterface.levelWon.panelWin.btnNextLevel.removeEventListener(MouseEvent.CLICK,this.nextLevel);
         }
         if(this.userInterface.levelLost.panelLose)
         {
            this.userInterface.levelLost.btnMenu.removeEventListener(MouseEvent.CLICK,this.evtMenu);
         }
         if(this.userInterface.levelLost.panelLose)
         {
            this.userInterface.levelLost.btnTryAgain.removeEventListener(MouseEvent.CLICK,this.resetLevel);
         }
         while(node = this.world.GetBodyList())
         {
            this.world.DestroyBody(node);
         }
         this.world = null;
         App.inst.game = null;
      }
      
      public function removeItem(item:MovieClip) : *
      {
         if(!item.body)
         {
            return;
         }
         this.world.DestroyBody(item.body);
         item.body = null;
         item.visible = false;
         if(item.nonScaled)
         {
            item.nonScaled.visible = false;
         }
      }
      
      private function updateScrapeMax(item:MovieClip) : *
      {
         var v:b2Vec2 = item.body.GetLinearVelocity();
         var s:Number = v.Length();
         if(s > this.scrapeMax)
         {
            this.scrapeMax = s;
         }
      }
      
      private function handleCollisions() : *
      {
         var contact:Contact = null;
         var shape1:b2Shape = null;
         var shape2:b2Shape = null;
         var body1:b2Body = null;
         var body2:b2Body = null;
         var item1:MovieClip = null;
         var item2:MovieClip = null;
         this.scrapeMax = 0;
         this.scratchMax = 0;
         for(var j:int = 0; j < this.contactListener.contacts.length; j++)
         {
            contact = Contact(this.contactListener.contacts[j]);
            if(Boolean(contact.item1.soundThud) || Boolean(contact.item2.soundThud))
            {
               this.collisionNoise("thud",contact);
            }
            if(Boolean(contact.item1.soundThunk) || Boolean(contact.item2.soundThunk))
            {
               this.collisionNoise("thunk",contact);
            }
            if(Boolean(contact.item1.soundClunk) || Boolean(contact.item2.soundClunk))
            {
               this.collisionNoise("clunk",contact);
            }
            if(Boolean(contact.item1.soundClatter) || Boolean(contact.item2.soundClatter))
            {
               this.collisionNoise("clatter",contact);
            }
         }
         this.contactListener.contacts = new Array();
         var c:b2Contact = this.world.m_contactList;
         while(c)
         {
            if(c.GetManifoldCount() != 0)
            {
               shape1 = c.GetShape1();
               shape2 = c.GetShape2();
               body1 = shape1.GetBody();
               body2 = shape2.GetBody();
               item1 = MovieClip(body1.GetUserData());
               item2 = MovieClip(body2.GetUserData());
               if(Boolean(item1.isFailure) && Boolean(item2.isSheep))
               {
                  this.levelFailed();
               }
               if(Boolean(item2.isFailure) && Boolean(item1.isSheep))
               {
                  this.levelFailed();
               }
               if(Boolean(item1.isSwitch) && !body2.IsStatic())
               {
                  this.switchActive(item1);
               }
               if(Boolean(item2.isSwitch) && !body1.IsStatic())
               {
                  this.switchActive(item2);
               }
               if(c.IsSolid())
               {
                  if(Boolean(item1.isSheep) && shape1 == item1.bottomShape)
                  {
                     item1.obj.canJump = true;
                  }
                  if(Boolean(item2.isSheep) && shape2 == item2.bottomShape)
                  {
                     item2.obj.canJump = true;
                  }
                  if(Boolean(item1.isTrampoline) && shape1 == item1.bouncyShape)
                  {
                     this.hitTrampoline(item1,item2);
                  }
                  if(Boolean(item2.isTrampoline) && shape2 == item2.bouncyShape)
                  {
                     this.hitTrampoline(item2,item1);
                  }
                  if(Boolean(item1.isSheep) && shape1 == item1.leftShape)
                  {
                     item1.obj.animHitL = true;
                  }
                  if(Boolean(item2.isSheep) && shape2 == item2.leftShape)
                  {
                     item2.obj.animHitL = true;
                  }
                  if(Boolean(item1.isSheep) && shape1 == item1.rightShape)
                  {
                     item1.obj.animHitR = true;
                  }
                  if(Boolean(item2.isSheep) && shape2 == item2.rightShape)
                  {
                     item2.obj.animHitR = true;
                  }
                  if(Boolean(item1.isSheep) && shape1 == item1.topShape)
                  {
                     item1.obj.animHitT = true;
                  }
                  if(Boolean(item2.isSheep) && shape2 == item2.topShape)
                  {
                     item2.obj.animHitT = true;
                  }
                  if(item1.soundScrape)
                  {
                     this.updateScrapeMax(item1);
                  }
                  if(item2.soundScrape)
                  {
                     this.updateScrapeMax(item2);
                  }
                  if(item1.soundScratch)
                  {
                     this.updateScratchMax(item1);
                  }
                  if(item2.soundScratch)
                  {
                     this.updateScratchMax(item2);
                  }
               }
            }
            c = c.m_next;
         }
         this.scrapeFollow += (this.scrapeMax - this.scrapeFollow) / 6;
         Sounds.volume("pushloop",Math.min(this.scrapeFollow,1));
         this.scratchFollow += (this.scratchMax - this.scratchFollow) / 8;
         Sounds.volume("brickloop",Math.min(this.scratchFollow,0.6));
      }
      
      private function evtExitFrame(evt:Event) : *
      {
         if(this.handledExitFrame)
         {
            return;
         }
         this.handledExitFrame = true;
      }
      
      private function collisionNoise(soundID:String, contact:Contact) : *
      {
         if(!this.lastPlayed[soundID])
         {
            this.lastPlayed[soundID] = 0;
         }
         if(this.lastPlayed[soundID] > this.frame - 3)
         {
            return;
         }
         this.lastPlayed[soundID] = this.frame;
         var speed:Number = contact.velocity.Length() / 17;
         if(speed > 0.3)
         {
            Sounds.play(soundID,false,0,undefined,Math.min(speed,1));
         }
      }
      
      private function hitTrampoline(trampoline:MovieClip, item:MovieClip) : *
      {
         trampoline.gfx.gotoAndPlay("bounce");
         var mass:Number = Number(item.body.GetMass());
         var soundID:String = "trampolineshaun";
         if(mass < 0.5)
         {
            soundID = "trampolinetimmy";
         }
         if(mass > 1)
         {
            soundID = "trampolineshirley";
         }
         trampoline.gfx.soundID = soundID;
      }
      
      public function selectSheep(sheep:MovieClip, playSound:Boolean = true) : *
      {
         var btn:MovieClip = null;
         if(this.curSheep == sheep)
         {
            return;
         }
         btn = MovieClip(this.userInterface.getChildByName("btn_" + this.curSheep.id));
         btn.highlight.gotoAndStop("idle");
         this.curSheep.highlight.gotoAndStop("idle");
         this.curSheep.obj.selected = false;
         this.curSheep = sheep;
         btn = MovieClip(this.userInterface.getChildByName("btn_" + this.curSheep.id));
         btn.highlight.gotoAndStop("active");
         this.curSheep.highlight.gotoAndPlay("active");
         this.curSheep.obj.selected = true;
         if(playSound)
         {
            Sounds.stop(this.curSheep.id + "voice");
            Sounds.play(this.curSheep.id + "alert");
         }
      }
      
      private function initLevel(levelNum:int) : *
      {
         this.levelID = levelNum;
         this.frame = 0;
         this.state = "transitioning";
         this.level = this.clip.level;
         this.shirley = this.clip.level.shirley;
         this.shaun = this.clip.level.shaun;
         this.timmy = this.clip.level.timmy;
         this.curSheep = this.timmy;
         this.shirley.obj = new Sheep(this.shirley,"shirley");
         this.shaun.obj = new Sheep(this.shaun,"shaun");
         this.timmy.obj = new Sheep(this.timmy,"timmy");
         this.level.gotoAndStop(this.levelID);
         this.selectSheep(this.shaun,false);
         this.level.physicsHolder.visible = false;
         this.level.goal.visible = false;
         this.level.shirley.mouseChildren = false;
         this.level.shaun.mouseChildren = false;
         this.level.timmy.mouseChildren = false;
         Sounds.stop("pushloop");
         Sounds.stop("brickloop");
         Sounds.stop("atmosphere");
         Sounds.play("pushloop",true);
         Sounds.play("brickloop",true);
         Sounds.play("atmosphere",true);
         if(this.levelID == 10)
         {
            Sounds.stop("music");
            Sounds.play("timed");
         }
         else if(!Sounds.inst.isPlaying("music"))
         {
            Sounds.play("start");
         }
         this.atmosphereVol = 0;
         this.fadeAtmosphere();
         var levelDef:Object = Levels.defs[this.levelID - 1];
         var hintFrame:int = Math.floor(levelDef.attempts / 1) + 1;
         if(App.inst.showHints)
         {
            ++levelDef.attempts;
         }
         this.level.hints.gotoAndStop(Math.min(this.level.hints.totalFrames,hintFrame));
         Levels.saveToSO();
         this.level.hints.visible = App.inst.showHints;
         if(levelDef.complete)
         {
            this.level.hints.visible = false;
         }
         this.world = LevelGen.createLevelPhysics(this.clip,this.levelID,this.debug);
         this.updateStatus();
         this.clip.addEventListener(Event.ENTER_FRAME,this.evtEnterFrame);
         this.clip.addEventListener(Event.EXIT_FRAME,this.evtExitFrame);
         this.userInterface.btnMenu.addEventListener(MouseEvent.CLICK,this.evtMenu);
         this.userInterface.btnRetry.addEventListener(MouseEvent.CLICK,this.resetLevel);
         this.userInterface.btn_shirley.buttonMode = true;
         this.userInterface.btn_shaun.buttonMode = true;
         this.userInterface.btn_timmy.buttonMode = true;
         this.userInterface.btn_shirley.mouseChildren = false;
         this.userInterface.btn_shaun.mouseChildren = false;
         this.userInterface.btn_timmy.mouseChildren = false;
         this.userInterface.btn_shirley.id = "shirley";
         this.userInterface.btn_shaun.id = "shaun";
         this.userInterface.btn_timmy.id = "timmy";
         this.userInterface.btn_shirley.addEventListener(MouseEvent.CLICK,this.evtSelectSheep);
         this.userInterface.btn_shaun.addEventListener(MouseEvent.CLICK,this.evtSelectSheep);
         this.userInterface.btn_timmy.addEventListener(MouseEvent.CLICK,this.evtSelectSheep);
         this.level.shirley.addEventListener(MouseEvent.CLICK,this.evtSelectSheep);
         this.level.shaun.addEventListener(MouseEvent.CLICK,this.evtSelectSheep);
         this.level.timmy.addEventListener(MouseEvent.CLICK,this.evtSelectSheep);
      }
      
      public function levelComplete() : *
      {
         var diff:String = null;
         var targetFrames:* = undefined;
         if(this.state != "play")
         {
            return;
         }
         this.endMessage = "";
         if(!Sounds.inst.isPlaying("music"))
         {
            Sounds.play("win");
         }
         this.endFrame = this.frame;
         var levelDef:Object = Levels.defs[this.levelID - 1];
         var allCompleted:Boolean = Levels.allCompleted();
         var prevCompleted:Boolean = Boolean(levelDef.complete);
         levelDef.complete = true;
         if(!allCompleted && Levels.allCompleted())
         {
            App.inst.showWinScreen = true;
         }
         if(levelDef.best == 0)
         {
            levelDef.best = this.frame;
         }
         if(this.frame < levelDef.best)
         {
            diff = Maths.formatNum(Math.abs(levelDef.best - this.frame) / 30,1,1);
            this.endMessage = "GREAT! " + diff + " SECONDS FASTER THAN YOUR PREVIOUS BEST";
            levelDef.best = this.frame;
         }
         else if(this.frame == levelDef.best)
         {
            this.endMessage = "GREAT! YOU SET A NEW BEST TIME";
            levelDef.best = this.frame;
         }
         else
         {
            targetFrames = levelDef.best;
            if(levelDef.best > levelDef.par)
            {
               targetFrames = levelDef.par;
            }
            diff = Maths.formatNum(Math.abs(targetFrames - this.frame) / 30,1,1);
            this.endMessage = "FINISH " + diff + " SECONDS FASTER FOR BONUS POINTS";
         }
         Levels.processUnlocks();
         Levels.saveToSO();
         trace("Level " + this.levelID + " complete");
         trace("  Frames:     " + this.frame);
         trace("  Best:       " + levelDef.best);
         trace("  Par:        " + levelDef.par);
         trace("");
         this.state = "complete";
         this.userInterface.levelWon.gotoAndPlay("in");
         this.userInterface.levelWon.btnMenu.addEventListener(MouseEvent.CLICK,this.evtMenu);
         this.userInterface.levelWon.btnTryAgain.addEventListener(MouseEvent.CLICK,this.resetLevel);
         this.userInterface.levelWon.btnNextLevel.addEventListener(MouseEvent.CLICK,this.nextLevel);
         if(this.levelID == Levels.defs.length)
         {
            this.userInterface.levelWon.btnNextLevel.visible = false;
         }
         this.shirley.obj.animState = "victory";
         this.shaun.obj.animState = "victory";
         this.timmy.obj.animState = "victory";
      }
      
      private function paint() : *
      {
         var pos:b2Vec2 = null;
         var dispObj:DisplayObject = null;
         var item:MovieClip = null;
         var a1:Point = null;
         var a2:Point = null;
         var b1:Point = null;
         var b2:Point = null;
         var d1:Point = null;
         var d2:Point = null;
         for(var j:int = 0; j < this.level.numChildren; j++)
         {
            dispObj = this.level.getChildAt(j);
            if(dispObj is MovieClip)
            {
               item = MovieClip(dispObj);
               if(item.body)
               {
                  pos = b2Body(item.body).GetPosition();
                  item.x = this.m2px(pos.x);
                  item.y = this.m2px(pos.y);
                  item.rotation = Maths.radToDeg(b2Body(item.body).GetAngle());
                  if(item.rotationOffset)
                  {
                     item.rotation -= item.rotationOffset;
                  }
                  if(item.isSwing)
                  {
                     a1 = Coords.getLocal(this.level.rope1,this.level);
                     a2 = Coords.getLocal(this.level.rope2,this.level);
                     b1 = Coords.getLocal(item.point1,this.level);
                     b2 = Coords.getLocal(item.point2,this.level);
                     d1 = b1.subtract(a1);
                     d2 = b2.subtract(a2);
                     this.level.rope1.scaleX = d1.length / 100;
                     this.level.rope2.scaleX = d2.length / 100;
                     this.level.rope1.rotation = Maths.radToDeg(Math.atan2(d1.y,d1.x));
                     this.level.rope2.rotation = Maths.radToDeg(Math.atan2(d2.y,d2.x));
                  }
                  if(item.nonScaled)
                  {
                     item.nonScaled.x = item.x;
                     item.nonScaled.y = item.y;
                     item.nonScaled.rotation = item.rotation;
                  }
                  if(item.isSheep)
                  {
                     item.obj.paint();
                  }
               }
            }
         }
      }
      
      public function nextLevel(e:Event = null) : *
      {
         this.state = "transitioning";
         ++App.inst.curLevelID;
         Transition.goto("reset");
         this.dispose();
      }
      
      private function switchActive(switchClip:MovieClip) : *
      {
         switchClip.touched = true;
         if(switchClip.active)
         {
            return;
         }
         switchClip.active = true;
         switchClip.gotoAndStop("on");
         switch(this.levelID)
         {
            case 12:
               this.level.bridgeGfx.gotoAndPlay("open");
               this.level.bridge.bodyRef.SetXForm(new b2Vec2(this.level.bridge.origX,this.level.bridge.origY),this.level.bridge.bodyRef.GetAngle());
               break;
            case 8:
            case 10:
            case 4:
            case 9:
               this.level.gate.gotoAndPlay("open");
               this.level.gate.bodyRef.SetXForm(new b2Vec2(this.level.gate.origX,this.level.gate.origY - this.px2m(this.level.gate.height / 2)),this.level.gate.bodyRef.GetAngle());
         }
      }
      
      private function evtMenu(e:Event = null) : *
      {
         this.state = "transitioning";
         Transition.goto("menu");
         this.dispose();
      }
      
      private function checkMovementKeys() : *
      {
         if(Keys.isDown(Keys.UP) || Keys.isDown(Keys.W) || Keys.isDown(Keys.SPACE))
         {
            this.curSheep.obj.tryJump();
         }
         if(Keys.isDown(Keys.LEFT) || Keys.isDown(Keys.A))
         {
            this.curSheep.obj.walkForce(-1);
         }
         if(Keys.isDown(Keys.RIGHT) || Keys.isDown(Keys.D))
         {
            this.curSheep.obj.walkForce(1);
         }
         if(Keys.isDown(Keys.NUMBER_1) || Keys.isDown(Keys.NUMPAD_1) || Keys.isDown(Keys.F1))
         {
            this.selectSheep(this.shirley);
         }
         if(Keys.isDown(Keys.NUMBER_2) || Keys.isDown(Keys.NUMPAD_2) || Keys.isDown(Keys.F2))
         {
            this.selectSheep(this.shaun);
         }
         if(Keys.isDown(Keys.NUMBER_3) || Keys.isDown(Keys.NUMPAD_3) || Keys.isDown(Keys.F3))
         {
            this.selectSheep(this.timmy);
         }
      }
      
      public function levelFailed() : *
      {
         if(this.state != "play")
         {
            return;
         }
         trace("Level Failed");
         if(!Sounds.inst.isPlaying("music"))
         {
            Sounds.play("fail");
         }
         this.userInterface.levelLost.gotoAndPlay("in");
         this.userInterface.levelLost.btnMenu.addEventListener(MouseEvent.CLICK,this.evtMenu);
         this.userInterface.levelLost.btnTryAgain.addEventListener(MouseEvent.CLICK,this.resetLevel);
         this.shirley.obj.animState = "shocked";
         this.shaun.obj.animState = "shocked";
         this.timmy.obj.animState = "shocked";
         this.state = "failed";
      }
      
      public function resetLevel(e:Event = null) : *
      {
         if(!Sounds.inst.isPlaying("music"))
         {
            Sounds.play("restart");
         }
         this.state = "transitioning";
         Transition.goto("reset");
         this.dispose();
      }
      
      public function fadeAtmosphere() : *
      {
         if(this.state == "play")
         {
            this.atmosphereTarget = Maths.randomNum(0.1,1);
            this.atmosphereChoose = this.frame + Maths.randomInt(30,300);
         }
         else
         {
            this.atmosphereTarget = 0;
            this.atmosphereChoose = this.frame + 30;
         }
      }
      
      public function evtSelectSheep(e:Event) : *
      {
         this.selectSheep(MovieClip(this.level.getChildByName(e.target.id)));
      }
   }
}
