package org.everest.flex.utils
{
    import flash.events.Event;

    import mx.core.FlexGlobals;
    import mx.rpc.events.ResultEvent;
    import mx.rpc.events.SchemaLoadEvent;
    import mx.rpc.http.HTTPService;
    import mx.rpc.xml.Schema;
    import mx.rpc.xml.SchemaLoader;

    /**
     * Asynchronously loads a list of XSD Schema for a given URL
     * XSD import load is done in a batch at the end to prevent redundand
     * load of reoccuring imports.
     *
     * @author rothe
     */
    public class BatchSchemaLoader extends SchemaLoader
    {
        private var _dejavu:Object = new Object(); //prevent duplicate loads

        public function BatchSchemaLoader(httpService:HTTPService=null)
        {
            super(httpService);
        }

        /**
         * Asynchronously loads a list of XSD Schema for a given URL
         * XSD import load is done in a batch at the end to prevent redundand
         * load of reoccuring imports.
         * Event.COMPLETE is dispatched when all schemata are loaded
         *
         * @param schemaLocations array of urls
         * @param noCache if true a token will be attached to the url to bypass browser caching
         *
         */
        public function loadAll(schemaLocations:Array, noCache:Boolean=false):void
        {

            for each (var schemaLocation:String in schemaLocations)
            {
                var url:String = getQualifiedLocation(schemaLocation);
                if(!_dejavu[url]){

                    _dejavu[url]=true;

                    if (noCache)
                    {
                        //prevent browser cache by attaching a random parameter
                        super.load(schemaLocation +  "?nocache=" + new Date().milliseconds);
                    } else {
                        super.load(schemaLocation);
                    }

                } else {
                    trace("schema already loaded from: " + url);
                }
            }

        }

        /**
         * DO NOT USE! Use loadAll(schemaLocations, noCache) instead.
         *
         */
        override public function load(url:String):void
        {
            trace("DO NOT USE! Use loadAll(schemaLocations, noCache) instead.");
            throw new Error("unsuported operation");
        }

        override protected function resultHandler(event:ResultEvent):void
        {
            super.resultHandler(event);


            if (loadsOutstanding <= 0)
            {
                 dispatchEvent(new Event(Event.COMPLETE));

            } else {
                // we need to override the parent behaviour
                var xml:XML = XML(event.result);
                var schema:Schema = new Schema(xml);
                var loadEvent:SchemaLoadEvent = SchemaLoadEvent.createEvent(schema, null);
                dispatchEvent(loadEvent);
            }
        }

        public override function schemaImports(schema:mx.rpc.xml.Schema, parentLocation:String, schemaManager:mx.rpc.xml.SchemaManager = null):void
        {
            var importQName:QName = schema.schemaConstants.importQName;
            var schemaXML:XML = schema.xml;
            var imports:XMLList = schemaXML.elements(importQName);
            for each (var importNode:XML in imports)
            {
                var location:String = importNode.attribute("schemaLocation").toString();
                var importURI:String = importNode.attribute("namespace").toString();
                if (location != null)
                {
                    //load imports only if not already present or scheduled
                    var url:String = getQualifiedLocation(location, parentLocation);
                    if (_dejavu[url] == null)
                    {
                        _dejavu[url]=true;
                        super.load(url);
                    }

                }
            }
        }
    }
}