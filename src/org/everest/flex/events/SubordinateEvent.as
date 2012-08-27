package org.everest.flex.events
{
    import flash.events.Event;

    /**
     * Subordinate events are used by a member to load a subordinate collection
     * that is sometimes needed for a view component. Subordinate means that
     * the incomming data will not replace the current view instead the data
     * will be injected into the presenter of the current view.
     *
     * @author rothe
     */
    public class SubordinateEvent extends Event
    {
        public static const LOAD_FEED:String = "loadFeedSubordinateEvent";
        //public static const LOAD_ENTRY:String = "loadEntrySubordinateEvent";
        //public static const RESET_LIST:String = "resetListSubordinateEvent";

        public var url:String;

        public function SubordinateEvent(type:String, bubbles:Boolean=true,
                                        cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
        }
    }
}