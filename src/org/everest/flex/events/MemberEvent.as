package org.everest.flex.events
{
    import org.everest.flex.model.Member;

    import flash.events.Event;
    import flash.utils.ByteArray;

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
        public static const CREATE_MEMBER_FROM_XLS:String = "createMemberFromXlsEvent";
        public static const UPDATE_MEMBER_FROM_XLS:String = "updateMemberFromXlsEvent";

        public var binaryData : ByteArray;
        public var member : Member;
        private var _pageUrl : String;

        public function MemberEvent(type:String, bubbles:Boolean=true,
                                    ancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
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