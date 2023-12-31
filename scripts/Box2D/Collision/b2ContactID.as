package Box2D.Collision
{
   public class b2ContactID
   {
       
      
      public var _key:uint;
      
      public var features:Box2D.Collision.Features;
      
      public function b2ContactID()
      {
         this.features = new Box2D.Collision.Features();
         super();
         this.features._m_id = this;
      }
      
      public function Set(id:b2ContactID) : void
      {
         this.key = id._key;
      }
      
      public function Copy() : b2ContactID
      {
         var id:b2ContactID = new b2ContactID();
         id.key = this.key;
         return id;
      }
      
      public function set key(value:uint) : void
      {
         this._key = value;
         this.features._referenceEdge = this._key & 255;
         this.features._incidentEdge = (this._key & 65280) >> 8 & 255;
         this.features._incidentVertex = (this._key & 16711680) >> 16 & 255;
         this.features._flip = (this._key & 4278190080) >> 24 & 255;
      }
      
      public function get key() : uint
      {
         return this._key;
      }
   }
}
