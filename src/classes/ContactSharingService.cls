// @See: http://blog.jeffdouglas.com/2009/11/25/programmatically-creating-sharing-rules-with-apex/
public class ContactSharingService {
	ContactShareSelector contactShareSelector;
	GroupSelector groupSelector;
	GenericDml genericDml;
	
	public ContactSharingService(ContactShareSelector contactShareSelector, GroupSelector groupSelector, GenericDml genericDml) {
		this.contactShareSelector = contactShareSelector;
		this.groupSelector = groupSelector;
		this.genericDml = genericDml;
	}

	public ContactSharingService() {
		this(new ContactShareSelector(), new GroupSelector(), new GenericDml());
	}
	 
	private static final String PUBLIC_GROUP_TYPE = 'Organization';
	
	public virtual List<ContactShare> adjustPrivacy(Map<Id, Contact> newContactByIdMap, Map<Id, Contact> oldContactByIdMap) {
		Id publicGroupId = this.groupSelector.selectByType(PUBLIC_GROUP_TYPE).Id;
		List<ContactShare> newContactShareList = new List<ContactShare>();
		Set<Id> obsoleteContactShareContactIdSet = new Set<Id>();
		
		for (Contact newContact : newContactByIdMap.values()) {
			if (isNewlyPublic(newContact, oldContactByIdMap)) {
				newContactShareList.add(createNewShare(newContact.Id, publicGroupId));
			}

			if (isNewlyPrivate(newContact, oldContactByIdMap)) {
				obsoleteContactShareContactIdSet.add(newContact.Id);
			}
		} 

		this.genericDml.doInsert(newContactShareList);
		this.deleteContactSharesFor(obsoleteContactShareContactIdSet);
		return newContactShareList;  
	}
	 
	@testVisible
	private Boolean isNewlyPublic(Contact newContact, Map<Id, Contact> oldContactByIdMap) {
		return newContact.MakePublic__c
			&& wasOldPrivate(newContact, oldContactByIdMap);
	} 

	@testVisible
	private Boolean isNewlyPrivate(Contact newContact, Map<Id, Contact> oldContactByIdMap) {
		return !newContact.MakePublic__c
			&& !wasOldPrivate(newContact, oldContactByIdMap);
	} 
	
	@testVisible
	private Boolean wasOldPrivate(Contact newContact, Map<Id, Contact> oldContactByIdMap) {
		return oldContactByIdMap == null
			|| oldContactByIdMap != null  
				&& oldContactByIdMap.get(newContact.Id) != null 
				&& !oldContactByIdMap.get(newContact.Id).MakePublic__c;
	}
	
	@testVisible
	private ContactShare createNewShare(Id contactId, Id publicGroupId) {
		return new ContactShare(
					ContactAccessLevel = 'Edit',
					ContactId = contactId, 
					RowCause = 'Manual',
					UserOrGroupId = publicGroupId 
				);
	}
	
	@testVisible
	private List<Database.DeleteResult> deleteContactSharesFor(Set<Id> obsoleteContactShareContactIdSet) {
		return (!obsoleteContactShareContactIdSet.isEmpty())
			? this.genericDml.doDelete(this.contactShareSelector.selectManualByContactId(obsoleteContactShareContactIdSet))
			: null;
	}
}