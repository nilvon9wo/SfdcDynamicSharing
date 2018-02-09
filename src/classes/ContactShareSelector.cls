public virtual class ContactShareSelector {
    public virtual List<ContactShare> selectManualByContactId(Set<Id> contactIdSet) {
    	return [
    		SELECT Id
    		FROM ContactShare
    		WHERE RowCause = 'Manual'
    			AND ContactId IN: contactIdSet
    	];
    }
}