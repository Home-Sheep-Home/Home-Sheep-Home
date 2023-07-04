package Box2D.Dynamics.Joints
{
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Dynamics.b2Body;
   
   public class b2PulleyJointDef extends b2JointDef
   {
       
      
      public var maxLength1:Number;
      
      public var maxLength2:Number;
      
      public var length1:Number;
      
      public var localAnchor1:b2Vec2;
      
      public var localAnchor2:b2Vec2;
      
      public var groundAnchor1:b2Vec2;
      
      public var groundAnchor2:b2Vec2;
      
      public var ratio:Number;
      
      public var length2:Number;
      
      public function b2PulleyJointDef()
      {
         this.groundAnchor1 = new b2Vec2();
         this.groundAnchor2 = new b2Vec2();
         this.localAnchor1 = new b2Vec2();
         this.localAnchor2 = new b2Vec2();
         super();
         type = b2Joint.e_pulleyJoint;
         this.groundAnchor1.Set(-1,1);
         this.groundAnchor2.Set(1,1);
         this.localAnchor1.Set(-1,0);
         this.localAnchor2.Set(1,0);
         this.length1 = 0;
         this.maxLength1 = 0;
         this.length2 = 0;
         this.maxLength2 = 0;
         this.ratio = 1;
         collideConnected = true;
      }
      
      public function Initialize(b1:b2Body, b2:b2Body, ga1:b2Vec2, ga2:b2Vec2, anchor1:b2Vec2, anchor2:b2Vec2, r:Number) : void
      {
         body1 = b1;
         body2 = b2;
         this.groundAnchor1.SetV(ga1);
         this.groundAnchor2.SetV(ga2);
         this.localAnchor1 = body1.GetLocalPoint(anchor1);
         this.localAnchor2 = body2.GetLocalPoint(anchor2);
         var d1X:Number = anchor1.x - ga1.x;
         var d1Y:Number = anchor1.y - ga1.y;
         this.length1 = Math.sqrt(d1X * d1X + d1Y * d1Y);
         var d2X:Number = anchor2.x - ga2.x;
         var d2Y:Number = anchor2.y - ga2.y;
         this.length2 = Math.sqrt(d2X * d2X + d2Y * d2Y);
         this.ratio = r;
         var C:Number = this.length1 + this.ratio * this.length2;
         this.maxLength1 = C - this.ratio * b2PulleyJoint.b2_minPulleyLength;
         this.maxLength2 = (C - b2PulleyJoint.b2_minPulleyLength) / this.ratio;
      }
   }
}
