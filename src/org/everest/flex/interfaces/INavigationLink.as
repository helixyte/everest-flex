package org.everest.flex.interfaces
{
    [Bindable]
    /**
     * Holds the url reference to a REST resource and a descriptive title.
     *
     * @author rothe
     */
    public interface INavigationLink
    {

        /**
         * @return get the title of the link
         */
        function get title():String;

        /**
         * @param value set the title of the link
         *
         */
        function set title(value:String):void;

        /**
         * @return get the url to which this link is pointing
         */
        function get href():String;

        /**
         * @param value set the url to which this link is pointing
         */
        function set href(value:String):void;

        /**
         * kind is a helper to determine wether to load a MEMBER or COLLECTION.
         * @see  org.everest.flex.model.Link.MEMBER  org.everest.flex.model.Link.COLLECTION
         * @return
         */
        function get kind():String;

        /**
         * kind is a helper to determine wether to load a MEMBER or COLLECTION.
         *
         * @param kind org.everest.flex.model.Link.MEMBER or org.everest.flex.model.Link.COLLECTION
         *
         */
        function set kind(kind:String):void;

    }
}