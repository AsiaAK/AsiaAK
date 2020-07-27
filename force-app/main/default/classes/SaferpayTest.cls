@isTest
private class SaferpayTest {
    static testmethod void initializePaymentTest() {
        Account accountRecord = TestObjectFactory.getPersonAccount();
        insert accountRecord;
        Opportunity opportunityRecord = TestObjectFactory.getOpportunity(accountRecord.Id);
        insert opportunityRecord;
        Payment__c paymentRecord = TestObjectFactory.getPayment(opportunityRecord.Id);
        System.Test.setMock(HttpCalloutMock.class, new SaferpayHttpCalloutMockup('a0D4E000000sYNZ', false));
        System.Test.startTest();
            Saferpay.initializePayment(paymentRecord);
        System.Test.stopTest();
    }
    
    static testmethod void assertPaymentTest() {
        Account accountRecord = TestObjectFactory.getPersonAccount();
        insert accountRecord;
        Opportunity opportunityRecord = TestObjectFactory.getOpportunity(accountRecord.Id);
        insert opportunityRecord;
        Payment__c paymentRecord = TestObjectFactory.getPayment(opportunityRecord.Id);
        System.Test.setMock(HttpCalloutMock.class, new SaferpayHttpCalloutMockup('a0D4E000000sYNZ', false));
        System.Test.startTest();
            Saferpay.assertPayment(paymentRecord);
        System.Test.stopTest();
    }
    
    static testmethod void captureTransactionTest() {
        Account accountRecord = TestObjectFactory.getPersonAccount();
        insert accountRecord;
        Opportunity opportunityRecord = TestObjectFactory.getOpportunity(accountRecord.Id);
        insert opportunityRecord;
        Payment__c paymentRecord = TestObjectFactory.getPayment(opportunityRecord.Id);
        System.Test.setMock(HttpCalloutMock.class, new SaferpayHttpCalloutMockup('a0D4E000000sYNZ', false));
        System.Test.startTest();
            Saferpay.captureTransaction(paymentRecord);
        System.Test.stopTest();
    }

    static testmethod void httpsInterfaceSuccessTest() {
        Account accountRecord = TestObjectFactory.getPersonAccount();
        insert accountRecord;
        Opportunity opportunityRecord = TestObjectFactory.getOpportunity(accountRecord.Id);
        insert opportunityRecord;
        Payment__c paymentRecord = TestObjectFactory.getPayment(opportunityRecord.Id);
        System.Test.setMock(HttpCalloutMock.class, new SaferpayHttpCalloutMockup('a0D4E000000sYNZ', false));
        System.Test.startTest();
            Saferpay.httpsInterface(paymentRecord);
        System.Test.stopTest();
    }

    static testmethod void httpsInterfaceErrorTest() {
        Account accountRecord = TestObjectFactory.getPersonAccount();
        insert accountRecord;
        Opportunity opportunityRecord = TestObjectFactory.getOpportunity(accountRecord.Id);
        insert opportunityRecord;
        Payment__c paymentRecord = TestObjectFactory.getPayment(opportunityRecord.Id);
        System.Test.setMock(HttpCalloutMock.class, new SaferpayHttpCalloutMockup('a0D4E000000sYNZ', true));
        System.Test.startTest();
            Saferpay.httpsInterface(paymentRecord);
        System.Test.stopTest();
    }
}