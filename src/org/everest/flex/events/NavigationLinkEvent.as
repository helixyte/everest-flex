package org.everest.flex.events
{
    import org.everest.flex.interfaces.INavigationLink;

    import flash.events.Event;

    /**
     * The event triggered to load a url from an INavigation instance
     *
     * @author rothe
     */
    public class NavigationLinkEvent extends Event
    {
        public static const GOTO_LINK:String = "gotoLinkNavigationLinkEvent";

        public var link:INavigationLink;

        public function NavigationLinkEvent(type:String, bubbles:Boolean=true,
                                            cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
        }
    }
}