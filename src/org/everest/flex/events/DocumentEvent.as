package org.everest.flex.events
{
    import flash.events.Event;

    import org.everest.flex.model.DocumentDescriptor;

    /**
     * Events for a REST document.
     *
     * @author rothe
     */
    public class DocumentEvent extends Event
    {
        public static const DOCUMENT_LOADED:String = "documentLoadedDocumentEvent";
        public static const DOCUMENT_CHANGED:String = "documentChanged";
        public static const SUB_DOCUMENT_LOADED:String = "subDocumentLoadedDocumentEvent";
        public static const SUB_DOCUMENT_CHANGED:String = "subDocumentChanged";

        public var document:DocumentDescriptor;

        public function DocumentEvent(type:String, bubbles:Boolean=true,
                                      cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
        }
    }
}