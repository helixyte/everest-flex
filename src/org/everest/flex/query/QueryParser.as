package org.everest.flex.query
{

    /**
     * Parses a query string and converts it to Criterion objects.
     * @see http://www.opensearch.org/Specifications/OpenSearch/1.1
     * @author rothe
     */
    public class QueryParser
    {
        public function QueryParser()
        {
        }

        public static function parse(query:String):Criteria{

            var result:Criteria = new Criteria();

            for each (var term:String in query.split("~")){
                result.put(parseTerm(term));
            }

            return result;

        }

        private static function parseTerm(term:String):Criterion{


            var c1:int = term.indexOf(":");
            var c2:int = term.indexOf(":", c1+1);

            var name:String = term.substr(0,c1);
            var operator:String = term.substr(c1+1,c2-c1-1);
            var value:String = term.substr(c2+1);

            return new Criterion(name, operator, parseValue(value));
        }

        private static function parseValue(csv:String):Array{

            var len:int = csv.length;

            var ignore:Boolean = false;
            var result:Array = new Array();
            var term:String = "";

            for (var i:int = 0; i < len; i++){
                var char:String = csv.charAt(i) ;
                if(char == '"'){
                    ignore = !ignore;
                } else if ((char == ',')&&(!ignore)){

                    if(term.length > 0) {result.push(term);}
                    term = "";
                } else if((char != " ")||ignore){
                    term += char;
                }

            }
            if(term.length > 0){
                result.push(term);
            }

            return result;
        }
    }
}