package com.aardman.app
{
   import Box2D.Collision.*;
   import Box2D.Collision.Shapes.*;
   import Box2D.Common.Math.*;
   import Box2D.Dynamics.*;
   import Box2D.Dynamics.Joints.*;
   import com.deeperbeige.lib3as.Box2DUtils;
   import com.deeperbeige.lib3as.Coords;
   import com.deeperbeige.lib3as.Maths;
   import flash.display.*;
   import flash.events.*;
   import flash.geom.*;
   import flash.net.*;
   
   public class LevelGen
   {
       
      
      public function LevelGen()
      {
         super();
      }
      
      private static function px2m(px:Number) : Number
      {
         return Game.inst.px2m(px);
      }
      
      private static function m2px(m:Number) : Number
      {
         return Game.inst.m2px(m);
      }
      
      public static function createLevelPhysics(clip:MovieClip, levelID:int, defaultPaint:Boolean) : b2World
      {
         var shapeDefs:Array = null;
         var world:b2World = null;
         var body:b2Body = null;
         var bodyDef:b2BodyDef = null;
         var debugDraw:b2DebugDraw = null;
         var dispObj:DisplayObject = null;
         var item:MovieClip = null;
         var topDefs:Array = null;
         var leftDefs:Array = null;
         var rightDefs:Array = null;
         var bottomDefs:Array = null;
         var density:Number = NaN;
         var wallDef:b2PolygonDef = null;
         var ballDef:b2CircleDef = null;
         var circleSensorDef:b2CircleDef = null;
         var boxDef:b2PolygonDef = null;
         var platformDef:b2PolygonDef = null;
         var ropeJointDef:b2DistanceJointDef = null;
         var p1:Point = null;
         var p2:Point = null;
         var jointDef:b2RevoluteJointDef = null;
         var pos:Point = null;
         var s:b2Shape = null;
         var level:MovieClip = clip.level;
         level.worldBox.visible = false;
         var environment:b2AABB = new b2AABB();
         environment.lowerBound.Set(px2m(level.worldBox.x),px2m(level.worldBox.y));
         environment.upperBound.Set(px2m(level.worldBox.x + level.worldBox.width),px2m(level.worldBox.y + level.worldBox.height));
         var gravity:b2Vec2 = new b2Vec2(0,11);
         world = new b2World(environment,gravity,true);
         if(defaultPaint)
         {
            debugDraw = new b2DebugDraw();
            debugDraw.m_sprite = level.physicsHolder;
            debugDraw.m_drawScale = m2px(1);
            debugDraw.m_fillAlpha = 0.5;
            debugDraw.m_lineThickness = 1;
            debugDraw.m_drawFlags = b2DebugDraw.e_shapeBit;
            world.SetDebugDraw(debugDraw);
         }
         for(var j:int = 0; j < level.numChildren; j++)
         {
            dispObj = level.getChildAt(j);
            if(dispObj is MovieClip)
            {
               item = MovieClip(dispObj);
               if(item.isSheep)
               {
                  bodyDef = new b2BodyDef();
                  bodyDef.position.Set(px2m(item.x),px2m(item.y));
                  bodyDef.userData = item;
                  bodyDef.linearDamping = 0.5;
                  bodyDef.fixedRotation = true;
                  bodyDef.allowSleep = false;
                  density = 1;
                  if(item.isShirley)
                  {
                     topDefs = Polys.shirleyTop;
                     leftDefs = Polys.shirleyLeft;
                     rightDefs = Polys.shirleyRight;
                     bottomDefs = Polys.shirleyBottom;
                     density = 1.2;
                  }
                  if(item.isShaun)
                  {
                     topDefs = Polys.shaunTop;
                     leftDefs = Polys.shaunLeft;
                     rightDefs = Polys.shaunRight;
                     bottomDefs = Polys.shaunBottom;
                  }
                  if(item.isTimmy)
                  {
                     topDefs = Polys.timmyTop;
                     leftDefs = Polys.timmyLeft;
                     rightDefs = Polys.timmyRight;
                     bottomDefs = Polys.timmyBottom;
                  }
                  body = world.CreateBody(bodyDef);
                  item.topShape = Box2DUtils.addDecompShapes(body,px2m(1),density,0.7,0,topDefs);
                  item.leftShape = Box2DUtils.addDecompShapes(body,px2m(1),density,0,0,leftDefs);
                  item.rightShape = Box2DUtils.addDecompShapes(body,px2m(1),density,0,0,rightDefs);
                  item.bottomShape = Box2DUtils.addDecompShapes(body,px2m(1),density,0.5,0,bottomDefs);
                  body.SetMassFromShapes();
                  item.body = body;
               }
               if(item.isWall)
               {
                  bodyDef = new b2BodyDef();
                  bodyDef.position.Set(px2m(item.x),px2m(item.y));
                  bodyDef.userData = item;
                  wallDef = new b2PolygonDef();
                  wallDef.SetAsOrientedBox(px2m(100 * item.scaleX) / 2,px2m(100 * item.scaleY) / 2,new b2Vec2(0,0),Maths.degToRad(item.rotation));
                  wallDef.friction = 0.5;
                  wallDef.density = 0;
                  wallDef.restitution = 0;
                  if(item.isFailure)
                  {
                     wallDef.isSensor = true;
                     item.visible = false;
                  }
                  body = world.CreateBody(bodyDef);
                  body.CreateShape(wallDef);
                  body.SetMassFromShapes();
                  item.bodyRef = body;
               }
               if(item.isBall)
               {
                  bodyDef = new b2BodyDef();
                  bodyDef.position.Set(px2m(item.x),px2m(item.y));
                  bodyDef.angularDamping = 3;
                  bodyDef.userData = item;
                  ballDef = new b2CircleDef();
                  ballDef.localPosition.Set(0,0);
                  ballDef.radius = px2m(item.scaleX * 100 / 2);
                  ballDef.friction = 0.3;
                  ballDef.density = 1;
                  ballDef.restitution = 0.3;
                  body = world.CreateBody(bodyDef);
                  body.CreateShape(ballDef);
                  body.SetMassFromShapes();
                  item.body = body;
                  item.rotationOffset = item.rotation;
               }
               if(item.isSwitch)
               {
                  bodyDef = new b2BodyDef();
                  bodyDef.position.Set(px2m(item.x),px2m(item.y));
                  bodyDef.userData = item;
                  circleSensorDef = new b2CircleDef();
                  circleSensorDef.localPosition.Set(0,px2m(item.height / 4));
                  circleSensorDef.radius = px2m(item.width / 2);
                  circleSensorDef.density = 0;
                  circleSensorDef.isSensor = true;
                  body = world.CreateBody(bodyDef);
                  body.CreateShape(circleSensorDef);
                  body.SetMassFromShapes();
                  item.active = false;
               }
               if(item.isBox)
               {
                  bodyDef = new b2BodyDef();
                  bodyDef.position.Set(px2m(item.x),px2m(item.y));
                  bodyDef.angularDamping = 0.5;
                  bodyDef.userData = item;
                  boxDef = new b2PolygonDef();
                  boxDef.SetAsOrientedBox(px2m(100 * item.scaleX) / 2,px2m(100 * item.scaleY) / 2,new b2Vec2(0,0),Maths.degToRad(item.rotation));
                  boxDef.friction = 0.7;
                  boxDef.density = 1;
                  boxDef.restitution = 0.2;
                  body = world.CreateBody(bodyDef);
                  body.CreateShape(boxDef);
                  body.SetMassFromShapes();
                  item.body = body;
                  item.rotationOffset = -item.rotation;
               }
               if(item.isGround)
               {
                  bodyDef = new b2BodyDef();
                  bodyDef.position.Set(px2m(item.x),px2m(item.y));
                  bodyDef.userData = item;
                  switch(levelID)
                  {
                     case 1:
                        shapeDefs = Polys.l01;
                        break;
                     case 2:
                        shapeDefs = Polys.l02;
                        break;
                     case 3:
                        shapeDefs = Polys.l03;
                        break;
                     case 4:
                        shapeDefs = Polys.l04;
                        break;
                     case 5:
                        shapeDefs = Polys.l05;
                        break;
                     case 6:
                        shapeDefs = Polys.l06;
                        break;
                     case 7:
                        shapeDefs = Polys.l07;
                        break;
                     case 8:
                        shapeDefs = Polys.l08;
                        break;
                     case 9:
                        shapeDefs = Polys.l09;
                        break;
                     case 10:
                        shapeDefs = Polys.l10;
                        break;
                     case 11:
                        shapeDefs = Polys.l11;
                        break;
                     case 12:
                        shapeDefs = Polys.l12;
                        break;
                     case 13:
                        shapeDefs = Polys.l13;
                        break;
                     case 14:
                        shapeDefs = Polys.l14;
                        break;
                     case 15:
                        shapeDefs = Polys.l15;
                  }
                  body = world.CreateBody(bodyDef);
                  Box2DUtils.addDecompShapes(body,px2m(1),0,0.5,0,shapeDefs);
                  body.SetMassFromShapes();
                  item.visible = false;
               }
               if(item.isTrampoline)
               {
                  bodyDef = new b2BodyDef();
                  bodyDef.position.Set(px2m(item.x),px2m(item.y));
                  bodyDef.userData = item;
                  body = world.CreateBody(bodyDef);
                  item.bouncyShape = Box2DUtils.addDecompShapes(body,px2m(1),1,0.1,1.5,Polys.trampolineBouncy);
                  item.staticShape = Box2DUtils.addDecompShapes(body,px2m(1),1,0.3,0,Polys.trampolineBase);
                  body.SetMassFromShapes();
                  item.body = body;
               }
               if(item.isSeesaw)
               {
                  bodyDef = new b2BodyDef();
                  bodyDef.position.Set(px2m(item.x),px2m(item.y));
                  bodyDef.userData = item;
                  body = world.CreateBody(bodyDef);
                  Box2DUtils.addDecompShapes(body,px2m(1),0.5,0.3,0,Polys.seesaw);
                  body.SetMassFromShapes();
                  item.body = body;
               }
               if(item.isSwing)
               {
                  bodyDef = new b2BodyDef();
                  bodyDef.position.Set(px2m(item.x),px2m(item.y));
                  bodyDef.angularDamping = 0.5;
                  bodyDef.linearDamping = 0.1;
                  bodyDef.userData = item;
                  platformDef = new b2PolygonDef();
                  platformDef.SetAsOrientedBox(px2m(item.width) / 2,px2m(item.height) / 2,new b2Vec2(0,0),Maths.degToRad(item.rotation));
                  platformDef.friction = 0.3;
                  platformDef.density = 0.9;
                  platformDef.restitution = 0;
                  body = world.CreateBody(bodyDef);
                  body.CreateShape(platformDef);
                  body.SetMassFromShapes();
                  item.body = body;
                  item.rotationOffset = -item.rotation;
                  p1 = Coords.getLocal(item.point1,level);
                  p2 = Coords.getLocal(item.point2,level);
                  ropeJointDef = new b2DistanceJointDef();
                  ropeJointDef.Initialize(body,world.GetGroundBody(),new b2Vec2(px2m(p1.x),px2m(p1.y)),new b2Vec2(px2m(level.rope1.x),px2m(level.rope1.y)));
                  world.CreateJoint(ropeJointDef);
                  ropeJointDef = new b2DistanceJointDef();
                  ropeJointDef.Initialize(body,world.GetGroundBody(),new b2Vec2(px2m(p2.x),px2m(p2.y)),new b2Vec2(px2m(level.rope2.x),px2m(level.rope2.y)));
                  world.CreateJoint(ropeJointDef);
               }
               if(item.hasPin)
               {
                  item.hasPin.visible = false;
                  jointDef = new b2RevoluteJointDef();
                  pos = Coords.getLocal(item.hasPin,level);
                  jointDef.Initialize(item.body,world.GetGroundBody(),new b2Vec2(px2m(pos.x),px2m(pos.y)));
                  world.CreateJoint(jointDef);
               }
               if(item.lowFriction)
               {
                  s = body.GetShapeList();
                  while(s)
                  {
                     s.m_friction = s.GetFriction() / 2;
                     s = s.GetNext();
                  }
               }
               if(item.nonScaled)
               {
                  item.removeChild(item.nonScaled);
                  level.addChildAt(item.nonScaled,level.getChildIndex(item));
                  j++;
                  item.nonScaled.scaleX = 1;
                  item.nonScaled.scaleY = 1;
                  item.visible = false;
               }
               if(item.isInvisible)
               {
                  item.visible = false;
               }
            }
         }
         Game.inst.contactListener = new ContactListener();
         world.SetContactListener(Game.inst.contactListener);
         switch(levelID)
         {
            case 12:
               level.bridge.visible = false;
               level.bridge.origX = level.bridge.bodyRef.GetWorldCenter().x;
               level.bridge.origY = level.bridge.bodyRef.GetWorldCenter().y;
               level.bridge.bodyRef.SetXForm(new b2Vec2(px2m(200),px2m(-100)),level.bridge.bodyRef.GetAngle());
               break;
            case 8:
            case 10:
            case 4:
            case 9:
               level.gate.origX = level.gate.bodyRef.GetWorldCenter().x;
               level.gate.origY = level.gate.bodyRef.GetWorldCenter().y;
         }
         return world;
      }
   }
}
