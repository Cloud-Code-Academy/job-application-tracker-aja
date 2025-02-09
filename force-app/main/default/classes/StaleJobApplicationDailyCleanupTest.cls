/**
 * @description This class tests StaleJobApplicationDailyCleanup
 * @author Jonathan Lyles
 * @created 2025-01-31
 */
@isTest
private class StaleJobApplicationDailyCleanupTest {
    /**
     * @description Handles setup of test data
     */
    @testSetup
    static void setupTestData() {
        // Use the TestDataFactory to create test data
        Id profileId = TestDataFactory.getProfileId();
        String uniqueUserName = TestDataFactory.createUniqueUsername();
        User testUser = TestDataFactory.createUser(uniqueUsername, profileId);
        Account testAccount = TestDataFactory.createAccount();
        Contact testContact = TestDataFactory.createContact(testAccount.Id);
        Job_Application__c testJobPositive = TestDataFactory.createJobApplication(testUser.Id, testAccount.Id, testContact.Id, Date.today().addDays(-31));
        // Test data for the negative scenario         
        Job_Application__c testJobNegative = TestDataFactory.createJobApplication(testUser.Id, testAccount.Id, testContact.Id, Date.today().addDays(-5));
    }
    /**
     * @description Verifies stale jobs are properly closed and commented
     * If a job application record has a follow up date more than 31 days ago, and the status of this record is not "Closed" or "Accepted", that this record's
     * status is updated to "Closed" and the following comment is added to the Notes__c field: "Closed by an automated process".
     */
    @isTest
    static void StaleJobCleanupPostiveTest(){
        // Query for the positive sceneario, where the follow up date is more than 30 days ago, and the status is not closed or accepted
        String positiveQuery = 'SELECT Status__c, Notes__c FROM Job_Application__c WHERE Follow_Up_Date__c < N_DAYS_AGO:30';

        Test.startTest();
        StaleJobApplicationDailyCleanup staleJobs = new StaleJobApplicationDailyCleanup();
        Database.executeBatch(staleJobs,200);
        Test.stopTest();

        List<Job_Application__c> jobs = Database.query(positiveQuery) ;
        System.assertEquals('Closed', jobs[0].Status__c,'Status should be closed');
        System.assertEquals('Closed by an automated process', jobs[0].Notes__c, 'Notes field should indicate record status changed to closed by an automated process');
    }
    /**
     * @description Verifies negative scenarios
     * No action should be taken if a job application record has a status of "Closed" or "Accepted", or where the follow up date is less than 31 days ago.
     */
    static void StaleJobCleanupNegativeTest(){
        // Query for the positive sceneario, where the follow up date is less than 30 days ago, and the status is not closed or accepted
        String NegativeQuery = 'SELECT Status__c, Notes__c FROM Job_Application__c WHERE Follow_Up_Date__c > N_DAYS_AGO:30 AND (Status__c != \'Closed\' AND Status__c != \'Accepted\')';

        Test.startTest();
        StaleJobApplicationDailyCleanup notStaleJobs = new StaleJobApplicationDailyCleanup();
        Database.executeBatch(notStaleJobs,200);
        Test.stopTest();

        List<Job_Application__c> jobs = Database.query(negativeQuery) ;
        System.assertEquals('Saved', jobs[0].Status__c,'Status should be saved');
        System.assertEquals(null, jobs[0].Notes__c, 'Notes field should null');
    }

}