@isTest
public class FindNewJobsTest {
    @isTest
    static void testExecute() {
        // Set up mock callout response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();
        FindNewJobs job = new FindNewJobs();
        System.enqueueJob(job);
        Test.stopTest();

        // Verify that the job applications were created (if applicable)
        List<Job_Application__c> jobApps = [SELECT Id FROM Job_Application__c];
        System.assert(jobApps.size() > 0, 'Job applications should be created');
    }
}