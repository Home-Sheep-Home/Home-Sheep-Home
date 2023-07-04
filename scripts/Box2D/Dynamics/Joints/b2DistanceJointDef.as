package Box2D.Dynamics.Joints
{
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Dynamics.b2Body;
   
   public class b2DistanceJointDef extends b2JointDef
   {
       
      
      public var localAnchor1:b2Vec2;
      
      public var length:Number;
      
      public var dampingRatio:Number;
      
      public var localAnchor2:b2Vec2;
      
      public var frequencyHz:Number;
      
      public function b2DistanceJointDef()
      {
         this.localAnchor1 = new b2Vec2();
         this.localAnchor2 = new b2Vec2();
         super();
         type = b2Joint.e_distanceJoint;
         this.length = 1;
         this.frequencyHz = 0;
         this.dampingRatio = 0;
      }
      
      public function Initialize(b1:b2Body, b2:b2Body, anchor1:b2Vec2, anchor2:b2Vec2) : void
      {
         body1 = b1;
         body2 = b2;
         this.localAnchor1.SetV(body1.GetLocalPoint(anchor1));
         this.localAnchor2.SetV(body2.GetLocalPoint(anchor2));
         var dX:Number = anchor2.x - anchor1.x;
         var dY:Number = anchor2.y - anchor1.y;
         this.length = Math.sqrt(dX * dX + dY * dY);
         this.frequencyHz = 0;
         this.dampingRatio = 0;
      }
   }
}
