package org.everest.flex.events
{
    import org.everest.flex.utils.RestFault;

    import flash.events.Event;

    /**
     * Events for REST faults.
     *
     * @author rothe
     */
    public class RestFaultEvent extends Event
    {
        public static const ERROR:String = "errorMessageEvent";

        public var fault:*;

        public var cause:Event;

        public function RestFaultEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
        }

        public function get title():String
        {
            return fault.faultString;
        }

        public function get message():String
        {
            // FIXME: improve the way response errors are handled
            var msg:String = "";
            if ((fault != null) && (fault.content != null) && (fault.content.length > 0)) {
                //trace("- Error Response Body:\n", content);
                try {
                    var html:XML = new XML(fault.content);
                    msg = String(html.body.text()).replace("\n", "");
                }
                catch (e:TypeError) {
                    msg = "Check server log for the error message or the debug URL.";
                }

            } else if((fault != null) && (fault.faultString != null)&&(fault.faultString.length > 0)){
                msg += fault.faultString;

            } else {
                msg = "An internal server error has occured (500).";
            }
            return msg;
        }
    }
}