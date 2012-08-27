package org.everest.flex.model.managers
{

    import flash.events.Event;

    import mx.logging.Log;
    import mx.logging.LogEventLevel;
    import mx.logging.targets.TraceTarget;
    import mx.rpc.events.FaultEvent;
    import mx.rpc.events.SchemaLoadEvent;
    import mx.rpc.events.XMLLoadEvent;
    import mx.rpc.xml.Schema;
    import mx.rpc.xml.SchemaTypeRegistry;
    import mx.utils.ObjectUtil;

    import org.everest.flex.ui.components.ErrorView;
    import org.everest.flex.utils.BatchSchemaLoader;
    import org.everest.flex.utils.PatchedXMLDecoder;
    import org.everest.flex.utils.PatchedXMLEncoder;


    /**
     * Loads and stores a collection of one or more XML schema definitions.
     * It is used to marshal and unmarshal the XML to client entities.
     *
     * @author rothe
     */
    public class SchemaManager
    {
        [Bindable]
        public var ready:Boolean = false;

        [Bindable]
        private var _schemaManager:mx.rpc.xml.SchemaManager;

        private var _schemaTypeRegistry:SchemaTypeRegistry;
        private var _objectRootMappings:Object = new Object(); //needed to determin root element for serialization


        public function SchemaManager()
        {
            _schemaManager = new mx.rpc.xml.SchemaManager();
            _schemaTypeRegistry = SchemaTypeRegistry.getInstance();
            initializeLogging();
        }

        private function initializeLogging():void{
            // Create a target.
            var logTarget:TraceTarget = new TraceTarget();

            // Log all log levels.
            logTarget.level = LogEventLevel.ALL;

            // Add date, time, category, and log level to the output.
            logTarget.includeDate = true;
            logTarget.includeTime = true;
            logTarget.includeCategory = true;
            logTarget.includeLevel = true;

            // Begin logging.
            Log.addTarget(logTarget);
        }


        public function loadSchemata(schemaLocations:Array):void
        {
            var loader:BatchSchemaLoader = new BatchSchemaLoader();
                loader.addEventListener(SchemaLoadEvent.LOAD, schemaLoader_loadHandler);
                loader.addEventListener(XMLLoadEvent.LOAD, schemaLoader_xmlLoadHandler);
                loader.addEventListener(FaultEvent.FAULT, schemaLoader_faultHandler);
                loader.addEventListener(Event.COMPLETE, schemaLoader_completeHandler);
                loader.loadAll(schemaLocations);
        }

        public function registerClass(qname:QName, vo:Class, rootElementName:String=null):void
        {
            if (rootElementName != null)
            {
                var className:String = ObjectUtil.getClassInfo(vo).name;
                _objectRootMappings[className] = new QName(qname.uri,rootElementName);
            }

            _schemaTypeRegistry.registerClass(qname,vo);
        }

        public function registerCollectionClass(qname:QName, vo:Class):void
        {

            _schemaTypeRegistry.registerCollectionClass(qname,vo);
        }

        public function decode(xml:XML, qname:QName=null):*
        {
            if (qname == null)
            {
                qname = xml.name() as QName;
            }
            var xmlDecoder:PatchedXMLDecoder = new PatchedXMLDecoder();
            xmlDecoder.schemaManager = _schemaManager;
            //                xmlDecoder.strictMode = true;
            xmlDecoder.makeObjectsBindable = true;
            return xmlDecoder.decode(xml, qname);
        }

        public function encode(entity:*):String
        {
            var className:String = ObjectUtil.getClassInfo(entity).name;
            var qName:QName = _objectRootMappings[className];
            var xmlEncoder:PatchedXMLEncoder = new PatchedXMLEncoder();
            xmlEncoder.schemaManager = _schemaManager;

            var result:XMLList = xmlEncoder.encode(entity, qName);

            if (result != null)
            {
                return result.toXMLString();
            }

            return null;
        }

        /**
         * Dispatched once SchemaLoader has completed loading all schemata
         */
        private function schemaLoader_completeHandler(event:Event):void
        {
            trace("schemaLoader_completeHandler ");
            this.ready = true;
        }

        /**
         * Dispatched once SchemaLoader has loaded a new schema
         */
        private function schemaLoader_loadHandler(event:SchemaLoadEvent):void
        {
            trace("schemaLoader_loadHandler ");
            var schema:Schema = event.schema;
            _schemaManager.addSchema(schema);

            trace(_schemaManager.currentSchema);
        }


        /**
         * Dispatched each time SchemaLoader loads a schema
         * This may occur multiple times if a schema contains any imported/included schemas
         */
        private function schemaLoader_xmlLoadHandler(event:XMLLoadEvent):void
        {
            trace("schemaLoader_xmlLoadHandler " + event.location);
        }

        private function schemaLoader_faultHandler(event:FaultEvent):void
        {
            ErrorView.show("Schema could not be loaded: " + event);
            trace("schemaLoader_faultHandler " + event);

        }

    }
}