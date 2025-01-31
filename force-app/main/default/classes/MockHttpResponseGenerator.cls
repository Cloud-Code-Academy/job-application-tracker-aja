// Mock class for HTTP 
@isTest     
public class MockHttpResponseGenerator implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setBody('{"jobs": [{"id": "123", "title": "Test Job", "location": "Remote", "link": "http://example.com", "company": "Test Corp", "snippet": "<b>Great job</b>", "salary": "$100k"}]}');
        return res;
    }
}