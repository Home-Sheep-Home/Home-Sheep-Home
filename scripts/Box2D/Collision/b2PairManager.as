package Box2D.Collision
{
   import Box2D.Common.*;
   import Box2D.Common.Math.*;
   
   public class b2PairManager
   {
       
      
      public var m_pairCount:int;
      
      public var m_pairBuffer:Array;
      
      public var m_hashTable:Array;
      
      public var m_callback:Box2D.Collision.b2PairCallback;
      
      public var m_pairs:Array;
      
      public var m_pairBufferCount:int;
      
      public var m_broadPhase:Box2D.Collision.b2BroadPhase;
      
      public var m_freePair:uint;
      
      public function b2PairManager()
      {
         var i:uint = 0;
         super();
         this.m_hashTable = new Array(b2Pair.b2_tableCapacity);
         for(i = 0; i < b2Pair.b2_tableCapacity; i++)
         {
            this.m_hashTable[i] = b2Pair.b2_nullPair;
         }
         this.m_pairs = new Array(b2Settings.b2_maxPairs);
         for(i = 0; i < b2Settings.b2_maxPairs; i++)
         {
            this.m_pairs[i] = new b2Pair();
         }
         this.m_pairBuffer = new Array(b2Settings.b2_maxPairs);
         for(i = 0; i < b2Settings.b2_maxPairs; i++)
         {
            this.m_pairBuffer[i] = new b2BufferedPair();
         }
         for(i = 0; i < b2Settings.b2_maxPairs; i++)
         {
            this.m_pairs[i].proxyId1 = b2Pair.b2_nullProxy;
            this.m_pairs[i].proxyId2 = b2Pair.b2_nullProxy;
            this.m_pairs[i].userData = null;
            this.m_pairs[i].status = 0;
            this.m_pairs[i].next = i + 1;
         }
         this.m_pairs[int(b2Settings.b2_maxPairs - 1)].next = b2Pair.b2_nullPair;
         this.m_pairCount = 0;
         this.m_pairBufferCount = 0;
      }
      
      public static function EqualsPair(pair1:b2BufferedPair, pair2:b2BufferedPair) : Boolean
      {
         return pair1.proxyId1 == pair2.proxyId1 && pair1.proxyId2 == pair2.proxyId2;
      }
      
      public static function Hash(proxyId1:uint, proxyId2:uint) : uint
      {
         var key:uint = uint(proxyId2 << 16 & 4294901760 | proxyId1);
         key = uint(~key + (key << 15 & 4294934528));
         key ^= key >> 12 & 1048575;
         key += key << 2 & 4294967292;
         key ^= key >> 4 & 268435455;
         key *= 2057;
         return uint(key ^ key >> 16 & 65535);
      }
      
      public static function Equals(pair:b2Pair, proxyId1:uint, proxyId2:uint) : Boolean
      {
         return pair.proxyId1 == proxyId1 && pair.proxyId2 == proxyId2;
      }
      
      private function FindHash(proxyId1:uint, proxyId2:uint, hash:uint) : b2Pair
      {
         var pair:b2Pair = null;
         var index:uint = uint(this.m_hashTable[hash]);
         pair = this.m_pairs[index];
         while(index != b2Pair.b2_nullPair && Equals(pair,proxyId1,proxyId2) == false)
         {
            index = pair.next;
            pair = this.m_pairs[index];
         }
         if(index == b2Pair.b2_nullPair)
         {
            return null;
         }
         return pair;
      }
      
      private function Find(proxyId1:uint, proxyId2:uint) : b2Pair
      {
         var temp:uint = 0;
         if(proxyId1 > proxyId2)
         {
            temp = proxyId1;
            proxyId1 = proxyId2;
            proxyId2 = temp;
         }
         var hash:uint = uint(Hash(proxyId1,proxyId2) & b2Pair.b2_tableMask);
         return this.FindHash(proxyId1,proxyId2,hash);
      }
      
      private function ValidateBuffer() : void
      {
      }
      
      public function Commit() : void
      {
         var bufferedPair:b2BufferedPair = null;
         var i:int = 0;
         var pair:b2Pair = null;
         var proxy1:b2Proxy = null;
         var proxy2:b2Proxy = null;
         var removeCount:int = 0;
         var proxies:Array = this.m_broadPhase.m_proxyPool;
         for(i = 0; i < this.m_pairBufferCount; i++)
         {
            bufferedPair = this.m_pairBuffer[i];
            pair = this.Find(bufferedPair.proxyId1,bufferedPair.proxyId2);
            pair.ClearBuffered();
            proxy1 = proxies[pair.proxyId1];
            proxy2 = proxies[pair.proxyId2];
            if(pair.IsRemoved())
            {
               if(pair.IsFinal() == true)
               {
                  this.m_callback.PairRemoved(proxy1.userData,proxy2.userData,pair.userData);
               }
               bufferedPair = this.m_pairBuffer[removeCount];
               bufferedPair.proxyId1 = pair.proxyId1;
               bufferedPair.proxyId2 = pair.proxyId2;
               removeCount++;
            }
            else if(pair.IsFinal() == false)
            {
               pair.userData = this.m_callback.PairAdded(proxy1.userData,proxy2.userData);
               pair.SetFinal();
            }
         }
         for(i = 0; i < removeCount; i++)
         {
            bufferedPair = this.m_pairBuffer[i];
            this.RemovePair(bufferedPair.proxyId1,bufferedPair.proxyId2);
         }
         this.m_pairBufferCount = 0;
         if(Box2D.Collision.b2BroadPhase.s_validate)
         {
            this.ValidateTable();
         }
      }
      
      public function RemoveBufferedPair(proxyId1:int, proxyId2:int) : void
      {
         var bufferedPair:b2BufferedPair = null;
         var pair:b2Pair = this.Find(proxyId1,proxyId2);
         if(pair == null)
         {
            return;
         }
         if(pair.IsBuffered() == false)
         {
            pair.SetBuffered();
            bufferedPair = this.m_pairBuffer[this.m_pairBufferCount];
            bufferedPair.proxyId1 = pair.proxyId1;
            bufferedPair.proxyId2 = pair.proxyId2;
            ++this.m_pairBufferCount;
         }
         pair.SetRemoved();
         if(Box2D.Collision.b2BroadPhase.s_validate)
         {
            this.ValidateBuffer();
         }
      }
      
      private function RemovePair(proxyId1:uint, proxyId2:uint) : *
      {
         var pair:b2Pair = null;
         var temp:uint = 0;
         var index:uint = 0;
         var userData:* = undefined;
         if(proxyId1 > proxyId2)
         {
            temp = proxyId1;
            proxyId1 = proxyId2;
            proxyId2 = temp;
         }
         var hash:uint = uint(Hash(proxyId1,proxyId2) & b2Pair.b2_tableMask);
         var node:uint = uint(this.m_hashTable[hash]);
         var pNode:b2Pair = null;
         while(node != b2Pair.b2_nullPair)
         {
            if(Equals(this.m_pairs[node],proxyId1,proxyId2))
            {
               index = node;
               pair = this.m_pairs[node];
               if(pNode)
               {
                  pNode.next = pair.next;
               }
               else
               {
                  this.m_hashTable[hash] = pair.next;
               }
               pair = this.m_pairs[index];
               userData = pair.userData;
               pair.next = this.m_freePair;
               pair.proxyId1 = b2Pair.b2_nullProxy;
               pair.proxyId2 = b2Pair.b2_nullProxy;
               pair.userData = null;
               pair.status = 0;
               this.m_freePair = index;
               --this.m_pairCount;
               return userData;
            }
            pNode = this.m_pairs[node];
            node = pNode.next;
         }
         return null;
      }
      
      public function Initialize(broadPhase:Box2D.Collision.b2BroadPhase, callback:Box2D.Collision.b2PairCallback) : void
      {
         this.m_broadPhase = broadPhase;
         this.m_callback = callback;
      }
      
      public function AddBufferedPair(proxyId1:int, proxyId2:int) : void
      {
         var bufferedPair:b2BufferedPair = null;
         var pair:b2Pair = this.AddPair(proxyId1,proxyId2);
         if(pair.IsBuffered() == false)
         {
            pair.SetBuffered();
            bufferedPair = this.m_pairBuffer[this.m_pairBufferCount];
            bufferedPair.proxyId1 = pair.proxyId1;
            bufferedPair.proxyId2 = pair.proxyId2;
            ++this.m_pairBufferCount;
         }
         pair.ClearRemoved();
         if(Box2D.Collision.b2BroadPhase.s_validate)
         {
            this.ValidateBuffer();
         }
      }
      
      private function AddPair(proxyId1:uint, proxyId2:uint) : b2Pair
      {
         var temp:uint = 0;
         if(proxyId1 > proxyId2)
         {
            temp = proxyId1;
            proxyId1 = proxyId2;
            proxyId2 = temp;
         }
         var hash:uint = uint(Hash(proxyId1,proxyId2) & b2Pair.b2_tableMask);
         var pair:b2Pair = pair = this.FindHash(proxyId1,proxyId2,hash);
         if(pair != null)
         {
            return pair;
         }
         var pIndex:uint = this.m_freePair;
         pair = this.m_pairs[pIndex];
         this.m_freePair = pair.next;
         pair.proxyId1 = proxyId1;
         pair.proxyId2 = proxyId2;
         pair.status = 0;
         pair.userData = null;
         pair.next = this.m_hashTable[hash];
         this.m_hashTable[hash] = pIndex;
         ++this.m_pairCount;
         return pair;
      }
      
      private function ValidateTable() : void
      {
      }
   }
}
