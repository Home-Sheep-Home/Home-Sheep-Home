package com.aardman.app
{
   import com.deeperbeige.lib3as.Btn;
   import com.deeperbeige.lib3as.Keys;
   import com.deeperbeige.lib3as.Maths;
   import com.deeperbeige.lib3as.Preloader;
   import com.deeperbeige.lib3as.Sounds;
   import com.deeperbeige.lib3as.Transition;
   import com.mochibot.*;
   import flash.display.LoaderInfo;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.StageAlign;
   import flash.display.StageScaleMode;
   import flash.events.*;
   import flash.geom.Point;
   import flash.net.*;
   import flash.text.TextField;
   import flash.ui.ContextMenu;
   import mochi.as3.*;
   
   public class App extends MovieClip
   {
      
      private static var _inst:com.aardman.app.App;
       
      
      public var txtScore:TextField;
      
      public var mochiHolder:MovieClip;
      
      private var linfo:LoaderInfo;
      
      public var texture:MovieClip;
      
      public var btnContinue:SimpleButton;
      
      public var curLevel:Object;
      
      private var stsUsername:String = "";
      
      public var sounds:Sounds;
      
      public var debug:Boolean = false;
      
      private var runningOnSTS:Boolean = false;
      
      public var transition:MovieClip;
      
      public var curLevelID:int;
      
      public var btnSubmitScore:SimpleButton;
      
      private var levelsClip:MovieClip;
      
      public var gameClip:MovieClip;
      
      public var btnStart:SimpleButton;
      
      public var btnLogin:SimpleButton;
      
      public var levels:MovieClip;
      
      public var preloader:Preloader;
      
      public var gfx:MovieClip;
      
      private var stsUserLoggedIn:Boolean = false;
      
      public var wipeProgress:MovieClip;
      
      private var stsUserSUID:String = "";
      
      public var preloaderAnim:MovieClip;
      
      public var trans:Transition;
      
      public var selectedLevel:MovieClip;
      
      public var popup:MovieClip;
      
      public var userInterface:MovieClip;
      
      public var btnPlay:SimpleButton;
      
      public var whiteFrame:MovieClip;
      
      public var chkHints:MovieClip;
      
      public var showHints:Boolean;
      
      public var soundControls:MovieClip;
      
      public var showWinScreen:Boolean = false;
      
      public var game:com.aardman.app.Game;
      
      public var btnShowScores:SimpleButton;
      
      public function App()
      {
         var params:Object = null;
         super();
         addFrameScript(0,this.frame1,10,this.frame11,40,this.frame41,41,this.frame42,50,this.frame51,51,this.frame52,60,this.frame61,70,this.frame71,80,this.frame81,90,this.frame91,91,this.frame92,100,this.frame101,101,this.frame102,110,this.frame111,111,this.frame112);
         _inst = this;
         this.sounds = new Sounds();
         this.showHints = true;
         this.trans = new Transition(this,this.transition,false);
         Keys.init(this);
         Levels.loadFromSO();
         this.whiteFrame.mouseEnabled = false;
         stage.scaleMode = StageScaleMode.NO_SCALE;
         stage.align = StageAlign.TOP_LEFT;
         stage.focus = null;
         var myMenu:ContextMenu = new ContextMenu();
         myMenu.hideBuiltInItems();
         this.contextMenu = myMenu;
         var myhost:LocalConnection = new LocalConnection();
         var domain:String = myhost.domain;
         this.linfo = root.loaderInfo;
         if(domain.search("shaunthesheep.com") > -1 || domain.search("shaunthesheep.co.uk") > -1)
         {
            this.runningOnSTS = true;
            if(this.linfo != null)
            {
               params = this.linfo.parameters;
               if(params != null && params.hotwire != null)
               {
                  this.stsUserSUID = params.hotwire;
                  this.checkSUID();
               }
            }
         }
      }
      
      public static function get inst() : com.aardman.app.App
      {
         return _inst;
      }
      
      public static function neatTime(frames:int) : String
      {
         var seconds:int = Math.floor(frames / 30);
         var minutes:int = Math.floor(seconds / 60);
         var minuteSeconds:int = seconds % 60;
         return Maths.formatNum(minutes,2) + ":" + Maths.formatNum(minuteSeconds,2);
      }
      
      private function checkSUID() : void
      {
         var loader:URLLoader = new URLLoader();
         loader.addEventListener(Event.COMPLETE,this.handleComplete,false,0,true);
         loader.dataFormat = URLLoaderDataFormat.VARIABLES;
         loader.load(new URLRequest("http://www.shaunthesheep.com/user/suidtn/" + this.stsUserSUID));
      }
      
      internal function frame71() : *
      {
         this.displayScores(Levels.score());
      }
      
      private function overLevel(e:Event) : *
      {
         this.setSelectedLevel(MovieClip(e.target));
      }
      
      public function removeListeners() : *
      {
         var clip:MovieClip = null;
         for(var j:int = 0; j < Levels.defs.length; j++)
         {
            clip = MovieClip(this.levelsClip.getChildByName("l" + j));
            clip.removeEventListener(MouseEvent.CLICK,this.clickLevel);
            clip.removeEventListener(MouseEvent.MOUSE_OVER,this.overLevel);
         }
         this.levelsClip.stage.removeEventListener(KeyboardEvent.KEY_DOWN,this.evtKeyDown);
         this.btnSubmitScore.removeEventListener(MouseEvent.CLICK,this.submitScore);
         this.btnShowScores.removeEventListener(MouseEvent.CLICK,this.showScores);
      }
      
      internal function frame81() : *
      {
         this.displayScores();
      }
      
      private function initGame(clip:MovieClip) : *
      {
         this.game = new com.aardman.app.Game(clip,MovieClip(getChildByName("userInterface")),this.curLevelID + 1);
      }
      
      public function showShaunTheSheepSite(e:Event = null) : *
      {
         var url:String = "http://x.mochiads.com/link/b3762cace8ee2c9d";
         try
         {
            navigateToURL(new URLRequest(url),"_blank");
         }
         catch(e:Error)
         {
         }
      }
      
      private function evtKeyDown(e:KeyboardEvent) : *
      {
         switch(e.keyCode)
         {
            case Keys.LEFT:
               this.switchLevel(-1,0);
               break;
            case Keys.RIGHT:
               this.switchLevel(1,0);
               break;
            case Keys.UP:
               this.switchLevel(0,-1);
               break;
            case Keys.DOWN:
               this.switchLevel(0,1);
               break;
            case Keys.ENTER:
            case Keys.SPACE:
               this.playLevel();
         }
      }
      
      public function evtStart(e:Event) : *
      {
         this.btnStart.removeEventListener(MouseEvent.CLICK,this.evtStart);
         if(this.runningOnSTS && this.stsUsername == "")
         {
            Transition.goto("loginwarn");
         }
         else
         {
            Transition.goto("menu");
         }
      }
      
      internal function frame91() : *
      {
         play();
      }
      
      internal function frame11() : *
      {
         this.preloaderAnim.gotoAndPlay("out");
      }
      
      private function submitScore(e:Event = null) : *
      {
         this.removeListeners();
         Transition.goto("submitscore");
      }
      
      internal function frame1() : *
      {
         this.preloader = new Preloader(this,"loaded",function():*
         {
            preloaderAnim.txtLoaded.text = preloader.strLoaded;
         });
         this.preloader.requiredVersion(10,"versionwarn");
      }
      
      internal function frame101() : *
      {
         play();
      }
      
      public function setSelectedLevel(clip:MovieClip) : *
      {
         if(this.selectedLevel == clip)
         {
            return;
         }
         if(this.selectedLevel)
         {
            this.selectedLevel.gotoAndPlay("out");
         }
         this.selectedLevel = clip;
         this.selectedLevel.gotoAndPlay("over");
      }
      
      public function showLogin(e:Event = null) : *
      {
         var url:String = "/user/login/linkback/games-homesheephome";
         try
         {
            navigateToURL(new URLRequest(url),"_self");
         }
         catch(e:Error)
         {
         }
      }
      
      internal function evtScoresClosed() : *
      {
         Transition.goto("menu");
      }
      
      internal function frame92() : *
      {
         this.initGame(this.gameClip);
         stop();
      }
      
      internal function frame102() : *
      {
         gotoAndStop("game");
      }
      
      private function showScores(e:Event = null) : *
      {
         this.removeListeners();
         Transition.goto("showscores");
      }
      
      private function handleComplete(event:Event) : void
      {
         var loader:URLLoader = URLLoader(event.target);
         if(loader.data.response != "null")
         {
            this.stsUsername = loader.data.response;
         }
      }
      
      private function displayScores(score:int = -1) : *
      {
         var opts:Object;
         var boardID:String;
         var o:Object = null;
         if(this.runningOnSTS)
         {
            trace("Competition scoreboard");
            o = {
               "n":[6,12,10,8,6,12,4,7,7,15,6,1,14,1,3,7],
               "f":function(i:Number, s:String):String
               {
                  if(s.length == 16)
                  {
                     return s;
                  }
                  return this.f(i + 1,s + this.n[i].toString(16));
               }
            };
         }
         else
         {
            trace("Viral scoreboard");
            o = {
               "n":[10,1,10,12,3,10,2,0,11,0,1,2,0,5,7,10],
               "f":function(i:Number, s:String):String
               {
                  if(s.length == 16)
                  {
                     return s;
                  }
                  return this.f(i + 1,s + this.n[i].toString(16));
               }
            };
         }
         boardID = String(o.f(0,""));
         opts = {};
         opts.boardID = boardID;
         opts.onClose = this.evtScoresClosed;
         opts.width = 550;
         opts.height = 350;
         opts.res = "640x480";
         if(score >= 0)
         {
            opts.score = score;
         }
         if(this.stsUsername != "")
         {
            opts.name = this.stsUsername;
         }
         MochiScores.showLeaderboard(opts);
      }
      
      internal function frame111() : *
      {
         this.showWinScreen = false;
         Sounds.stop("music");
         Sounds.play("gamewin");
         play();
      }
      
      internal function frame112() : *
      {
         this.btnContinue.addEventListener(MouseEvent.CLICK,this.evtContinue);
         stop();
      }
      
      public function initLevels(clip:MovieClip = null) : *
      {
         var level:Object = null;
         Sounds.stop("pushloop");
         Sounds.stop("brickloop");
         Sounds.stop("atmosphere");
         if(this.showWinScreen)
         {
            gotoAndStop("win");
            return;
         }
         stage.focus = null;
         Levels.loadFromSO();
         if(clip)
         {
            this.levelsClip = clip;
         }
         for(var j:int = 0; j < Levels.defs.length; j++)
         {
            level = Levels.defs[j];
            clip = MovieClip(this.levelsClip.getChildByName("l" + j));
            clip.txtLevel.text = j + 1;
            clip.lock.visible = true;
            clip.complete.visible = level.complete;
            if(!level.locked || this.debug)
            {
               clip.id = j;
               clip.lock.visible = false;
               clip.buttonMode = true;
               clip.mouseChildren = false;
               clip.addEventListener(MouseEvent.CLICK,this.clickLevel);
               clip.addEventListener(MouseEvent.MOUSE_OVER,this.overLevel);
            }
         }
         this.setSelectedLevel(!!this.curLevelID ? MovieClip(this.levelsClip.getChildByName("l" + this.curLevelID)) : this.levelsClip.l0);
         this.levelsClip.stage.addEventListener(KeyboardEvent.KEY_DOWN,this.evtKeyDown);
         getChildByName("btnSubmitScore").addEventListener(MouseEvent.CLICK,this.submitScore);
         getChildByName("btnShowScores").addEventListener(MouseEvent.CLICK,this.showScores);
         this.txtScore.text = Maths.formatNum(Levels.score(),6);
         if(this.runningOnSTS && this.stsUsername == "")
         {
            getChildByName("btnSubmitScore").visible = false;
         }
      }
      
      internal function frame42() : *
      {
         stop();
         Btn.init(this.btnLogin,this.showLogin);
         Btn.init(this.btnPlay,this.playAnyway);
      }
      
      public function evtContinue(e:Event) : *
      {
         this.btnContinue.removeEventListener(MouseEvent.CLICK,this.evtContinue);
         Transition.goto("menu");
      }
      
      private function switchLevel(dirX:Number, dirY:Number) : *
      {
         var level:Object = null;
         var clip:MovieClip = null;
         var p:Point = null;
         var dist:Number = NaN;
         var dp:Number = NaN;
         var bestClip:MovieClip = null;
         var bestDist:Number = 10000;
         for(var j:int = 0; j < Levels.defs.length; j++)
         {
            level = Levels.defs[j];
            clip = MovieClip(this.levelsClip.getChildByName("l" + j));
            if(!level.locked)
            {
               if(clip != this.selectedLevel)
               {
                  p = new Point(clip.x - this.selectedLevel.x,clip.y - this.selectedLevel.y);
                  dist = p.length;
                  if(dist <= bestDist)
                  {
                     p.normalize(1);
                     dp = Maths.dotProduct(dirX,dirY,p.x,p.y);
                     if(dp >= 0.9)
                     {
                        bestDist = dist;
                        bestClip = clip;
                     }
                  }
               }
            }
         }
         if(bestClip)
         {
            this.setSelectedLevel(bestClip);
         }
      }
      
      internal function frame41() : *
      {
         play();
      }
      
      private function playLevel() : *
      {
         this.removeListeners();
         this.showHints = this.chkHints.selected;
         this.curLevelID = this.selectedLevel.id;
         this.curLevel = Levels.defs[this.selectedLevel.id];
         Transition.goto("game");
      }
      
      internal function frame51() : *
      {
         SoundLib.init(this.sounds);
         MochiBot.track(this,"450d01ec");
         MochiServices.connect("a2fc7f7723264d04",this.mochiHolder);
         if(!Sounds.inst.isPlaying("music"))
         {
            Sounds.play("intro");
         }
         this.texture.mouseEnabled = false;
         if(this.runningOnSTS)
         {
            this.popup.gotoAndStop("idle");
         }
         else
         {
            this.popup.gotoAndPlay("popup");
         }
         play();
      }
      
      internal function frame52() : *
      {
         this.btnStart.addEventListener(MouseEvent.CLICK,this.evtStart);
         stop();
      }
      
      public function playAnyway(e:Event = null) : *
      {
         Transition.goto("menu");
      }
      
      private function clickLevel(e:Event) : *
      {
         this.playLevel();
      }
      
      internal function frame61() : *
      {
         this.chkHints.selected = this.showHints;
         this.initLevels(this.levels);
         if(!Sounds.inst.isPlaying("music"))
         {
            Sounds.play("menu");
         }
      }
   }
}
