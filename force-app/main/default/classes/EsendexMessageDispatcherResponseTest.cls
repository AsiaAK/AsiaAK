@isTest
private class EsendexMessageDispatcherResponseTest {
    static testmethod void deserializeTest() {
        System.Test.startTest();
            EsendexMessageDispatcherResponse obj = new EsendexMessageDispatcherResponse(TestObjectFactory.getEsendexMessageDispatcherResponse());
            obj.deserialize();
        System.Test.stopTest();
    }
}