package org.everest.flex.model.managers
{
    import flash.events.Event;
    import flash.events.EventDispatcher;

    import mx.collections.ArrayCollection;

    import org.everest.flex.events.MemberEvent;
    import org.everest.flex.model.DocumentDescriptor;
    import org.everest.flex.model.Member;
    import org.everest.flex.model.MembersCollection;
    import org.everest.flex.ui.components.ErrorView;

    /**
     * The member manager keeps track of rest member model objects and
     * provides a transactional interface for working with the model.
     *
     * @author rothe
     */
    public class MemberManager extends EventDispatcher
    {
        private var _member:Member;
        private var _subMember:Member;
        private var _subMembers:MembersCollection;

        public function loadEntry(documentDescriptor:DocumentDescriptor):void
        {
            var mmbrs:ArrayCollection = documentDescriptor.members;
            if ((mmbrs != null)&&(mmbrs.length > 0))
            {
                _member = mmbrs.getItemAt(0) as Member;
                dispatchEvent(new Event(MemberEvent.MEMBER_CHANGED));
            }
            else
            {
                ErrorView.show("Error while trying to load the ressource. Maybe it does not exist.");
            }

        }

        public function loadSubEntry(documentDescriptor:DocumentDescriptor):void
        {
            var mmbrs:ArrayCollection = documentDescriptor.members;
            if (mmbrs != null)
            {
                if ((mmbrs.length == 1))
                {
                    _subMember = mmbrs.getItemAt(0) as Member;
                    dispatchEvent(new Event("subMemberChanged"));
                } else {

                    _subMembers = new MembersCollection();
                    for each (var entry:Member in mmbrs)
                    {
                        _subMembers.addItem(entry);
                    }
                    dispatchEvent(new Event("subMembersChanged"));
                }

            }
            else
            {
                ErrorView.show("Error while trying to load the ressource. Maybe it does not exist.");
            }

        }

        [Bindable(Event="memberChanged")]
        public function get member():Member
        {
            return _member;
        }

        [Bindable(Event="subMemberChanged")]
        public function get subMember():Member
        {
            return _subMember;
        }

        [Bindable(Event="subMembersChanged")]
        public function get subMembers():MembersCollection
        {
            return _subMembers;
        }
        public function reset():void
        {
            _member = null;
            dispatchEvent(new Event(MemberEvent.MEMBER_CHANGED));
        }
    }
}