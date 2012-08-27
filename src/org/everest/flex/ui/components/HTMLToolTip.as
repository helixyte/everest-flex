package org.everest.flex.ui.components
{
    import mx.controls.ToolTip;

    /**
     * Tooltip that allows html tags to format content (e.g. <b>..</b> etc.)
     *
     * @author rothe
     */
    public class HTMLToolTip extends ToolTip
    {
        public function HTMLToolTip()
        {
            super();
        }

        override protected function commitProperties():void{
            super.commitProperties();
            textField.htmlText = text;
        }
    }
}