package org.everest.flex.ui.validators
{
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;

    import mx.events.ValidationResultEvent;
    import mx.validators.Validator;

    [Bindable]
    /**
     * This class helps to have a better control over the form validation.  It
     * takes an array of form validators and executes them when the validateForm
     * method is invoked.
     *
     * @author rothe
     */
    public class FormValidator extends EventDispatcher
    {
        /**
         * bindable variable that is updated whenever one of the validation functions are called.
         */
        public var formIsValid:Boolean = false;

        /**
         * an list of flex form validators
         */
        [ArrayElementType("mx.validators.Validator")]
        public var validators:Array;

        private var focusedFormControl:DisplayObject;

        public function FormValidator(target:IEventDispatcher=null)
        {
            super(target);
        }

        /**
         * Invoke this method to run a list of validators that are injected to
         * this class.
         * The result is in the bindable formIsValid parameter.
         * @see #formIsValid
         *
         * @param event
         */
        public function validateForm(event:Event=null):void
        {
            formIsValid = true;

            if(event != null){
                focusedFormControl = event.target as DisplayObject;
            }

            for each( var validator:Validator in validators ){
                validate(validator);
            }
        }


        /**
         * As an alternative to a list of validators this method can be used
         * to validate the form against a single validator.
         *
         * @param validator the validator
         * @return teh result
         *
         */
        private function validate(validator:Validator):Boolean
        {
            var validatorSource:DisplayObject = validator.source as DisplayObject;
            var supressEvents:Boolean = validatorSource != focusedFormControl;
            var event:ValidationResultEvent = validator.validate(null, supressEvents)
            var currentControlIsValid:Boolean = event.type == ValidationResultEvent.VALID;

            formIsValid = formIsValid && currentControlIsValid;
            return currentControlIsValid;
        }
    }
}