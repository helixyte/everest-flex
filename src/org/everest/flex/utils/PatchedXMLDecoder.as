package org.everest.flex.utils
{
    import org.everest.flex.interfaces.INavigationLink;
    import org.everest.flex.model.Link;
    import org.everest.flex.model.MembersCollection;

    import mx.rpc.xml.ContentProxy;
    import mx.rpc.xml.DecodingContext;
    import mx.rpc.xml.XMLDecoder;
    import mx.utils.ObjectUtil;

    /**
     *	Andy McIntosh - April 10, 2009
     *
     *  Work around for #SDK-17271 where XMLDecoder incorrectly
     *  decodes elements that do not contain sub-elements.
     *
     * 	(https://bugs.adobe.com/jira/browse/SDK-17271)
     *
     * 	Added second condition below that checks to see if the value is
     *  an empty node which may have attributes that need decoded,
     *  by testing if the inner value of the node is blank.
     */
    public class PatchedXMLDecoder extends XMLDecoder
    {
        public function PatchedXMLDecoder()
        {
            super();
        }

        public override function setValue(parent:*, name:*, value:*, type:Object=null):void
        {
            /**
             * prevent the bug of an empty array beeing added in each array
             */
            if (mx.rpc.xml.TypeIterator.isIterable(parent) &&
                mx.rpc.xml.TypeIterator.isIterable(value))
            {
                return;
            }

            super.setValue(parent, name, value, type);
        }
        override protected function parseValue(name:*, value:XMLList):*
        {
            var result:* = value;
            trace(value);


            // We unwrap simple content and get the value as a String
            var isSimple:Boolean = value.hasSimpleContent();
            if (isSimple && value[0] && value[0].toString() != "")
            {
                if (isXSINil(value))
                    result = null;
                else
                    result = value.toString();
            }
                // Otherwise, as a convenience we unwrap an XMLList containing only one
                // XML node...
            else if (value.length() == 1)
            {
                result = value[0];
            }

            return result;
        }



        /**
         * complexContent:
         *   extension:
         *     (annotation?, ((group | all | choice | sequence)?, ((attribute | attributeGroup)*, anyAttribute?), (assert | report)*))
         *
         * @private
         */
        public override function decodeComplexRestriction(definition:XML, parent:*, name:QName, value:*):void
        {
            var context:mx.rpc.xml.DecodingContext = new mx.rpc.xml.DecodingContext();

            // We need to remember that the base and the extension definitions are
            // really sibling elements, although they are not visible from each other's
            // definitions.
            context.hasContextSiblings = true;

            var baseName:String = getAttributeFromNode("base", definition);
            if (baseName == null)
                throw new Error ("A complexContent extension must declare a base type.");

            var baseType:QName = schemaManager.getQNameForPrefixedName(baseName, definition);

            // complexContent base type must be a complexType
            var baseDefinition:XML = schemaManager.getNamedDefinition(baseType, constants.complexTypeQName);
            if (baseDefinition == null)
                throw new Error("Cannot find base type definition '" + baseType + "'");

            // FIXME: Should we care if base type is marked final?

            // Fix for SDK-16891. It seems the sequence order for base types are not
            // honored by some web services so we allow lax processing to find them.
            var originalLaxSequence:Boolean = context.laxSequence;
            context.laxSequence = true;

            // First encode all of the properties of the base type
            decodeComplexType(baseDefinition, parent, name, value, null, context);

            // Then release the scope of the base type definition
            schemaManager.releaseScope();

            var childElements:XMLList = definition.elements();
            var valueElements:XMLList = new XMLList();
            if (value is XML)
                valueElements = (value as XML).elements();
            else if (value is XMLList)
                valueElements = value;

            for each (var childDefinition:XML in childElements)
            {
                if (childDefinition.name() == constants.sequenceQName)
                {
                    // <sequence>
                    decodeSequence(childDefinition, parent, name, valueElements, context);
                }
                else if (childDefinition.name() == constants.groupQName)
                {
                    // <group>
                    decodeGroupReference(childDefinition, parent, name, valueElements, context);
                }
                else if (childDefinition.name() == constants.allQName)
                {
                    // <all>
                    decodeAll(childDefinition, parent, name, valueElements, context);
                }
                else if (childDefinition.name() == constants.choiceQName)
                {
                    // <choice>
                    decodeChoice(childDefinition, parent, name, valueElements, context);
                }
                else if (childDefinition.name() == constants.attributeQName)
                {
                    // <attribute>
                    decodeAttribute(childDefinition, parent, value);
                }
                else if (childDefinition.name() == constants.attributeGroupQName)
                {
                    // <attributeGroup>
                    decodeAttributeGroup(childDefinition, parent, value);
                }
                else if (childDefinition.name() == constants.anyAttributeQName)
                {
                    // <anyAttribute>
                    decodeAnyAttribute(childDefinition, parent, value);
                }
            }

            // Finally, reset to the original laxSequence setting
            context.laxSequence = originalLaxSequence;
        }


        /**
         * choice:
         *    (annotation?, (element | group | choice | sequence | any)*)
         *
         * @param context A DecodingContext instance. Used to keep track
         * of the index of the element being processed in the current model
         * group.
         *
         * @private
         */
        public override function decodeChoice(definition:XML, parent:*, name:QName, valueElements:XMLList,
                                     context:DecodingContext = null, isRequired:Boolean = true):Boolean
        {
            if (context == null)
                context = new DecodingContext();
            var maxOccurs:uint = getMaxOccurs(definition);
            var minOccurs:uint = getMinOccurs(definition);

            // If maxOccurs is 0 this choice must not be present.
            if (maxOccurs == 0)
                return false;
            // If minOccurs == 0 the choice is optional so it can be omitted if
            // a value was not provided.
            if (valueElements == null && minOccurs == 0)
                return true;

            var choiceElements:XMLList = definition.elements();
            // If no elements in the choice definition, we can say the choice was
            // satisfied no matter what value is provided.
            if (choiceElements.length() == 0)
                return true;

            var choiceSatisfied:Boolean;
            var lastIndex:uint;
            var choiceOccurs:uint;

            for (choiceOccurs = 0; choiceOccurs < maxOccurs; choiceOccurs++)
            {
                lastIndex = context.index + 0;
                choiceSatisfied = false;
                //We loop through the possible choices until one of them consumes
                //at least one of the valueElements. However, any of the choiceElements
                //with minOccurs=0 could potentially satisfy the choice.
                for each (var childDefinition:XML in choiceElements)
                {
                    if (childDefinition.name() == constants.elementTypeQName)
                    {
                        // <element>
                        /**
                         * PATCHED TO AN UNLAZY CHOICE
                         */
                        choiceSatisfied =  decodeGroupElement(childDefinition, parent, valueElements, context, false);
                        if (context.index > lastIndex) break;
                    }
                    else if (childDefinition.name() == constants.sequenceQName)
                    {
                        // <sequence>
                        choiceSatisfied =  decodeSequence(childDefinition, parent, name, valueElements, context, false);
                        if (context.index > lastIndex) break;
                    }
                    else if (childDefinition.name() == constants.groupQName)
                    {
                        // <group>
                        choiceSatisfied =  decodeGroupReference(childDefinition, parent, name, valueElements, context, false);
                        if (context.index > lastIndex) break;
                    }
                    else if (childDefinition.name() == constants.choiceQName)
                    {
                        // <choice>
                        choiceSatisfied =  decodeChoice(childDefinition, parent, name, valueElements, context, false);
                        if (context.index > lastIndex) break;
                    }
                    else if (childDefinition.name() == constants.anyQName)
                    {
                        // <any>
                        choiceSatisfied =  decodeAnyElement(childDefinition, parent, name, valueElements, context, false);
                        if (context.index > lastIndex) break;
                    }
                }
                if (!choiceSatisfied)
                {
                    break;
                }
            }

            if (choiceOccurs < minOccurs)
            {
                if (isRequired && strictOccurenceBounds)
                    throw new Error("Value supplied for choice "+ name.toString() +" occurs " +
                        choiceOccurs + " times which falls short of minOccurs " + minOccurs + ".");
                else
                    return false;
            }

            return true;
        }



//        /**
//         * Used to decode a local element definition. This element may also simply
//         * refer to a top level element.
//         *
//         * Element content:
//         * (annotation?, ((simpleType | complexType)?, (unique | key | keyref)*))
//         *
//         * FIXME: Support substitutionGroup, block and redefine?
//         * FIXME: Do we care about abstract or final?
//         *
//         * FIXME: Remove isRequired if not necessary...
//         *
//         * @private
//         */
//        public override function decodeGroupElement(definition:XML, parent:*, valueElements:XMLList,
//                                           context:DecodingContext = null, isRequired:Boolean = true, hasSiblings:Boolean = true):Boolean
//        {
//            if (context == null)
//                context = new DecodingContext();
//
//            // <element minOccurs="..." maxOccurs="..."> occur on the local element,
//            // not on a referent, so we capture this information first.
//            var maxOccurs:uint = getMaxOccurs(definition);
//            var minOccurs:uint = getMinOccurs(definition);
//
//            // If the maximum occurence is 0 this element must not be present.
//            if (maxOccurs == 0)
//                return true;
//
//            // <element ref="..."> may be used to point to a top-level element definition
//            var ref:QName;
//            if (definition.attribute("ref").length() == 1)
//            {
//                ref = schemaManager.getQNameForPrefixedName(definition.@ref, definition, true);
//                definition = schemaManager.getNamedDefinition(ref, constants.elementTypeQName);
//                if (definition == null)
//                    throw new Error("Cannot resolve element definition for ref '" + ref + "'");
//            }
//
//            var elementName:String = definition.@name.toString();
//            var elementQName:QName = schemaManager.getQNameForElement(elementName, getAttributeFromNode("form", definition));
//
//            // Now that we've resolved the real element name, get the applicable
//            // values from the given valueElements
//            var applicableValues:XMLList = getApplicableValues(parent, valueElements,
//                elementQName, context, maxOccurs);
//
//            // If we have a single xml node with that name and it has the xsi:nil
//            // attribute set to true, we set a null
//            if (applicableValues.length() == 1 && isXSINil(applicableValues[0]))
//            {
//                setValue(parent, elementQName, null);
//                context.index++;
//
//                // If we found our element by reference, we now release the schema scope
//                if (ref != null)
//                    schemaManager.releaseScope();
//
//                return true;
//            }
//
//            // If maxOccurs > 1 we always create an array, even if it will be empty or null.
//            if (maxOccurs > 1)
//            {
//                // If we have a type, provide this when creating an array in case
//                // a custom strongly typed collection class has been registered.
//                var typeAttribute:String = getAttributeFromNode("type", definition);
//                var typeQName:QName;
//                if (typeAttribute != null)
//                {
//                    typeQName = schemaManager.getQNameForPrefixedName(typeAttribute, definition);
//                }
//
//                var emptyArray:* = createIterableValue(typeQName);
//
//                // If this is not the only property in the definition, we assign the
//                // array on a named property on the parent.
//                if (hasSiblings)
//                {
//                    setValue(parent, elementQName, emptyArray, typeQName);
//                }
//                else
//                {
//                    // If this is a "wrapped array", the iterable value should be assigned
//                    // as the value of the parent itself. However, we only replace
//                    // the parent if it hasn't been created already. (It could be
//                    // created if the parent QName has a registered collectionClass
//                    // in the SchemaTypeRegistry - see bug FB-11399).
//                    if (!(parent is ContentProxy && parent.object_proxy::content != undefined))
//                    {
//                        setValue(parent, null, emptyArray, typeQName);
//                    }
//                }
//            }
//
//            // If minOccurs == 0 the element is optional so we can omit it if
//            // a value was not provided.
//            if (applicableValues.length() == 0)
//            {
//                // If we found our element by reference, we now release the schema scope
//                if (ref != null)
//                    schemaManager.releaseScope();
//
//                if (minOccurs == 0)
//                    return true;
//                else
//                    return false;
//            }
//
//            var element:*;
//
//            // We treat maxOccurs="1" as a special case and not check the
//            // occurence because we need to pass through values to SOAP
//            // encoded Arrays which do not rely on minOccurs/maxOccurs
//            if (maxOccurs == 1)
//            {
//                element = decodeElementTopLevel(definition, elementQName, parseValue(elementQName, applicableValues));
//                setValue(parent, elementQName, element);
//                context.index++;
//            }
//            else if (maxOccurs > 1)
//            {
//                // If maxOccurs is greater than 1 then we would expect an
//                // Array of values
//                if (applicableValues.length() < minOccurs)
//                {
//                    // If we found our element by reference, we now release the schema scope
//                    if (ref != null)
//                        schemaManager.releaseScope();
//
//                    if (strictOccurenceBounds)
//                        throw new Error("Value supplied for element '" + elementQName +
//                            "' occurs " + applicableValues.length() + " times which falls short of minOccurs " +
//                            minOccurs + ".");
//                    else
//                        return false;
//                }
//
//                if (applicableValues.length() > maxOccurs)
//                {
//                    // If we found our element by reference, we now release the schema scope
//                    if (ref != null)
//                        schemaManager.releaseScope();
//
//                    if (strictOccurenceBounds)
//                        throw new Error("Value supplied for element of type '" + elementQName +
//                            "' occurs " + applicableValues.length() + " times which exceeds maxOccurs " +
//                            maxOccurs + ".");
//                    else
//                        return false;
//                }
//
//                var elementOccurs:uint;
//                for (elementOccurs = 0; elementOccurs < maxOccurs
//                    && elementOccurs < applicableValues.length();
//                    elementOccurs++)
//                {
//                    var item:XML = applicableValues[elementOccurs];
//
//                    element = decodeElementTopLevel(definition, elementQName, item);
//                    setValue(parent, elementQName, element);
//                    context.index++;
//                }
//            }
//
//            // If we found our element by reference, we now release the schema scope
//            if (ref != null)
//                schemaManager.releaseScope();
//
//            return true;
//        }
    }
}