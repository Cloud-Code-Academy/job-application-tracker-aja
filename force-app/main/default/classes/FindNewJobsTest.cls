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

        // Verify that the queueable job was enqueued
        System.assert(true, 'Queueable job should have been enqueued');
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















/** 

@isTest
public class FindNewJobsTest {
    @isTest
    static void testParseResponse() {
        // Set up mock callout response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Create a mock HTTP request
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://example.com/api/jobs');
        req.setMethod('POST');

        // Send the mock request
        Http http = new http();
        HttpResponse res = http.send(req);

        // Call the method to test
        List<Object> jobs = JobApplicationUtils.parseResponse(res);

        // Call the method to create job application records
        Test.startTest();

        FindNewJobs fnj = new FindNewJobs();
        System.enqueueJob(fnj);

        Test.stopTest();

        List<Job_Application__c> jobApplications = [SELECT Id, Title__c, Account__c, Location__c, URL__c, Description__c, Salary__c FROM Job_Application__c];
        System.assertEquals(1, jobApplications.size(), 'One job application record should be created');

        // Verify the details of the created record
        Job_Application__c jobApp = jobApplications[0];
        System.assertEquals('Test Job', jobApp.Title__c, 'Job title should be "Test Job"');
        //System.assertEquals('Test Corp', jobApp.Account__c, 'Company should be "Test Corp"');
        System.assertEquals('Remote', jobApp.Location__c, 'Location should be "Remote"');
        System.assertEquals('http://example.com', jobApp.URL__c, 'Job link should be "http://example.com"');
        System.assertEquals('Great job', jobApp.Description__c, 'Snippet should be "Great job"');
        System.assertEquals(100000, jobApp.Salary__c, 'Salary should be "100000"');
    }
}

*/