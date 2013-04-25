package org.everest.flex.model.managers
{
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
    import flash.events.TimerEvent;
    import flash.net.URLRequest;
    import flash.net.navigateToURL;
    import flash.utils.Dictionary;
    import flash.utils.Timer;
    
    import mx.collections.ArrayCollection;
    import mx.core.FlexGlobals;
    import mx.events.BrowserChangeEvent;
    import mx.managers.CursorManager;
    import mx.managers.IBrowserManager;
    
    import org.as3commons.lang.StringUtils;
    import org.everest.flex.events.DocumentEvent;
    import org.everest.flex.events.NavigationEvent;
    import org.everest.flex.model.ContentType;
    import org.everest.flex.model.DocumentDescriptor;
    import org.everest.flex.model.EverestConfiguration;
    import org.everest.flex.model.Member;
    import org.everest.flex.model.Module;
    import org.everest.flex.model.SchemaModelEntry;
    import org.everest.flex.namespaces.atom;
    import org.everest.flex.ui.components.ErrorView;
    import org.osmf.utils.URL;

    /**
     * In combination with the shell event map this class represents the cental
     * everest application controller.
     * It handles:
     * - application initialization and configuration
     * - serialization and deserialization
     * - url construction
     * - feed and document model
     * - loading of modules
     *
     * @author rothe
     */
    public class EverestShellManager extends EventDispatcher
    {
        private static var ROOT_FRAGMENT:String = "/";

        private var _dispatcher:IEventDispatcher;
        private var _browserManager:IBrowserManager;
        private var _selectedIndex:int;
        private var _pageTitle:String;
        private var _document:DocumentDescriptor;
        private var _subDocument:DocumentDescriptor;
        private var _appUrl:URL;
        private var _modules:Dictionary;
        private var _schemaManager:SchemaManager;
        private var _staticUrlPrefix:String = '';

        public function EverestShellManager(dispatcher:IEventDispatcher)
        {
            _dispatcher = dispatcher;
            _modules = new Dictionary();
            _schemaManager = new SchemaManager();

        }

        public function set pageTitle(title:String):void
        {
            _pageTitle = title;
        }

        public function initBrowserManager(browserManager:IBrowserManager):void
        {
            _browserManager = browserManager;
            _browserManager.addEventListener(
                BrowserChangeEvent.BROWSER_URL_CHANGE,
                handleBrowserURLChange
            );

            _browserManager.init(ROOT_FRAGMENT, _pageTitle);
            if (fragment == ROOT_FRAGMENT) {
                handleBrowserURLChange();
            }
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

        public function loadHome():void
        {
            trace("- Goto Home");
            //TODO FIX THIS
//            var event:NavigationEvent =
//                new NavigationEvent(NavigationEvent.LOAD_PAGE);
//            event.pageUrl = appServiceUrl;
//            _dispatcher.dispatchEvent(event);
        }

        public function loadModule(type:String, urlFragment:String, moduleUrl:String=null):void
        {

            if (moduleUrl == null)
            {
                moduleUrl = getModuleUrl(type);
            }

            trace("- Goto Module: " + moduleUrl);

            if (fragment != urlFragment)
            {
                fragment = urlFragment;
                _browserManager.setFragment(urlFragment)
            }


            _document = new DocumentDescriptor("Module", type, null, moduleUrl);
            _document.urlFragment = urlFragment;
            dispatchEvent(new DocumentEvent(DocumentEvent.DOCUMENT_CHANGED));
        }

        private function delayLoad(pageUrl:String, doc:XML):void
        {
            //we need to delay the load as not all schemas are ready
            var minuteTimer:Timer = new Timer(1000, 5);
            minuteTimer.addEventListener(TimerEvent.TIMER_COMPLETE,
                function():void{
                    loadDocument(pageUrl,doc);
                });

            // starts the timer ticking
            minuteTimer.start();
        }

        public function loadSubDocument(doc:XML):void
        {
            var title:String;
            var type:String;
            var members:ArrayCollection = new ArrayCollection();

            switch (doc.localName()) {

                case "entry":
                    title = doc.atom::title.text();
                    type = doc.atom::content.@type;
                    trace("- Loading entry: " + title + " type: " + type);

                    members.addItem(deserializeMember(doc));
                    break;

                case "feed":
                    title = doc.atom::title.text();
                    type = doc.atom::content.@type;
                    trace("- Loading entry: " + title + " type: " + type);

                    for each (var entry:XML in doc.atom::entry)
                    {
                        members.addItem(deserializeMember(entry));
                    }
//					members.addItem(deserializeMember(doc));
                    break;
            }


            _subDocument = new DocumentDescriptor(
                                title, type, doc, null
                            );
            _subDocument.members = members;

            dispatchEvent(new DocumentEvent(DocumentEvent.SUB_DOCUMENT_CHANGED));
            CursorManager.removeBusyCursor();
        }
		
		public function hasViewForDocument(doc:XML):Boolean
		{
			use namespace atom;
			var result:Boolean;
			var type:String;
			switch (doc.localName()) {
				case "service":
					result = true;
					break;				
				case "feed":
					type = doc.atom::content_type.@name;
					result = type in _modules;
					break;				
				case "entry":
					type = doc.atom::content.@type;
					result = type in _modules;
			}
			return result;
		}

        public function loadDocument(pageUrl:String, doc:XML):void
        {
            use namespace atom;

            //delay the decoding until all schema have been loaded
            if ((doc.localName() != "service")&&(!_schemaManager.ready))
            {
                delayLoad(pageUrl, doc);
                return;
            }

            var title:String;
            var type:String;
            var members:ArrayCollection = new ArrayCollection();

            if (pageUrl == null)
            {
                pageUrl = doc.link.(@rel=="self")[0].@href;
            }

            switch (doc.localName()) {
                case "service":
                    title = "Menu";
                    type = ContentType.APP_SERVICE;
                    trace("- Loading menu...");
                    break;

                case "feed":
                    title = doc.atom::title.text();
                    type = doc.atom::content_type.@name;
                    trace("- Loading feed: " + title + " type: " + type);

                    use namespace atom;

                    for each (var entry:XML in doc.entry)
                    {
                        members.addItem(deserializeMember(entry));
                    }
                    break;

                case "entry":
                    title = doc.atom::title.text();
                    type = doc.atom::content.@type;
                    trace("- Loading entry: " + title + " type: " + type);

                    members.addItem(deserializeMember(doc));
                    break;
            }

            fragment = fragmentFromUrl(new URL(pageUrl));

            _document = new DocumentDescriptor(
                title, type, doc, getModuleUrl(type)
            );
            _document.members = members;

            dispatchEvent(new DocumentEvent(DocumentEvent.DOCUMENT_CHANGED));
            CursorManager.removeBusyCursor();
        }

        private function deserializeMember(entry:XML):Member{


            trace("deserializing a Member");
            use namespace atom;
            for each (var element:XML in entry.content[0].children()){
                var member:Member = _schemaManager.decode(element);
                member.title = entry.title;
                member.selfLink = entry.link.(@rel=="self")[0].@href;

                return member;
            }


            return null;
        }

        public function serializeMember(member:Member):String{

            trace("serializing Member");
            try
            {
                var xmlString:String = _schemaManager.encode(member);
            }
            catch(error:Error)
            {
                ErrorView.show("Error while encoding the request. " + error.message);
            }

            trace(xmlString);
            return xmlString;
        }

        public function loadConfiguration(everestConfiguration:EverestConfiguration):void{

            if (everestConfiguration != null)
            {
                _staticUrlPrefix = everestConfiguration.staticUrlPrefix;

                //load the schema mappings
                var schemaLocations:Array = new Array();

                for each (var entry:SchemaModelEntry in everestConfiguration.schemaMappings){
                    entry.register(_schemaManager);
                    if (entry.schemaLocation != null)
                    {
                        schemaLocations.push(entry.schemaLocation);
                    }
                }

                _schemaManager.loadSchemata(schemaLocations);

                //register all modules
                var nocacheToken:Number = new Date().milliseconds;
                for each (var module:Module in everestConfiguration.modules)
                {
                    _modules[module.contentType] = module.moduleUrl + "?nocache=" + nocacheToken;
                }
            } else {
                ErrorView.show("Configuration is missing. Everest client can continue load.");
            }
        }



        [Bindable(Event="selectedIndexChanged")]
        public function get selectedIndex():int
        {
            return _selectedIndex;
        }

        public function loadPageNewWindow(pageUrl:String):void
        {
            var newUrl:String;
            var url:URL = new URL(pageUrl);
            if ((url.host == '') || (url.host == appUrl.host && url.port == appUrl.port)) {
                newUrl = _browserManager.base;
                newUrl += newUrl.indexOf('#') > -1 ? "/" + url.path : "#/" + url.path;
                if (url.query.length > 0) {
                    newUrl += "?" + url.query;
                }
            }
            else {
                newUrl = pageUrl;
            }
            trace("- Load Page in New Window, URL: " + newUrl);
            navigateToURL(new URLRequest(newUrl), "_blank");
        }

        public function loadNewMember(pageUrl:String, doc:XML):void
        {
            //this is all a bit messy as the result object has no
            //id attributes because the database commit will happen
            //after the result is sent.
            use namespace atom;
            var url:String = doc.link.(@rel=="self")[0].@href;
            if (StringUtils.contains(url, "/None/"))
            {
                //no way to determine the url of the newly created member
                //so reload the current view
                url = fragment;
            }

            //go ahead and refetch the member
            trace("- Goto Member: " + url);
            var event:NavigationEvent =
                new NavigationEvent(NavigationEvent.LOAD_PAGE);
            event.pageUrl = url;
            _dispatcher.dispatchEvent(event);
        }

        public function loadMember(atomEntry:XML):void
        {
            use namespace atom;
            var url:String = atomEntry.link.(@rel=="self")[0].@href;
            trace("- Goto Member: " + url);
            var event:NavigationEvent =
                new NavigationEvent(NavigationEvent.LOAD_PAGE);
            event.pageUrl = url;
            _dispatcher.dispatchEvent(event);
        }


        public function getCurrentBaseUrl():String
        {
            return topLevelUrl + fragment.split("?")[0]
        }

//        public function get appServiceUrl():String
//        {
//            return topLevelUrl + APP_SERVICE;
//        }



        private function handleBrowserURLChange(event:BrowserChangeEvent=null):void
        {

            if ((fragment == null) || (fragment.length <= 2))
            {
                //load the menu module directly
                loadModule(ContentType.APP_SERVICE,
                           fragment, getModuleUrl(ContentType.APP_SERVICE));
            } else {
                var newEvent:NavigationEvent =
                    new NavigationEvent(NavigationEvent.LOAD_PAGE);
                newEvent.pageUrl = navigateUrl;
                trace("- Navigate To: " + newEvent.pageUrl);
                _dispatcher.dispatchEvent(newEvent);
            }
        }

        private function get navigateUrl():String
        {
            var url:String = "";
                url = topLevelUrl + fragment;

            return url
        }

        private function get topLevelUrl():String
        {
            return appUrl.protocol + "://" + appUrl.host + ":" + appUrl.port;
        }

        private function get appUrl():URL
        {
            if (_appUrl == null) {
                _appUrl = new URL(FlexGlobals.topLevelApplication.url);
            }
            return _appUrl;
        }

        private function get fragment():String
        {
            var browser_fragment:String = _browserManager.fragment;
            if (browser_fragment.length == 0 ||
                browser_fragment.charAt(0) != ROOT_FRAGMENT) {
                browser_fragment = ROOT_FRAGMENT + browser_fragment;
                fragment = browser_fragment;
            }
            return browser_fragment;
        }

        private function set fragment(newFragment:String):void
        {
            _browserManager.setFragment(newFragment);
        }

        private function fragmentFromUrl(url:URL):String
        {
            var path:String = ROOT_FRAGMENT + url.path;
//            if (path == APP_SERVICE) {
//                path = ROOT_FRAGMENT;
//            }
            if (url.query.length > 0) {
                path += "?" + url.query;
            }
            trace("- current path: " + path);
            return path;
        }

        private function getModuleUrl(type:String):String
        {
            return _staticUrlPrefix + _modules[type];
        }

    }
}