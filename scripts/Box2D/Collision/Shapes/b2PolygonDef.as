package Box2D.Collision.Shapes
{
   import Box2D.Common.*;
   import Box2D.Common.Math.*;
   
   public class b2PolygonDef extends b2ShapeDef
   {
      
      private static var s_mat:b2Mat22 = new b2Mat22();
       
      
      public var vertices:Array;
      
      public var vertexCount:int;
      
      public function b2PolygonDef()
      {
         this.vertices = new Array(b2Settings.b2_maxPolygonVertices);
         super();
         type = b2Shape.e_polygonShape;
         this.vertexCount = 0;
         for(var i:int = 0; i < b2Settings.b2_maxPolygonVertices; i++)
         {
            this.vertices[i] = new b2Vec2();
         }
      }
      
      public function SetAsOrientedBox(hx:Number, hy:Number, center:b2Vec2 = null, angle:Number = 0) : void
      {
         var xfPosition:b2Vec2 = null;
         var xfR:b2Mat22 = null;
         var i:int = 0;
         this.vertexCount = 4;
         this.vertices[0].Set(-hx,-hy);
         this.vertices[1].Set(hx,-hy);
         this.vertices[2].Set(hx,hy);
         this.vertices[3].Set(-hx,hy);
         if(center)
         {
            xfPosition = center;
            xfR = s_mat;
            xfR.Set(angle);
            for(i = 0; i < this.vertexCount; i++)
            {
               center = this.vertices[i];
               hx = xfPosition.x + (xfR.col1.x * center.x + xfR.col2.x * center.y);
               center.y = xfPosition.y + (xfR.col1.y * center.x + xfR.col2.y * center.y);
               center.x = hx;
            }
         }
      }
      
      public function SetAsBox(hx:Number, hy:Number) : void
      {
         this.vertexCount = 4;
         this.vertices[0].Set(-hx,-hy);
         this.vertices[1].Set(hx,-hy);
         this.vertices[2].Set(hx,hy);
         this.vertices[3].Set(-hx,hy);
      }
   }
}
