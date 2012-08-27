package org.everest.flex.query
{
    import com.adobe.utils.StringUtil;

    /**
     * Represents a OpenSearch term in the schema of name:operator:value.
     * @see http://www.opensearch.org/Specifications/OpenSearch/1.1
     * @author rothe
     */
    public class Criterion
    {

        public var name:String;
        public var operator:String;
        public var value:Array;

        public function Criterion(name:String, operator:String, value:Array)
        {
            this.name = name;
            this.operator = operator;
            this.value = value;
        }

        /**
         * Converts the value array in a comma speparated list of quoted strings.
         *
         * @return comma speparated list of quoted strings
         */
        public function getValueAsString():String{

            var result:String = "";

            if ((value != null) && (value.length > 0)) {

                for each (var val:String in value) {

                    result += StringUtil.trim(val) + ', ';
                }

                return result.substr(0, result.length -2);
            }

            return result;

        }

        public function toString():String{

            var result:String = name + ":" + operator + ":";

            if ((value != null) && (value.length > 0)) {

                for each (var val:String in value) {
                    if(val != null){
                        result += '"' + StringUtil.trim(val) + '",';
                    }
                }

                return result.substr(0, result.length -1);
            }

            return result;
        }


    }
}