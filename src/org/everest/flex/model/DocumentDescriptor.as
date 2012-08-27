package org.everest.flex.model
{
    import mx.collections.ArrayCollection;

    [Bindable]
    /**
     * A document encapsulates the raw xml data and its metadata (url, type ...)
     * It is used by the everest flex framework during load and to dispatch
     * the propper view.
     *
     * @author rothe
     */
    public class DocumentDescriptor
    {
        public var title:String;
        public var type:String;
        public var data:XML;
        public var moduleUrl:String = null;
        public var members:ArrayCollection;
        public var urlFragment:String;

        public function DocumentDescriptor(title:String, type:String, data:XML,
                                           moduleUrl:String)
        {
            this.title = title;
            this.type = type;
            this.data = data;
            this.moduleUrl = moduleUrl;
        }
    }
}