package org.everest.flex.ui.components
{
    import flashx.textLayout.operations.CutOperation;
    import flashx.textLayout.operations.DeleteTextOperation;
    import flashx.textLayout.operations.FlowOperation;

    import mx.collections.ArrayCollection;
    import mx.collections.IList;

    import spark.components.ComboBox;
    import spark.events.TextOperationEvent;

    /**
     * A combo box with an auto complete behaviour.
     *
     * @author rothe
     */
    public class FilterComboBox extends ComboBox
    {

        private var lastText:String = '';
        public function FilterComboBox()
        {
            super();
        }

        /**
         *  @private
         */
        protected override function textInput_changeHandler(event:TextOperationEvent):void
        {
            lastText = textInput.text;
            if(dataProvider){
                ArrayCollection(dataProvider).refresh();
            }

            if ((openOnInput) && (!isDropDownOpen))
            {
                    // Open the dropDown if it isn't already open
                    openDropDown();
            }
        }

        /**
         *  @private
         */
        override protected function commitProperties():void
        {
            super.commitProperties();

            if (textInput.text == '')
            {
                textInput.text = lastText;
            }
        }



        public override function set dataProvider(value:IList):void
        {
            super.dataProvider = value;

            //set our filter function
            var x:ArrayCollection = ArrayCollection(dataProvider);
                x.filterFunction = filter;

            //labelChanged = true;
            invalidateProperties();
        }

        protected function reset():void{

            this.textInput.text = "";
            //set our filter function
            var x:ArrayCollection = ArrayCollection(dataProvider);
            x.refresh();


            if(dataProvider.length>0){
                selectedIndex = 0;
            } else {
                this.selectedItem = null;
            }



        }


        public function filter(item:Object):Boolean
        {
            if(item == null) return false;
            if((textInput.text.length <  1)||(textInput.text == "All")) return true;

            var needle:String = textInput.text.toLowerCase();
            var label:String = itemToLabel(item).toLowerCase();
            var res:int = 0;

            for each(var n:String in needle.split(" ")){
                var pos:int = label.search(n);

                //all terms must match (logic and)
                res = Math.min(res, pos);

                if(res < 0){
                    return false;
                }

            }

            return res >=0;
        }

        public function get text():String{
            return this.textInput.text;
        }
    }
}