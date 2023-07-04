package mochi.as3
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   public class MochiScores
   {
      
      private static var boardID:String;
      
      public static var onErrorHandler:Object;
      
      public static var onCloseHandler:Object;
       
      
      public function MochiScores()
      {
         super();
      }
      
      public static function showLeaderboard(options:Object = null) : void
      {
         var n:Number = NaN;
         if(options != null)
         {
            delete options.clip;
            MochiServices.setContainer();
            MochiServices.bringToTop();
            if(options.name != null)
            {
               if(options.name is TextField)
               {
                  if(options.name.text.length > 0)
                  {
                     options.name = options.name.text;
                  }
               }
            }
            if(options.score != null)
            {
               if(options.score is TextField)
               {
                  if(options.score.text.length > 0)
                  {
                     options.score = options.score.text;
                  }
               }
               else if(options.score is MochiDigits)
               {
                  options.score = options.score.value;
               }
               n = Number(options.score);
               if(isNaN(n))
               {
                  trace("ERROR: Submitted score \'" + options.score + "\' will be rejected, score is \'Not a Number\'");
               }
               else if(n == Number.NEGATIVE_INFINITY || n == Number.POSITIVE_INFINITY)
               {
                  trace("ERROR: Submitted score \'" + options.score + "\' will be rejected, score is an infinite");
               }
               else
               {
                  if(Math.floor(n) != n)
                  {
                     trace("WARNING: Submitted score \'" + options.score + "\' will be truncated");
                  }
                  options.score = n;
               }
            }
            if(options.onDisplay != null)
            {
               options.onDisplay();
            }
            else if(MochiServices.clip != null)
            {
               if(MochiServices.clip is MovieClip)
               {
                  MochiServices.clip.stop();
               }
               else
               {
                  trace("Warning: Container is not a MovieClip, cannot call default onDisplay.");
               }
            }
         }
         else
         {
            options = {};
            if(MochiServices.clip is MovieClip)
            {
               MochiServices.clip.stop();
            }
            else
            {
               trace("Warning: Container is not a MovieClip, cannot call default onDisplay.");
            }
         }
         if(options.onClose != null)
         {
            onCloseHandler = options.onClose;
         }
         else
         {
            onCloseHandler = function():void
            {
               if(MochiServices.clip is MovieClip)
               {
                  MochiServices.clip.play();
               }
               else
               {
                  trace("Warning: Container is not a MovieClip, cannot call default onClose.");
               }
            };
         }
         if(options.onError != null)
         {
            onErrorHandler = options.onError;
         }
         else
         {
            onErrorHandler = null;
         }
         if(options.boardID == null)
         {
            if(MochiScores.boardID != null)
            {
               options.boardID = MochiScores.boardID;
            }
         }
         MochiServices.warnID(options.boardID,true);
         trace("[MochiScores] NOTE: Security Sandbox Violation errors below are normal");
         MochiServices.send("scores_showLeaderboard",{"options":options},null,onClose);
      }
      
      public static function closeLeaderboard() : void
      {
         MochiServices.send("scores_closeLeaderboard");
      }
      
      public static function getPlayerInfo(callbackObj:Object, callbackMethod:Object = null) : void
      {
         MochiServices.send("scores_getPlayerInfo",null,callbackObj,callbackMethod);
      }
      
      public static function requestList(callbackObj:Object, callbackMethod:Object = null) : void
      {
         MochiServices.send("scores_requestList",null,callbackObj,callbackMethod);
      }
      
      public static function scoresArrayToObjects(scores:Object) : Object
      {
         var i:Number = NaN;
         var j:Number = NaN;
         var o:Object = null;
         var row_obj:Object = null;
         var item:String = null;
         var param:String = null;
         var so:Object = {};
         for(item in scores)
         {
            if(typeof scores[item] == "object")
            {
               if(scores[item].cols != null && scores[item].rows != null)
               {
                  so[item] = [];
                  o = scores[item];
                  for(j = 0; j < o.rows.length; j++)
                  {
                     row_obj = {};
                     for(i = 0; i < o.cols.length; i++)
                     {
                        row_obj[o.cols[i]] = o.rows[j][i];
                     }
                     so[item].push(row_obj);
                  }
               }
               else
               {
                  so[item] = {};
                  for(param in scores[item])
                  {
                     so[item][param] = scores[item][param];
                  }
               }
            }
            else
            {
               so[item] = scores[item];
            }
         }
         return so;
      }
      
      public static function submit(score:Number, name:String, callbackObj:Object = null, callbackMethod:Object = null) : void
      {
         score = Number(score);
         if(isNaN(score))
         {
            trace("ERROR: Submitted score \'" + String(score) + "\' will be rejected, score is \'Not a Number\'");
         }
         else if(score == Number.NEGATIVE_INFINITY || score == Number.POSITIVE_INFINITY)
         {
            trace("ERROR: Submitted score \'" + String(score) + "\' will be rejected, score is an infinite");
         }
         else
         {
            if(Math.floor(score) != score)
            {
               trace("WARNING: Submitted score \'" + String(score) + "\' will be truncated");
            }
            score = Number(score);
         }
         MochiServices.send("scores_submit",{
            "score":score,
            "name":name
         },callbackObj,callbackMethod);
      }
      
      public static function onClose(args:Object = null) : void
      {
         if(args && args.error == true && Boolean(onErrorHandler))
         {
            if(args.errorCode == null)
            {
               args.errorCode = "IOError";
            }
            onErrorHandler(args.errorCode);
            MochiServices.doClose();
            return;
         }
         onCloseHandler();
         MochiServices.doClose();
      }
      
      public static function setBoardID(boardID:String) : void
      {
         MochiServices.warnID(boardID,true);
         MochiScores.boardID = boardID;
         MochiServices.send("scores_setBoardID",{"boardID":boardID});
      }
   }
}
