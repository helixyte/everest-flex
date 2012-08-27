package org.everest.flex.model
{
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
        public var selfLink:String;
        public var href:String;
        public var title:String;
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
                return new Link(title, href);
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

    }
}