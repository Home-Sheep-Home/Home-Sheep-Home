package Box2D.Collision.Shapes
{
   import Box2D.Collision.*;
   import Box2D.Common.*;
   import Box2D.Common.Math.*;
   import Box2D.Dynamics.*;
   
   public class b2PolygonShape extends b2Shape
   {
      
      private static var s_computeMat:b2Mat22 = new b2Mat22();
      
      private static var s_sweptAABB1:b2AABB = new b2AABB();
      
      private static var s_sweptAABB2:b2AABB = new b2AABB();
       
      
      public var m_coreVertices:Array;
      
      public var m_vertices:Array;
      
      private var s_supportVec:b2Vec2;
      
      public var m_centroid:b2Vec2;
      
      public var m_normals:Array;
      
      public var m_obb:b2OBB;
      
      public var m_vertexCount:int;
      
      public function b2PolygonShape(def:b2ShapeDef)
      {
         var i:int = 0;
         var edgeX:Number = NaN;
         var edgeY:Number = NaN;
         var len:Number = NaN;
         var n1X:Number = NaN;
         var n1Y:Number = NaN;
         var n2X:Number = NaN;
         var n2Y:Number = NaN;
         var vX:Number = NaN;
         var vY:Number = NaN;
         var dX:Number = NaN;
         var dY:Number = NaN;
         var det:Number = NaN;
         this.s_supportVec = new b2Vec2();
         this.m_obb = new b2OBB();
         this.m_vertices = new Array(b2Settings.b2_maxPolygonVertices);
         this.m_normals = new Array(b2Settings.b2_maxPolygonVertices);
         this.m_coreVertices = new Array(b2Settings.b2_maxPolygonVertices);
         super(def);
         m_type = e_polygonShape;
         var poly:b2PolygonDef = def as b2PolygonDef;
         this.m_vertexCount = poly.vertexCount;
         var i1:int = i;
         var i2:int = i;
         for(i = 0; i < this.m_vertexCount; i++)
         {
            this.m_vertices[i] = poly.vertices[i].Copy();
         }
         for(i = 0; i < this.m_vertexCount; i++)
         {
            i1 = i;
            i2 = i + 1 < this.m_vertexCount ? i + 1 : 0;
            edgeX = this.m_vertices[i2].x - this.m_vertices[i1].x;
            edgeY = this.m_vertices[i2].y - this.m_vertices[i1].y;
            len = Math.sqrt(edgeX * edgeX + edgeY * edgeY);
            this.m_normals[i] = new b2Vec2(edgeY / len,-edgeX / len);
         }
         this.m_centroid = ComputeCentroid(poly.vertices,poly.vertexCount);
         ComputeOBB(this.m_obb,this.m_vertices,this.m_vertexCount);
         for(i = 0; i < this.m_vertexCount; i++)
         {
            i1 = i - 1 >= 0 ? i - 1 : this.m_vertexCount - 1;
            i2 = i;
            n1X = Number(this.m_normals[i1].x);
            n1Y = Number(this.m_normals[i1].y);
            n2X = Number(this.m_normals[i2].x);
            n2Y = Number(this.m_normals[i2].y);
            vX = this.m_vertices[i].x - this.m_centroid.x;
            vY = this.m_vertices[i].y - this.m_centroid.y;
            dX = n1X * vX + n1Y * vY - b2Settings.b2_toiSlop;
            dY = n2X * vX + n2Y * vY - b2Settings.b2_toiSlop;
            det = 1 / (n1X * n2Y - n1Y * n2X);
            this.m_coreVertices[i] = new b2Vec2(det * (n2Y * dX - n1Y * dY) + this.m_centroid.x,det * (n1X * dY - n2X * dX) + this.m_centroid.y);
         }
      }
      
      public static function ComputeCentroid(vs:Array, count:int) : b2Vec2
      {
         var c:b2Vec2 = null;
         var inv3:Number = NaN;
         var p2:b2Vec2 = null;
         var p3:b2Vec2 = null;
         var e1X:Number = NaN;
         var e1Y:Number = NaN;
         var e2X:Number = NaN;
         var e2Y:Number = NaN;
         var D:Number = NaN;
         var triangleArea:Number = NaN;
         c = new b2Vec2();
         var area:Number = 0;
         var p1X:Number = 0;
         var p1Y:Number = 0;
         inv3 = 1 / 3;
         for(var i:int = 0; i < count; i++)
         {
            p2 = vs[i];
            p3 = i + 1 < count ? vs[int(i + 1)] : vs[0];
            e1X = p2.x - p1X;
            e1Y = p2.y - p1Y;
            e2X = p3.x - p1X;
            e2Y = p3.y - p1Y;
            D = e1X * e2Y - e1Y * e2X;
            triangleArea = 0.5 * D;
            area += triangleArea;
            c.x += triangleArea * inv3 * (p1X + p2.x + p3.x);
            c.y += triangleArea * inv3 * (p1Y + p2.y + p3.y);
         }
         c.x *= 1 / area;
         c.y *= 1 / area;
         return c;
      }
      
      public static function ComputeOBB(obb:b2OBB, vs:Array, count:int) : void
      {
         var i:int = 0;
         var root:b2Vec2 = null;
         var uxX:Number = NaN;
         var uxY:Number = NaN;
         var length:Number = NaN;
         var uyX:Number = NaN;
         var uyY:Number = NaN;
         var lowerX:Number = NaN;
         var lowerY:Number = NaN;
         var upperX:Number = NaN;
         var upperY:Number = NaN;
         var j:int = 0;
         var area:Number = NaN;
         var dX:Number = NaN;
         var dY:Number = NaN;
         var rX:Number = NaN;
         var rY:Number = NaN;
         var centerX:Number = NaN;
         var centerY:Number = NaN;
         var tMat:b2Mat22 = null;
         var p:Array = new Array(b2Settings.b2_maxPolygonVertices + 1);
         for(i = 0; i < count; i++)
         {
            p[i] = vs[i];
         }
         p[count] = p[0];
         var minArea:Number = Number.MAX_VALUE;
         for(i = 1; i <= count; i++)
         {
            root = p[int(i - 1)];
            uxX = p[i].x - root.x;
            uxY = p[i].y - root.y;
            length = Math.sqrt(uxX * uxX + uxY * uxY);
            uxX /= length;
            uxY /= length;
            uyX = -uxY;
            uyY = uxX;
            lowerX = Number.MAX_VALUE;
            lowerY = Number.MAX_VALUE;
            upperX = -Number.MAX_VALUE;
            upperY = -Number.MAX_VALUE;
            for(j = 0; j < count; j++)
            {
               dX = p[j].x - root.x;
               dY = p[j].y - root.y;
               rX = uxX * dX + uxY * dY;
               rY = uyX * dX + uyY * dY;
               if(rX < lowerX)
               {
                  lowerX = rX;
               }
               if(rY < lowerY)
               {
                  lowerY = rY;
               }
               if(rX > upperX)
               {
                  upperX = rX;
               }
               if(rY > upperY)
               {
                  upperY = rY;
               }
            }
            area = (upperX - lowerX) * (upperY - lowerY);
            if(area < 0.95 * minArea)
            {
               minArea = area;
               obb.R.col1.x = uxX;
               obb.R.col1.y = uxY;
               obb.R.col2.x = uyX;
               obb.R.col2.y = uyY;
               centerX = 0.5 * (lowerX + upperX);
               centerY = 0.5 * (lowerY + upperY);
               tMat = obb.R;
               obb.center.x = root.x + (tMat.col1.x * centerX + tMat.col2.x * centerY);
               obb.center.y = root.y + (tMat.col1.y * centerX + tMat.col2.y * centerY);
               obb.extents.x = 0.5 * (upperX - lowerX);
               obb.extents.y = 0.5 * (upperY - lowerY);
            }
         }
      }
      
      override public function ComputeSweptAABB(aabb:b2AABB, transform1:b2XForm, transform2:b2XForm) : void
      {
         var aabb1:b2AABB = s_sweptAABB1;
         var aabb2:b2AABB = s_sweptAABB2;
         this.ComputeAABB(aabb1,transform1);
         this.ComputeAABB(aabb2,transform2);
         aabb.lowerBound.Set(aabb1.lowerBound.x < aabb2.lowerBound.x ? aabb1.lowerBound.x : aabb2.lowerBound.x,aabb1.lowerBound.y < aabb2.lowerBound.y ? aabb1.lowerBound.y : aabb2.lowerBound.y);
         aabb.upperBound.Set(aabb1.upperBound.x > aabb2.upperBound.x ? aabb1.upperBound.x : aabb2.upperBound.x,aabb1.upperBound.y > aabb2.upperBound.y ? aabb1.upperBound.y : aabb2.upperBound.y);
      }
      
      public function GetVertices() : Array
      {
         return this.m_vertices;
      }
      
      public function GetCoreVertices() : Array
      {
         return this.m_coreVertices;
      }
      
      public function GetCentroid() : b2Vec2
      {
         return this.m_centroid;
      }
      
      public function GetOBB() : b2OBB
      {
         return this.m_obb;
      }
      
      public function GetFirstVertex(xf:b2XForm) : b2Vec2
      {
         return b2Math.b2MulX(xf,this.m_coreVertices[0]);
      }
      
      public function Centroid(xf:b2XForm) : b2Vec2
      {
         return b2Math.b2MulX(xf,this.m_centroid);
      }
      
      override public function TestSegment(xf:b2XForm, lambda:Array, normal:b2Vec2, segment:b2Segment, maxLambda:Number) : Boolean
      {
         var tX:Number = NaN;
         var tY:Number = NaN;
         var tMat:b2Mat22 = null;
         var tVec:b2Vec2 = null;
         var numerator:Number = NaN;
         var denominator:Number = NaN;
         var lower:Number = 0;
         var upper:Number = maxLambda;
         tX = segment.p1.x - xf.position.x;
         tY = segment.p1.y - xf.position.y;
         tMat = xf.R;
         var p1X:Number = tX * tMat.col1.x + tY * tMat.col1.y;
         var p1Y:Number = tX * tMat.col2.x + tY * tMat.col2.y;
         tX = segment.p2.x - xf.position.x;
         tY = segment.p2.y - xf.position.y;
         tMat = xf.R;
         var p2X:Number = tX * tMat.col1.x + tY * tMat.col1.y;
         var p2Y:Number = tX * tMat.col2.x + tY * tMat.col2.y;
         var dX:Number = p2X - p1X;
         var dY:Number = p2Y - p1Y;
         var index:int = -1;
         for(var i:int = 0; i < this.m_vertexCount; i++)
         {
            tVec = this.m_vertices[i];
            tX = tVec.x - p1X;
            tY = tVec.y - p1Y;
            tVec = this.m_normals[i];
            numerator = tVec.x * tX + tVec.y * tY;
            denominator = tVec.x * dX + tVec.y * dY;
            if(denominator < 0 && numerator < lower * denominator)
            {
               lower = numerator / denominator;
               index = i;
            }
            else if(denominator > 0 && numerator < upper * denominator)
            {
               upper = numerator / denominator;
            }
            if(upper < lower)
            {
               return false;
            }
         }
         if(index >= 0)
         {
            lambda[0] = lower;
            tMat = xf.R;
            tVec = this.m_normals[index];
            normal.x = tMat.col1.x * tVec.x + tMat.col2.x * tVec.y;
            normal.y = tMat.col1.y * tVec.x + tMat.col2.y * tVec.y;
            return true;
         }
         return false;
      }
      
      override public function ComputeMass(massData:b2MassData) : void
      {
         var p2:b2Vec2 = null;
         var p3:b2Vec2 = null;
         var e1X:Number = NaN;
         var e1Y:Number = NaN;
         var e2X:Number = NaN;
         var e2Y:Number = NaN;
         var D:Number = NaN;
         var triangleArea:Number = NaN;
         var px:Number = NaN;
         var py:Number = NaN;
         var ex1:Number = NaN;
         var ey1:Number = NaN;
         var ex2:Number = NaN;
         var ey2:Number = NaN;
         var intx2:Number = NaN;
         var inty2:Number = NaN;
         var centerX:Number = 0;
         var centerY:Number = 0;
         var area:Number = 0;
         var I:Number = 0;
         var p1X:Number = 0;
         var p1Y:Number = 0;
         var k_inv3:Number = 1 / 3;
         for(var i:int = 0; i < this.m_vertexCount; i++)
         {
            p2 = this.m_vertices[i];
            p3 = i + 1 < this.m_vertexCount ? this.m_vertices[int(i + 1)] : this.m_vertices[0];
            e1X = p2.x - p1X;
            e1Y = p2.y - p1Y;
            e2X = p3.x - p1X;
            e2Y = p3.y - p1Y;
            D = e1X * e2Y - e1Y * e2X;
            triangleArea = 0.5 * D;
            area += triangleArea;
            centerX += triangleArea * k_inv3 * (p1X + p2.x + p3.x);
            centerY += triangleArea * k_inv3 * (p1Y + p2.y + p3.y);
            px = p1X;
            py = p1Y;
            ex1 = e1X;
            ey1 = e1Y;
            ex2 = e2X;
            ey2 = e2Y;
            intx2 = k_inv3 * (0.25 * (ex1 * ex1 + ex2 * ex1 + ex2 * ex2) + (px * ex1 + px * ex2)) + 0.5 * px * px;
            inty2 = k_inv3 * (0.25 * (ey1 * ey1 + ey2 * ey1 + ey2 * ey2) + (py * ey1 + py * ey2)) + 0.5 * py * py;
            I += D * (intx2 + inty2);
         }
         massData.mass = m_density * area;
         centerX *= 1 / area;
         centerY *= 1 / area;
         massData.center.Set(centerX,centerY);
         massData.I = m_density * I;
      }
      
      public function GetNormals() : Array
      {
         return this.m_normals;
      }
      
      public function Support(xf:b2XForm, dX:Number, dY:Number) : b2Vec2
      {
         var tVec:b2Vec2 = null;
         var tMat:b2Mat22 = null;
         var value:Number = NaN;
         tMat = xf.R;
         var dLocalX:Number = dX * tMat.col1.x + dY * tMat.col1.y;
         var dLocalY:Number = dX * tMat.col2.x + dY * tMat.col2.y;
         var bestIndex:int = 0;
         tVec = this.m_coreVertices[0];
         var bestValue:Number = tVec.x * dLocalX + tVec.y * dLocalY;
         for(var i:int = 1; i < this.m_vertexCount; i++)
         {
            tVec = this.m_coreVertices[i];
            value = tVec.x * dLocalX + tVec.y * dLocalY;
            if(value > bestValue)
            {
               bestIndex = i;
               bestValue = value;
            }
         }
         tMat = xf.R;
         tVec = this.m_coreVertices[bestIndex];
         this.s_supportVec.x = xf.position.x + (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y);
         this.s_supportVec.y = xf.position.y + (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y);
         return this.s_supportVec;
      }
      
      public function GetVertexCount() : int
      {
         return this.m_vertexCount;
      }
      
      override public function ComputeAABB(aabb:b2AABB, xf:b2XForm) : void
      {
         var tMat:b2Mat22 = null;
         var tVec:b2Vec2 = null;
         var R:b2Mat22 = s_computeMat;
         tMat = xf.R;
         tVec = this.m_obb.R.col1;
         R.col1.x = tMat.col1.x * tVec.x + tMat.col2.x * tVec.y;
         R.col1.y = tMat.col1.y * tVec.x + tMat.col2.y * tVec.y;
         tVec = this.m_obb.R.col2;
         R.col2.x = tMat.col1.x * tVec.x + tMat.col2.x * tVec.y;
         R.col2.y = tMat.col1.y * tVec.x + tMat.col2.y * tVec.y;
         R.Abs();
         var absR:b2Mat22 = R;
         tVec = this.m_obb.extents;
         var hX:Number = absR.col1.x * tVec.x + absR.col2.x * tVec.y;
         var hY:Number = absR.col1.y * tVec.x + absR.col2.y * tVec.y;
         tMat = xf.R;
         tVec = this.m_obb.center;
         var positionX:Number = xf.position.x + (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y);
         var positionY:Number = xf.position.y + (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y);
         aabb.lowerBound.Set(positionX - hX,positionY - hY);
         aabb.upperBound.Set(positionX + hX,positionY + hY);
      }
      
      override public function UpdateSweepRadius(center:b2Vec2) : void
      {
         var tVec:b2Vec2 = null;
         var dX:Number = NaN;
         var dY:Number = NaN;
         m_sweepRadius = 0;
         for(var i:int = 0; i < this.m_vertexCount; i++)
         {
            tVec = this.m_coreVertices[i];
            dX = tVec.x - center.x;
            dY = tVec.y - center.y;
            dX = Math.sqrt(dX * dX + dY * dY);
            if(dX > m_sweepRadius)
            {
               m_sweepRadius = dX;
            }
         }
      }
      
      override public function TestPoint(xf:b2XForm, p:b2Vec2) : Boolean
      {
         var tVec:b2Vec2 = null;
         var dot:Number = NaN;
         var tMat:b2Mat22 = xf.R;
         var tX:Number = p.x - xf.position.x;
         var tY:Number = p.y - xf.position.y;
         var pLocalX:Number = tX * tMat.col1.x + tY * tMat.col1.y;
         var pLocalY:Number = tX * tMat.col2.x + tY * tMat.col2.y;
         for(var i:int = 0; i < this.m_vertexCount; i++)
         {
            tVec = this.m_vertices[i];
            tX = pLocalX - tVec.x;
            tY = pLocalY - tVec.y;
            tVec = this.m_normals[i];
            dot = tVec.x * tX + tVec.y * tY;
            if(dot > 0)
            {
               return false;
            }
         }
         return true;
      }
   }
}
