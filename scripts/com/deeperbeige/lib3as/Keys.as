package com.deeperbeige.lib3as
{
   import flash.display.DisplayObject;
   import flash.events.KeyboardEvent;
   
   public class Keys
   {
      
      public static const RIGHT:uint = 39;
      
      public static const LEFT:uint = 37;
      
      public static const NUMPAD_DECIMAL:uint = 110;
      
      public static const A:uint = 65;
      
      public static const B:uint = 66;
      
      public static const C:uint = 67;
      
      public static const D:uint = 68;
      
      public static const E:uint = 69;
      
      public static const F:uint = 70;
      
      public static const G:uint = 71;
      
      public static const H:uint = 72;
      
      public static const I:uint = 73;
      
      public static const J:uint = 74;
      
      public static const PAGE_UP:uint = 33;
      
      public static const L:uint = 76;
      
      public static const M:uint = 77;
      
      public static const O:uint = 79;
      
      public static const MINUS:uint = 189;
      
      public static const Q:uint = 81;
      
      public static const PAGE_DOWN:uint = 34;
      
      public static const S:uint = 83;
      
      public static const T:uint = 84;
      
      public static const N:uint = 78;
      
      public static const P:uint = 80;
      
      public static const X:uint = 88;
      
      public static const R:uint = 82;
      
      public static const ALTERNATE:uint = 18;
      
      public static const QUOTE:uint = 222;
      
      public static const V:uint = 86;
      
      public static const W:uint = 87;
      
      public static const BACKSPACE:uint = 8;
      
      public static const Y:uint = 89;
      
      public static const Z:uint = 90;
      
      public static const SHIFT:uint = 16;
      
      public static const K:uint = 75;
      
      public static const U:uint = 85;
      
      public static const WINDOWS_PLAY_PAUSE:uint = 179;
      
      public static const WINDOWS_KEY_LEFT:uint = 91;
      
      public static const NUM_LOCK:uint = 144;
      
      public static const WINDOWS_VOLUME_MUTE:uint = 173;
      
      public static const ESCAPE:uint = 27;
      
      public static const NUMPAD_ADD:uint = 107;
      
      public static const SEMICOLON:uint = 186;
      
      public static const UP:uint = 38;
      
      public static const LEFTBRACKET:uint = 219;
      
      public static const DOWN:uint = 40;
      
      public static const F3:uint = 114;
      
      public static const F5:uint = 116;
      
      public static const F7:uint = 118;
      
      public static const F9:uint = 120;
      
      public static const COMMA:uint = 188;
      
      public static const F6:uint = 117;
      
      public static const ENTER:uint = 13;
      
      public static const INSERT:uint = 45;
      
      public static const END:uint = 35;
      
      public static const NUMBER_2:uint = 50;
      
      public static const F4:uint = 115;
      
      public static const NUMBER_6:uint = 54;
      
      public static const NUMBER_7:uint = 55;
      
      public static const NUMBER_4:uint = 52;
      
      public static const NUMBER_5:uint = 53;
      
      public static const NUMBER_8:uint = 56;
      
      public static const WINDOWS_VOLUME_DOWN:uint = 174;
      
      public static const NUMBER_3:uint = 51;
      
      public static const F1:uint = 112;
      
      public static const F2:uint = 113;
      
      public static const WINDOWS_FORWARD:uint = 167;
      
      public static const NUMBER_0:uint = 48;
      
      public static const NUMBER_1:uint = 49;
      
      public static const F8:uint = 119;
      
      public static const BACKSLASH:uint = 220;
      
      public static const NUMBER_9:uint = 57;
      
      public static const NUMPAD_MULTIPLY:uint = 106;
      
      public static const HOME:uint = 36;
      
      public static const F10:uint = 121;
      
      public static const SPACE:uint = 32;
      
      public static const F12:uint = 123;
      
      public static const F13:uint = 124;
      
      public static const F14:uint = 125;
      
      public static const F11:uint = 122;
      
      public static const F15:uint = 126;
      
      private static var keyDownUsed:Object = new Object();
      
      public static const WINDOWS_VOLUME_UP:uint = 175;
      
      public static const RIGHTBRACKET:uint = 221;
      
      public static const EQUAL:uint = 187;
      
      public static const WINDOWS_KEY_RIGHT:uint = 92;
      
      private static var keycodes:Array = new Array(256);
      
      public static const COMMAND:uint = 15;
      
      public static const CONTROL:uint = 17;
      
      public static const WINDOWS_BACK:uint = 166;
      
      public static const PAUSE_BREAK:uint = 19;
      
      public static const NUMPAD_ENTER:uint = 108;
      
      public static const NUMPAD:uint = 21;
      
      public static const SLASH:uint = 191;
      
      public static const SCROLL_LOCK:uint = 145;
      
      public static const TAB:uint = 9;
      
      public static const WINDOWS_RIGHT_CLICK:uint = 93;
      
      public static const DELETE:uint = 46;
      
      public static const NUMPAD_DIVIDE:uint = 111;
      
      public static const NUMPAD_1:uint = 97;
      
      public static const NUMPAD_2:uint = 98;
      
      public static const PERIOD:uint = 190;
      
      public static const NUMPAD_4:uint = 100;
      
      public static const NUMPAD_5:uint = 101;
      
      public static const NUMPAD_6:uint = 102;
      
      public static const NUMPAD_0:uint = 96;
      
      public static const NUMPAD_8:uint = 104;
      
      public static const NUMPAD_9:uint = 105;
      
      public static const NUMPAD_3:uint = 99;
      
      public static const CAPS_LOCK:uint = 20;
      
      public static const NUMPAD_SUBTRACT:uint = 109;
      
      public static const BACKQUOTE:uint = 192;
      
      public static const NUMPAD_7:uint = 103;
      
      private static var initSprite:DisplayObject;
       
      
      public function Keys()
      {
         super();
      }
      
      private static function onKeyDown(event:KeyboardEvent) : *
      {
         keycodes[event.keyCode] = true;
      }
      
      private static function onKeyUp(event:KeyboardEvent) : *
      {
         keycodes[event.keyCode] = false;
      }
      
      public static function isDown(key:uint) : Boolean
      {
         return keycodes[key];
      }
      
      public static function init(stageSprite:DisplayObject) : *
      {
         stageSprite.stage.addEventListener(KeyboardEvent.KEY_DOWN,onKeyDown,false,int.MAX_VALUE);
         stageSprite.stage.addEventListener(KeyboardEvent.KEY_UP,onKeyUp,false,int.MAX_VALUE - 1);
         initSprite = stageSprite;
         keycodes = new Array(256);
         for(var j:int = 0; j < 256; keycodes[j] = false,j++)
         {
         }
      }
   }
}
