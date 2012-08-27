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