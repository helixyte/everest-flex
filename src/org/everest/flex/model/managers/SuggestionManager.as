package org.everest.flex.model.managers
{

    import flash.events.Event;
    import flash.events.EventDispatcher;

    import mx.collections.ArrayCollection;
    import mx.rpc.xml.XMLDecoder;

    import org.everest.flex.events.CollectionEvent;
    import org.everest.flex.namespaces.atom;

    /**
     * The suggestion manager keeps track of rest suggest model objects and
     * provides a transactional interface for working with the model.
     *
     * @author rothe
     */
    public class SuggestionManager extends EventDispatcher
    {
        private var _members:ArrayCollection = new ArrayCollection();
        private var _member:Object;

        private var _selectedMembers:Array = new Array();

        public function loadData(doc:XML):void
        {
            _members.removeAll();
            _members.refresh();
            _member = null;

            var title:String;
            var type:String;

            use namespace atom;

            switch (doc.localName()) {

                case "feed":
                    title = doc.atom::title.text();
                    type = doc.atom::content_type.@name;
                    trace("- Loading feed: " + title + " type: " + type);

                    use namespace atom;

                    for each (var entry:XML in doc.entry)
                {
                    _members.addItem(loadMember(entry));
                }
                    break;

                case "entry":
                    title = doc.atom::title.text();
                    type = doc.atom::content.@type;
                    trace("- Loading entry: " + title + " type: " + type);

                    _member = loadMember(doc);
                    break;
            }
            dispatchEvent(new CollectionEvent(CollectionEvent.MEMBERS_CHANGED));

        }

        protected function loadMember(entry:XML):Object{
            use namespace atom;

            var result:Object = new Object();

            for each (var content:XML in XMLList(entry.content[0]).children()) {

                var decoder:XMLDecoder = new XMLDecoder();

                var object:Object = decoder.decode(content);

                if (object != null) {

                    result = object;
                }

                break;
            }

            result.title = entry.title;
            result.selfLink = entry.link.(@rel=="self")[0].@href;

            return result;

        }

        [Bindable(CollectionEvent="membersChanged")]
        public function get member():*
        {
            return _member;
        }

        [Bindable(CollectionEvent="membersChanged")]
        public function get members():ArrayCollection
        {
            return _members;
        }

        [Bindable (event="selectedMembersChanged")]
        public function get selectedMembers():Array
        {
            return _selectedMembers;
        }

        public function selectMembers(selected:Array):void
        {
            _selectedMembers = selected;
            dispatchEvent(new CollectionEvent(CollectionEvent.SELECTED_MEMBERS_CHANGED));
        }

        public function clearSelection():void
        {
            selectMembers([]);
        }

    }
}