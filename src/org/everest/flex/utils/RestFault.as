package org.everest.flex.utils
{
    import mx.rpc.Fault;

    /**
     * Data object for presenting a REST fault.
     *
     * @author rothe
     */
    public class RestFault extends Fault
    {
        public var location:String;

        public function RestFault(faultCode:String, faultString:String, faultDetail:String = null, location:String=null)
        {
            super(faultCode, faultString, faultDetail);
            this.location = location;
        }
    }
}