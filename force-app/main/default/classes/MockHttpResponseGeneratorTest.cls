@isTest
private class MockHttpResponseGeneratorTest {

    @isTest
    static void respondTest() {
        Test.startTest();

        MockHttpResponseGenerator mock = new MockHttpResponseGenerator();
        HttpResponse response = mock.respond(req);

        Test.stopTest();
    }
}