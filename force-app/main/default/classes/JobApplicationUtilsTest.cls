
/**
 * @description This class test the methods in JobApplicationUtils
 * @author  Jonathan Lyles
 * @created 2025-01-31
 */
@isTest
public class JobApplicationUtilsTest {
    /**
     * @description Tests if Http request parameters are correct
     */
    @isTest
    static void testGetHttpRequest() {
        HttpRequest request = JobApplicationUtils.getHttpRequest();
        System.assertNotEquals(null, request, 'Request should not be null');
        System.assertEquals('POST', request.getMethod(), 'Method should be POST');
        System.assert(request.getBody().contains('keywords'), 'Request body should contain keywords');
    }
    /**
     * @description Tests if correct number of job applications were created from the response
     */
    @isTest
    static void testParseResponse() {
        String mockResponse = '{"jobs": [{"id": "123", "title": "Test Job", "location": "Remote", "link": "http://example.com", "company": "Test Corp", "snippet": "<b>Great job</b>", "salary": "$100k"}] }';
        HttpResponse response = new HttpResponse();
        response.setBody(mockResponse);
        response.setStatusCode(200);
        
        List<Object> jobs = JobApplicationUtils.parseResponse(response);
        System.assertEquals(1, jobs.size(), 'Should parse one job');
    }
    /**
     * @description Tests parsing of JSON and record creation and record field values
     */
    @isTest
    static void testCreateJobApplicationRecords() {
        List<Object> jobs = new List<Object>();
        Map<String, Object> job = new Map<String, Object>{
            'id' => '123',
            'title' => 'Test Job',
            'location' => 'Remote',
            'link' => 'http://example.com',
            'company' => 'Test Corp',
            'snippet' => '<b>Great job</b>',
            'salary' => '$100k'
        };
        jobs.add(job);
        
        Test.startTest();
        JobApplicationUtils.createJobApplicationRecords(jobs);
        Test.stopTest();
        
        List<Job_Application__c> jobApps = [SELECT Id, Title__c, Description__c FROM Job_Application__c WHERE job_id__c = '123'];
        System.assertEquals(1, jobApps.size(), 'Should insert one job application');
        System.assertEquals('Test Job', jobApps[0].Title__c, 'Title should be "Test Job"');
        System.assertEquals('Great job', jobApps[0].Description__c, 'Description should be "Great Job"');
    }
    /**
     * @description Tests salary parsing into valid salaries
     */
    @isTest
    static void testParseValidSalary() {

        Test.startTest();
        Decimal resultA = JobApplicationUtils.parseSalary('$120k');
        Decimal resultB = JobApplicationUtils.parseSalary('$120k - $150k');
        Decimal resultC = JobApplicationUtils.parseSalary('$120k-$150k');
        Decimal resultD = JobApplicationUtils.parseSalary('$50 per hour');
        Decimal resultE = JobApplicationUtils.parseSalary('$25 - $50 per hour');
        Decimal resultF = JobApplicationUtils.parseSalary('$25-$50 per hour');

        Test.stopTest();
        System.assertEquals(120000, resultA,'Salary should be 120000');
        System.assertEquals(150000, resultB,'Salary should be 150000');
        System.assertEquals(150000, resultC,'Salary should be 150000');
        System.assertEquals(104000, resultD,'Salary should be 104000');
        System.assertEquals(104000, resultE,'Salary should be 104000');
        System.assertEquals(104000, resultF,'Salary should be 104000');
    }
    /**
     * @description Tests valid handling of invalid salary data
     */
    @isTest
    static void testParseInvalidSalary(){
        String invalidSalary = 'invalidSalaryFormat';

        Test.startTest();
        Decimal result = JobApplicationUtils.parseSalary(invalidSalary);
        Test.stopTest();
        
        System.assertEquals(null, result, 'Expected null due to exception in parsing');

    }
}