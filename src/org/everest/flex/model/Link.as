package org.everest.flex.model
{
    import org.everest.flex.interfaces.INavigationLink;

    /**
     * Default implementation for the navigation link interface. It holds an url
     * to a REST member or collection and a descriptive title.
     * @see org.everest.flex.interfaces.INavigationLink
     * @author rothe
     */
    public class Link implements INavigationLink
    {

        public static const MEMBER:String="MEMBER";
        public static const COLLECTION:String="COLLECTION";

		public var rel:String;
		public var length:uint;
        private var _href:String;
        private var _title:String;
        private var _kind:String;
        private var _id:*;

        public function Link(title:String=null, url:String=null, kind:String=MEMBER, id:*=null)
        {
            this.href = url;
            this.title = title;
            this.kind = kind;
            this.id = id;
        }

        public function get title():String{
            return _title;
        }

        public function get href():String
        {
            return _href;
        }

        public function set href(value:String):void
        {
            this._href = value;

        }

        public function set title(value:String):void
        {
            this._title = value;

        }

        public function get kind():String
        {
            return _kind;
        }

        public function set kind(value:String):void
        {
            _kind = value;
        }

        public function get id():*
        {
            return _id;
        }
        
        public function set id(value:*):void
        {
            _id = value;
        }
        
    }
}