package org.everest.flex.model
{
    /**
     * Holds the metadata associated with an atom feed.
     *
     * @author rothe
     */
    public class FeedInfo
    {
        public var generatorUri:String;
        public var searchTerms:String;
        public var sortTerms:String;
        public var firstPageLink:String;
        public var previousPageLink:String;
        public var nextPageLink:String;
        public var lastPageLink:String;
        public var startIndex:int;
        public var startNumber:int;
        public var endNumber:int;
        public var totalResults:int;
        public var itemsPerPage:int;

        public function FeedInfo()
        {
        }
    }
}