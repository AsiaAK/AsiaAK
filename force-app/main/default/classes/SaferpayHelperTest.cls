@isTest
private class SaferpayHelperTest {
    static testmethod void getPayloadTest() {
        System.Test.startTest();
            SaferpayHelper.getPayload('initialize', new Payment__c());
            SaferpayHelper.getPayload('assert', new Payment__c());
            SaferpayHelper.getPayload('capture', new Payment__c());
        System.Test.stopTest();
    }
    
    static testmethod void deserializeResponseTest() {
        HttpResponse errorResponse = new HttpResponse();
        errorResponse.setStatusCode(400);
        errorResponse.setBody(TestObjectFactory.getSaferpayErrorResponse('a0D4E000000sYNZ'));
        HttpResponse initializeResponse = new HttpResponse();
        initializeResponse.setStatusCode(200);
        initializeResponse.setBody(TestObjectFactory.getSaferpayInitializeResponse('a0D4E000000sYNZ'));
        HttpResponse assertResponse = new HttpResponse();
        assertResponse.setStatusCode(200);
        assertResponse.setBody(TestObjectFactory.getSaferpayAssertResponse('a0D4E000000sYNZ'));
        HttpResponse captureResponse = new HttpResponse();
        captureResponse.setStatusCode(200);
        captureResponse.setBody(TestObjectFactory.getSaferpayCaptureResponse('a0D4E000000sYNZ'));
        System.Test.setMock(HttpCalloutMock.class, new SaferpayHttpCalloutMockup('a0D4E000000sYNZ', false));
        System.Test.startTest();
            SaferpayHelper.deserializeResponse('error', errorResponse);
            SaferpayHelper.deserializeResponse('initialize', initializeResponse);
            SaferpayHelper.deserializeResponse('error', errorResponse);
            SaferpayHelper.deserializeResponse('assert', assertResponse);
            SaferpayHelper.deserializeResponse('capture', captureResponse);
        System.Test.stopTest();
    }
    
    static testmethod void performDMLTest() {
        HttpResponse errorResponse = new HttpResponse();
        errorResponse.setStatusCode(400);
        errorResponse.setBody(TestObjectFactory.getSaferpayErrorResponse('a0D4E000000sYNZ'));
        HttpResponse initializeResponse = new HttpResponse();
        initializeResponse.setStatusCode(200);
        initializeResponse.setBody(TestObjectFactory.getSaferpayInitializeResponse('a0D4E000000sYNZ'));
        System.Test.setMock(HttpCalloutMock.class, new SaferpayHttpCalloutMockup('a0D4E000000sYNZ', false));
        System.Test.startTest();
            SaferpayHelper.performDML();
            SaferpayHelper.deserializeResponse('error', errorResponse);
            SaferpayHelper.deserializeResponse('initialize', initializeResponse);
            SaferpayHelper.performDML();
        System.Test.stopTest();
    }
}