package org.everest.flex.ui.presenters
{
    import com.adobe.utils.StringUtil;

    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
    import flash.events.TimerEvent;
    import flash.net.URLRequest;
    import flash.net.navigateToURL;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    import flash.utils.Timer;
    import flash.utils.getTimer;

    import mx.collections.ArrayCollection;
    import mx.collections.Sort;
    import mx.controls.Alert;
    import mx.events.CloseEvent;
    import mx.managers.BrowserManager;

    import org.everest.flex.events.CollectionEvent;
    import org.everest.flex.events.MemberEvent;
    import org.everest.flex.events.NavigationEvent;
    import org.everest.flex.model.FeedInfo;
    import org.everest.flex.model.Member;
    import org.everest.flex.model.ResourceState;
    import org.everest.flex.query.Criteria;
    import org.everest.flex.query.QueryParser;
    import org.everest.flex.ui.components.ConfirmationView;
    import org.everest.flex.ui.components.ErrorView;

    import spark.collections.SortField;

    /**
     * Contains the presentation logic and data for the REST collection view.
     * This class contains methods to access and manipultate the collection data
     * model. It can be extended by an everest implementation to add additional
     * featrues.
     * @see org.everest.flex.ui.views.CollectionView
     * @see org.everest.flex.maps.CollectionEventMap
     * @author rothe
     */
    public class CollectionPresentationModel extends EventDispatcher
    {
        [Bindable]
        public var startNumber:int;

        [Bindable]
        public var endNumber:int;

        [Bindable]
        public var totalResults:int;

        [Bindable]
        public var totalRequestTime:String = "0.0";

        [Bindable]
        public var criteria:Criteria = new Criteria();

        [Bindable]
        public var pageSizes:ArrayCollection = new ArrayCollection([
            {label:"10", data:10},
            {label:"50", data:50},
            {label:"100", data:100},
            {label:"500", data:500},
            {label:"1000", data:1000}
        ]);

        /**
         * When sorting by nested members the server requires the sort criteria
         * to include the child attributes to be sorted by.
         * E.g. sort by company requries company.name as criteria
         */
        public var sortFieldNames:Dictionary = new Dictionary();


        protected var dispatcher:IEventDispatcher;


        private var _timer:Timer = new Timer(100);

        private var _viewState:String = ResourceState.PENDING_REQUEST;

        private var _members:ArrayCollection = new ArrayCollection();

        private var _selectedMembers:Vector.<Object> = new Vector.<Object>();

        private var _requestStartTime:int = 0;

        private var _searchMode:Boolean = false;

        private var _selectedPageSize:Object;

        private var _generatorUri:String = "foobar";

        private var _firstPageLink:String;

        private var _previousPageLink:String;

        private var _nextPageLink:String;

        private var _lastPageLink:String;

        private var _sortFields:Array = new Array();

        // Pattern adopted from http://djangosnippets.org/snippets/585/
        // We need a separate utility class for our custom string conversions
        private var camelCaseSplitPattern:RegExp = /(((?<=[a-z])[A-Z])|([A-Z](?![A-Z]|$)))/g;

        public function CollectionPresentationModel(dispatcher:IEventDispatcher)
        {
            this.dispatcher = dispatcher;
            resetRequestStartTime();
            _timer.addEventListener(TimerEvent.TIMER, calcTotalRequestTime);
        }

        public function filterCollection():void
        {
            // FIXME: just a quick hack - create the final URL using another object.
            var params:Array = prepareRequestParams();
            var url:String = _generatorUri + "?" + params.join("&");
            trace("- Filter URL: " + url);
            gotoPage(url);
        }

        public function changePageSize(pageSize:Object):void
        {
            if (selectedPageSize != pageSize) {
                trace("- Goto First Page with " + pageSize.data + " items per page");
                selectedPageSize = pageSize;
                filterCollection();
            }
        }

//        public function reset():void
//        {
//             criteria = new Criteria();
//            resetInput();
//        }

        public function navigateToMember(selectedMember:Object):void
        {
            var url:String = Member(selectedMember).selfLink;
            navigateToLink(url);
        }

        public function downloadCSV():void{
            var params:Array = prepareRequestParams();

            var url:String = _generatorUri.substr(_generatorUri.length - 1) == "/" ? _generatorUri.substr(0, _generatorUri.length - 1) : _generatorUri;
                url +=  ".csv/?" + params.join("&");

            navigateToURL(new URLRequest(url));

        }

        public function deleteSelected():void
        {
            ConfirmationView.show(
                "Are you sure you want to delete this member?",
                "Delete member confirmation",
                deleteSelectedCloseHandler);
        }

        public function createMember(member:Member):void
        {
            trace("- Create Member using a value object:\n" + member.toString());

            var event:MemberEvent;
                event = new MemberEvent(MemberEvent.CREATE_MEMBER);
                event.member = member;

            dispatcher.dispatchEvent(event);
        }

        public function createMemberFromXls(fileData:ByteArray):void
        {
            trace("- Create Member using an Excel sheet.\n");

            var event:MemberEvent = new MemberEvent(MemberEvent.CREATE_MEMBER_FROM_XLS);
                event.binaryData = fileData;

            dispatcher.dispatchEvent(event);
        }

        public function navigateToLink(url:String):void
        {
            trace("- Goto Link: " + url);
            var event:NavigationEvent =
                new NavigationEvent(NavigationEvent.LOAD_PAGE);
            event.pageUrl = url;
            dispatcher.dispatchEvent(event);
        }

        /**
         * Will reload the current url to reset all filters and input changes.
         */
        public function resetPage():void
        {
            criteria = new Criteria();
            var url:String = BrowserManager.getInstance().fragment;
            var i:int = url.indexOf("?");
            if(i>0){
                //strip the query part
                url = url.substr(0,i);
            }

            trace("- Reset Page: " + url);
            var event:NavigationEvent =
                new NavigationEvent(NavigationEvent.LOAD_PAGE);
            event.pageUrl = url;
            dispatcher.dispatchEvent(event);
        }

        public function presentFirstPage():void
        {
            trace("- Goto First Page: " + _firstPageLink);
            gotoPage(_firstPageLink);
        }

        public function presentPreviousPage():void
        {
            trace("- Goto Previous Page: " + _previousPageLink);
            gotoPage(_previousPageLink);
        }

        public function presentNextPage():void
        {
            trace("- Goto Next Page: " + _nextPageLink);
            gotoPage(_nextPageLink);
        }

        public function presentLastPage():void
        {
            trace("- Goto Last Page: " + _lastPageLink);
            gotoPage(_lastPageLink);
        }

        [Bindable(CollectionEvent="membersChanged")]
        public function get members():ArrayCollection
        {
            return _members;
        }

        public function set members(list:ArrayCollection):void
        {
            _members = list;
            updateViewState(ResourceState.PENDING_REQUEST);
            dispatchEvent(new CollectionEvent(CollectionEvent.MEMBERS_CHANGED));
        }

        public function sortMembersBy(sortFields:Array, multiColumnSort:Boolean=false):void
        {
           var sortField:SortField = sortFields[0];

            if (multiColumnSort) {
                if (findSortField(sortField.name) == null) {
                    _sortFields.push(sortField);
                }
                else {
                    toggleSortOrder(sortField.name);
                }
            } else {
                if (findSortField(sortField.name) != null) {
                    toggleSortOrder(sortField.name);
                } else {
                    _sortFields = [sortField];
                }
            }
            var sort:Sort = new Sort();
            sort.fields = _sortFields;
            members.sort = sort;

            if (selectedPageSize != null && totalResults > selectedPageSize.data) {
                trace("- Sends sort request on the server...");
                // We do not want to call members.refresh() at this stage because
                // this will fire a sorting on the client.
                filterCollection();
            }
            else {
                trace("- Sorts members on the client...");
                members.refresh();
            }
        }

//        public function sortMembersBy(dataField:String, multiColumnSort:Boolean=false):void
//        {
//            var sort:Sort = new Sort();
//            if (multiColumnSort) {
//                if (findSortField(dataField) == null) {
//                    // FIXME: SortField should be instantiated with numeric=True
//                    //        if the dataField is a number. This can be done by
//                    //        inspecting the criteria on OpenSearchDescription
//                    _sortFields.push(new SortField(dataField, true));
//                }
//                else {
//                    toggleSortOrder(dataField);
//                }
//            }
//            else {
//                _sortFields = [new SortField(dataField, true)];
//            }
//            sort.fields = _sortFields;
//            members.sort = sort;
//            if (selectedPageSize != null &&
//                totalResults > selectedPageSize.data) {
//                trace("- Sends sort request on the server...");
//                // We do not want to call members.refresh() at this stage because
//                // this will fire a sorting on the client.
//                filterCollection();
//            }
//            else {
//                trace("- Sorts members on the client...");
//                members.refresh();
//            }
//        }

//        [Bindable(Event="selectedMembersChanged")]
//        public function get selectedMembers():Array
//        {
//            return _selectedMembers;
//        }
//
//        public function set selectedMembers(selected:Array):void
//        {
//            _selectedMembers = selected;
//            dispatchEvent(new CollectionEvent(CollectionEvent.SELECTED_MEMBERS_CHANGED));
//        }

        public function selectMembers(selected:Array):void
        {
            var event:CollectionEvent =
                new CollectionEvent(CollectionEvent.SELECT_MEMBERS);
            event.members = selected;
            dispatcher.dispatchEvent(event);
        }

        [Bindable(Event="selectedMembersChanged")]
        public function get selectedMembers():Vector.<Object>
        {
               return _selectedMembers;
        }

        public function set selectedMembers(members:Vector.<Object>):void
        {
            this._selectedMembers = members
        }

//        [Bindable(Event="selectedMembersChanged")]
//        public function get selectedMembers():Vector
//        {
//            var indices:Vector.<int> = new Vector.<int>();
//            for each (var item:Object in selectedMembers) {
//                indices.push(members.getItemIndex(item));
//            }
//            return indices;
//        }
//
//        public function set selectedMemberIndices(indices:Vector.<int>):Vector.<int>
//        {
//            var indices:Vector.<int> = new Vector.<int>();
//            for each (var item:Object in selectedMembers) {
//                indices.push(members.getItemIndex(item));
//            }
//            return indices;
//        }


        public function selectAllMembers():void
        {
            var event:CollectionEvent =
                new CollectionEvent(CollectionEvent.SELECT_MEMBERS);
            event.members = members.source;
            dispatcher.dispatchEvent(event);
        }

        public function set feedInfo(info:FeedInfo):void
        {
            if (info != null) {
                _generatorUri = info.generatorUri;
                firstPageLink = info.firstPageLink;
                previousPageLink = info.previousPageLink;
                nextPageLink = info.nextPageLink;
                lastPageLink = info.lastPageLink;
                startNumber = info.startNumber;
                endNumber = info.endNumber;
                totalResults = info.totalResults;
                setPageSize(info.itemsPerPage);

                if(info.searchTerms != null){
                    this.criteria = QueryParser.parse(info.searchTerms);
                } else {
                    this.criteria = new Criteria();
                }
            }
        }

        [Bindable(event="viewStateChanged")]
        public function get viewState():String
        {
            return _viewState;
        }

        public function updateViewState(state:String):void
        {
            if (_viewState != state)
            {
                _viewState = state;
                switch (_viewState) {
                    case ResourceState.PENDING_REQUEST:
                        _timer.stop();
                        break;
                    case ResourceState.PENDING_RESPONSE:
                        _timer.start();
                        break;
                }
                dispatchEvent(new Event("viewStateChanged"));
            }
        }

        [Bindable(Event="selectedMembersChanged")]
        public function get hasSelectedMembers():Boolean
        {
            return selectedMembers.length > 0;
        }

        [Bindable(CollectionEvent="membersChanged")]
        public function get hasMembers():Boolean
        {
            return _members.length > 0;
        }

        [Bindable("firstPageLinkChanged")]
        public function get hasFirstPage():Boolean
        {
            return firstPageLink != null;
        }

        [Bindable("firstPageLinkChanged")]
        public function get firstPageLink():String
        {
            return _firstPageLink;
        }

        public function set firstPageLink(link:String):void
        {
            if (_firstPageLink != link)
            {
                _firstPageLink = link;
                dispatchEvent(new Event("firstPageLinkChanged"));
            }
        }

        [Bindable("previousPageLinkChanged")]
        public function get hasPreviousPage():Boolean
        {
            return previousPageLink != null;
        }

        [Bindable("previousPageLinkChanged")]
        public function get previousPageLink():String
        {
            return _previousPageLink;
        }

        public function set previousPageLink(link:String):void
        {
            if (_previousPageLink != link)
            {
                _previousPageLink = link;
                dispatchEvent(new Event("previousPageLinkChanged"));
            }
        }

        [Bindable("nextPageLinkChanged")]
        public function get hasNextPage():Boolean
        {
            return nextPageLink != null;
        }

        [Bindable("nextPageLinkChanged")]
        public function get nextPageLink():String
        {
            return _nextPageLink;
        }

        public function set nextPageLink(link:String):void
        {
            if (_nextPageLink != link)
            {
                _nextPageLink = link;
                dispatchEvent(new Event("nextPageLinkChanged"));
            }
        }

        [Bindable("lastPageLinkChanged")]
        public function get hasLastPage():Boolean
        {
            return lastPageLink != null;
        }

        [Bindable("lastPageLinkChanged")]
        public function get lastPageLink():String
        {
            return _lastPageLink;
        }

        public function set lastPageLink(link:String):void
        {
            if (_lastPageLink != link)
            {
                _lastPageLink = link;
                dispatchEvent(new Event("lastPageLinkChanged"));
            }
        }

        [Bindable("selectedPageSizeChanged")]
        public function get selectedPageSize():Object
        {
            return _selectedPageSize;
        }

        public function set selectedPageSize(pageSize:Object):void
        {
            if (_selectedPageSize != pageSize)
            {
                _selectedPageSize = pageSize;
                dispatchEvent(new Event("selectedPageSizeChanged"));
            }
        }

        [Bindable(Event="filterButtonLabelChanged")]
        public function get filterButtonLabel():String
        {
            var lbl:String = "Filter";
            if (_searchMode) {
                lbl = "Search";
            }
            return lbl;
        }

        protected function set searchMode(value:Boolean):void
        {
            _searchMode = value;
            dispatchEvent(new Event("filterButtonLabelChanged"));
        }

        protected function makeQuotedStringList(input:String):String
        {
            var result:String;
            var values:Array = [];
            for each (var val:String in input.split(',')) {
                values.push(quoteString(val));
            }
            if (values.length > 0) {
                result = values.join(",");
            }
            return result;
        }

        protected function quoteString(value:String):String
        {
            return '"' + StringUtil.trim(value) + '"';
        }


//        protected function prepareRequestCriteria():Array
//        {
//
//            var results:ArrayCollection = new ArrayCollection();
//            var c:Vector.<Criterion> = criteria.list();
//            for each (var criterion:Criterion in c){
//                results.addItem(criterion);
//            }
//
//            return results.toArray();
//
//        }

        protected function prepareRequestSortOrdering():Array
        {
            var sortOrder:Array = new Array();
            for each (var field:SortField in _sortFields) {

                var name:String = sortFieldNames[field.name];

                if (name == null)
                {
                    name =  field.name;
                }
                name = StringUtil.replace(name,"_","-");
                sortOrder.push(convertSortOrderField(name) + ":" +
                               (field.descending ? "desc" : "asc"));
            }
            return sortOrder;
        }

        private function prepareRequestParams():Array
        {
            var params:Array = new Array();
            // query criteria
            if (criteria.length > 0) {
                params.push(criteria.toString());
            }
            // sort order criteria
            var sortOrder:Array = prepareRequestSortOrdering();
            if (sortOrder.length > 0) {
                params.push("sort=" + sortOrder.join("~"));
            }
            // request page size
            if (selectedPageSize)
            {
                params.push("size=" + selectedPageSize.data);
            }


            return params;
        }

        private function gotoPage(url:String):void
        {
            var event:NavigationEvent =
                new NavigationEvent(NavigationEvent.LOAD_PAGE);
            event.pageUrl = url;
            dispatcher.dispatchEvent(event);
            resetRequestStartTime();
            updateViewState(ResourceState.PENDING_RESPONSE);
        }

        private function setPageSize(itemsPerPage:int):void
        {
            for each (var ps:Object in pageSizes) {
                if (ps.data == itemsPerPage) {
                    selectedPageSize = ps;
                    break;
                }
            }
        }

        private function calcTotalRequestTime(event:TimerEvent):void
        {
            var now:int = getTimer();
            var total:Number = (now - _requestStartTime) / 1000;
            totalRequestTime = total.toFixed(1);
        }

        private function resetRequestStartTime():void
        {
            _requestStartTime = getTimer();
        }

        private function toggleSortOrder(dataField:String):void
        {
            //the field that gets toggled will be appended to the end of the list
            //to get lowest priority
            var sortField:SortField = null;
            var newSortFields:Array = new Array();
            for each (var field:SortField in _sortFields) {
                if (field.name == dataField) {
                    sortField = field;
                } else {
                    newSortFields.push(field);
                }
            }
            if (sortField != null) {
                sortField.descending = !sortField.descending;
                newSortFields.push(sortField);
                _sortFields = newSortFields;
            }
        }

        private function findSortField(dataField:String):SortField
        {
            var found:SortField;
            for each (var field:SortField in _sortFields) {
                if (field.name == dataField) {
                    found = field;
                    break;
                }
            }
            return found;
        }

        private function convertSortOrderField(fieldName:String,
                                               separator:String="-"):String
        {
            return fieldName.replace(camelCaseSplitPattern, separator + "$1")
                            .toLocaleLowerCase();
        }

        private function deleteSelectedCloseHandler(event:CloseEvent):void
        {
            if (event.detail == Alert.OK) {
                deleteSelectedHandler()
            }
        }

        private function deleteSelectedHandler():void
        {
            if (_selectedMembers.length == 1)
            {
                var member:Member = _selectedMembers.pop();
                trace("- Delete Member: " + member.selfLink);
                var event:MemberEvent = new MemberEvent(MemberEvent.DELETE_MEMBER);
                event.member = member;
                dispatcher.dispatchEvent(event);
            } else {
                ErrorView.show("Please select only one row.");
            }
        }

        public function get sortFields():Array
        {
            return _sortFields;
        }

    }
}