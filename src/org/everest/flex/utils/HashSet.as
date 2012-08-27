package org.everest.flex.utils
{

    import flash.utils.Dictionary;

    import mx.collections.ArrayCollection;

    /**
     *  Similar to a Java HashSet where there are no duplicate entries.
     */
    public class HashSet
    {

        private var _items : Dictionary;

        private var _stringItems : Object;

        private var _size : uint = 0;

        public function HashSet()
        {
            _items = new Dictionary();
            _stringItems = new Object();
        }

        public function add(item : *) : Boolean {
            if (item is String) {
                if (_stringItems[item] !== undefined) return false;
                _stringItems[item] = item;

            } else {
                if (_items[item] !== undefined) return false;
                _items[item] = item;
            }

            _size++;
            return true;
        }

        public function get size() : uint {
            return _size;
        }

        public function has(item : *) : Boolean {
            if (item is String) return _stringItems[item] !== undefined;
            return _items[item] !== undefined;
        }

        public function toArray() : Array {
            var items : Array = new Array();
            var item : *;
            for each (item in _stringItems) {
                items.push(item);
            }
            for each (item in _items) {
                items.push(item);
            }
            return items;
        }

        public function toArrayCollection() : ArrayCollection {
            return new ArrayCollection(toArray());
        }

        public function remove(item : *) : Boolean {
            if (item is String) {
                if (_stringItems[item] === undefined) return false;
                delete _stringItems[item];

            } else {
                if (_items[item] === undefined) return false;
                delete _items[item];
            }

            _size--;
            return true;
        }

        public function clear() : Boolean {
            if (!_size) return false;
            _items = new Dictionary();
            _stringItems = new Object();
            _size = 0;
            return true;
        }
    }
}