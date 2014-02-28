package org.everest.flex.ui.presenters
{
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
    
    import org.everest.flex.events.CollectionEvent;
    import org.everest.flex.events.DocumentEvent;
    import org.everest.flex.events.MemberEvent;
    import org.everest.flex.events.RestFaultEvent;
    import org.everest.flex.model.DocumentDescriptor;
    import org.everest.flex.model.ResourceState;
    import org.everest.flex.ui.components.ErrorView;
    import org.everest.flex.ui.components.WarningView;

    /**
     * Contains the presentation logic and data for the EverestShellView.
     * The everest shell is the entry point and context in which an everest flex
     * application is running.
     *
     * @author rothe
     */
    public class ShellPresentationModel extends EventDispatcher
    {
        private var _viewState:String = ResourceState.PENDING_REQUEST;

//        private var _appRelease:String;

        private var _dispatcher:IEventDispatcher;

        private var _selectedIndex:int = 0;

        private var _document:DocumentDescriptor;

        private var _subDocument:DocumentDescriptor;

        public function ShellPresentationModel(dispatcher:IEventDispatcher)
        {
            _dispatcher = dispatcher;
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
                dispatchEvent(new Event("viewStateChanged"));
            }
        }

        public function showRestFault(event:RestFaultEvent):void
        {
            var message:String = event.message;

            var code:String = "";
            if (event.fault)
            {
                code = event.fault.faultCode;
            }

            if (code.indexOf("307") > -1)
            {
                message = "Your request triggered warnings:\n" + message;
                WarningView.show(message, function():void {
                        //resend the original request to the redirect location
                        var cause:Event = event.cause;

                        if (cause is MemberEvent)
                        {
                            var e:MemberEvent = new MemberEvent(cause.type);
                            e.binaryData = MemberEvent(cause).binaryData;
                            e.contentType = MemberEvent(cause).contentType;
							e.editMode = MemberEvent(cause).editMode;
                            e.responseContentType = MemberEvent(cause).responseContentType;
                            e.pageUrl = MemberEvent(cause).pageUrl;
                            e.member = MemberEvent(cause).member;
                            e.member.selfLink = event.fault.location;
                            _dispatcher.dispatchEvent(e);
                        }else if (cause is CollectionEvent)
                        {
                            var ce:CollectionEvent = new CollectionEvent(cause.type);
                            ce.pageUrl = event.fault.location;
                            _dispatcher.dispatchEvent(ce);
                        }else
                        {
                            trace("Can not handle this event type.");
                        }
                 });

            } else if (message.length > 0) {
                ErrorView.show(message);
            }
        }

        public function loadDocument():void
        {
            var event:DocumentEvent =
                new DocumentEvent(DocumentEvent.DOCUMENT_LOADED);
            event.document = _document;
            _dispatcher.dispatchEvent(event);
        }

        public function loadSubDocument():void
        {
            var event:DocumentEvent =
                new DocumentEvent(DocumentEvent.SUB_DOCUMENT_LOADED);
            event.document = _subDocument;
            _dispatcher.dispatchEvent(event);
        }

        [Bindable(Event="selectedIndexChanged")]
        public function get selectedIndex():int
        {
            return _selectedIndex;
        }

        public function set selectedIndex(index:int):void
        {
            _selectedIndex = index;
            dispatchEvent(new Event("selectedIndexChanged"));
        }

        [Bindable(Event="documentChanged")]
        public function get document():DocumentDescriptor
        {
            return _document;
        }

        [Bindable(Event="subDocumentChanged")]
        public function get subDocument():DocumentDescriptor
        {
            return _subDocument;
        }

        public function set document(doc:DocumentDescriptor):void
        {
            _document = doc;
            dispatchEvent(new DocumentEvent(DocumentEvent.DOCUMENT_CHANGED));
            updateViewState(ResourceState.PENDING_REQUEST);
        }

        public function set subDocument(doc:DocumentDescriptor):void
        {
            _subDocument = doc;
            dispatchEvent(new Event("subDocumentChanged"));
        }
    }
}