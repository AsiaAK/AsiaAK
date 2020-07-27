@isTest
private class Five9CallsTest {
    static testMethod void testGet() {
       /* Account accountRecord = TestObjectFactory.getPersonAccount();
        insert accountRecord;
        Opportunity opportunityRecord = TestObjectFactory.getOpportunity(accountRecord.Id);
        insert opportunityRecord;
        Payment__c paymentRecord = TestObjectFactory.getPayment(opportunityRecord.Id);
        insert paymentRecord;*/
        System.Test.setMock(HttpCalloutMock.class, new Five9CalloutMock());
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.httpMethod = 'GET';
        req.requestBody = Blob.valueof('');
        req.params.put('logintoken', 'jhhu58oih050p!');
        req.params.put('CallDurationInSeconds', '10000000000');
        RestContext.request = req;
        RestContext.response= res;
        System.Test.startTest();
            Five9Calls.addCallTask();
        System.Test.stopTest();
    }
}