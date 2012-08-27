package org.everest.flex.model
{

    import org.everest.flex.model.managers.SchemaManager;

    /**
     * Defines the mapping of a the server data model entry (ressource)
     * to the client data model and back.
     * One entry combines a ressource member and the associated collection.
     *
     * @author rothe
     */
    public class SchemaModelEntry
    {
        public var schemaLocation:String;

        private var ns:String;
        private var typePrefix:String;
        private var modelClass:Class;
        private var linkClass:Class;
        private var collectionClass:Class;
        private var rootElement:String;


        /**
         * Object of this class presents the member and the collection of a given
         * everest application ressuorce.
         *
         * @param rootElement the XML root element name (e.g. 'cusotmer')
         * @param ns the XML target name space (e.g. 'http://ns.example.com/cusstomer')
         * @param typePrefix the first part of the name of the resource entity (e.g. Customer not CustomerMember!)
         * @param modelClass reference to the ActionScript class presenting the ressource member
         * @param schemaLocation the optional location of the xsd schema
         * @param collectionClass  the optional class to be uesd for the collection (default is com.everest.model.MembersCollection)
         * @param linkClass thel optional class to be used for a link (default is com.everest.model.Link)
         *
         */
        public function SchemaModelEntry(rootElement:String,
                                         ns:String,
                                         typePrefix:String,
                                         modelClass:Class,
                                         schemaLocation:String=null,
                                         collectionClass:Class=null,
                                         linkClass:Class=null)
        {
            this.rootElement = rootElement;
            this.ns = ns;
            this.typePrefix = typePrefix;
            this.modelClass = modelClass;
            this.schemaLocation = schemaLocation;
            this.collectionClass = collectionClass != null ? collectionClass : MembersCollection;
            this.linkClass = linkClass != null ? linkClass : Link;
        }

        /**
         * Register this schema model entry with a given SchemaManager.
         *
         * @param schemaManager the SchemaManager where to register
         */
        public function register(schemaManager:SchemaManager):void
        {
            schemaManager.registerClass(new QName(ns,typePrefix + "Type"), modelClass, rootElement);
            schemaManager.registerClass(new QName(ns,typePrefix + "LinkType"), linkClass);
            schemaManager.registerCollectionClass(new QName(ns, typePrefix + "CollectionType"), collectionClass);
            schemaManager.registerClass(new QName(ns, typePrefix + "CollectionLinkType"), linkClass);
        }
    }
}