@IsTest 
public class SummaryControllerTest{
    static testMethod void testController1() {
        Account customer = TestObjectFactory.getPersonAccount(); insert customer;
        Account clinic = TestObjectFactory.getBusinessAccount(); insert clinic;
        Opportunity opportunity = TestObjectFactory.getOpportunity(customer.Id); opportunity.Clinic__c = clinic.Id; insert opportunity;
        Payment__c payment = TestObjectFactory.getPayment(opportunity.Id); insert payment;
        
        Apexpages.currentPage().getParameters().put('PaymentId', payment.Id);
        SummaryController sc = new SummaryController(new ApexPages.StandardSetController(new List<Payment__c>([SELECT Id FROM Payment__c])));
         List<AggregateResult> agResult=[select count(id) cnt,CALENDAR_MONTH(OpportunityAppointmentDate__c) calMonth, CALENDAR_YEAR(OpportunityAppointmentDate__c) calYear,  TransactionStatus__c ts, sum(paymentamount__c) totalamount,sum(PaymentNetAmount__c) netamount,sum(PaymentVATAmount__c) vatamount,Opportunity__r.Clinic__r.ClinicInvoiceCode__c cc,
                        Opportunity__r.Clinic__r.name clname,Opportunity__r.Clinic__r.billingstreet street,Opportunity__r.Clinic__r.billingpostalcode postcode,Opportunity__r.Clinic__r.billingcity city
                        from Payment__c GROUP BY CALENDAR_MONTH(OpportunityAppointmentDate__c),TransactionStatus__c,CALENDAR_YEAR(OpportunityAppointmentDate__c),Opportunity__r.Clinic__r.ClinicInvoiceCode__c,
                        Opportunity__r.Clinic__r.name,Opportunity__r.Clinic__r.billingstreet,Opportunity__r.Clinic__r.billingpostalcode,Opportunity__r.Clinic__r.billingcity LIMIT 1];
        wrapperclass wc = new wrapperclass(agResult[0]); 
}
        
    }