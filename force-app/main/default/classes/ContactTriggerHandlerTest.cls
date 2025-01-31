@isTest
public class ContactTriggerHandlerTest {
    //tests for all scenarios related to updating primary contact whether from job application trigger or contact trigger

    @testSetup
    static void setup() {
        // Create Accounts
        Account account1 = new Account(Name = 'Account 1');
        insert account1;

        Account account2 = new Account(Name = 'Account 2');
        insert account2;

        // Create Contacts
        Contact contact1 = new Contact(LastName = 'Contact 1', AccountId = account1.Id);
        insert contact1;

        Contact contact2 = new Contact(LastName = 'Contact 2', AccountId = account2.Id);
        insert contact2;

        // Create Job Applications
        Job_Application__c jobApp1 = new Job_Application__c(Name = 'Job App 1', Account__c = account1.Id);
        insert jobApp1;

        Job_Application__c jobApp2 = new Job_Application__c(Name = 'Job App 2');
        insert jobApp2;
    }

    @isTest
    static void testPrimaryContactAlreadyPopulatedNoChange() {
        // Retrieve test data
        Job_Application__c jobApp = [SELECT Id, PrimaryContact__c FROM Job_Application__c LIMIT 1];
        Contact contact = [SELECT Id FROM Contact LIMIT 1];

        // Set PrimaryContact__c
        jobApp.PrimaryContact__c = contact.Id;
        update jobApp;

        // Verify no trigger actions when PrimaryContact__c is already populated
        Test.startTest();
        update jobApp;
        Test.stopTest();

        Job_Application__c updatedJobApp = [SELECT PrimaryContact__c FROM Job_Application__c WHERE Id = :jobApp.Id];
        System.assertEquals(contact.Id, updatedJobApp.PrimaryContact__c, 'PrimaryContact__c should remain unchanged.');
    }

    @isTest
    static void testPrimaryContactPopulatedRelatedContactAdded() {
        // Retrieve test data
        Job_Application__c jobApp = [SELECT Id, PrimaryContact__c FROM Job_Application__c LIMIT 1];
        Contact contact = [SELECT Id FROM Contact LIMIT 1];

        // Set PrimaryContact__c
        jobApp.PrimaryContact__c = contact.Id;
        update jobApp;

        // Add a new related Contact
        Contact newContact = new Contact(LastName = 'New Contact', Job_Application__c = jobApp.Id);

        Test.startTest();
        insert newContact;
        Test.stopTest();

        Job_Application__c updatedJobApp = [SELECT PrimaryContact__c FROM Job_Application__c WHERE Id = :jobApp.Id];
        System.assertEquals(contact.Id, updatedJobApp.PrimaryContact__c, 'PrimaryContact__c should not change when a new related contact is added.');
    }

    @isTest
    static void testPrimaryContactPopulatedRelatedAccountAdded() {
        // Retrieve test data
        Job_Application__c jobApp = [SELECT Id, PrimaryContact__c FROM Job_Application__c LIMIT 1];
        Contact contact = [SELECT Id FROM Contact LIMIT 1];

        // Set PrimaryContact__c
        jobApp.PrimaryContact__c = contact.Id;
        update jobApp;

        // Update Account__c field
        Account account = [SELECT Id FROM Account LIMIT 1];
        jobApp.Account__c = account.Id;

        Test.startTest();
        update jobApp;
        Test.stopTest();

        Job_Application__c updatedJobApp = [SELECT PrimaryContact__c FROM Job_Application__c WHERE Id = :jobApp.Id];
        System.assertEquals(contact.Id, updatedJobApp.PrimaryContact__c, 'PrimaryContact__c should not change when Account__c is updated.');
    }

    @isTest
    static void testPrimaryContactNullRelatedContactAdded() {
        // Retrieve test data
        Job_Application__c jobApp = [SELECT Id, PrimaryContact__c FROM Job_Application__c WHERE PrimaryContact__c = null LIMIT 1];

        // Add a related Contact
        Contact newContact = new Contact(LastName = 'New Contact', Job_Application__c = jobApp.Id);

        Test.startTest();
        insert newContact;
        Test.stopTest();

        Job_Application__c updatedJobApp = [SELECT PrimaryContact__c FROM Job_Application__c WHERE Id = :jobApp.Id];
        System.assertEquals(newContact.Id, updatedJobApp.PrimaryContact__c, 'PrimaryContact__c should be set to the first related contact.');
    }

    @isTest
    static void testPrimaryContactNullRelatedAccountAdded() {
        // Retrieve test data
        Job_Application__c jobApp = [SELECT Id, PrimaryContact__c FROM Job_Application__c WHERE PrimaryContact__c = null LIMIT 1];
        Account account = [SELECT Id FROM Account LIMIT 1];

        // Update Account__c field
        jobApp.Account__c = account.Id;

        Test.startTest();
        update jobApp;
        Test.stopTest();

        Job_Application__c updatedJobApp = [SELECT PrimaryContact__c FROM Job_Application__c WHERE Id = :jobApp.Id];
        Contact expectedContact = [SELECT Id FROM Contact WHERE AccountId = :account.Id LIMIT 1];
        System.assertEquals(expectedContact.Id, updatedJobApp.PrimaryContact__c, 'PrimaryContact__c should be set to the first contact related to the Account.');
    }

    @isTest
    static void testAfterUpdateAssignPrimaryContactFromContacts() {
        // Retrieve a Job Application with no PrimaryContact__c
        Job_Application__c jobApp = [SELECT Id, PrimaryContact__c FROM Job_Application__c WHERE PrimaryContact__c = null LIMIT 1];

        // Create and insert a Contact linked to the Job Application
        Contact contact = new Contact(LastName = 'Updated Contact', Job_Application__c = jobApp.Id);
        insert contact;

        // Update the Contact to trigger afterUpdate logic
        contact.LastName = 'Updated LastName';

        Test.startTest();
        update contact; // This should call afterUpdate
        Test.stopTest();

        // Verify that PrimaryContact__c is set correctly
        Job_Application__c updatedJobApp = [SELECT PrimaryContact__c FROM Job_Application__c WHERE Id = :jobApp.Id];
        System.assertEquals(contact.Id, updatedJobApp.PrimaryContact__c, 'PrimaryContact__c should be set to the updated Contact.');
}

}
