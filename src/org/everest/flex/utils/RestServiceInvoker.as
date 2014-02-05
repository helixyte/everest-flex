package org.everest.flex.utils
{
    import com.asfusion.mate.actionLists.IScope;
    import com.asfusion.mate.actionLists.ServiceHandlers;
    import com.asfusion.mate.actions.IAction;
    import com.asfusion.mate.actions.builders.ServiceInvoker;
    import com.asfusion.mate.actions.builders.serviceClasses.Request;
    import com.asfusion.mate.core.ISmartObject;
    import com.asfusion.mate.core.Properties;
    import com.asfusion.mate.events.UnhandledFaultEvent;
    
    import flash.events.EventDispatcher;
    import flash.utils.ByteArray;
    
    import mx.rpc.AsyncToken;
    import mx.rpc.Fault;
    import mx.rpc.Responder;
    import mx.rpc.events.FaultEvent;
    import mx.rpc.events.ResultEvent;
    import mx.rpc.http.HTTPService;

    [DefaultProperty("MXMLrequest")]
    [Exclude(name="MXMLrequest", kind="property")]
    /**
     * The RestServiceInvoker is a copy of the HTTPServiceInvoker with two modifications:
     *  - it allows sending of binary data
     *  - REST errors are sent by the server with HTTP status code 200 to overcome the sandbox restriction.
     *    so this class intercepts incomming messages to see if the payload indicates a server error
     *    if this is the case a regular FaultEvent is triggered.
     */
    public class RestServiceInvoker extends ServiceInvoker implements IAction
    {
        /**
         *  @private
         *  No documentation about this yet
         */
        protected var proxyChanged:Boolean;

        /*-.........................................resultFormat..........................................*/
        private var _resultFormat:String;
        /**
         * Value that indicates how you want to deserialize the result returned by the HTTP call. The value for this is based on the following:
         * <ul><li>Whether you are returning XML or name/value pairs.</li>
         * <li>How you want to access the results; you can access results as an object, text, or XML.</li></ul>
         * <p>The default value is <code>object</code>. The following values are permitted:
         * <ul><li><code>object</code> The value returned is XML and is parsed as a tree of ActionScript objects. This is the default.</li>
         * <li><code>array</code> The value returned is XML and is parsed as a tree of ActionScript objects however if the top level object is not an Array,
         * a new Array is created and the result set as the first item. If makeObjectsBindable is true then the Array will be wrapped in an ArrayCollection.</li>
         * <li><code>xml</code> The value returned is XML and is returned as literal XML in an ActionScript XMLnode object.</li>
         * <li><code>flashvars</code> The value returned is text containing name=value pairs separated by ampersands, which is parsed into an ActionScript object.</li>
         * <li><code>text</code> The value returned is text, and is left raw.</li>
         * <li><code>e4x</code> The value returned is XML and is returned as literal XML in an ActionScript XML object, which can be accessed using ECMAScript for XML (E4X) expressions.</li></ul></p>
         */
        public function get resultFormat():String
        {
            return _resultFormat;
        }

        [Inspectable(enumeration="object,array,xml,flashvars,text,e4x")]
        public function set resultFormat(value:String):void
        {
            _resultFormat = value;
        }


        /*-.........................................url..........................................*/
        private var _url:Object;
        /**
         * Location of the service. If you specify the <code>url</code> and a non-default destination, your destination in the services-config.xml file must allow the specified URL.
         */
        public function get url():Object
        {
            return _url
        }

        public function set url(value:Object):void
        {
            _url = value;
        }


        /*-.........................................method..........................................*/
        private var _method:Object;
        /**
         * HTTP method for sending the request. Permitted values are GET, POST, PATCH, HEAD, OPTIONS, PUT, TRACE and DELETE.
         * Lowercase letters are converted to uppercase letters. The default value is GET.
         */
        override public function get method():Object
        {
            return _method;
        }

        [Inspectable(enumeration="GET,POST,PATCH,HEAD,OPTIONS,PUT,TRACE,DELETE")]
        override public function set method(value:Object):void
        {
            _method = value;
        }


        /*-.........................................rootURL..........................................*/
        private var _rootURL:String;
        /**
         * The URL that the RestHttpService object should use when computing relative URLs.
         * This property is only used when going through the proxy.
         * When the <code>useProxy</code> property is set to <code>false</code>, the relative URL is
         * computed automatically
         * based on the location of the SWF running this application. If not set explicitly <code>rootURL</code>
         * is automatically set to the URL of mx.messaging.config.LoaderConfig.url.
         */
        public function get rootURL():String
        {
            return _rootURL;
        }

        public function set rootURL(value:String):void
        {
            _rootURL = value;
        }

        /*-.........................................useProxy..........................................*/
        private var _useProxy:Boolean;
        /**
         * Specifies whether to use the Flex proxy service. The default value is <code>false</code>. If you do not specify true to proxy
         * requests though the Flex server, you must ensure that the player can reach the target URL.
         * You also cannot use destinations defined in the services-config.xml file if the <code>useProxy</code> property is set to <code>false</code>.
         *
         * @defult false
         */
        public function get useProxy():Boolean
        {
            return _useProxy;
        }

        public function set useProxy(value:Boolean):void
        {
            _useProxy = value;
            proxyChanged = true;
        }

        /*-.........................................contentType..........................................*/
        private var _contentType:Object;
        /**
         * Type of content for service requests. The default is <code>application/x-www-form-urlencoded</code> which sends requests like a normal HTTP POST with name-value pairs.
         * <code>application/xml</code> send requests as XML.
         */
        public function get contentType():Object
        {
            return _contentType;
        }

        public function set contentType(value:Object):void
        {
            _contentType = value;
        }


		/*-.........................................responseContentType..........................................*/
		private var _responseContentType:Object;
		/**
		 * Type of content for the service request response. This is put in an ACCEPT header.
		 */
		public function get responseContentType():Object
		{
			return _responseContentType;
		}
		
		public function set responseContentType(value:Object):void
		{
			_responseContentType = value;
		}
		
		
        /*-.........................................headers..........................................*/
        private var _headers:Object;
        /**
         * Custom HTTP headers to be sent to the third party endpoint. If multiple headers need to be sent with the same name the value should be specified as an Array.
         */
        public function get headers():Object
        {
            return _headers;
        }

        public function set headers(value:Object):void
        {
            _headers = value;
        }

        /*-.........................................request..........................................*/
        private var _request:Object;
        /**
         * Object of name-value pairs used as parameters to the URL. If the <code>contentType</code> property is set to <code>application/xml</code>,
         * it should be an XML document.
         * the request object can include <code>smartObjects</code> from the <code>EventMap</code> such as:
         * event, lastResult, currentEvent, resultObject, fault, message, data etc.
         */
        public function get request():Object
        {
            return _request;
        }

        public function set request(value:Object):void
        {
            _request = value;
        }

        /*-.........................................MXMLrequest..........................................*/
        /**
         * @private
         */
        public function get MXMLrequest():*
        {
            return request;
        }

        public function set MXMLrequest(value:Request):void
        {
            request = value;
        }


        /*-.........................................instance..........................................*/
        /**
         * If this property is null, a new RestHttpService instance is created on
         * the <code>prepare</code> method. Otherwise, this instance will be used.
         * The class that will be used to create the instance if none is provided is
         *  <code>mx.rpc.http.RestHttpService</code>.
         *
         * @default null
         */
        public function get instance():HTTPService
        {
            return currentInstance;
        }
        public function set instance(value:HTTPService):void
        {
            currentInstance = value;
        }

        //        [ArrayElementType("com.asfusion.mate.actions.IAction")]
        //        public function set resultHandlers(value:Array):void
        //        {
        //            _resultHandlers = value;
        //        }

        /*-----------------------------------------------------------------------------------------------------------
        *                                          Override protected methods
        -------------------------------------------------------------------------------------------------------------*/
        /*-.........................................createInstance..........................................*/
        /**
         * @inheritDoc
         */
        override protected function prepare(scope:IScope):void
        {
            super.prepare(scope);
            if(!currentInstance) currentInstance = new HTTPService();
            var httpInstance:HTTPService = currentInstance;
            if(url)
            {
                var realURL:String = (url is ISmartObject) ? ISmartObject(url).getValue(scope).toString() : url.toString();
                if ((realURL)&&(realURL.indexOf('flashfilter') < 0))
                {
                    realURL = realURL.indexOf("?") > 0 ? realURL + "&flashfilter=true" : realURL + "?flashfilter=true";
                }
                httpInstance.url = realURL;
            }
            if(request)
            {
                var smartRequest:Object;
                if(request is ISmartObject)
                {
                    smartRequest = ISmartObject(request).getValue(scope);
                }
                else
                {
                    smartRequest = request;
                }
                if(smartRequest is XML || smartRequest is String || smartRequest is ByteArray)
                {
                    httpInstance.request = smartRequest;
                }
                else
                {
                    var realRequest:Object = new Object();
                    realRequest = Properties.smartCopy(smartRequest, realRequest, scope);
                    httpInstance.request = realRequest;
                }
            }

            if(channelSet)				httpInstance.channelSet = channelSet;
            if(contentType)
			{
				httpInstance.contentType = (contentType is ISmartObject) 
					? ISmartObject(contentType).getValue(scope).toString() 
					: contentType.toString();	
			}
            if(destination) 			httpInstance.destination = destination;
            if(headers)					httpInstance.headers = headers;
			if(responseContentType)
			{
				httpInstance.headers['ACCEPT'] = (responseContentType is ISmartObject) 
					? ISmartObject(responseContentType).getValue(scope).toString() 
					: responseContentType.toString();
			}
            if(requestTimeoutChanged)	httpInstance.requestTimeout = requestTimeout
            if(resultFormat) 			httpInstance.resultFormat = resultFormat;
            if(rootURL)					httpInstance.rootURL = rootURL;
            if(proxyChanged)			httpInstance.useProxy = useProxy;
            if(objectsBindableChanged)	httpInstance.makeObjectsBindable = makeObjectsBindable;
            if(method)
            {
                var realMethod:String = (method is ISmartObject) ? ISmartObject(method).getValue(scope).toString() : method.toString();                
                // Since Flex only passes GET and POST requests, we have to
                // replace DELETE, PATCH and PUT methods with POST and 
                // set a corresponding X-HTTP-Method-Override header.
                if (realMethod == RestActions.DELETE || realMethod == RestActions.PATCH 
                    || realMethod == RestActions.PUT)
                {
                    httpInstance.headers['X-HTTP-Method-Override'] = realMethod;
                    realMethod = RestActions.POST;
                }
                httpInstance.method = realMethod;
            }
            if(username && password)
            {
                if(username is ISmartObject)
                {
                    username = ISmartObject(username).getValue(scope);
                }
                if(password is ISmartObject)
                {
                    password = ISmartObject(password).getValue(scope);
                }
                httpInstance.setCredentials(username as String, password as String);
            }
            if(remoteUsername && remotePassword)
            {
                if(remoteUsername is ISmartObject)
                {
                    remoteUsername = ISmartObject(remoteUsername).getValue(scope);
                }
                if(remotePassword is ISmartObject)
                {
                    remotePassword = ISmartObject(remotePassword).getValue(scope);
                }
                httpInstance.setRemoteCredentials(remoteUsername as String, remotePassword as String);
            }


        }

        /*-.........................................run..........................................*/
        /**
         * @inheritDoc
         */
        override protected function run(scope:IScope):void
        {
            token = currentInstance.send();
            scope.lastReturn = token;
        }

        /**
         * @inheritDoc
         */
        override protected function complete(scope:IScope):void
        {
            // Error state when we don't have a token.  Maybe we called a method that returned
            // void instead?
            if (token == null)
            {
                return;
            }

            // Create a dispatcher to be invoked from the token responder that dispatches
            // the result/fault event the handlers listen to
            var dispatcher:EventDispatcher = new EventDispatcher();

            // Generate a responder associated with the token and dispatcher, and add it
            // to the list of responds for the token
            token.addResponder(createResponder(token, dispatcher));

            // The inner handlers dispatcher is the internal dispatcher the responder uses
            innerHandlersDispatcher = dispatcher;

            if (resultHandlers && resultHandlers.length > 0)
            {
                var resultHandlersInstance:ServiceHandlers = createInnerHandlers(scope,
                    ResultEvent.RESULT,
                    resultHandlers,
                    ServiceHandlers) as ServiceHandlers;
                resultHandlersInstance.token = token;
                resultHandlersInstance.validateNow();
            }

            if ((faultHandlers && faultHandlers.length > 0)
                || scope.dispatcher.hasEventListener(UnhandledFaultEvent.FAULT))
            {
                var faultHandlersInstance:ServiceHandlers = createInnerHandlers(scope,
                    FaultEvent.FAULT,
                    faultHandlers,
                    ServiceHandlers) as ServiceHandlers;
                faultHandlersInstance.token = token;
                faultHandlersInstance.validateNow();
            }
        }


        protected function createResponder(token:AsyncToken, dispatcher:EventDispatcher):Responder
        {
            return new Responder(

                function(data:Object):void
                {

                    // Convert the result into a result event and notify inner handlers
                    var resultEvent:ResultEvent;
                    if (data is ResultEvent)
                    {
                        var result:XML = XML(ResultEvent(data).result);
                        //                        var rootElement:Object = result.children()[0];

                        if((result != null) && (result.name() == "error")){
                            resultEvent = FaultEvent.createEvent(
                                new RestFault(result.code, result.message, result.details, result.location), token);
                        } else {
                            resultEvent = ResultEvent.createEvent(result, token);
                        }
                    }
                    else
                    {
                        resultEvent = ResultEvent.createEvent(data, token);
                    }
                    dispatcher.dispatchEvent(resultEvent);
                },
                function(info:Object):void
                {


                    // Convert the error into a fault event and notify inner handlers
                    var faultEvent:FaultEvent;
                    if (info is FaultEvent)
                    {
                        faultEvent = FaultEvent.createEvent(FaultEvent(info).fault, token);
                    }
                    else if (info is Fault)
                    {
                        faultEvent = FaultEvent.createEvent(Fault(info), token);
                    }
                    else
                    {
                        faultEvent = FaultEvent.createEvent(new Fault(info.toString(), info.toString()), token);
                    }
                    dispatcher.dispatchEvent(faultEvent);
                });
        }
    }
}