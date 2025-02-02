/**
 * @description This class ensures successful creation and sending of interview reminder emails the day before
 * @author Jonathan Lyles
 * @created 2025-01-31
 */


@isTest
private class InterviewReminderTest {
    /**
     * @description This is a data factory method for creation of test data
     */
    @TestSetup
    static void setupTestData(){
        // Use the TestDataFactory to create test data
        Id profileId = TestDataFactory.getProfileId();
        String uniqueUserName = TestDataFactory.createUniqueUsername();
        User testUser = TestDataFactory.createUser(uniqueUsername, profileId);
        Account testAccount = TestDataFactory.createAccount();
        Contact testContact = TestDataFactory.createContact(testAccount.Id);
        Job_Application__c testJob = TestDataFactory.createJobApplication(testUser.Id, testAccount.Id, testContact.Id, Date.today().addDays(14));
        Event jobInterview = TestDataFactory.createEvent(testUser.Id, testContact.Id, testJob.Id, testJob.location__c);
    }
    /**
     * @description Tests email count is correct
     * Before the test, there should be no emails, after the test, there should be one email.
     */
    @isTest
    static void testEmailCount() {
        System.assertEquals(0, [SELECT COUNT() FROM EmailMessage WHERE RelatedToId IN (SELECT Id FROM Job_Application__c WHERE Name = 'JobApplicationName')] , 'There should be no found email at this stage of the test');
        Test.startTest();
         // Call the batchable class
         InterviewReminder batchJob = new InterviewReminder();
         
         // Run the batchable with a batch size of 1
         Database.executeBatch(batchJob, 200);
        
          
        Test.stopTest();
        EmailMessage emailMessage = [SELECT Id, Subject, RelatedToId, ToAddress 
        FROM EmailMessage
        WHERE  RelatedToId IN(
            SELECT Id
            FROM Job_Application__c
            WHERE Name = 'JobApplicationName'
        )
        LIMIT 1
        ];
        // Assert: Verifies the correct count of email messages
        System.assertEquals(1, [SELECT COUNT() FROM EmailMessage WHERE RelatedToId IN (SELECT Id FROM Job_Application__c WHERE Name = 'JobApplicationName')] , 'There should be one found email after the test has executed');
        // Assert: Verifies the email subject is not null
        System.assertNotEquals(null, emailMessage.Subject, 'Should not be null');
        // Assert: Verifies the text in the email subject
        System.assertEquals('Reminder: Interview Scheduled Tomorrow', emailMessage.Subject, 'Title should be \'Reminder: Interview Scheduled Tomorrow\'');
        // Assert: Verifies the email is sent to the right address
        System.assertEquals('test@test.com', emailMessage.ToAddress, 'ToAddress is not test@test.com');
    }
}