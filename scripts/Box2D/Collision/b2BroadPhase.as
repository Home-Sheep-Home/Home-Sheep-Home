package Box2D.Collision
{
   import Box2D.Common.*;
   import Box2D.Common.Math.*;
   
   public class b2BroadPhase
   {
      
      public static var s_validate:Boolean = false;
      
      public static const b2_nullEdge:uint = b2Settings.USHRT_MAX;
      
      public static const b2_invalid:uint = b2Settings.USHRT_MAX;
       
      
      public var m_bounds:Array;
      
      public var m_quantizationFactor:b2Vec2;
      
      public var m_worldAABB:Box2D.Collision.b2AABB;
      
      public var m_freeProxy:uint;
      
      public var m_proxyCount:int;
      
      public var m_proxyPool:Array;
      
      public var m_queryResultCount:int;
      
      public var m_pairManager:Box2D.Collision.b2PairManager;
      
      public var m_timeStamp:uint;
      
      public var m_queryResults:Array;
      
      public function b2BroadPhase(worldAABB:Box2D.Collision.b2AABB, callback:b2PairCallback)
      {
         var i:int = 0;
         var dY:Number = NaN;
         var tProxy:b2Proxy = null;
         var j:int = 0;
         this.m_pairManager = new Box2D.Collision.b2PairManager();
         this.m_proxyPool = new Array(b2Settings.b2_maxPairs);
         this.m_bounds = new Array(2 * b2Settings.b2_maxProxies);
         this.m_queryResults = new Array(b2Settings.b2_maxProxies);
         this.m_quantizationFactor = new b2Vec2();
         super();
         this.m_pairManager.Initialize(this,callback);
         this.m_worldAABB = worldAABB;
         this.m_proxyCount = 0;
         for(i = 0; i < b2Settings.b2_maxProxies; i++)
         {
            this.m_queryResults[i] = 0;
         }
         this.m_bounds = new Array(2);
         for(i = 0; i < 2; i++)
         {
            this.m_bounds[i] = new Array(2 * b2Settings.b2_maxProxies);
            for(j = 0; j < 2 * b2Settings.b2_maxProxies; j++)
            {
               this.m_bounds[i][j] = new b2Bound();
            }
         }
         var dX:Number = worldAABB.upperBound.x - worldAABB.lowerBound.x;
         dY = worldAABB.upperBound.y - worldAABB.lowerBound.y;
         this.m_quantizationFactor.x = b2Settings.USHRT_MAX / dX;
         this.m_quantizationFactor.y = b2Settings.USHRT_MAX / dY;
         for(i = 0; i < b2Settings.b2_maxProxies - 1; i++)
         {
            tProxy = new b2Proxy();
            this.m_proxyPool[i] = tProxy;
            tProxy.SetNext(i + 1);
            tProxy.timeStamp = 0;
            tProxy.overlapCount = b2_invalid;
            tProxy.userData = null;
         }
         tProxy = new b2Proxy();
         this.m_proxyPool[int(b2Settings.b2_maxProxies - 1)] = tProxy;
         tProxy.SetNext(b2Pair.b2_nullProxy);
         tProxy.timeStamp = 0;
         tProxy.overlapCount = b2_invalid;
         tProxy.userData = null;
         this.m_freeProxy = 0;
         this.m_timeStamp = 1;
         this.m_queryResultCount = 0;
      }
      
      public static function BinarySearch(bounds:Array, count:int, value:uint) : uint
      {
         var mid:int = 0;
         var bound:b2Bound = null;
         var low:int = 0;
         var high:int = count - 1;
         while(low <= high)
         {
            mid = (low + high) / 2;
            bound = bounds[mid];
            if(bound.value > value)
            {
               high = mid - 1;
            }
            else
            {
               if(bound.value >= value)
               {
                  return uint(mid);
               }
               low = mid + 1;
            }
         }
         return uint(low);
      }
      
      public function QueryAABB(aabb:Box2D.Collision.b2AABB, userData:*, maxCount:int) : int
      {
         var lowerIndex:uint = 0;
         var upperIndex:uint = 0;
         var proxy:b2Proxy = null;
         var lowerValues:Array = new Array();
         var upperValues:Array = new Array();
         this.ComputeBounds(lowerValues,upperValues,aabb);
         var lowerIndexOut:Array = [lowerIndex];
         var upperIndexOut:Array = [upperIndex];
         this.Query(lowerIndexOut,upperIndexOut,lowerValues[0],upperValues[0],this.m_bounds[0],2 * this.m_proxyCount,0);
         this.Query(lowerIndexOut,upperIndexOut,lowerValues[1],upperValues[1],this.m_bounds[1],2 * this.m_proxyCount,1);
         var count:int = 0;
         var i:int = 0;
         while(i < this.m_queryResultCount && count < maxCount)
         {
            proxy = this.m_proxyPool[this.m_queryResults[i]];
            userData[i] = proxy.userData;
            i++;
            count++;
         }
         this.m_queryResultCount = 0;
         this.IncrementTimeStamp();
         return count;
      }
      
      public function Commit() : void
      {
         this.m_pairManager.Commit();
      }
      
      public function GetProxy(proxyId:int) : b2Proxy
      {
         var proxy:b2Proxy = this.m_proxyPool[proxyId];
         if(proxyId == b2Pair.b2_nullProxy || proxy.IsValid() == false)
         {
            return null;
         }
         return proxy;
      }
      
      private function IncrementTimeStamp() : void
      {
         var i:uint = 0;
         if(this.m_timeStamp == b2Settings.USHRT_MAX)
         {
            for(i = 0; i < b2Settings.b2_maxProxies; i++)
            {
               (this.m_proxyPool[i] as b2Proxy).timeStamp = 0;
            }
            this.m_timeStamp = 1;
         }
         else
         {
            ++this.m_timeStamp;
         }
      }
      
      private function Query(lowerQueryOut:Array, upperQueryOut:Array, lowerValue:uint, upperValue:uint, bounds:Array, boundCount:uint, axis:int) : void
      {
         var bound:b2Bound = null;
         var i:int = 0;
         var s:int = 0;
         var proxy:b2Proxy = null;
         var lowerQuery:uint = BinarySearch(bounds,boundCount,lowerValue);
         var upperQuery:uint = BinarySearch(bounds,boundCount,upperValue);
         for(var j:uint = lowerQuery; j < upperQuery; j++)
         {
            bound = bounds[j];
            if(bound.IsLower())
            {
               this.IncrementOverlapCount(bound.proxyId);
            }
         }
         if(lowerQuery > 0)
         {
            i = int(lowerQuery - 1);
            bound = bounds[i];
            s = int(bound.stabbingCount);
            while(s)
            {
               bound = bounds[i];
               if(bound.IsLower())
               {
                  proxy = this.m_proxyPool[bound.proxyId];
                  if(lowerQuery <= proxy.upperBounds[axis])
                  {
                     this.IncrementOverlapCount(bound.proxyId);
                     s--;
                  }
               }
               i--;
            }
         }
         lowerQueryOut[0] = lowerQuery;
         upperQueryOut[0] = upperQuery;
      }
      
      private function TestOverlapValidate(p1:b2Proxy, p2:b2Proxy) : Boolean
      {
         var bounds:Array = null;
         var bound1:b2Bound = null;
         var bound2:b2Bound = null;
         for(var axis:int = 0; axis < 2; axis++)
         {
            bounds = this.m_bounds[axis];
            bound1 = bounds[p1.lowerBounds[axis]];
            bound2 = bounds[p2.upperBounds[axis]];
            if(bound1.value > bound2.value)
            {
               return false;
            }
            bound1 = bounds[p1.upperBounds[axis]];
            bound2 = bounds[p2.lowerBounds[axis]];
            if(bound1.value < bound2.value)
            {
               return false;
            }
         }
         return true;
      }
      
      private function ComputeBounds(lowerValues:Array, upperValues:Array, aabb:Box2D.Collision.b2AABB) : void
      {
         var minVertexX:Number = aabb.lowerBound.x;
         var minVertexY:Number = aabb.lowerBound.y;
         minVertexX = b2Math.b2Min(minVertexX,this.m_worldAABB.upperBound.x);
         minVertexY = b2Math.b2Min(minVertexY,this.m_worldAABB.upperBound.y);
         minVertexX = b2Math.b2Max(minVertexX,this.m_worldAABB.lowerBound.x);
         minVertexY = b2Math.b2Max(minVertexY,this.m_worldAABB.lowerBound.y);
         var maxVertexX:Number = aabb.upperBound.x;
         var maxVertexY:Number = aabb.upperBound.y;
         maxVertexX = b2Math.b2Min(maxVertexX,this.m_worldAABB.upperBound.x);
         maxVertexY = b2Math.b2Min(maxVertexY,this.m_worldAABB.upperBound.y);
         maxVertexX = b2Math.b2Max(maxVertexX,this.m_worldAABB.lowerBound.x);
         maxVertexY = b2Math.b2Max(maxVertexY,this.m_worldAABB.lowerBound.y);
         lowerValues[0] = uint(this.m_quantizationFactor.x * (minVertexX - this.m_worldAABB.lowerBound.x)) & b2Settings.USHRT_MAX - 1;
         upperValues[0] = uint(this.m_quantizationFactor.x * (maxVertexX - this.m_worldAABB.lowerBound.x)) & 65535 | 1;
         lowerValues[1] = uint(this.m_quantizationFactor.y * (minVertexY - this.m_worldAABB.lowerBound.y)) & b2Settings.USHRT_MAX - 1;
         upperValues[1] = uint(this.m_quantizationFactor.y * (maxVertexY - this.m_worldAABB.lowerBound.y)) & 65535 | 1;
      }
      
      public function CreateProxy(aabb:Box2D.Collision.b2AABB, userData:*) : uint
      {
         var index:uint = 0;
         var proxy:b2Proxy = null;
         var bounds:Array = null;
         var lowerIndex:uint = 0;
         var upperIndex:uint = 0;
         var lowerIndexOut:Array = null;
         var upperIndexOut:Array = null;
         var tArr:Array = null;
         var j:int = 0;
         var tEnd:int = 0;
         var tBound1:b2Bound = null;
         var tBound2:b2Bound = null;
         var tBoundAS3:b2Bound = null;
         var tIndex:int = 0;
         var proxy2:b2Proxy = null;
         var proxyId:uint = this.m_freeProxy;
         proxy = this.m_proxyPool[proxyId];
         this.m_freeProxy = proxy.GetNext();
         proxy.overlapCount = 0;
         proxy.userData = userData;
         var boundCount:uint = uint(2 * this.m_proxyCount);
         var lowerValues:Array = new Array();
         var upperValues:Array = new Array();
         this.ComputeBounds(lowerValues,upperValues,aabb);
         for(var axis:int = 0; axis < 2; axis++)
         {
            bounds = this.m_bounds[axis];
            lowerIndexOut = [lowerIndex];
            upperIndexOut = [upperIndex];
            this.Query(lowerIndexOut,upperIndexOut,lowerValues[axis],upperValues[axis],bounds,boundCount,axis);
            lowerIndex = uint(lowerIndexOut[0]);
            upperIndex = uint(upperIndexOut[0]);
            tArr = new Array();
            tEnd = boundCount - upperIndex;
            for(j = 0; j < tEnd; j++)
            {
               tArr[j] = new b2Bound();
               tBound1 = tArr[j];
               tBound2 = bounds[int(upperIndex + j)];
               tBound1.value = tBound2.value;
               tBound1.proxyId = tBound2.proxyId;
               tBound1.stabbingCount = tBound2.stabbingCount;
            }
            tEnd = int(tArr.length);
            tIndex = upperIndex + 2;
            for(j = 0; j < tEnd; j++)
            {
               tBound2 = tArr[j];
               tBound1 = bounds[int(tIndex + j)];
               tBound1.value = tBound2.value;
               tBound1.proxyId = tBound2.proxyId;
               tBound1.stabbingCount = tBound2.stabbingCount;
            }
            tArr = new Array();
            tEnd = upperIndex - lowerIndex;
            for(j = 0; j < tEnd; j++)
            {
               tArr[j] = new b2Bound();
               tBound1 = tArr[j];
               tBound2 = bounds[int(lowerIndex + j)];
               tBound1.value = tBound2.value;
               tBound1.proxyId = tBound2.proxyId;
               tBound1.stabbingCount = tBound2.stabbingCount;
            }
            tEnd = int(tArr.length);
            tIndex = lowerIndex + 1;
            for(j = 0; j < tEnd; j++)
            {
               tBound2 = tArr[j];
               tBound1 = bounds[int(tIndex + j)];
               tBound1.value = tBound2.value;
               tBound1.proxyId = tBound2.proxyId;
               tBound1.stabbingCount = tBound2.stabbingCount;
            }
            upperIndex++;
            tBound1 = bounds[lowerIndex];
            tBound2 = bounds[upperIndex];
            tBound1.value = lowerValues[axis];
            tBound1.proxyId = proxyId;
            tBound2.value = upperValues[axis];
            tBound2.proxyId = proxyId;
            tBoundAS3 = bounds[int(lowerIndex - 1)];
            tBound1.stabbingCount = lowerIndex == 0 ? 0 : tBoundAS3.stabbingCount;
            tBoundAS3 = bounds[int(upperIndex - 1)];
            tBound2.stabbingCount = tBoundAS3.stabbingCount;
            for(index = lowerIndex; index < upperIndex; index++)
            {
               tBoundAS3 = bounds[index];
               ++tBoundAS3.stabbingCount;
            }
            for(index = lowerIndex; index < boundCount + 2; index++)
            {
               tBound1 = bounds[index];
               proxy2 = this.m_proxyPool[tBound1.proxyId];
               if(tBound1.IsLower())
               {
                  proxy2.lowerBounds[axis] = index;
               }
               else
               {
                  proxy2.upperBounds[axis] = index;
               }
            }
         }
         ++this.m_proxyCount;
         for(var i:int = 0; i < this.m_queryResultCount; i++)
         {
            this.m_pairManager.AddBufferedPair(proxyId,this.m_queryResults[i]);
         }
         this.m_pairManager.Commit();
         this.m_queryResultCount = 0;
         this.IncrementTimeStamp();
         return proxyId;
      }
      
      public function DestroyProxy(proxyId:uint) : void
      {
         var tBound1:b2Bound = null;
         var tBound2:b2Bound = null;
         var bounds:Array = null;
         var lowerIndex:uint = 0;
         var upperIndex:uint = 0;
         var lowerValue:uint = 0;
         var upperValue:uint = 0;
         var tArr:Array = null;
         var j:int = 0;
         var tEnd:int = 0;
         var tIndex:int = 0;
         var index:uint = 0;
         var index2:int = 0;
         var proxy2:b2Proxy = null;
         var proxy:b2Proxy = this.m_proxyPool[proxyId];
         var boundCount:int = 2 * this.m_proxyCount;
         for(var axis:int = 0; axis < 2; axis++)
         {
            bounds = this.m_bounds[axis];
            lowerIndex = uint(proxy.lowerBounds[axis]);
            upperIndex = uint(proxy.upperBounds[axis]);
            tBound1 = bounds[lowerIndex];
            lowerValue = tBound1.value;
            tBound2 = bounds[upperIndex];
            upperValue = tBound2.value;
            tArr = new Array();
            tEnd = upperIndex - lowerIndex - 1;
            for(j = 0; j < tEnd; j++)
            {
               tArr[j] = new b2Bound();
               tBound1 = tArr[j];
               tBound2 = bounds[int(lowerIndex + 1 + j)];
               tBound1.value = tBound2.value;
               tBound1.proxyId = tBound2.proxyId;
               tBound1.stabbingCount = tBound2.stabbingCount;
            }
            tEnd = int(tArr.length);
            tIndex = int(lowerIndex);
            for(j = 0; j < tEnd; j++)
            {
               tBound2 = tArr[j];
               tBound1 = bounds[int(tIndex + j)];
               tBound1.value = tBound2.value;
               tBound1.proxyId = tBound2.proxyId;
               tBound1.stabbingCount = tBound2.stabbingCount;
            }
            tArr = new Array();
            tEnd = boundCount - upperIndex - 1;
            for(j = 0; j < tEnd; j++)
            {
               tArr[j] = new b2Bound();
               tBound1 = tArr[j];
               tBound2 = bounds[int(upperIndex + 1 + j)];
               tBound1.value = tBound2.value;
               tBound1.proxyId = tBound2.proxyId;
               tBound1.stabbingCount = tBound2.stabbingCount;
            }
            tEnd = int(tArr.length);
            tIndex = int(upperIndex - 1);
            for(j = 0; j < tEnd; j++)
            {
               tBound2 = tArr[j];
               tBound1 = bounds[int(tIndex + j)];
               tBound1.value = tBound2.value;
               tBound1.proxyId = tBound2.proxyId;
               tBound1.stabbingCount = tBound2.stabbingCount;
            }
            tEnd = boundCount - 2;
            for(index = lowerIndex; index < tEnd; index++)
            {
               tBound1 = bounds[index];
               proxy2 = this.m_proxyPool[tBound1.proxyId];
               if(tBound1.IsLower())
               {
                  proxy2.lowerBounds[axis] = index;
               }
               else
               {
                  proxy2.upperBounds[axis] = index;
               }
            }
            tEnd = int(upperIndex - 1);
            for(index2 = int(lowerIndex); index2 < tEnd; index2++)
            {
               tBound1 = bounds[index2];
               --tBound1.stabbingCount;
            }
            this.Query([0],[0],lowerValue,upperValue,bounds,boundCount - 2,axis);
         }
         for(var i:int = 0; i < this.m_queryResultCount; i++)
         {
            this.m_pairManager.RemoveBufferedPair(proxyId,this.m_queryResults[i]);
         }
         this.m_pairManager.Commit();
         this.m_queryResultCount = 0;
         this.IncrementTimeStamp();
         proxy.userData = null;
         proxy.overlapCount = b2_invalid;
         proxy.lowerBounds[0] = b2_invalid;
         proxy.lowerBounds[1] = b2_invalid;
         proxy.upperBounds[0] = b2_invalid;
         proxy.upperBounds[1] = b2_invalid;
         proxy.SetNext(this.m_freeProxy);
         this.m_freeProxy = proxyId;
         --this.m_proxyCount;
      }
      
      public function TestOverlap(b:b2BoundValues, p:b2Proxy) : Boolean
      {
         var bounds:Array = null;
         var bound:b2Bound = null;
         for(var axis:int = 0; axis < 2; axis++)
         {
            bounds = this.m_bounds[axis];
            bound = bounds[p.upperBounds[axis]];
            if(b.lowerValues[axis] > bound.value)
            {
               return false;
            }
            bound = bounds[p.lowerBounds[axis]];
            if(b.upperValues[axis] < bound.value)
            {
               return false;
            }
         }
         return true;
      }
      
      public function Validate() : void
      {
         var pair:b2Pair = null;
         var proxy1:b2Proxy = null;
         var proxy2:b2Proxy = null;
         var overlap:Boolean = false;
         var bounds:b2Bound = null;
         var boundCount:uint = 0;
         var stabbingCount:uint = 0;
         var i:uint = 0;
         var bound:b2Bound = null;
         for(var axis:int = 0; axis < 2; axis++)
         {
            bounds = this.m_bounds[axis];
            boundCount = uint(2 * this.m_proxyCount);
            stabbingCount = 0;
            for(i = 0; i < boundCount; i++)
            {
               bound = bounds[i];
               if(bound.IsLower() == true)
               {
                  stabbingCount++;
               }
               else
               {
                  stabbingCount--;
               }
            }
         }
      }
      
      private function IncrementOverlapCount(proxyId:uint) : void
      {
         var proxy:b2Proxy = this.m_proxyPool[proxyId];
         if(proxy.timeStamp < this.m_timeStamp)
         {
            proxy.timeStamp = this.m_timeStamp;
            proxy.overlapCount = 1;
         }
         else
         {
            proxy.overlapCount = 2;
            this.m_queryResults[this.m_queryResultCount] = proxyId;
            ++this.m_queryResultCount;
         }
      }
      
      public function InRange(aabb:Box2D.Collision.b2AABB) : Boolean
      {
         var dX:Number = NaN;
         var dY:Number = NaN;
         var d2X:Number = NaN;
         var d2Y:Number = NaN;
         dX = aabb.lowerBound.x;
         dY = aabb.lowerBound.y;
         dX -= this.m_worldAABB.upperBound.x;
         dY -= this.m_worldAABB.upperBound.y;
         d2X = this.m_worldAABB.lowerBound.x;
         d2Y = this.m_worldAABB.lowerBound.y;
         d2X -= aabb.upperBound.x;
         d2Y -= aabb.upperBound.y;
         dX = b2Math.b2Max(dX,d2X);
         dY = b2Math.b2Max(dY,d2Y);
         return b2Math.b2Max(dX,dY) < 0;
      }
      
      public function MoveProxy(proxyId:uint, aabb:Box2D.Collision.b2AABB) : void
      {
         var as3arr:Array = null;
         var as3int:int = 0;
         var axis:uint = 0;
         var index:uint = 0;
         var bound:b2Bound = null;
         var prevBound:b2Bound = null;
         var nextBound:b2Bound = null;
         var nextProxyId:uint = 0;
         var nextProxy:b2Proxy = null;
         var bounds:Array = null;
         var lowerIndex:uint = 0;
         var upperIndex:uint = 0;
         var lowerValue:uint = 0;
         var upperValue:uint = 0;
         var deltaLower:int = 0;
         var deltaUpper:int = 0;
         var prevProxyId:uint = 0;
         var prevProxy:b2Proxy = null;
         if(proxyId == b2Pair.b2_nullProxy || b2Settings.b2_maxProxies <= proxyId)
         {
            return;
         }
         if(aabb.IsValid() == false)
         {
            return;
         }
         var boundCount:uint = uint(2 * this.m_proxyCount);
         var proxy:b2Proxy = this.m_proxyPool[proxyId];
         var newValues:b2BoundValues = new b2BoundValues();
         this.ComputeBounds(newValues.lowerValues,newValues.upperValues,aabb);
         var oldValues:b2BoundValues = new b2BoundValues();
         for(axis = 0; axis < 2; axis++)
         {
            bound = this.m_bounds[axis][proxy.lowerBounds[axis]];
            oldValues.lowerValues[axis] = bound.value;
            bound = this.m_bounds[axis][proxy.upperBounds[axis]];
            oldValues.upperValues[axis] = bound.value;
         }
         for(axis = 0; axis < 2; axis++)
         {
            bounds = this.m_bounds[axis];
            lowerIndex = uint(proxy.lowerBounds[axis]);
            upperIndex = uint(proxy.upperBounds[axis]);
            lowerValue = uint(newValues.lowerValues[axis]);
            upperValue = uint(newValues.upperValues[axis]);
            bound = bounds[lowerIndex];
            deltaLower = lowerValue - bound.value;
            bound.value = lowerValue;
            bound = bounds[upperIndex];
            deltaUpper = upperValue - bound.value;
            bound.value = upperValue;
            if(deltaLower < 0)
            {
               index = lowerIndex;
               while(index > 0 && lowerValue < (bounds[int(index - 1)] as b2Bound).value)
               {
                  bound = bounds[index];
                  prevBound = bounds[int(index - 1)];
                  prevProxyId = prevBound.proxyId;
                  prevProxy = this.m_proxyPool[prevBound.proxyId];
                  ++prevBound.stabbingCount;
                  if(prevBound.IsUpper() == true)
                  {
                     if(this.TestOverlap(newValues,prevProxy))
                     {
                        this.m_pairManager.AddBufferedPair(proxyId,prevProxyId);
                     }
                     as3arr = prevProxy.upperBounds;
                     as3int = int(as3arr[axis]);
                     as3int++;
                     as3arr[axis] = as3int;
                     ++bound.stabbingCount;
                  }
                  else
                  {
                     as3arr = prevProxy.lowerBounds;
                     as3int = int(as3arr[axis]);
                     as3int++;
                     as3arr[axis] = as3int;
                     --bound.stabbingCount;
                  }
                  as3arr = proxy.lowerBounds;
                  as3int = int(as3arr[axis]);
                  as3int--;
                  as3arr[axis] = as3int;
                  bound.Swap(prevBound);
                  index--;
               }
            }
            if(deltaUpper > 0)
            {
               index = upperIndex;
               while(index < boundCount - 1 && (bounds[int(index + 1)] as b2Bound).value <= upperValue)
               {
                  bound = bounds[index];
                  nextBound = bounds[int(index + 1)];
                  nextProxyId = nextBound.proxyId;
                  nextProxy = this.m_proxyPool[nextProxyId];
                  ++nextBound.stabbingCount;
                  if(nextBound.IsLower() == true)
                  {
                     if(this.TestOverlap(newValues,nextProxy))
                     {
                        this.m_pairManager.AddBufferedPair(proxyId,nextProxyId);
                     }
                     as3arr = nextProxy.lowerBounds;
                     as3int = int(as3arr[axis]);
                     as3int--;
                     as3arr[axis] = as3int;
                     ++bound.stabbingCount;
                  }
                  else
                  {
                     as3arr = nextProxy.upperBounds;
                     as3int = int(as3arr[axis]);
                     as3int--;
                     as3arr[axis] = as3int;
                     --bound.stabbingCount;
                  }
                  as3arr = proxy.upperBounds;
                  as3int = int(as3arr[axis]);
                  as3int++;
                  as3arr[axis] = as3int;
                  bound.Swap(nextBound);
                  index++;
               }
            }
            if(deltaLower > 0)
            {
               index = lowerIndex;
               while(index < boundCount - 1 && (bounds[int(index + 1)] as b2Bound).value <= lowerValue)
               {
                  bound = bounds[index];
                  nextBound = bounds[int(index + 1)];
                  nextProxyId = nextBound.proxyId;
                  nextProxy = this.m_proxyPool[nextProxyId];
                  --nextBound.stabbingCount;
                  if(nextBound.IsUpper())
                  {
                     if(this.TestOverlap(oldValues,nextProxy))
                     {
                        this.m_pairManager.RemoveBufferedPair(proxyId,nextProxyId);
                     }
                     as3arr = nextProxy.upperBounds;
                     as3int = int(as3arr[axis]);
                     as3int--;
                     as3arr[axis] = as3int;
                     --bound.stabbingCount;
                  }
                  else
                  {
                     as3arr = nextProxy.lowerBounds;
                     as3int = int(as3arr[axis]);
                     as3int--;
                     as3arr[axis] = as3int;
                     ++bound.stabbingCount;
                  }
                  as3arr = proxy.lowerBounds;
                  as3int = int(as3arr[axis]);
                  as3int++;
                  as3arr[axis] = as3int;
                  bound.Swap(nextBound);
                  index++;
               }
            }
            if(deltaUpper < 0)
            {
               index = upperIndex;
               while(index > 0 && upperValue < (bounds[int(index - 1)] as b2Bound).value)
               {
                  bound = bounds[index];
                  prevBound = bounds[int(index - 1)];
                  prevProxyId = prevBound.proxyId;
                  prevProxy = this.m_proxyPool[prevProxyId];
                  --prevBound.stabbingCount;
                  if(prevBound.IsLower() == true)
                  {
                     if(this.TestOverlap(oldValues,prevProxy))
                     {
                        this.m_pairManager.RemoveBufferedPair(proxyId,prevProxyId);
                     }
                     as3arr = prevProxy.lowerBounds;
                     as3int = int(as3arr[axis]);
                     as3int++;
                     as3arr[axis] = as3int;
                     --bound.stabbingCount;
                  }
                  else
                  {
                     as3arr = prevProxy.upperBounds;
                     as3int = int(as3arr[axis]);
                     as3int++;
                     as3arr[axis] = as3int;
                     ++bound.stabbingCount;
                  }
                  as3arr = proxy.upperBounds;
                  as3int = int(as3arr[axis]);
                  as3int--;
                  as3arr[axis] = as3int;
                  bound.Swap(prevBound);
                  index--;
               }
            }
         }
      }
   }
}
