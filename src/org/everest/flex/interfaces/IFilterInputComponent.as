package org.everest.flex.interfaces
{
    import org.everest.flex.query.Criteria;

    /**
     * Filter Components are UI Form elements that can bind to a criterion in an associated criteria model.
     * They will update the model with a specific criterion that this component is responsible for.
     *
     * @author rothe
     */
    public interface IFilterInputComponent
    {

        /**
         * Defines the name for the query term (name:operator:value)
         *
         * @param value
         */
         function set name(value:String):void;

        /**
         * Defines the operator in the query term e.g. 'equal-to'
         * @param value
         */
         function set operator(value:String):void;

         /**
          * Set a list of Criterion objects
          * @param crit
          */
         function set criteria(crit:Criteria):void;

         /**
          * Get a list of Criterion objects
          * @param crit
          */
         function get criteria():Criteria;
    }
}