package org.everest.flex.model.managers
{

    import flash.events.EventDispatcher;

    import mx.collections.ArrayCollection;

    import org.everest.flex.events.CollectionEvent;
    import org.everest.flex.events.FeedInfoEvent;
    import org.everest.flex.model.DocumentDescriptor;
    import org.everest.flex.model.FeedInfo;
    import org.everest.flex.model.Member;
    import org.everest.flex.namespaces.atom;
    import org.everest.flex.namespaces.opensearch;

    /**
     * The collection manager keeps track of rest collection model objects and
     * provides a transactional interface for working with the model.
     *
     * @author rothe
     */
    public class CollectionManager extends EventDispatcher
    {
        private var _members:ArrayCollection = new ArrayCollection();

        private var _selectedMembers:Array = new Array();

        private var _feedInfo:FeedInfo;

        public function loadFeed(documentDescriptor:DocumentDescriptor):void
        {
            var feed:XML = documentDescriptor.data;

            if (feed != null)
            {
                _members.removeAll();
                _members.refresh(); // This is required, otherwise an exception is
                // thrown when sorting a collection - looks like
                // an ugly hack. Maybe there is a better solution

                // FIXME: use OpenSearchDescription Document
                _feedInfo = createFeedInfo(feed);

                _members = documentDescriptor.members;

                dispatchEvent(new CollectionEvent(CollectionEvent.MEMBERS_CHANGED));
                dispatchEvent(new FeedInfoEvent(FeedInfoEvent.FEED_INFO_CHANGED));
            }else{
                _feedInfo = new FeedInfo();
                _feedInfo.generatorUri = documentDescriptor.urlFragment;
                dispatchEvent(new FeedInfoEvent(FeedInfoEvent.FEED_INFO_CHANGED));
            }
        }

        [Bindable(event="feedInfoChanged")]
        public function get feedInfo():FeedInfo
        {
            return _feedInfo;
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

        public function removeMember(member:Member):void
        {
            _members.removeItemAt(_members.getItemIndex(member));
            clearSelection();
        }

        protected function createFeedInfo(feed:XML):FeedInfo
        {
            var fi:FeedInfo = new FeedInfo();
                fi.generatorUri = feed.atom::generator.@uri;
                fi.searchTerms = feed.opensearch::Query[0].@searchTerms;
                fi.sortTerms = feed.opensearch::Query[0].@sortTerms;
                fi.firstPageLink = findPageLink(feed, 'first');
                fi.previousPageLink = findPageLink(feed, 'previous');
                fi.nextPageLink = findPageLink(feed, 'next');
                fi.lastPageLink = findPageLink(feed, 'last');
                fi.totalResults = int(feed.opensearch::totalResults);
                fi.startIndex = int(feed.opensearch::startIndex);
                fi.startNumber = fi.totalResults > 0 ? (fi.startIndex + 1) : 0;
                fi.endNumber = fi.startIndex + feed.atom::entry.length();
                fi.itemsPerPage = int(feed.opensearch::itemsPerPage);

            return fi;
        }

        private function findPageLink(feed:XML, relation:String):String
        {
            use namespace atom;
            var link:String;
            var links:XMLList = feed.link.(@rel==relation);
            if (links.length() == 1) {
                link = links[0].@href;
            }
            return link;
        }
    }
}