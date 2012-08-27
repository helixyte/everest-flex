package org.everest.flex.ui.presenters
{
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;

    import mx.collections.ArrayCollection;

    import org.everest.flex.events.CollectionEvent;
    import org.everest.flex.model.SelectionChoice;

    /**
     * This class holds the data model and presentation logic for the
     * SuggestionDropDownView which is a complete independent view.
     * The view loads a collection from the configured url and uses it to provide an
     * auto complete drop-down box.
     * It can be used as part of a form to filter a collection or to edit/create a new
     * member.
     *
     * @author rothe
     */
    public class SuggestionDropDownListPresentationModel extends EventDispatcher
    {
        protected var dispatcher:IEventDispatcher;

        protected var _members:ArrayCollection;
        protected var _member:Object;

        private var _memberAttribute:String;

        protected var _suggestion:ArrayCollection = new ArrayCollection();

        /**
         *
         * @param dispatcher
         * @param memberAttribute the attribute that will be used as the drop down value.
         * If null the member itself will be returned upon selectioin.
         *
         */
        public function SuggestionDropDownListPresentationModel(dispatcher:IEventDispatcher,
                                                                memberAttribute:String="selfLink")
        {
            this.dispatcher = dispatcher;
            _memberAttribute = memberAttribute;
            resetSuggestion();
        }

        [Bindable(CollectionEvent="membersChanged")]
        public function get members():ArrayCollection
        {
            return _members;
        }

        public function set members(list:ArrayCollection):void
        {
            _members = list;

            if (_members != null) {
                resetSuggestion();
                for each (var m:Object in _members) {
                    if(_memberAttribute){
                        _suggestion.addItem(new SelectionChoice(m.title, m[_memberAttribute]));
                    }else{
                        _suggestion.addItem(new SelectionChoice(m.title, m));
                    }
                }
            }
            dispatchEvent(new CollectionEvent(CollectionEvent.MEMBERS_CHANGED));
        }

        public function get member():Object
        {
            return _member;
        }

        public function set member(member:Object):void
        {
            _member = member;
            if (_member != null) {
                resetSuggestion();

                var items:* = member[_memberAttribute];
                if (items != null)
                {
                    for each (var item:* in items) {
                        _suggestion.addItem(new SelectionChoice(item.toString(), item));
                    }
                    if (_suggestion.length < 1)
                    {
                        _suggestion.addItem(new SelectionChoice(items.toString(), items));
                    }
                }
            }
            dispatchEvent(new CollectionEvent(CollectionEvent.MEMBERS_CHANGED));
        }


        [Bindable(CollectionEvent="membersChanged")]
        public function get suggestion():ArrayCollection
        {
            return _suggestion;
        }

        private function resetSuggestion():void
        {
            _suggestion.removeAll();
            //            _suggestion.addItem(new Choice('All', null));
        }
    }
}