package org.everest.flex.events
{
    import flash.events.Event;

    /**
     * User interface triggered events to load pages or sub pages by navigating
     * to another REST url.
     *
     * @author rothe
     */
    public class NavigationEvent extends Event
    {
        public static const LOAD_PAGE:String = "loadPageNavigationEvent";
        public static const LOAD_HOME:String = "loadHomeNavigationEvent";
        public static const LOAD_MODULE:String = "loadModule";
        public static const LOAD_SUBORDINATE_PAGE:String = "loadSubordinatePageNavigationEvent";
        public static const NEW_WINDOW:String = "newWindowNavigationEvent"; // load page in new window
        public var pageUrl:String;
        public var contentType:String;

        public function NavigationEvent(type:String, bubbles:Boolean=true,
                                        cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
        }
    }
}