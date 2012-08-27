package org.everest.flex.ui.components
{
    import flash.events.Event;

    import mx.core.IFlexDisplayObject;

    import org.everest.flex.interfaces.IFilterInputComponent;
    import org.everest.flex.query.Criteria;
    import org.everest.flex.query.Criterion;

    import spark.components.RadioButton;
    import spark.components.RadioButtonGroup;

    /**
     * A radio group that encapsulates support for filtering by implementing the
     * IFilterInputComponent
     *
     * @author rothe
     */
    public class QueryRadioGroup extends RadioButtonGroup implements IFilterInputComponent
    {
        private var _criteria:Criteria;
        private var _operator:String;
        private var _name:String;

        public function QueryRadioGroup(document:IFlexDisplayObject=null)
        {
            super(document);
            addEventListener(Event.CHANGE, changeHandler);
        }

        public function set name(value:String):void{
            this._name = value;
        }

        public function set operator(value:String):void{
            this._operator = value;
        }

        public function set criteria(crit:Criteria):void{

            this._criteria = crit;
            var criterion:Criterion = crit.get(_name, _operator);

            if(criterion != null){

                var value:String = criterion.getValueAsString();
                var len:int = numRadioButtons;

                for (var idx:int=0; idx<len; idx++) {
                    var rb:RadioButton = getRadioButtonAt(idx);
                    if(String(rb.value) == value){
                        rb.selected = true;
                    }else{
                        rb.selected = false;
                    }

                }
            }

        }

        [Bindable]
        public function get criteria():Criteria{

            return this._criteria;
        }

        protected function changeHandler(event:Event):void
        {
            if(selection.value == null){
                _criteria.remove(_name, _operator);
            }else{

                _criteria.put(new Criterion(_name, _operator, [selection.value]));
            }
        }
    }
}