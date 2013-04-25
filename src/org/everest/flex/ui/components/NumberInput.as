package org.everest.flex.ui.components
{
    import com.adobe.utils.StringUtil;
    import org.everest.flex.interfaces.IFilterInputComponent;
    import org.everest.flex.query.Criteria;
    import org.everest.flex.query.Criterion;

    import mx.events.FlexEvent;

    import spark.components.TextInput;
    import spark.events.TextOperationEvent;


    /**
     * A text input field that is restriced to numbers. It furthermore encapsulates
     * support for filtering by implementing IFilterInputComponent
     *
     * @author rothe
     */
    public class NumberInput extends TextInput implements IFilterInputComponent
    {

        private var _conversionFactor:Number = 0;
        private var _criteria:Criteria;
        private var _operator:String;



        public function NumberInput()
        {
            super();
            setStyle("restrict", '0-9');
            addEventListener(TextOperationEvent.CHANGE, changeHandler);
        }

        /**
         * The factor is applied to convert between the actual search value
         * and the input box contents.
         *
         * @param factor
         * @return
         *
         */
        public function set conversionFactor(factor:Number):void{
            this._conversionFactor = factor;
        }

        public function set operator(value:String):void{
            this._operator = value;
        }

        public function set criteria(crit:Criteria):void{

            this._criteria = crit;

            var criterion:Criterion = crit.get(name, _operator);

            if(criterion != null){

                var val:Number = Number(criterion.getValueAsString());

                if(_conversionFactor != 0){
                    val = val * _conversionFactor;
                }

                this.text = String(val);
            } else {
                this.text = "";
            }

        }

        [Bindable]
        public function get criteria():Criteria{

            return this._criteria;
        }

		public function set textValue(value:String):void
		{
			super.text = value;
			changeHandler(null);
		}
		
        protected function changeHandler(event:TextOperationEvent):void
        {
            if(text.length == 0){

                _criteria.remove(name, _operator);

            }else{
                var val:Number = Number(text);

                if(_conversionFactor != 0){
                    val = val / _conversionFactor;
                }

                _criteria.put(new Criterion(name, _operator, [val]));
            }
        }
    }
}