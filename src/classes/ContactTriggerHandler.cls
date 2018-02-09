public virtual class ContactTriggerHandler extends F45_TRIG_AbstractTriggerHandler {
	ContactSharingService contactSharingService;
	
	public ContactTriggerHandler(ContactSharingService contactSharingService) {
		this.contactSharingService = contactSharingService;
	}
	 
	public ContactTriggerHandler() {
		this(new ContactSharingService());
	}
	  
    public override virtual void onAfterInsert (Map<Id, SObject> newSObjectByIdMap) {
    	this.contactSharingService.adjustPrivacy((Map<Id, Contact>) newSObjectByIdMap, (Map<Id, Contact>) null);
    } 
    
    public override virtual void onAfterUpdate (Map<Id, SObject> newSObjectByIdMap, Map<Id, SObject> oldSObjectByIdMap) {
    	this.contactSharingService.adjustPrivacy((Map<Id, Contact>) newSObjectByIdMap, (Map<Id, Contact>) oldSObjectByIdMap);
    }
    
}