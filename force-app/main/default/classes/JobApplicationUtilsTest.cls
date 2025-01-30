/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class JobApplicationUtilsTest {

    @isTest
    static void getHttpRequestTest() {

        //Call the method under test
        HttpRequest request = JobApplicationUtils.getHttpRequest();

        //Assert the method is POST
        Assert.areEqual('POST', request.getMethod(),'The HTTP method should be POST.');
        Assert.areEqual('application/json', request.getHeader('Content-Type'), 'The content type should be application/json');
        Assert.areEqual('https://jooble.org/api/03c23409-1a24-4fcf-a10d-d05da812186b', request.getEndpoint(), 'The endpoint is not properly set. It should be https://jooble.org/api/03c23409-1a24-4fcf-a10d-d05da812186b');
        Assert.areEqual('{"keywords": "Salesforce", "location": "Raleigh", "salary": 1}', request.getBody(), 'The body is not properly set');
        
    }
}