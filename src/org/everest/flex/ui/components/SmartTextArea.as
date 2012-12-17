package org.everest.flex.ui.components
{
    import com.adobe.utils.StringUtil;

    import flash.desktop.Clipboard;
    import flash.desktop.ClipboardFormats;

    import flashx.textLayout.container.ScrollPolicy;
    import flashx.textLayout.operations.PasteOperation;
    import flashx.textLayout.operations.SplitParagraphOperation;

    import org.everest.flex.interfaces.IFilterInputComponent;
    import org.everest.flex.query.Criteria;
    import org.everest.flex.query.Criterion;

    import spark.components.TextArea;
    import spark.events.TextOperationEvent;

    /**
     * A spark text area with a special feature to convert new-line characters
     * in comma separated values. It furthermore adds support for filtering by
     * implementing IFilterInputComponent
     *
     * @author rothe
     */
    public class SmartTextArea extends TextArea implements IFilterInputComponent
    {

        private const NEWLINE:String = "\n";
        private const CARRIAGE_RETURN:String = "\r";
        private const SEPARATOR:String = ",";
        private const RESIZE_FACTOR:Number = 1.3;

        private var _criteria:Criteria;
        private var _operator:String;

        private var initialHeight:Number;


        public function SmartTextArea()
        {
            super();
            addEventListener(TextOperationEvent.CHANGING, 
                             onTextChangingHandler);
            addEventListener(TextOperationEvent.CHANGE, 
                             onTextChangedHandler);

            setStyle("verticalScrollPolicy", ScrollPolicy.AUTO);
            percentWidth = 100;
            heightInLines = 1;
        }

        /**
         * Allows to programmatically change the text and the associated 
         * criteria.
         *
         * @param value
         */
        public function set textValue(value:String):void
        {
            super.text = value;
            onTextChangedHandler(null);
        }

        private function onTextChangingHandler(event:TextOperationEvent):void
        {
            if (event.operation is PasteOperation) {
                event.preventDefault();
                insertNewText(
                    getClipboardText(),
                    PasteOperation(event.operation).absoluteStart,
                    PasteOperation(event.operation).absoluteEnd
                );
            }
            else if (event.operation is SplitParagraphOperation) {
                event.preventDefault();
                insertNewText(
                    SEPARATOR,
                    SplitParagraphOperation(event.operation).absoluteStart,
                    SplitParagraphOperation(event.operation).absoluteEnd
                );
            }
            dispatchEvent(new TextOperationEvent(TextOperationEvent.CHANGE));
        }

        private function getClipboardText():String
        {
            var txt:String = String(
                Clipboard.generalClipboard.getData(
                                        ClipboardFormats.TEXT_FORMAT)
            );
            var delim:String;
            if (txt.indexOf(CARRIAGE_RETURN) != -1) {
                delim = CARRIAGE_RETURN;
            }
            else {
                delim = NEWLINE;
            }
            var lines:Array = txt.split(delim);
            return lines.join(SEPARATOR);
        }

        private function insertNewText(txt:String, start:int, end:int):void
        {
            var leftPart:String = text.substring(0, start);
            var rightPart:String = text.substring(end, text.length);
            text = leftPart + txt + rightPart;
            var insertionPoint:int = start + txt.length;
            selectRange(insertionPoint, insertionPoint);
        }

        public function set operator(value:String):void{
            this._operator = value;
        }

        public function set criteria(crit:Criteria):void{

            trace("criteria updated");
            this._criteria = crit;

            var criterion:Criterion = crit.get(name,_operator);

            if(criterion != null){
                this.text = criterion.getValueAsString();
            } else {
                this.text = "";
            }

        }

        [Bindable]
        public function get criteria():Criteria{

            return this._criteria;
        }

        protected function onTextChangedHandler(event:TextOperationEvent):void
        {
            //update criterion in filter criteria
            if(_criteria != null){
                if(text.length > 0){
                var values:Array = StringUtil.trim(text).split(',');
                    _criteria.put(new Criterion(name, _operator, values));
                }else{
                    _criteria.remove(name, _operator);
                }
            }
        }

    }
}