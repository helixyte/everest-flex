package org.everest.flex.ui.components
{
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    
    import mx.core.UIComponent;
    import mx.events.SandboxMouseEvent;
    
    import org.everest.flex.ui.skins.ResizableTitleWindowSkin;
    
    import spark.components.TitleWindow;

    /**
     *  A normal spark TitleWindow with a resize handle.
     */
    public class ResizableTitleWindow extends TitleWindow
    {
        /**
         *  Constructor.
         */
        public function ResizableTitleWindow()
        {
            super();
        }


        private var clickOffset:Point;


        [SkinPart("false")]

        /**
         *  The skin part that defines the area where
         *  the user may drag to resize the window.
         */
        public var resizeHandle:UIComponent;

        /**
         *  @private
         */
        override protected function partAdded(partName:String, instance:Object) : void
        {
            super.partAdded(partName, instance);

            if (instance == resizeHandle)
            {
                resizeHandle.addEventListener(MouseEvent.MOUSE_DOWN, resizeHandle_mouseDownHandler);
            }
        }

        /**
         *  @private
         */
        override protected function partRemoved(partName:String, instance:Object):void
        {
            if (instance == resizeHandle)
            {
                resizeHandle.removeEventListener(MouseEvent.MOUSE_DOWN, resizeHandle_mouseDownHandler);
            }

            super.partRemoved(partName, instance);
        }

        private var prevWidth:Number;
        private var prevHeight:Number;

        protected function resizeHandle_mouseDownHandler(event:MouseEvent):void
        {
            if (enabled && isPopUp && !clickOffset)
            {
                clickOffset = new Point(event.stageX, event.stageY);
                prevWidth = width;
                prevHeight = height;

                var sbRoot:DisplayObject = systemManager.getSandboxRoot();

                sbRoot.addEventListener(
                    MouseEvent.MOUSE_MOVE, resizeHandle_mouseMoveHandler, true);
                sbRoot.addEventListener(
                    MouseEvent.MOUSE_UP, resizeHandle_mouseUpHandler, true);
                sbRoot.addEventListener(
                    SandboxMouseEvent.MOUSE_UP_SOMEWHERE, resizeHandle_mouseUpHandler)
            }
        }


        protected function resizeHandle_mouseMoveHandler(event:MouseEvent):void
        {
            event.stopImmediatePropagation();

            if (!clickOffset)
            {
                return;
            }

            width = prevWidth + (event.stageX - clickOffset.x);
            width = (width < minWidth) ? minWidth : width;

            height = prevHeight + (event.stageY - clickOffset.y);
            height = (height < minHeight) ? minHeight : height;
            event.updateAfterEvent();
        }


        protected function resizeHandle_mouseUpHandler(event:Event):void
        {
            clickOffset = null;
            prevWidth = NaN;
            prevHeight = NaN;

            var sbRoot:DisplayObject = systemManager.getSandboxRoot();

            sbRoot.removeEventListener(
                MouseEvent.MOUSE_MOVE, resizeHandle_mouseMoveHandler, true);
            sbRoot.removeEventListener(
                MouseEvent.MOUSE_UP, resizeHandle_mouseUpHandler, true);
            sbRoot.removeEventListener(
                SandboxMouseEvent.MOUSE_UP_SOMEWHERE, resizeHandle_mouseUpHandler);
        }

        override public function stylesInitialized():void {

            super.stylesInitialized();

            this.setStyle("skinClass",Class(ResizableTitleWindowSkin));

        }
    }
}