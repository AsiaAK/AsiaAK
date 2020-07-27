public class PaymentHandler {
    public void afterInsert(Map<Id, Payment__c> newMap) {
        PaymentHelper.generatePaymentLinks(newMap);
        PaymentHelper.generateInvoiceIds(newMap);
    }
    
    public void beforeUpdate(Map<Id, Payment__c> newMap, Map<Id, Payment__c> oldMap) {
        PaymentHelper.generateInvoiceIds(newMap, oldMap);
    }
    
    public void afterUpdate(Map<Id, Payment__c> newMap, Map<Id, Payment__c> oldMap) {
        PaymentHelper.generatePaymentLinks(newMap, oldMap);
        PaymentHelper.sendInvoices(newMap, oldMap);
    }
}