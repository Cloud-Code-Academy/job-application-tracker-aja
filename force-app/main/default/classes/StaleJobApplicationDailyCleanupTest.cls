@isTest
private class StaleJobApplicationDailyCleanupTest {
    @testSetup
    static void setupTestData() {
         // Use the TestDataFactory to create test data
         Id profileId = TestDataFactory.getProfileId();
         String uniqueUserName = TestDataFactory.createUniqueUsername();
         User testUser = TestDataFactory.createUser(uniqueUsername, profileId);
         Account testAccount = TestDataFactory.createAccount();
         Contact testContact = TestDataFactory.createContact(testAccount.Id);
         Job_Application__c testJob = TestDataFactory.createJobApplication(testUser.Id, testAccount.Id, testContact.Id, Date.today().addDays(-31));
         Event jobInterview = TestDataFactory.createEvent(testUser.Id, testContact.Id, testJob.Id, testJob.location__c);
    }
    @isTest
    static void StaleJobCleanupTest(){
        Test.startTest();
        StaleJobApplicationDailyCleanup doomedJobs = new StaleJobApplicationDailyCleanup();
        Database.executeBatch(doomedJobs,200);
        Test.stopTest();
        List<Job_Application__c> jobs = [SELECT Status__c, Notes__c FROM Job_Application__c];
        System.assertEquals('Closed', jobs[0].Status__c,'Status should be closed');
        System.assertEquals('Closed by an automated process', jobs[0].Notes__c, 'Notes field should indicate record status changed to closed by an automated process');
    }
}