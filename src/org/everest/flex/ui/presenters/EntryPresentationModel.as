package org.everest.flex.ui.presenters
{
    import org.everest.flex.events.MemberEvent;

    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;

    import mx.collections.ArrayCollection;

    /**
     * Simple presentation model that will hold an atom entry
     *
     * @author rothe
     */
    public class EntryPresentationModel extends EventDispatcher
    {
        protected var dispatcher:IEventDispatcher;

        protected var _member:*;

        public function EntryPresentationModel(dispatcher:IEventDispatcher,
                                                                memberAttribute:String="selfLink")
        {
            this.dispatcher = dispatcher;
        }

        [Bindable(Event="memberChanged")]
        public function get member():*
        {
            return _member;
        }

        public function set member(member:*):void
        {
            _member = member;
            dispatchEvent(new Event(MemberEvent.MEMBER_CHANGED));
        }

        public function set members(members:ArrayCollection):void
        {
            if ((members != null)&&(members.length > 0))
            {
                this._member = members.getItemAt(0);
            }
        }

    }
}