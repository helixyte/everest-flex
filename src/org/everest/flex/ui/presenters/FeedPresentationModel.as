package org.everest.flex.ui.presenters
{
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;

    import mx.collections.ArrayCollection;

    import org.everest.flex.events.CollectionEvent;

    /**
     * Simple presentation model that will hold atom entries in a
     * list of members
     *
     * @author rothe
     */
    public class FeedPresentationModel extends EventDispatcher
    {
        protected var dispatcher:IEventDispatcher;

        protected var _members:ArrayCollection;

        public var member:Object; //placeholder

        public function FeedPresentationModel(dispatcher:IEventDispatcher,
                                              memberAttribute:String="selfLink")
        {
            this.dispatcher = dispatcher;
        }

        [Bindable(CollectionEvent="membersChanged")]
        public function get members():ArrayCollection
        {
            return _members;
        }

        public function set members(list:ArrayCollection):void
        {
            _members = list;
            dispatchEvent(new CollectionEvent(CollectionEvent.MEMBERS_CHANGED));
        }
    }
}