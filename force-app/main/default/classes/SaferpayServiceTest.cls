@isTest
private class SaferpayServiceTest {
    static testMethod void testGet() {
        Account accountRecord = TestObjectFactory.getPersonAccount();
        insert accountRecord;
        Opportunity opportunityRecord = TestObjectFactory.getOpportunity(accountRecord.Id);
        insert opportunityRecord;
        Payment__c paymentRecord = TestObjectFactory.getPayment(opportunityRecord.Id);
        insert paymentRecord;
        System.Test.setMock(HttpCalloutMock.class, new SaferpayHttpCalloutMockup(paymentRecord.Id, false));
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.httpMethod = 'GET';
        req.requestBody = Blob.valueof('');
        req.params.put('paymentId', paymentRecord.Id);
        req.params.put('DATA', 'MSGTYPE="PayConfirm",ORDERID="' + paymentRecord.Id + '"');
        RestContext.request = req;
        RestContext.response= res;
        System.Test.startTest();
            SaferpayService.doGet();
        System.Test.stopTest();
    }
}