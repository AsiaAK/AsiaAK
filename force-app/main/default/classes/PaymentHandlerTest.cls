@isTest
private class PaymentHandlerTest {
    static testmethod void afterInsertTest() {
        System.Test.startTest();
            PaymentHandler obj = new PaymentHandler();
            obj.afterInsert(new Map<Id, Payment__c>());
        System.Test.stopTest();
    }
    
    static testmethod void afterUpdateTest() {
        System.Test.startTest();
            PaymentHandler obj = new PaymentHandler();
            obj.afterUpdate(new Map<Id, Payment__c>(), new Map<Id, Payment__c>());
        System.Test.stopTest();
    }
}