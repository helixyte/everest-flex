package org.everest.flex.utils
{
    import flash.events.IEventDispatcher;
    import flash.utils.getQualifiedClassName;

    /**
     * Simple utility used in mate event maps to trace infomation while debugging.
     */
    public class TraceUtils
    {
        public static const START_HANDLER_MSG:String = "Start of actions";
        public static const END_HANDLER_MSG:String = "End of actions";
        public static const START_INJECTOR_MSG:String = "Start of injections";
        public static const END_INJECTOR_MSG:String = "End of injections";

        public static function traceMessage(message:String, target:*,
                                            dispatcher:IEventDispatcher):void
        {
            var msg:String = '* ' + getClassName(dispatcher) + ' :: ' + message;
            var targetName:String;
            if (target is String) {
                targetName = target;
            }
            else {
                targetName = getClassName(target);
            }
            msg += ' for ' + targetName;
            trace(msg);
        }

        private static function getClassName(object:*):String
        {
            return getQualifiedClassName(object).split("::")[1];
        }
    }
}