package org.everest.flex.events
{
    import flash.events.Event;
    import flash.utils.ByteArray;
    
    import org.everest.flex.model.Member;
    import org.everest.flex.utils.RestActions;

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
        public static const CREATE_MEMBER_FROM_DATA:String = "createMemberFromDataEvent";
        public static const EDIT_MEMBER:String = "editMemberEvent";
        public static const EDIT_MEMBER_IN_BACKGROUND:String = "editMemberBackgroundEvent";
        public static const EDIT_MEMBER_FROM_DATA:String = "editMemberFromDataEvent";
        
        public static const EDIT_MODE_UPDATE:String = "update";
        public static const EDIT_MODE_REPLACE:String = "replace";
        public static const EDIT_MODES:Vector.<String> = 
            Vector.<String>([EDIT_MODE_UPDATE, EDIT_MODE_REPLACE]);

        public var binaryData:ByteArray;
		public var member:Member;
		public var contentType:String;
		public var responseContentType:String;

        private var _editMode:String;
        private var _pageUrl:String;

        public function MemberEvent(type:String, bubbles:Boolean=true,
                                    cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
            if (type == EDIT_MEMBER)
            {
                // Set default edit mode.
                _editMode = EDIT_MODE_REPLACE;
            }
        }
		
        public function set pageUrl(url:String):void
        {
            // Allow the URL to be set once.
            if (_pageUrl == null)
            {
                _pageUrl = url;
            }
        }

        public function get pageUrl():String
        {
            return _pageUrl;
        }

        public function set editMode(mode:String):void
        {
            if (!mode in EDIT_MODES)
            {
                throw new Error("Invalid edit mode ", mode);
            }
            _editMode = mode;
        }
        
        public function get editMode():String
        {
            return _editMode;
        }
        
        public function get editAction():String
        {
            if (_editMode == EDIT_MODE_REPLACE)
            {
                return RestActions.PUT;
            }
            else if (_editMode == EDIT_MODE_UPDATE)
            {
                return RestActions.PATCH;
            }
            else
            {
                throw new Error('No edit action set.');
            }
        }
	
	}
}