package Box2D.Dynamics.Contacts
{
   import Box2D.Common.Math.b2Vec2;
   
   public class b2ContactConstraintPoint
   {
       
      
      public var r2:b2Vec2;
      
      public var separation:Number;
      
      public var positionImpulse:Number;
      
      public var normalImpulse:Number;
      
      public var tangentMass:Number;
      
      public var equalizedMass:Number;
      
      public var tangentImpulse:Number;
      
      public var localAnchor1:b2Vec2;
      
      public var localAnchor2:b2Vec2;
      
      public var normalMass:Number;
      
      public var velocityBias:Number;
      
      public var r1:b2Vec2;
      
      public function b2ContactConstraintPoint()
      {
         this.localAnchor1 = new b2Vec2();
         this.localAnchor2 = new b2Vec2();
         this.r1 = new b2Vec2();
         this.r2 = new b2Vec2();
         super();
      }
   }
}
