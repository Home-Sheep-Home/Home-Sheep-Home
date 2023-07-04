package com.deeperbeige.lib3as
{
   import Box2D.Collision.*;
   import Box2D.Collision.Shapes.*;
   import Box2D.Common.Math.*;
   import Box2D.Common.b2Settings;
   import Box2D.Dynamics.*;
   import flash.display.*;
   import flash.geom.*;
   
   public class Box2DUtils
   {
       
      
      public function Box2DUtils()
      {
         super();
      }
      
      public static function addDecompShapes(body:b2Body, scaleFactor:Number, density:Number, friction:Number, restitution:Number, shapeData:Array, isSensor:Boolean = false) : b2Shape
      {
         var vertices:Array = null;
         var shapeDef:b2PolygonDef = null;
         var vertexIdx:int = 0;
         var vertex:Array = null;
         var lastShape:b2Shape = null;
         for(var shapeIdx:int = 0; shapeIdx < shapeData.length; shapeIdx++)
         {
            vertices = shapeData[shapeIdx];
            shapeDef = new b2PolygonDef();
            shapeDef.density = density;
            shapeDef.friction = friction;
            shapeDef.restitution = restitution;
            shapeDef.vertexCount = vertices.length;
            shapeDef.isSensor = isSensor;
            if(vertices.length > b2Settings.b2_maxPolygonVertices)
            {
               trace("Shape " + shapeIdx + " has " + vertices.length + " verticies but Box2D only supports" + b2Settings.b2_maxPolygonVertices);
            }
            for(vertexIdx = 0; vertexIdx < vertices.length; vertexIdx++)
            {
               vertex = vertices[vertexIdx];
               shapeDef.vertices[vertexIdx].Set(scaleFactor * vertex[0],scaleFactor * vertex[1]);
            }
            lastShape = body.CreateShape(shapeDef);
         }
         return lastShape;
      }
   }
}
