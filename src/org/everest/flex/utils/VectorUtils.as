package org.everest.flex.utils
{
    public class VectorUtils
    {
        /**
         * Utilty to work with Vector objects.
         */
        public function VectorUtils()
        {
        }

        /**
         * Convert a Vector to an Array.
         *
         * @param obj the vector to be converted
         * @return  an array containing all elements of the given vector
         *
         */
        public static function toArray(obj:Object):Array {
            if (!obj) {
                return [];
            } else if (obj is Array) {
                return obj as Array;
            } else if (obj is Vector.<*>) {
                var array:Array = new Array(obj.length);
                for (var i:int = 0; i < obj.length; i++) {
                    array[i] = obj[i];
                }
                return array;
            } else {
                return [obj];
            }
        }
    }
}