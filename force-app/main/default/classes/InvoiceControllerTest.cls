@IsTest (seeAllData=false)
public class InvoiceControllerTest {
    static testMethod void testController1() {
        Account customer = TestObjectFactory.getPersonAccount(); insert customer;
        Account clinic = TestObjectFactory.getBusinessAccount(); insert clinic;
        Opportunity opportunity = TestObjectFactory.getOpportunity(customer.Id); opportunity.Clinic__c = clinic.Id; insert opportunity;
        Payment__c payment = TestObjectFactory.getPayment(opportunity.Id); insert payment;
        
        Apexpages.currentPage().getParameters().put('PaymentId', payment.Id);
        InvoiceController ic = new InvoiceController();
        ic.getPayment();
        ic.getOpportunity();
        
    }
    
    static testMethod void testController2() {
        Account customer = TestObjectFactory.getPersonAccount(); insert customer;
        Account clinic = TestObjectFactory.getBusinessAccount(); insert clinic;
        Opportunity opportunity = TestObjectFactory.getOpportunity(customer.Id); opportunity.Clinic__c = clinic.Id; insert opportunity;
        Payment__c payment = TestObjectFactory.getPayment(opportunity.Id); insert payment;
        
        Apexpages.currentPage().getParameters().put('PaymentId', payment.Id);
        InvoiceController ic2 = new InvoiceController(new ApexPages.StandardSetController(new List<Payment__c>([SELECT Id FROM Payment__c])));
    }
}