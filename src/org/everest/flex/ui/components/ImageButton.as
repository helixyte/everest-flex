package org.everest.flex.ui.components
{
    import spark.components.Image;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.filters.*;

    /**
     * The ImageButton extends the Image class. Filters are applied to give
     * the user a visual feedback and to prevent having to provid an image asset
     * for each state.
     * When the Imagebutton is disabled its colors turn to gray
     */
    public class ImageButton extends Image
    {
        public function ImageButton()
        {
            super();
            buttonMode = true;

            addEventListener("enabledChanged",enableHandler);
            addEventListener(MouseEvent.CLICK,clickHandler);
            addEventListener(MouseEvent.MOUSE_OVER,overHandler);
            addEventListener(MouseEvent.MOUSE_OUT,outHandler);
        }

        /**
         * Change colors to normal/gray when the button is enable/disabled
         */
        private function enableHandler(event:Event):void
        {
            // define the color filter
            var matrix:Array = new Array();

            if (!enabled)
            {
                matrix = matrix.concat([0.31, 0.61, 0.08, 0, 0]); 	// red
                matrix = matrix.concat([0.31, 0.61, 0.08, 0, 0]); 	// green
                matrix = matrix.concat([0.31, 0.61, 0.08, 0, 0]); 	// blue
                matrix = matrix.concat([0, 0, 0, 1, 0]); 			// alpha
            }
            else
            {
                matrix = matrix.concat([1, 0, 0, 0, 0]); 	// red
                matrix = matrix.concat([0, 1, 0, 0, 0]); 	// green
                matrix = matrix.concat([0, 0, 1, 0, 0]); 	// blue
                matrix = matrix.concat([0, 0, 0, 1, 0]); 	// alpha
            }

            var filter:BitmapFilter = new ColorMatrixFilter(matrix);

            // apply color filter
            filters = new Array(filter) ;

            // activate or disacivate the button mode
            buttonMode = enabled ;

        }

        private function overHandler(event:Event):void
        {
            var matrix:Array = new Array();
                matrix = matrix.concat([1.3, 0, 0, 0, 0]); 	// red
                matrix = matrix.concat([0, 1.3, 0, 0, 0]); 	// green
                matrix = matrix.concat([0, 0, 1.3, 0, 0]); 	// blue
                matrix = matrix.concat([0, 0, 0, 1.3, 0]); 	// alpha

            var filter:BitmapFilter = new ColorMatrixFilter(matrix);
            filters = new Array(filter) ;
        }

        private function outHandler(event:Event):void
        {
            var matrix:Array = new Array();
            matrix = matrix.concat([1, 0, 0, 0, 0]); 	// red
            matrix = matrix.concat([0, 1, 0, 0, 0]); 	// green
            matrix = matrix.concat([0, 0, 1, 0, 0]); 	// blue
            matrix = matrix.concat([0, 0, 0, 1, 0]); 	// alpha

            var filter:BitmapFilter = new ColorMatrixFilter(matrix);
            filters = new Array(filter) ;
        }

        protected function clickHandler(event:MouseEvent):void
        {
            if (!enabled)
            {
                event.stopImmediatePropagation();
                return;
            }

        }

    }
}