@isTest
private class SaferpayResultControllerTest {
    static testmethod void controllerTestHttpsPayConfirm() {
        Saferpay__c saferpay = TestObjectFactory.getSaferpay(true);
        insert saferpay;
        Account accountRecord = TestObjectFactory.getPersonAccount();
        insert accountRecord;
        Opportunity opportunityRecord = TestObjectFactory.getOpportunity(accountRecord.Id);
        insert opportunityRecord;
        Payment__c paymentRecord = TestObjectFactory.getPayment(opportunityRecord.Id);
        insert paymentRecord;
        System.Test.setCurrentPage(Page.SaferpayResult);
        ApexPages.currentPage().getParameters().put('paymentId', paymentRecord.PaymentID__c);
        ApexPages.currentPage().getParameters().put('DATA', 'MSGTYPE="PayConfirm",ORDERID="' + paymentRecord.Id + '",PAYMENTMETHOD="2"');
        
        System.Test.setMock(HttpCalloutMock.class, new SaferpayHttpCalloutMockup(paymentRecord.Id, false));
        System.Test.startTest();
            SaferpayResultController obj = new SaferpayResultController();
            obj.checkPayment();
        System.Test.stopTest();
    }
    
    static testmethod void controllerTestHttpsAuthorizationResponse() {
        Saferpay__c saferpay = TestObjectFactory.getSaferpay(true);
        insert saferpay;
        Account accountRecord = TestObjectFactory.getPersonAccount();
        insert accountRecord;
        Opportunity opportunityRecord = TestObjectFactory.getOpportunity(accountRecord.Id);
        insert opportunityRecord;
        Payment__c paymentRecord = TestObjectFactory.getPayment(opportunityRecord.Id);
        insert paymentRecord;
        System.Test.setCurrentPage(Page.SaferpayResult);
        ApexPages.currentPage().getParameters().put('paymentId', paymentRecord.PaymentID__c);
        ApexPages.currentPage().getParameters().put('DATA', 'MSGTYPE="AuthorizationResponse",ORDERID="' + paymentRecord.Id + '",PAYMENTMETHOD="2"');
        
        System.Test.setMock(HttpCalloutMock.class, new SaferpayHttpCalloutMockup(paymentRecord.Id, false));
        System.Test.startTest();
            SaferpayResultController obj = new SaferpayResultController();
            obj.checkPayment();
        System.Test.stopTest();
    }
    
    static testmethod void controllerTestJson() {
        Saferpay__c saferpay = TestObjectFactory.getSaferpay(false);
        insert saferpay;
        Account accountRecord = TestObjectFactory.getPersonAccount();
        insert accountRecord;
        Opportunity opportunityRecord = TestObjectFactory.getOpportunity(accountRecord.Id);
        insert opportunityRecord;
        Payment__c paymentRecord = TestObjectFactory.getPayment(opportunityRecord.Id);
        insert paymentRecord;
        System.Test.setCurrentPage(Page.SaferpayResult);
        ApexPages.currentPage().getParameters().put('paymentId', paymentRecord.PaymentID__c);
        
        System.Test.setMock(HttpCalloutMock.class, new SaferpayHttpCalloutMockup(paymentRecord.Id, false));
        System.Test.startTest();
            SaferpayResultController obj = new SaferpayResultController();
            obj.checkPayment();
        System.Test.stopTest();
    }
}