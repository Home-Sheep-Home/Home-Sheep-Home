package Box2D.Dynamics.Joints
{
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Dynamics.b2Body;
   
   public class b2PrismaticJointDef extends b2JointDef
   {
       
      
      public var motorSpeed:Number;
      
      public var localAxis1:b2Vec2;
      
      public var referenceAngle:Number;
      
      public var upperTranslation:Number;
      
      public var localAnchor1:b2Vec2;
      
      public var localAnchor2:b2Vec2;
      
      public var enableLimit:Boolean;
      
      public var enableMotor:Boolean;
      
      public var maxMotorForce:Number;
      
      public var lowerTranslation:Number;
      
      public function b2PrismaticJointDef()
      {
         this.localAnchor1 = new b2Vec2();
         this.localAnchor2 = new b2Vec2();
         this.localAxis1 = new b2Vec2();
         super();
         type = b2Joint.e_prismaticJoint;
         this.localAxis1.Set(1,0);
         this.referenceAngle = 0;
         this.enableLimit = false;
         this.lowerTranslation = 0;
         this.upperTranslation = 0;
         this.enableMotor = false;
         this.maxMotorForce = 0;
         this.motorSpeed = 0;
      }
      
      public function Initialize(b1:b2Body, b2:b2Body, anchor:b2Vec2, axis:b2Vec2) : void
      {
         body1 = b1;
         body2 = b2;
         this.localAnchor1 = body1.GetLocalPoint(anchor);
         this.localAnchor2 = body2.GetLocalPoint(anchor);
         this.localAxis1 = body1.GetLocalVector(axis);
         this.referenceAngle = body2.GetAngle() - body1.GetAngle();
      }
   }
}
