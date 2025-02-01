@isTest
public class MockHttpResponseGeneratorTest {
    @isTest
    public static void testMockHttpResponse() {
        // Set up mock callout
        //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        MockHttpResponseGenerator mockGenerator = new MockHttpResponseGenerator();

        // Create HTTP request
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://example.com/api/jobs');
        req.setMethod('POST');
        
        // Send HTTP request
        //HttpResponse res = new Http().send(req);
        HttpResponse res = mockGenerator.respond(req);
        
        // Validate response
        System.assertEquals(200, res.getStatusCode(), 'Status code should be 200');
        System.assertNotEquals(null, res.getBody(), 'Response body should not be null');
        System.assert(res.getBody().contains('"jobs"'), 'Response body should contain job data');
    }

    @isTest
    public static void testMockHttpResponseDirectly() {
        // Directly invoke MockHttpResponseGenerator to ensure coverage
        MockHttpResponseGenerator mockGenerator = new MockHttpResponseGenerator();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://example.com/api/jobs');
        req.setMethod('POST');

        HttpResponse res = mockGenerator.respond(req);

        // Validate response
        System.assertEquals(200, res.getStatusCode(), 'Status code should be 200');
        System.assertNotEquals(null, res.getBody(), 'Response body should not be null');
        System.assert(res.getBody().contains('\"jobs\"'), 'Response body should contain job data');
    }
}