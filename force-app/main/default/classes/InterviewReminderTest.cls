@isTest
private class InterviewReminderTest {
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
    @isTest
    static void testEmailCount() {
        System.assertEquals(0, [SELECT COUNT() FROM EmailMessage WHERE RelatedToId IN (SELECT Id FROM Job_Application__c WHERE Name = 'JobApplicationName')] , 'There should be no found email at this stage of the test');
        Test.startTest();
         // Call the batchable class
         InterviewReminder batchJob = new InterviewReminder();
         
         // Run the batchable with a batch size of 1
         Database.executeBatch(batchJob, 1);
        
          
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
        
        System.assertEquals(1, [SELECT COUNT() FROM EmailMessage WHERE RelatedToId IN (SELECT Id FROM Job_Application__c WHERE Name = 'JobApplicationName')] , 'There should be one found email after the test has executed');
        System.assertNotEquals(null, emailMessage.Subject, 'Should not be null');
        System.assertEquals('Reminder: Interview Scheduled Tomorrow', emailMessage.Subject, 'Title should be \'Reminder: Interview Scheduled Tomorrow\'');
        System.assertEquals('test@test.com', emailMessage.ToAddress, 'ToAddress is not test@test.com');
    }
}