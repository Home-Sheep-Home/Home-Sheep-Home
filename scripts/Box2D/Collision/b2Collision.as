package Box2D.Collision
{
   import Box2D.Collision.Shapes.*;
   import Box2D.Common.*;
   import Box2D.Common.Math.*;
   
   public class b2Collision
   {
      
      public static const b2_nullFeature:uint = 255;
      
      private static var b2CollidePolyTempVec:b2Vec2 = new b2Vec2();
       
      
      public function b2Collision()
      {
         super();
      }
      
      public static function EdgeSeparation(poly1:b2PolygonShape, xf1:b2XForm, edge1:int, poly2:b2PolygonShape, xf2:b2XForm) : Number
      {
         var tMat:b2Mat22 = null;
         var tVec:b2Vec2 = null;
         var dot:Number = NaN;
         var count1:int = poly1.m_vertexCount;
         var vertices1:Array = poly1.m_vertices;
         var normals1:Array = poly1.m_normals;
         var count2:int = poly2.m_vertexCount;
         var vertices2:Array = poly2.m_vertices;
         tMat = xf1.R;
         tVec = normals1[edge1];
         var normal1WorldX:Number = tMat.col1.x * tVec.x + tMat.col2.x * tVec.y;
         var normal1WorldY:Number = tMat.col1.y * tVec.x + tMat.col2.y * tVec.y;
         tMat = xf2.R;
         var normal1X:Number = tMat.col1.x * normal1WorldX + tMat.col1.y * normal1WorldY;
         var normal1Y:Number = tMat.col2.x * normal1WorldX + tMat.col2.y * normal1WorldY;
         var index:int = 0;
         var minDot:Number = Number.MAX_VALUE;
         for(var i:int = 0; i < count2; i++)
         {
            tVec = vertices2[i];
            dot = tVec.x * normal1X + tVec.y * normal1Y;
            if(dot < minDot)
            {
               minDot = dot;
               index = i;
            }
         }
         tVec = vertices1[edge1];
         tMat = xf1.R;
         var v1X:Number = xf1.position.x + (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y);
         var v1Y:Number = xf1.position.y + (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y);
         tVec = vertices2[index];
         tMat = xf2.R;
         var v2X:Number = xf2.position.x + (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y);
         var v2Y:Number = xf2.position.y + (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y);
         v2X -= v1X;
         v2Y -= v1Y;
         return v2X * normal1WorldX + v2Y * normal1WorldY;
      }
      
      public static function b2TestOverlap(a:b2AABB, b:b2AABB) : Boolean
      {
         var t1:b2Vec2 = b.lowerBound;
         var t2:b2Vec2 = a.upperBound;
         var d1X:Number = t1.x - t2.x;
         var d1Y:Number = t1.y - t2.y;
         t1 = a.lowerBound;
         t2 = b.upperBound;
         var d2X:Number = t1.x - t2.x;
         var d2Y:Number = t1.y - t2.y;
         if(d1X > 0 || d1Y > 0)
         {
            return false;
         }
         if(d2X > 0 || d2Y > 0)
         {
            return false;
         }
         return true;
      }
      
      public static function FindIncidentEdge(c:Array, poly1:b2PolygonShape, xf1:b2XForm, edge1:int, poly2:b2PolygonShape, xf2:b2XForm) : void
      {
         var tMat:b2Mat22 = null;
         var tVec:b2Vec2 = null;
         var tClip:ClipVertex = null;
         var dot:Number = NaN;
         var count1:int = poly1.m_vertexCount;
         var normals1:Array = poly1.m_normals;
         var count2:int = poly2.m_vertexCount;
         var vertices2:Array = poly2.m_vertices;
         var normals2:Array = poly2.m_normals;
         tMat = xf1.R;
         tVec = normals1[edge1];
         var normal1X:Number = tMat.col1.x * tVec.x + tMat.col2.x * tVec.y;
         var normal1Y:Number = tMat.col1.y * tVec.x + tMat.col2.y * tVec.y;
         tMat = xf2.R;
         var tX:Number = tMat.col1.x * normal1X + tMat.col1.y * normal1Y;
         normal1Y = tMat.col2.x * normal1X + tMat.col2.y * normal1Y;
         normal1X = tX;
         var index:int = 0;
         var minDot:Number = Number.MAX_VALUE;
         for(var i:int = 0; i < count2; i++)
         {
            tVec = normals2[i];
            dot = normal1X * tVec.x + normal1Y * tVec.y;
            if(dot < minDot)
            {
               minDot = dot;
               index = i;
            }
         }
         var i1:int = index;
         var i2:int = i1 + 1 < count2 ? i1 + 1 : 0;
         tClip = c[0];
         tVec = vertices2[i1];
         tMat = xf2.R;
         tClip.v.x = xf2.position.x + (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y);
         tClip.v.y = xf2.position.y + (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y);
         tClip.id.features.referenceEdge = edge1;
         tClip.id.features.incidentEdge = i1;
         tClip.id.features.incidentVertex = 0;
         tClip = c[1];
         tVec = vertices2[i2];
         tMat = xf2.R;
         tClip.v.x = xf2.position.x + (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y);
         tClip.v.y = xf2.position.y + (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y);
         tClip.id.features.referenceEdge = edge1;
         tClip.id.features.incidentEdge = i2;
         tClip.id.features.incidentVertex = 1;
      }
      
      public static function b2CollidePolygons(manifold:b2Manifold, polyA:b2PolygonShape, xfA:b2XForm, polyB:b2PolygonShape, xfB:b2XForm) : void
      {
         var cv:ClipVertex = null;
         var poly1:b2PolygonShape = null;
         var poly2:b2PolygonShape = null;
         var edge1:int = 0;
         var flip:uint = 0;
         var np:int = 0;
         var v12:b2Vec2 = null;
         var separation:Number = NaN;
         var cp:b2ManifoldPoint = null;
         manifold.pointCount = 0;
         var edgeA:int = 0;
         var edgeAO:Array = [edgeA];
         var separationA:Number = FindMaxSeparation(edgeAO,polyA,xfA,polyB,xfB);
         edgeA = int(edgeAO[0]);
         if(separationA > 0)
         {
            return;
         }
         var edgeB:int = 0;
         var edgeBO:Array = [edgeB];
         var separationB:Number = FindMaxSeparation(edgeBO,polyB,xfB,polyA,xfA);
         edgeB = int(edgeBO[0]);
         if(separationB > 0)
         {
            return;
         }
         var xf1:b2XForm = new b2XForm();
         var xf2:b2XForm = new b2XForm();
         var k_relativeTol:Number = 0.98;
         var k_absoluteTol:Number = 0.001;
         if(separationB > k_relativeTol * separationA + k_absoluteTol)
         {
            poly1 = polyB;
            poly2 = polyA;
            xf1.Set(xfB);
            xf2.Set(xfA);
            edge1 = edgeB;
            flip = 1;
         }
         else
         {
            poly1 = polyA;
            poly2 = polyB;
            xf1.Set(xfA);
            xf2.Set(xfB);
            edge1 = edgeA;
            flip = 0;
         }
         var incidentEdge:Array = [new ClipVertex(),new ClipVertex()];
         FindIncidentEdge(incidentEdge,poly1,xf1,edge1,poly2,xf2);
         var count1:int = poly1.m_vertexCount;
         var vertices1:Array = poly1.m_vertices;
         var tVec:b2Vec2 = vertices1[edge1];
         var v11:b2Vec2 = tVec.Copy();
         if(edge1 + 1 < count1)
         {
            tVec = vertices1[int(edge1 + 1)];
            v12 = tVec.Copy();
         }
         else
         {
            tVec = vertices1[0];
            v12 = tVec.Copy();
         }
         var dv:b2Vec2 = b2Math.SubtractVV(v12,v11);
         var sideNormal:b2Vec2 = b2Math.b2MulMV(xf1.R,b2Math.SubtractVV(v12,v11));
         sideNormal.Normalize();
         var frontNormal:b2Vec2 = b2Math.b2CrossVF(sideNormal,1);
         v11 = b2Math.b2MulX(xf1,v11);
         v12 = b2Math.b2MulX(xf1,v12);
         var frontOffset:Number = b2Math.b2Dot(frontNormal,v11);
         var sideOffset1:Number = -b2Math.b2Dot(sideNormal,v11);
         var sideOffset2:Number = b2Math.b2Dot(sideNormal,v12);
         var clipPoints1:Array = [new ClipVertex(),new ClipVertex()];
         var clipPoints2:Array = [new ClipVertex(),new ClipVertex()];
         np = ClipSegmentToLine(clipPoints1,incidentEdge,sideNormal.Negative(),sideOffset1);
         if(np < 2)
         {
            return;
         }
         np = ClipSegmentToLine(clipPoints2,clipPoints1,sideNormal,sideOffset2);
         if(np < 2)
         {
            return;
         }
         manifold.normal = !!flip ? frontNormal.Negative() : frontNormal.Copy();
         var pointCount:int = 0;
         for(var i:int = 0; i < b2Settings.b2_maxManifoldPoints; i++)
         {
            cv = clipPoints2[i];
            separation = b2Math.b2Dot(frontNormal,cv.v) - frontOffset;
            if(separation <= 0)
            {
               cp = manifold.points[pointCount];
               cp.separation = separation;
               cp.localPoint1 = b2Math.b2MulXT(xfA,cv.v);
               cp.localPoint2 = b2Math.b2MulXT(xfB,cv.v);
               cp.id.key = cv.id._key;
               cp.id.features.flip = flip;
               pointCount++;
            }
         }
         manifold.pointCount = pointCount;
      }
      
      public static function FindMaxSeparation(edgeIndex:Array, poly1:b2PolygonShape, xf1:b2XForm, poly2:b2PolygonShape, xf2:b2XForm) : Number
      {
         var tVec:b2Vec2 = null;
         var tMat:b2Mat22 = null;
         var bestEdge:int = 0;
         var bestSeparation:Number = NaN;
         var increment:int = 0;
         var dot:Number = NaN;
         var count1:int = poly1.m_vertexCount;
         var normals1:Array = poly1.m_normals;
         tMat = xf2.R;
         tVec = poly2.m_centroid;
         var dX:Number = xf2.position.x + (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y);
         var dY:Number = xf2.position.y + (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y);
         tMat = xf1.R;
         tVec = poly1.m_centroid;
         dX -= xf1.position.x + (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y);
         dY -= xf1.position.y + (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y);
         var dLocal1X:Number = dX * xf1.R.col1.x + dY * xf1.R.col1.y;
         var dLocal1Y:Number = dX * xf1.R.col2.x + dY * xf1.R.col2.y;
         var edge:int = 0;
         var maxDot:Number = -Number.MAX_VALUE;
         for(var i:int = 0; i < count1; i++)
         {
            tVec = normals1[i];
            dot = tVec.x * dLocal1X + tVec.y * dLocal1Y;
            if(dot > maxDot)
            {
               maxDot = dot;
               edge = i;
            }
         }
         var s:Number = EdgeSeparation(poly1,xf1,edge,poly2,xf2);
         if(s > 0)
         {
            return s;
         }
         var prevEdge:int = edge - 1 >= 0 ? edge - 1 : count1 - 1;
         var sPrev:Number = EdgeSeparation(poly1,xf1,prevEdge,poly2,xf2);
         if(sPrev > 0)
         {
            return sPrev;
         }
         var nextEdge:int = edge + 1 < count1 ? edge + 1 : 0;
         var sNext:Number = EdgeSeparation(poly1,xf1,nextEdge,poly2,xf2);
         if(sNext > 0)
         {
            return sNext;
         }
         if(sPrev > s && sPrev > sNext)
         {
            increment = -1;
            bestEdge = prevEdge;
            bestSeparation = sPrev;
         }
         else
         {
            if(sNext <= s)
            {
               edgeIndex[0] = edge;
               return s;
            }
            increment = 1;
            bestEdge = nextEdge;
            bestSeparation = sNext;
         }
         while(true)
         {
            if(increment == -1)
            {
               edge = bestEdge - 1 >= 0 ? bestEdge - 1 : count1 - 1;
            }
            else
            {
               edge = bestEdge + 1 < count1 ? bestEdge + 1 : 0;
            }
            s = EdgeSeparation(poly1,xf1,edge,poly2,xf2);
            if(s > 0)
            {
               break;
            }
            if(s <= bestSeparation)
            {
               edgeIndex[0] = bestEdge;
               return bestSeparation;
            }
            bestEdge = edge;
            bestSeparation = s;
         }
         return s;
      }
      
      public static function ClipSegmentToLine(vOut:Array, vIn:Array, normal:b2Vec2, offset:Number) : int
      {
         var cv:ClipVertex = null;
         var numOut:int = 0;
         var vIn0:b2Vec2 = null;
         var vIn1:b2Vec2 = null;
         var distance0:Number = NaN;
         var interp:Number = NaN;
         var tVec:b2Vec2 = null;
         var cv2:ClipVertex = null;
         numOut = 0;
         cv = vIn[0];
         vIn0 = cv.v;
         cv = vIn[1];
         vIn1 = cv.v;
         distance0 = b2Math.b2Dot(normal,vIn0) - offset;
         var distance1:Number = b2Math.b2Dot(normal,vIn1) - offset;
         if(distance0 <= 0)
         {
            var _loc14_:*;
            vOut[_loc14_ = numOut++] = vIn[0];
         }
         if(distance1 <= 0)
         {
            vOut[_loc14_ = numOut++] = vIn[1];
         }
         if(distance0 * distance1 < 0)
         {
            interp = distance0 / (distance0 - distance1);
            cv = vOut[numOut];
            tVec = cv.v;
            tVec.x = vIn0.x + interp * (vIn1.x - vIn0.x);
            tVec.y = vIn0.y + interp * (vIn1.y - vIn0.y);
            cv = vOut[numOut];
            if(distance0 > 0)
            {
               cv2 = vIn[0];
               cv.id = cv2.id;
            }
            else
            {
               cv2 = vIn[1];
               cv.id = cv2.id;
            }
            numOut++;
         }
         return numOut;
      }
      
      public static function b2CollideCircles(manifold:b2Manifold, circle1:b2CircleShape, xf1:b2XForm, circle2:b2CircleShape, xf2:b2XForm) : void
      {
         var tMat:b2Mat22 = null;
         var tVec:b2Vec2 = null;
         var separation:Number = NaN;
         var dist:Number = NaN;
         var a:Number = NaN;
         manifold.pointCount = 0;
         tMat = xf1.R;
         tVec = circle1.m_localPosition;
         var p1X:Number = xf1.position.x + (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y);
         var p1Y:Number = xf1.position.y + (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y);
         tMat = xf2.R;
         tVec = circle2.m_localPosition;
         var p2X:Number = xf2.position.x + (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y);
         var p2Y:Number = xf2.position.y + (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y);
         var dX:Number = p2X - p1X;
         var dY:Number = p2Y - p1Y;
         var distSqr:Number = dX * dX + dY * dY;
         var r1:Number = circle1.m_radius;
         var r2:Number = circle2.m_radius;
         var radiusSum:Number = r1 + r2;
         if(distSqr > radiusSum * radiusSum)
         {
            return;
         }
         if(distSqr < Number.MIN_VALUE)
         {
            separation = -radiusSum;
            manifold.normal.Set(0,1);
         }
         else
         {
            dist = Math.sqrt(distSqr);
            separation = dist - radiusSum;
            a = 1 / dist;
            manifold.normal.x = a * dX;
            manifold.normal.y = a * dY;
         }
         manifold.pointCount = 1;
         var tPoint:b2ManifoldPoint = manifold.points[0];
         tPoint.id.key = 0;
         tPoint.separation = separation;
         p1X += r1 * manifold.normal.x;
         p1Y += r1 * manifold.normal.y;
         p2X -= r2 * manifold.normal.x;
         p2Y -= r2 * manifold.normal.y;
         var pX:Number = 0.5 * (p1X + p2X);
         var pY:Number = 0.5 * (p1Y + p2Y);
         var tX:Number = pX - xf1.position.x;
         var tY:Number = pY - xf1.position.y;
         tPoint.localPoint1.x = tX * xf1.R.col1.x + tY * xf1.R.col1.y;
         tPoint.localPoint1.y = tX * xf1.R.col2.x + tY * xf1.R.col2.y;
         tX = pX - xf2.position.x;
         tY = pY - xf2.position.y;
         tPoint.localPoint2.x = tX * xf2.R.col1.x + tY * xf2.R.col1.y;
         tPoint.localPoint2.y = tX * xf2.R.col2.x + tY * xf2.R.col2.y;
      }
      
      public static function b2CollidePolygonAndCircle(manifold:b2Manifold, polygon:b2PolygonShape, xf1:b2XForm, circle:b2CircleShape, xf2:b2XForm) : void
      {
         var tPoint:b2ManifoldPoint = null;
         var dX:Number = NaN;
         var dY:Number = NaN;
         var positionX:Number = NaN;
         var positionY:Number = NaN;
         var tVec:b2Vec2 = null;
         var tMat:b2Mat22 = null;
         var dist:Number = NaN;
         var pX:Number = NaN;
         var pY:Number = NaN;
         var s:Number = NaN;
         manifold.pointCount = 0;
         tMat = xf2.R;
         tVec = circle.m_localPosition;
         var cX:Number = xf2.position.x + (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y);
         var cY:Number = xf2.position.y + (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y);
         dX = cX - xf1.position.x;
         dY = cY - xf1.position.y;
         tMat = xf1.R;
         var cLocalX:Number = dX * tMat.col1.x + dY * tMat.col1.y;
         var cLocalY:Number = dX * tMat.col2.x + dY * tMat.col2.y;
         var normalIndex:int = 0;
         var separation:Number = -Number.MAX_VALUE;
         var radius:Number = circle.m_radius;
         var vertexCount:int = polygon.m_vertexCount;
         var vertices:Array = polygon.m_vertices;
         var normals:Array = polygon.m_normals;
         for(var i:int = 0; i < vertexCount; i++)
         {
            tVec = vertices[i];
            dX = cLocalX - tVec.x;
            dY = cLocalY - tVec.y;
            tVec = normals[i];
            s = tVec.x * dX + tVec.y * dY;
            if(s > radius)
            {
               return;
            }
            if(s > separation)
            {
               separation = s;
               normalIndex = i;
            }
         }
         if(separation < Number.MIN_VALUE)
         {
            manifold.pointCount = 1;
            tVec = normals[normalIndex];
            tMat = xf1.R;
            manifold.normal.x = tMat.col1.x * tVec.x + tMat.col2.x * tVec.y;
            manifold.normal.y = tMat.col1.y * tVec.x + tMat.col2.y * tVec.y;
            tPoint = manifold.points[0];
            tPoint.id.features.incidentEdge = normalIndex;
            tPoint.id.features.incidentVertex = b2_nullFeature;
            tPoint.id.features.referenceEdge = 0;
            tPoint.id.features.flip = 0;
            positionX = cX - radius * manifold.normal.x;
            positionY = cY - radius * manifold.normal.y;
            dX = positionX - xf1.position.x;
            dY = positionY - xf1.position.y;
            tMat = xf1.R;
            tPoint.localPoint1.x = dX * tMat.col1.x + dY * tMat.col1.y;
            tPoint.localPoint1.y = dX * tMat.col2.x + dY * tMat.col2.y;
            dX = positionX - xf2.position.x;
            dY = positionY - xf2.position.y;
            tMat = xf2.R;
            tPoint.localPoint2.x = dX * tMat.col1.x + dY * tMat.col1.y;
            tPoint.localPoint2.y = dX * tMat.col2.x + dY * tMat.col2.y;
            tPoint.separation = separation - radius;
            return;
         }
         var vertIndex1:int = normalIndex;
         var vertIndex2:int = vertIndex1 + 1 < vertexCount ? vertIndex1 + 1 : 0;
         tVec = vertices[vertIndex1];
         var tVec2:b2Vec2 = vertices[vertIndex2];
         var eX:Number = tVec2.x - tVec.x;
         var eY:Number = tVec2.y - tVec.y;
         var length:Number = Math.sqrt(eX * eX + eY * eY);
         eX /= length;
         eY /= length;
         dX = cLocalX - tVec.x;
         dY = cLocalY - tVec.y;
         var u:Number = dX * eX + dY * eY;
         tPoint = manifold.points[0];
         if(u <= 0)
         {
            pX = tVec.x;
            pY = tVec.y;
            tPoint.id.features.incidentEdge = b2_nullFeature;
            tPoint.id.features.incidentVertex = vertIndex1;
         }
         else if(u >= length)
         {
            pX = tVec2.x;
            pY = tVec2.y;
            tPoint.id.features.incidentEdge = b2_nullFeature;
            tPoint.id.features.incidentVertex = vertIndex2;
         }
         else
         {
            pX = eX * u + tVec.x;
            pY = eY * u + tVec.y;
            tPoint.id.features.incidentEdge = normalIndex;
            tPoint.id.features.incidentVertex = 0;
         }
         dX = cLocalX - pX;
         dY = cLocalY - pY;
         dist = Math.sqrt(dX * dX + dY * dY);
         dX /= dist;
         dY /= dist;
         if(dist > radius)
         {
            return;
         }
         manifold.pointCount = 1;
         tMat = xf1.R;
         manifold.normal.x = tMat.col1.x * dX + tMat.col2.x * dY;
         manifold.normal.y = tMat.col1.y * dX + tMat.col2.y * dY;
         positionX = cX - radius * manifold.normal.x;
         positionY = cY - radius * manifold.normal.y;
         dX = positionX - xf1.position.x;
         dY = positionY - xf1.position.y;
         tMat = xf1.R;
         tPoint.localPoint1.x = dX * tMat.col1.x + dY * tMat.col1.y;
         tPoint.localPoint1.y = dX * tMat.col2.x + dY * tMat.col2.y;
         dX = positionX - xf2.position.x;
         dY = positionY - xf2.position.y;
         tMat = xf2.R;
         tPoint.localPoint2.x = dX * tMat.col1.x + dY * tMat.col1.y;
         tPoint.localPoint2.y = dX * tMat.col2.x + dY * tMat.col2.y;
         tPoint.separation = dist - radius;
         tPoint.id.features.referenceEdge = 0;
         tPoint.id.features.flip = 0;
      }
   }
}
