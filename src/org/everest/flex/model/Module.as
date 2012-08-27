package org.everest.flex.model
{
    /**
     * The presentation for each ressource (member and/or collection) is handled
     * by a dedicated spark module (see flex documentation). This class defines
     * a mapping of a REST content type to a flex module.
     *
     * @author rothe
     */
    public class Module
    {
        public var contentType:String;
        public var moduleUrl:String;

        /**
         *
         * @param contentType content type (e.g. 'application/vnd.everest+xml;type=Customer')
         * @param moduleUrl the location of the module swf (e.g. 'com/myapp/modules/customer/CustomerMember.swf'
         *
         */
        public function Module(contentType:String, moduleUrl:String)
        {
            this.contentType = contentType;
            this.moduleUrl = moduleUrl;
        }
    }
}