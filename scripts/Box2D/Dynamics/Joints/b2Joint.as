package Box2D.Dynamics.Joints
{
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Dynamics.b2Body;
   import Box2D.Dynamics.b2TimeStep;
   
   public class b2Joint
   {
      
      public static const e_unknownJoint:int = 0;
      
      public static const e_inactiveLimit:int = 0;
      
      public static const e_atUpperLimit:int = 2;
      
      public static const e_atLowerLimit:int = 1;
      
      public static const e_gearJoint:int = 6;
      
      public static const e_revoluteJoint:int = 1;
      
      public static const e_equalLimits:int = 3;
      
      public static const e_distanceJoint:int = 3;
      
      public static const e_pulleyJoint:int = 4;
      
      public static const e_prismaticJoint:int = 2;
      
      public static const e_mouseJoint:int = 5;
       
      
      public var m_islandFlag:Boolean;
      
      public var m_body1:b2Body;
      
      public var m_prev:Box2D.Dynamics.Joints.b2Joint;
      
      public var m_next:Box2D.Dynamics.Joints.b2Joint;
      
      public var m_type:int;
      
      public var m_collideConnected:Boolean;
      
      public var m_node1:Box2D.Dynamics.Joints.b2JointEdge;
      
      public var m_node2:Box2D.Dynamics.Joints.b2JointEdge;
      
      public var m_inv_dt:Number;
      
      public var m_userData;
      
      public var m_body2:b2Body;
      
      public function b2Joint(def:b2JointDef)
      {
         this.m_node1 = new Box2D.Dynamics.Joints.b2JointEdge();
         this.m_node2 = new Box2D.Dynamics.Joints.b2JointEdge();
         super();
         this.m_type = def.type;
         this.m_prev = null;
         this.m_next = null;
         this.m_body1 = def.body1;
         this.m_body2 = def.body2;
         this.m_collideConnected = def.collideConnected;
         this.m_islandFlag = false;
         this.m_userData = def.userData;
      }
      
      public static function Destroy(joint:Box2D.Dynamics.Joints.b2Joint, allocator:*) : void
      {
      }
      
      public static function Create(def:b2JointDef, allocator:*) : Box2D.Dynamics.Joints.b2Joint
      {
         var joint:Box2D.Dynamics.Joints.b2Joint = null;
         switch(def.type)
         {
            case e_distanceJoint:
               joint = new b2DistanceJoint(def as b2DistanceJointDef);
               break;
            case e_mouseJoint:
               joint = new b2MouseJoint(def as b2MouseJointDef);
               break;
            case e_prismaticJoint:
               joint = new b2PrismaticJoint(def as b2PrismaticJointDef);
               break;
            case e_revoluteJoint:
               joint = new b2RevoluteJoint(def as b2RevoluteJointDef);
               break;
            case e_pulleyJoint:
               joint = new b2PulleyJoint(def as b2PulleyJointDef);
               break;
            case e_gearJoint:
               joint = new b2GearJoint(def as b2GearJointDef);
         }
         return joint;
      }
      
      public function GetBody2() : b2Body
      {
         return this.m_body2;
      }
      
      public function GetAnchor1() : b2Vec2
      {
         return null;
      }
      
      public function GetAnchor2() : b2Vec2
      {
         return null;
      }
      
      public function GetNext() : Box2D.Dynamics.Joints.b2Joint
      {
         return this.m_next;
      }
      
      public function GetType() : int
      {
         return this.m_type;
      }
      
      public function InitVelocityConstraints(step:b2TimeStep) : void
      {
      }
      
      public function GetReactionTorque() : Number
      {
         return 0;
      }
      
      public function GetUserData() : *
      {
         return this.m_userData;
      }
      
      public function GetReactionForce() : b2Vec2
      {
         return null;
      }
      
      public function SolvePositionConstraints() : Boolean
      {
         return false;
      }
      
      public function SetUserData(data:*) : void
      {
         this.m_userData = data;
      }
      
      public function GetBody1() : b2Body
      {
         return this.m_body1;
      }
      
      public function SolveVelocityConstraints(step:b2TimeStep) : void
      {
      }
      
      public function InitPositionConstraints() : void
      {
      }
   }
}
