@isTest
public class ContactMakePublicTriggerIntTest {
	private static final User TEST_USER = TEST_RunAsUserFactory.create(); 

    @isTest public static void testNewlyInsertedPublicContactsShouldHaveShareRecords() {
    	// Arrange
	    Integer quantity = 50;
	    Boolean makePublic = true;
	    List<Contact> testContactList =createTestContactList(quantity, makePublic);
	
    	// Act
    	Test.startTest();
    	System.runAs(TEST_USER) {
    		insert testContactList;		
    	}
    	Test.stopTest();
    	
    	// Assert
	    Set<Id> contactIdSet = (new Map<Id, Contact>(testContactList)).keySet();
	    assertSharesCreated(contactIdSet, quantity);
    }
    
    @isTest public static void testUpdatedContactsShouldHaveShareAppropriateRecords() {
    	// Arrange
	    Integer quantity = 50;
	    Boolean makePublic = false;
	    List<Contact> testContactList =createTestContactList(quantity, makePublic);
    	insert testContactList;		
	    
	    // Pretest
	    Set<Id> contactIdSet = (new Map<Id, Contact>(testContactList)).keySet();
		assertSharesCreated(contactIdSet, 0);
	    update testContactList;
		assertSharesCreated(contactIdSet, 0);
		
		// Rearrange		
	    for (Contact contact : testContactList) {
	    	contact.MakePublic__c = true;
	    }

    	// Act
    	Test.startTest();
    	System.runAs(TEST_USER) {
		    update testContactList;
    	}
    	Test.stopTest();
    	
    	// Assert
	    assertSharesCreated(contactIdSet, quantity);
    }

    @isTest public static void testNewlyUpdatedNonPublicContactsShouldNotHaveShareRecords() {
    	// Arrange
	    Integer quantity = 50;
	    Boolean makePublic = true;
	    List<Contact> testContactList =createTestContactList(quantity, makePublic);
    	insert testContactList;		
	
	    // Pretest
	    Set<Id> contactIdSet = (new Map<Id, Contact>(testContactList)).keySet();
		assertSharesCreated(contactIdSet, 50);
		
		// Rearrange		
	    for (Contact contact : testContactList) {
	    	contact.MakePublic__c = false;
	    }

    	// Act
    	Test.startTest();
    	System.runAs(TEST_USER) {
		    update testContactList;
    	}
    	Test.stopTest();
    	
    	// Assert
	    assertSharesCreated(contactIdSet, 0);
    }
    

	// Helpers ------------------------------------------------------------------------------------------------------------ 
	
	private static List<Contact> createTestContactList(Integer quantity, Boolean makePublic) {
    	List<Contact> contactList = new List<Contact>();
	    for (Integer i = 0; i < quantity;i++) {
	    	contactList.add(new Contact(
		      	FirstName = 'First ',
		      	LastName = 'Name ' + i,
		        Email = 'email'+i+'@email.com',
		        MakePublic__c = makePublic
	    	));
	    }
	    return contactList;
    }

    private static void assertSharesCreated(Set<Id> contactIdSet, Integer expectedQuantity) {
	    List<ContactShare> resultContactShareList = [
	    	SELECT Id, RowCause 
	    	FROM ContactShare 
			WHERE RowCause = 'Manual'
				AND ContactId IN :contactIdSet
		 ];
	    System.assertEquals(expectedQuantity, resultContactShareList.size());
    }
}