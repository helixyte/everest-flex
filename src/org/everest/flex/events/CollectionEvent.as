package org.everest.flex.events
{
    import flash.events.Event;

    /**
     * Events for REST collections.
     *
     * @author rothe
     */
    public class CollectionEvent extends Event
    {
        public static const GET_MEMBERS:String = "getMembers";
        public static const SELECT_MEMBERS:String = "selectMembers";
        public static const MEMBERS_CHANGED:String = "membersChanged";
        public static const SELECTED_MEMBERS_CHANGED:String = "selectedMembersChanged";

        public var pageUrl:String;

        public var members:Array;

        public function CollectionEvent(type:String, bubbles:Boolean=true,
                                        cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
        }
    }
}