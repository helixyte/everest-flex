package org.everest.flex.query
{
    import flash.utils.Dictionary;

    /**
     * Holds a list of Criterion objects that are used for the OpenSearch
     * implementation to filter or search over collections.
     * @see http://www.opensearch.org/Specifications/OpenSearch/1.1
     * @author rothe
     */
    public class Criteria
    {

        private var _criteria:Dictionary = new Dictionary();


        public function Criteria()
        {
        }

        public function put(criterion:Criterion):void{

            _criteria[criterion.name+criterion.operator] = criterion;
        }

        public function remove(name:String, operator:String):void{
            _criteria[name+operator] = null;
        }

        public function get(name:String, operator:String):Criterion{
            return _criteria[name+operator];
        }

        public function get length():int{
            return list().length;
        }

        public function list():Vector.<Criterion>{

            var results:Vector.<Criterion> = new Vector.<Criterion>();

            for each (var criterion:Criterion in _criteria){
                if((criterion != null)&&(criterion.name !="")){
                results.push(criterion);
                }
            }

            return results;
        }

        public function toString():String
        {
            var results:Array = new Array();
            var c:Vector.<Criterion> = list();
            for each (var criterion:Criterion in c){
                results.push(criterion);
            }

            return "q=" + results.join("~");
        }
    }
}