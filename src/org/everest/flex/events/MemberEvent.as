package org.everest.flex.events
{
    import flash.events.Event;
    import flash.utils.ByteArray;
    
    import org.everest.flex.model.Member;

    /**
     * Events for REST collection members.
     *
     * @author rothe
     */
    public class MemberEvent extends Event
    {
        public static const MEMBER_CHANGED:String = "memberChanged";
        public static const DELETE_MEMBER:String = "deleteMemberEvent";
        public static const CREATE_MEMBER:String = "createMemberEvent";
        public static const CREATE_MEMBER_IN_BACKGROUND:String = "createMemberBackgroundEvent";
        public static const EDIT_MEMBER:String = "editMemberEvent";
        public static const EDIT_MEMBER_IN_BACKGROUND:String = "editMemberBackgroundEvent";
        public static const CREATE_MEMBER_FROM_DATA:String = "createMemberFromDataEvent";
        public static const UPDATE_MEMBER_FROM_DATA:String = "updateMemberFromDataEvent";

        public var binaryData : ByteArray;
		public var member : Member;

		private var _contentType : String;
		private var _responseContentType : String;
        private var _pageUrl : String;
		private var _headers : Object;

        public function MemberEvent(type:String, bubbles:Boolean=true,
                                    cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
        }
		
		public function set contentType(contentType:String): void
		{
			_contentType = contentType;
		}
		
		public function get contentType(): String
		{
			return _contentType;
		}

		public function set responseContentType(responseContentType:String): void
		{
			_responseContentType = responseContentType;
		}
		
		public function get responseContentType(): String
		{
			return _responseContentType;
		}
		
        public function set pageUrl(url:String):void
        {
            //url shall not be overriden
            if (_pageUrl == null)
            {
                _pageUrl = url;
            }
        }

        public function get pageUrl():String
        {
            return _pageUrl;
        }

	
	}
}