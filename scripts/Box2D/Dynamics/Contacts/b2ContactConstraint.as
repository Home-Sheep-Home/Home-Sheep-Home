package Box2D.Dynamics.Contacts
{
   import Box2D.Collision.*;
   import Box2D.Common.*;
   import Box2D.Common.Math.*;
   import Box2D.Dynamics.*;
   
   public class b2ContactConstraint
   {
       
      
      public var points:Array;
      
      public var normal:b2Vec2;
      
      public var restitution:Number;
      
      public var body1:b2Body;
      
      public var manifold:b2Manifold;
      
      public var body2:b2Body;
      
      public var friction:Number;
      
      public var pointCount:int;
      
      public function b2ContactConstraint()
      {
         this.normal = new b2Vec2();
         super();
         this.points = new Array(b2Settings.b2_maxManifoldPoints);
         for(var i:int = 0; i < b2Settings.b2_maxManifoldPoints; i++)
         {
            this.points[i] = new b2ContactConstraintPoint();
         }
      }
   }
}
