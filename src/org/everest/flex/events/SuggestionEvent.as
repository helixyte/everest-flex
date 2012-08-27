package org.everest.flex.events
{
    import flash.events.Event;

    /**
     * Events that are used by auto 'sugest' components such as a combo box.
     * The suggestions are loaded from a REST collection.
     *
     * @author rothe
     */
    public class SuggestionEvent extends Event
    {
        public static const LOAD_DATA:String = "loadFeedSuggestionEvent";
//        public static const LOAD_FEED:String = "loadFeedSuggestionEvent";
        public static const LOAD_ENTRY:String = "loadEntrySuggestionEvent";
        public static const RESET_LIST:String = "resetListSuggestionEvent";

        public var url:String;

        public function SuggestionEvent(type:String, bubbles:Boolean=true,
                                        cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
        }
    }
}