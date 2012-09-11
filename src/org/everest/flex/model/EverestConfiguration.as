package org.everest.flex.model
{

    /**
     * An everest application must instantiate and inject this configuration
     * in the EverestEventMap.
     * The configuration includes definitions for mapping the server data model
     * to the client data model and back.
     * It furthermore defines a list of flex application modules and for which
     * content type they shall be loaded.
     *
     * @author rothe
     *
     */
    public class EverestConfiguration
    {

        public function EverestConfiguration()
        {
        }

        /**
         * if the everest-flex application is delivered from a sub-directory path
         * such as http://host:port:/staticUrlPrefix/everest-flex-app.swf then this
         * function needs to return the whole directory structure to where the
         * main application swf is placed. (default is '/public/')
         *
         * @return  sub-directory path where the application is placed. (default is '/public/')
         *
         */
        public function get staticUrlPrefix():String
        {
            return '/public/';
        }

        public function get schemaMappings():Vector.<SchemaModelEntry>
        {
            throw new Error('needs to be implemented in order to use everest');
        }

        public function get modules():Vector.<Module>
        {
            throw new Error('needs to be implemented in order to use everest');
        }
    }
}