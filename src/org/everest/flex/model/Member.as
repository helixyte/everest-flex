package org.everest.flex.model
{
    import flash.utils.getDefinitionByName;
    import flash.utils.getQualifiedClassName;
    
    import org.everest.flex.interfaces.INavigationLink;

    [Bindable]
    /**
     * Model object for a REST collection member. Can be specialized by an
     * everest application if needed. It can also just be a link from where the
     * member can be loaded.
     *
     * @author rothe
     */
    public class Member implements INavigationLink
    {
        public var title:String;
        public var selfLink:String;
        public var href:String;
        public var id:*;
        public var kind:String;

        public function Member(title:String, selfLink:String)
        {
            this.title = title;
            this.selfLink = selfLink;
            this.href = selfLink;
        }

        public function get link():INavigationLink{
            if ((href != null)&&(href.length > 0)){
                return new Link(title, href, Link.MEMBER, id);
            }
            return null;
        }

        public function set link(l:INavigationLink):void{
            this.title = l.title;
            this.href = l.href;
        }

        public function toString():String{
            return this.title;
        }
        
        public function blank():* {
            var ClassReference:Class = 
                getDefinitionByName(getQualifiedClassName(this)) as Class;
            var clone:Object = new ClassReference(null, null);
            clone.title = this.title;
            clone.selfLink = this.selfLink;
            clone.href = this.href;
            clone.id = this.id;
            clone.kind = this.kind;
            return clone;
        }

    }
}