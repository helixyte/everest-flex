package org.everest.flex.model
{
    import org.everest.flex.interfaces.INavigationLink;

    import mx.collections.ArrayCollection;

    [Bindable]
    /**
     * Model object of a REST collection that is either containing a set of
     * collection members or a link from where the collection can be loaded.
     *
     * @author rothe
     */
    public class MembersCollection extends ArrayCollection implements INavigationLink
    {
        public var href:String;
        public var title:String;
        public var kind:String;

        public function MembersCollection()
        {
            super();
        }

        public override function addItemAt(item:Object, index:int):void
        {
            if (item is Link)
            {
                this.link = item as Link;
            } else {
                super.addItemAt(item, index);
            }
        }

        public function get link():INavigationLink{
            if ((href != null)&&(href.length > 0)){
                return new Link(title, href,Link.COLLECTION);
            }
            return null;
        }

        public function set link(l:INavigationLink):void{
            this.title = l.title;
            this.href = l.href;
        }

        public override function toString():String{
            return this.title ? this.title + " (count)" : null; //TODO
        }

    }
}