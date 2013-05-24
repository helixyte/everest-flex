package org.everest.flex.utils
{
    import org.everest.flex.model.MembersCollection;

    import mx.collections.ArrayCollection;
    import mx.rpc.xml.XMLEncoder;

    /**
     * Lightly modified version of the XMLEncoder which was sometimes not encoding
     * data the way it was expected.
     */
    public class PatchedXMLEncoder extends XMLEncoder
    {
        public function PatchedXMLEncoder()
        {
            super();
        }


        public override function getValue(parent:*, name:*):*
        {

            /**
             * This is a patch to avoid having empty link elements in the serialized
             * MemberCollection.
             */
            if ((parent is MembersCollection)&&(name.localName == "link"))
            {
                return parent["link"];

            }

            return super.getValue(parent, name);

        }

        /**
         * choice:
         *    (annotation?, (element | group | choice | sequence | any)*)
         * 
         * @private
         */
        public override function encodeChoice(definition:XML, parent:XMLList, name:QName, value:*, isRequired:Boolean = true):Boolean
        {
            var maxOccurs:uint = getMaxOccurs(definition);
            var minOccurs:uint = getMinOccurs(definition);
            
            // If maxOccurs is 0 this choice must not be present.
            // If minOccurs == 0 the choice is optional so it can be omitted if
            // a value was not provided.
            if (maxOccurs == 0)
                return false;
            if (value == null && minOccurs == 0)
                return true;
            
            var choiceElements:XMLList = definition.elements();
            var choiceSatisfied:Boolean = true;
            
            // We don't enforce occurs bounds on the choice element itself. Since all
            // child elements of the choice definition would be properties on the
            // value object, simply looping through the choice children once would
            // encode the values that apply to each of the child elements.

            // An empty choice is satisfied by default, but if there are choiceElements
            // we need to start out with choiceSatisfied = false
            if (choiceElements.length() > 0)
                choiceSatisfied = false;
            
            for each (var childDefinition:XML in choiceElements)
            {
                if (childDefinition.name() == constants.elementTypeQName)
                {
                    // <element>
                    choiceSatisfied = encodeGroupElement(childDefinition, parent,
                        name, value, false);
                }
                else if (childDefinition.name() == constants.sequenceQName)
                {
                    // <sequence>
                    choiceSatisfied = encodeSequence(childDefinition, parent,
                        name, value, false);
                }
                else if (childDefinition.name() == constants.groupQName)
                {
                    // <group>
                    choiceSatisfied = encodeGroupReference(childDefinition, parent,
                        name, value, false);
                }
                else if (childDefinition.name() == constants.choiceQName)
                {
                    // <choice>
                    choiceSatisfied = encodeChoice(childDefinition, parent,
                        name, value, false);
                }
                else if (childDefinition.name() == constants.anyQName)
                {
                    // <any>
                    choiceSatisfied = encodeAnyElement(childDefinition, parent,
                        name, value, false);
                }
                
                // Patch to stop encoding more attributes after the choice 
                // has been satisfied with at least minOccurs number of elements.
                if (choiceSatisfied && parent.length() >= minOccurs)
                {
                    return choiceSatisfied;
                }
            }
            
            return choiceSatisfied;
        }
        
        /**
         * complexContent:
         *   restriction:
         *     (annotation?, (group | all | choice | sequence)?, ((attribute | attributeGroup)*, anyAttribute?), (assert | report)*)
         *
         * @private
         */ 
        public override function encodeComplexRestriction(restriction:XML, parent:XML, name:QName, value:*):void
        {
            var baseName:String = getAttributeFromNode("base", restriction);
            if (baseName == null)
                throw new Error ("A complexContent restriction must declare a base type.");

            var baseType:QName = schemaManager.getQNameForPrefixedName(baseName, restriction);

            // complexContent base type must be a complexType
            var baseDefinition:XML = schemaManager.getNamedDefinition(baseType, constants.complexTypeQName);
            if (baseDefinition == null)
                throw new Error("Cannot find base type definition '" + baseType + "'");

            // FIXME: Should we care if base type is marked final?

            // First encode all of the properties of the base type
            encodeComplexType(baseDefinition, parent, name, value);

            // Then release the scope of the base type definition
            schemaManager.releaseScope();

            // FIXME: Validate complex restriction based on the base type definition
            // complexContent base type must be a complexType
            // var baseDefinition:XML = schemaManager.getNamedDefinition(baseType, constants.complexTypeQName);
            // if (baseDefinition == null)
            //    throw new Error("Cannot find base type definition '" + baseType + "'");

            // FIXME: Should we care if base type is marked final?

            var childDefinitions:XMLList = restriction.elements();
            var children:XMLList = parent.elements();
            for each (var childDefinition:XML in childDefinitions)
            {
                if (childDefinition.name() == constants.sequenceQName)
                {
                    // <sequence>
                    encodeSequence(childDefinition, children, name, value);
                }
                else if (childDefinition.name() == constants.groupQName)
                {
                    // <group>
                    encodeGroupReference(childDefinition, children, name, value);
                }
                else if (childDefinition.name() == constants.allQName)
                {
                    // <all>
                    encodeAll(childDefinition, children, name, value);
                }
                else if (childDefinition.name() == constants.choiceQName)
                {
                    // <choice>
                    encodeChoice(childDefinition, children, name, value);
                }
                else if (childDefinition.name() == constants.attributeQName)
                {
                    // <attribute>
                    encodeAttribute(childDefinition, parent, name, value, restriction);
                }
                else if (childDefinition.name() == constants.attributeGroupQName)
                {
                    // <attributeGroup>
                    encodeAttributeGroup(childDefinition, parent, name, value, restriction);
                }
                else if (childDefinition.name() == constants.anyAttributeQName)
                {
                    // <anyAttribute>
                    encodeAnyAttribute(childDefinition, parent, name, value, restriction);
                }
            }
            parent.setChildren(children);
        }

        public override function encodeXSINil(definition:XML, name:QName, value:*, isRequired:Boolean = true):XML
        {
            // Check for nillable in the definition only if strictNillability is true.
            // Otherwise assume nillable=true.
            var nillable:Boolean = true;
            if (strictNillability)
            {
                if (definition != null)
                    nillable = definition.@nillable.toString() == "true" ? true : false;
                else
                    nillable = false; //XML schema default for nillable
            }

            var item:XML;

            // <element fixed="...">
            // Fixed is forbidden when nillable="true". We enforce that only if
            // strictNillability==true. Otherwise we take the fixed value if it
            // is provided.
            var fixedValue:String = getAttributeFromNode("fixed", definition);
            if (!(strictNillability && nillable) && fixedValue != null)
            {
                item = createElement(name);
                setValue(item, schemaManager.marshall(fixedValue, schemaManager.schemaDatatypes.stringQName));
                return item;
            }

            // After we are done with fixed, which can replace even a non-null value,
            // we only care about cases where value is null, so we can return otherwise.
            if (value != null)
                return null;

            // <element default="...">
            var defaultValue:String = getAttributeFromNode("default", definition);
            if (value == null && defaultValue != null)
            {
                item = createElement(name);
                setValue(item, schemaManager.marshall(defaultValue, schemaManager.schemaDatatypes.stringQName));
                return item;
            }

            // If null or undefined, and nillable, we set xsi:nil="true"
            // and return the element
            //            if (nillable && value === null && isRequired == true)
            //            {
            //                item = createElement(name);
            //                setValue(item, null);
            //                return item;
            //            }

            return null;
        }
    }
}