public with sharing class SaferpayQueueable implements Queueable, Database.AllowsCallouts{
    public List<Payment__c> records;
    
    public SaferpayQueueable(List<Payment__c> records) {
        this.records = records;
    }
    
    public void execute(QueueableContext context) {
        if(SaferpayUtils.config.UseHttpsInterface__c) {
            for(Payment__c record :this.records) {
                Saferpay.httpsInterface(record);
            }
        } else {
            for(Payment__c record :[SELECT Id, Name, PaymentID__c, CurrencyIsoCode, PaymentAmount__c FROM Payment__c WHERE Id IN :this.records]) {
                Saferpay.initializePayment(record);
            }
        }
        SaferpayHelper.performDML();
    }
}