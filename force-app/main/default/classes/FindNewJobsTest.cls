/**
 * @description This class tests FindNewJobsSchedulable and FindNewJobQueueable and ensures the job is request to find new jobs successfully retrieves and create new job application records
 * @author Jonathan Lyles
 * @created 2025-01-31
 */

@isTest
public class FindNewJobsTest {
    /**
     * @description Tests queueable job was successfully enqueued
     */
    
    @isTest
    static void testFindNewJobsScheduler() {

        // Set up mock callout response before scheduling job
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Test.startTest();
        // Schedule the job execution
        FindNewJobsSchedulable scheduler = new FindNewJobsSchedulable();
        scheduler.execute(null); //simulating execution from the scheduler
        Test.stopTest();

            // Verify that a Queueable job was enqueued
        AsyncApexJob job = [SELECT Id, Status, JobType 
        FROM AsyncApexJob 
        WHERE JobType = 'Queueable'
        ORDER BY CreatedDate DESC 
        LIMIT 1];

        // Verify that the queueable job was enqueued
        System.assertNotEquals(null, job, 'Expected a Queueable job to be enqueued');
        System.assert(job.Status == 'Queued' || job.Status == 'Processing' || job.Status == 'Completed', 'Queueable job should be enqueued or processing');
    }
    /**
     * @description Tests if queueable job correctly created a new job application record
     */
    @isTest
    static void testFindNewJobsQueueable() {
        // Set up mock callout response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();
        // Execute the Queueable job
        System.enqueueJob(new FindNewJobsQueueable());
        Test.stopTest();

        // Verify that job application records were created
        List<Job_Application__c> jobApplications = [
            SELECT Id, Title__c, Account__c, Location__c, URL__c, Description__c, Salary__c 
            FROM Job_Application__c
        ];
        
        // Assert: Verifies the correct number of job applications was created
        System.assertEquals(1, jobApplications.size(), 'One job application record should be created');

        // Assert: Verifies details of the created record
        Job_Application__c jobApp = jobApplications[0];
        System.assertEquals('Test Job', jobApp.Title__c, 'Job title should be "Test Job"');
        System.assertEquals('Remote', jobApp.Location__c, 'Location should be "Remote"');
        System.assertEquals('http://example.com', jobApp.URL__c, 'Job link should be "http://example.com"');
        System.assertEquals('Great job', jobApp.Description__c, 'Snippet should be "Great job"');
        System.assertEquals(100000, jobApp.Salary__c, 'Salary should be "100000"');
    }
}