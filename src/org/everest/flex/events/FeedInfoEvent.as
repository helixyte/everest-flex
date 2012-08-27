package org.everest.flex.events
{
    import flash.events.Event;

    /**
     * Event to announce changes of the feed information.
     *
     * @author rothe
     */
    public class FeedInfoEvent extends Event
    {
        public static const FEED_INFO_CHANGED:String = "feedInfoChanged";

        public function FeedInfoEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
        }
    }
}