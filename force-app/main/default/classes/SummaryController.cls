public with sharing class SummaryController {
    public List<AggregateResult> agResult {get;set;} 
    public wrapperclass wc {get;set;}
    public list<wrapperclass> wraplist{get;set;}
    private String queryString;
    public ApexPages.StandardSetController stController;
    
    
    public SummaryController(ApexPages.StandardSetController controller) {
        controller.setPageSize(2000);
        stController = controller;
        initInvoices();
    }
     
    public void initInvoices() {
        Map<Id, Payment__c> paymentsMap = new Map<Id, Payment__c>((List<Payment__c>)stController.getSelected());
        wraplist = new list<wrapperclass>();
        system.debug(paymentsMap.size());
        this.agResult = [select count(id) cnt,CALENDAR_MONTH(OpportunityAppointmentDate__c) calMonth, CALENDAR_YEAR(OpportunityAppointmentDate__c) calYear,  TransactionStatus__c ts, sum(paymentamount__c) totalamount,sum(PaymentNetAmount__c) netamount,sum(PaymentVATAmount__c) vatamount,Opportunity__r.Clinic__r.ClinicInvoiceCode__c cc,
                        Opportunity__r.Clinic__r.name clname,Opportunity__r.Clinic__r.billingstreet street,Opportunity__r.Clinic__r.billingpostalcode postcode,Opportunity__r.Clinic__r.billingcity city
                        from Payment__c where id IN :paymentsMap.keySet() and InvoiceNumberAuto__c != null  and (TransactionStatus__c='Paid' OR TransactionStatus__c='Credit note' OR TransactionStatus__c='Refunded' ) GROUP BY CALENDAR_MONTH(OpportunityAppointmentDate__c),TransactionStatus__c,CALENDAR_YEAR(OpportunityAppointmentDate__c),Opportunity__r.Clinic__r.ClinicInvoiceCode__c,
                        Opportunity__r.Clinic__r.name,Opportunity__r.Clinic__r.billingstreet,Opportunity__r.Clinic__r.billingpostalcode,Opportunity__r.Clinic__r.billingcity];
                        
                        for(AggregateResult ag: agResult){
                           wraplist.add(new wrapperclass(ag));
                        }
                        system.debug('mawraplist'+wraplist);
 
    }

}