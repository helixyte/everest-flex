package org.everest.flex.ui.presenters
{
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
    import flash.utils.ByteArray;
    import flash.utils.Timer;

    import mx.controls.Alert;
    import mx.events.CloseEvent;
    import mx.managers.BrowserManager;

    import org.everest.flex.events.MemberEvent;
    import org.everest.flex.events.NavigationEvent;
    import org.everest.flex.model.Member;
    import org.everest.flex.model.MembersCollection;
    import org.everest.flex.model.ResourceState;
    import org.everest.flex.ui.components.ConfirmationView;

    /**
     * Contains the presentation logic and data for the REST member view.
     * This class contains methods to access and manipultate the member data
     * model. It can be extended by an everest implementation to add additional
     * featrues for each member and its view.
     *
     * @author rothe
     */
    public class MemberPresentationModel extends EventDispatcher
    {
        public var dispatcher:IEventDispatcher;

        protected var _member:Member;
        protected var _selectedViewIndex:int = 0;
        private var _timer:Timer = new Timer(100);
        private var _viewState:String = ResourceState.PENDING_REQUEST;

        public function MemberPresentationModel(dispatcher:IEventDispatcher)
        {
            this.dispatcher = dispatcher;
        }

        [Bindable(Event="selectedViewIndexChanged")]
        public function get selectedViewIndex():int
        {
            return _selectedViewIndex;
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

        public function set member(member:Member):void
        {
            _member = member;
            _selectedViewIndex = 0;
            dispatchEvent(new Event("selectedViewIndexChanged"));
            updateViewState(ResourceState.VIEW);
            dispatchEvent(new Event(MemberEvent.MEMBER_CHANGED));
        }

        public function set subMember(member:Member):void
        {
           //needs to be overwritten if child wants to process sub members
        }

        public function set subMembers(member:MembersCollection):void
        {
            //needs to be overwritten if child wants to process sub members
        }

        [Bindable(Event="memberChanged")]
        public function get title():String
        {
            return _member.title;
        }

        public function navigateToLink(url:String):void
        {
            trace("- Goto Link: " + url);
            var event:NavigationEvent =
                new NavigationEvent(NavigationEvent.LOAD_PAGE);
            event.pageUrl = url;
            updateViewState(ResourceState.PENDING_REQUEST);
            dispatcher.dispatchEvent(event);
        }

        public function cancelEditing():void
        {
            _selectedViewIndex = 0;
            dispatchEvent(new Event("selectedViewIndexChanged"));
        }

        public function editMember():void
        {
            _selectedViewIndex = 1;
            dispatchEvent(new Event("selectedViewIndexChanged"));
        }

        public function submit(member:Member=null):void
        {
           trace("- Editing Member using XML\n");
           updateViewState(ResourceState.PENDING_REQUEST);
            var event:MemberEvent = new MemberEvent(MemberEvent.EDIT_MEMBER);

            if (member != null)
            {
                event.member = member;
            } else {
                event.member = _member;
            }

            dispatcher.dispatchEvent(event);
        }

        public function deleteMember():void
        {
            ConfirmationView.show("Are you sure you want to delete this member?", "Delete member confirmation", deleteMemberCloseHandler);
        }

        private function deleteMemberCloseHandler(event:CloseEvent):void
        {
            if (event.detail == Alert.OK) {
                deleteMemberHandler()
            }
        }

        private function deleteMemberHandler():void
        {
            trace("- Delete Member: " + _member.selfLink);
            var event:MemberEvent = new MemberEvent(MemberEvent.DELETE_MEMBER);
            event.member = _member;
            dispatcher.dispatchEvent(event);
        }

        public function updateMemberFromXls(fileData:ByteArray):void
        {
            trace("- Update Member using an Excel sheet.\n");

            var event:MemberEvent = new MemberEvent(MemberEvent.UPDATE_MEMBER_FROM_XLS);
            event.binaryData = fileData;
            event.member = _member;

            dispatcher.dispatchEvent(event);
        }

        /**
         * Will reload the current url to reset all input changes.
         */
        public function resetPage(e:Event=null):void
        {
            var url:String = BrowserManager.getInstance().fragment;
            url = url.substr(0,url.lastIndexOf("/")+1);

            trace("- Reset Page: " + url);
            var event:NavigationEvent =
                new NavigationEvent(NavigationEvent.LOAD_PAGE);
            event.pageUrl = url;
            dispatcher.dispatchEvent(event);
        }
    }
}