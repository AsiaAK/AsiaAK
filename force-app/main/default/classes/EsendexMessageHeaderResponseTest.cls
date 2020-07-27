@isTest
private class EsendexMessageHeaderResponseTest {
    static testmethod void deserializeTest() {
        System.Test.startTest();
            EsendexMessageHeaderResponse obj = new EsendexMessageHeaderResponse(TestObjectFactory.getEsendexMessageHeaderResponse());
            obj.deserialize();
        System.Test.stopTest();
    }
}