package Box2D.Collision
{
   import Box2D.Common.*;
   import Box2D.Common.Math.*;
   
   public class b2Manifold
   {
       
      
      public var pointCount:int = 0;
      
      public var normal:b2Vec2;
      
      public var points:Array;
      
      public function b2Manifold()
      {
         super();
         this.points = new Array(b2Settings.b2_maxManifoldPoints);
         for(var i:int = 0; i < b2Settings.b2_maxManifoldPoints; i++)
         {
            this.points[i] = new b2ManifoldPoint();
         }
         this.normal = new b2Vec2();
      }
      
      public function Set(m:b2Manifold) : void
      {
         this.pointCount = m.pointCount;
         for(var i:int = 0; i < b2Settings.b2_maxManifoldPoints; i++)
         {
            (this.points[i] as b2ManifoldPoint).Set(m.points[i]);
         }
         this.normal.SetV(m.normal);
      }
      
      public function Reset() : void
      {
         for(var i:int = 0; i < b2Settings.b2_maxManifoldPoints; i++)
         {
            (this.points[i] as b2ManifoldPoint).Reset();
         }
         this.normal.SetZero();
         this.pointCount = 0;
      }
   }
}
