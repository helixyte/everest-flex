package org.everest.flex.model
{
    [Bindable]
    /**
     * Entity that holds a label and a value to be used for selection in ui
     * elements.
     *
     * @author rothe
     */
    public class SelectionChoice
    {
        public var label:String;
        public var value:*;

        /**
         * Label and a value to be used for selection.
         *
         * @param label display label
         * @param value an associated value object
         *
         */
        public function SelectionChoice(label:String=null, value:*=null)
        {
            this.label = label;
            this.value = value;
        }
    }
}