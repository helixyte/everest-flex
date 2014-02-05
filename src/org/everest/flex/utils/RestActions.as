package org.everest.flex.utils
{
    /**
     * REST Actions.
     * 
     * @author gathmann
     */
    public class RestActions
    {
        public static const GET:String = "GET";
        public static const PUT:String = "PUT";
        public static const PATCH:String = "PATCH";
        public static const POST:String = "POST";
        public static const DELETE:String = "DELETE";
        public static const ALL:Vector.<String> = 
            new Vector.<String>([GET, PUT, PATCH, POST, DELETE]);
    }
}