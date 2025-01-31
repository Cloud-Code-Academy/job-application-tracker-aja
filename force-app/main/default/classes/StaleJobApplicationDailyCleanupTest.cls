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
        System.assertEquals(1, [SELECT COUNT() FROM Job_Application__c WHERE Follow_up_Date__c < N_DAYS_AGO:30],'There should be one job application with a follow up date more than 30 days in the past');
        Test.startTest();
        StaleJobApplicationDailyCleanup doomedJobs = new StaleJobApplicationDailyCleanup();
        Database.executeBatch(doomedJobs,200);
        Test.stopTest();
        System.assertEquals(0, [SELECT COUNT() FROM Job_Application__c WHERE Follow_up_Date__c < N_DAYS_AGO:30],'There should be no job applications with a follow up date more than 30 days in the past');
    }
}