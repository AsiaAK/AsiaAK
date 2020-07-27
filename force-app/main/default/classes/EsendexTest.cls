@isTest
private class EsendexTest {
    static testmethod void messageDispatcherTest() {
        System.Test.setMock(HttpCalloutMock.class, new EsendexHttpCalloutMockup(false));
        System.Test.startTest();
            Esendex.messageDispatcher(TestObjectFactory.getEsendexMessageDispatcherRequest());
        System.Test.stopTest();
    }
    
    static testmethod void messageHeaderTest() {
        System.Test.setMock(HttpCalloutMock.class, new EsendexHttpCalloutMockup(false));
        System.Test.startTest();
            Esendex.messageHeader('1183C73D-2E62-4F60-B610-30F160BDFBD5');
        System.Test.stopTest();
    }
}