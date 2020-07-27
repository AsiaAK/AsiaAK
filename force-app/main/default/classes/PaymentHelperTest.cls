@isTest
private class PaymentHelperTest {
    static testmethod void generatePaymentLinksTestInsert() {
        Saferpay__c saferpay = TestObjectFactory.getSaferpay(true);
        insert saferpay;
        System.Test.setMock(HttpCalloutMock.class, new SaferpayHttpCalloutMockup('a0D4E000000sYNA', false));
        System.Test.startTest();
            PaymentHelper.generatePaymentLinks(new Map<Id, Payment__c>{'a0D4E000000sYNA'=>new Payment__c()});
        System.Test.stopTest();
    }
    
    static testmethod void generatePaymentLinksTestUpdate() {
        Saferpay__c saferpay = TestObjectFactory.getSaferpay(true);
        insert saferpay;
        System.Test.setMock(HttpCalloutMock.class, new SaferpayHttpCalloutMockup('a0D4E000000sYNA', false));
        System.Test.startTest();
            PaymentHelper.generatePaymentLinks(
                new Map<Id, Payment__c>{'a0D4E000000sYNA'=>new Payment__c(Id = 'a0D4E000000sYNA', GenerateNewPaymentLink__c=true)},
                new Map<Id, Payment__c>{'a0D4E000000sYNA'=>new Payment__c(Id = 'a0D4E000000sYNA', GenerateNewPaymentLink__c=false)}
            );
        System.Test.stopTest();
    }
    static testmethod void sendInvoice() {
        Oekopost__c credentials = TestObjectFactory.getOekopostCredentials(); insert credentials;
        Account customer = TestObjectFactory.getPersonAccount(); insert customer;
        Opportunity opportunity = TestObjectFactory.getOpportunity(customer.Id); insert opportunity;
        
        Payment__c payment = TestObjectFactory.getPayment(opportunity.Id); insert payment;
        
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl.oekopostMock1());
        System.Test.startTest();
            payment.PaymentLink__c = 'http://test.com';
            update payment;
        System.Test.stopTest();
    }
    
    static testmethod void createPaymentDocuments() {
        Oekopost__c credentials = TestObjectFactory.getOekopostCredentials(); insert credentials;
        Account customer = TestObjectFactory.getPersonAccount(); insert customer;
        Opportunity opportunity = TestObjectFactory.getOpportunity(customer.Id); insert opportunity;
        Payment__c payment = TestObjectFactory.getPayment(opportunity.Id); insert payment;
        
        System.Test.startTest();
            PaymentHelper.createPaymentDocuments(payment.Id);
        System.Test.stopTest();
    }
}