/**
 * @description Test class for AccountUtils
 * Ensures that duplicates accounts are not created.
 * @author Jonathan Lyles
 * @created 2025-01-31
 * @updated 2025-02-08
 */

@isTest
public class AccountUtilsTest {
    // Set up test data
    @TestSetup
    static void makeData(){
        // Create a pre-existing account
        Account acc = new Account(Name = 'Pre-existing Account');
        insert acc;
        // Create two test job application records
        List<Job_Application__c> jobApps = new List<Job_Application__c>();
        Job_Application__c jobApp1 = new Job_Application__c();
        Job_Application__c jobApp2 = new Job_Application__c();
        // Assign field values to each job application
        jobApp1.Title__c = 'Test Job1';
        jobApp1.Location__c = 'Remote';
        jobApp1.Url__c = 'https://www.example1.com';
        jobApp1.Status__c = 'Saved';
        jobApp1.CompanyNameFromHttpResponse__c = 'Pre-existing Account';
        jobApp1.Description__c = 'This is the description of Test Job1';
        jobApp1.Salary__c = 120000;
        jobApp1.job_id__c = '12345';
        
        jobApp2.Title__c = 'Test Job2';
        jobApp2.Location__c = 'Remote';
        jobApp2.Url__c = 'https://www.example2.com';
        jobApp2.Status__c = 'Saved';
        jobApp2.CompanyNameFromHttpResponse__c = 'Non Pre-existing Account';
        jobApp2.Description__c = 'This is the description of Test Job2';
        jobApp2.Salary__c = 150000;
        jobApp2.job_id__c = '23456';

        jobApps.add(jobApp1);
        jobApps.add(jobApp2);

        insert jobApps;
    }
    /**
     * @description Tests successful creation of Job Application to Account Id Map
     */
    @isTest
    static void createJobApplicationIdToAccountIdMapTest() {
        // Get job applications
        String jobAppQuery =    'SELECT Id, Title__c, Location__c, Url__c, Status__c, CompanyNameFromHttpResponse__c, Description__c, Salary__c, job_id__c ' +
                                'FROM Job_Application__c ';
        List<Job_Application__c> jobApps = Database.query(jobAppQuery);
        // Create a map of job application Ids to account names map
        Map<Id, String> jobAppIdToAccountNameMapTest = new Map<Id, String>();
        for(Job_Application__c job : jobApps){
            jobAppIdToAccountNameMapTest.put(job.Id, job.CompanyNameFromHttpResponse__c);
        }
        Test.startTest();
        Map<Id, Id> jobAppIdToAccountIdMapTest = AccountUtils.createJobApplicationIdToAccountIdMap(jobAppIdToAccountNameMapTest);
        Test.stopTest();
        
        // Assert: The name should have two keys, and two values
        System.debug('map contents: ' + jobAppIdToAccountIdMapTest);
        System.debug('map keysets: ' + jobAppIdToAccountIdMapTest.keySet());
        System.debug('map values: ' + jobAppIdToAccountIdMapTest.values());
        
        System.assertEquals(2, (jobAppIdToAccountIdMapTest.keySet()).size(), 'Keyset size should be 2');
        System.assertEquals(2, (jobAppIdToAccountIdMapTest.values()).size(), 'Values size should be 2');
    }
    @isTest
    static void testCreateJobApplicationIdToAccountIdMap_ExceptionHandling() {
        // Step 1: Prepare the test data with an invalid account name (256+ chars, which exceeds the Salesforce limit of 255)
        String longAccountName = 'A'.repeat(260);
        Map<Id, String> jobApplicationIdToAccountNameMap = new Map<Id, String>{
            Id.valueOf('001000000000001') => longAccountName
        };

        Test.startTest();
        Map<Id, Id> result = AccountUtils.createJobApplicationIdToAccountIdMap(jobApplicationIdToAccountNameMap);
        Test.stopTest();

        // Step 2: Assert that the method returned null due to exception handling
        System.assertEquals(null, result, 'Expected null due to exception handling.');
    }
}


