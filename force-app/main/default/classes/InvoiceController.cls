public with sharing class InvoiceController {

    public String User { get; set; }
    public String PayId {get; set;}
    public List<Payment__c> listOfPayments {get;set;}
    public Map<Id, Opportunity> listOfOpportunities {get;set;}
    private String queryString;
    public ApexPages.StandardSetController stController;
    
    public InvoiceController(ApexPages.StandardSetController controller) {
        controller.setPageSize(2000);
        stController = controller;
        initInvoices();
    }
    public InvoiceController() {
    }
    
    public Payment__c getPayment() {
        Payment__c payment = new Payment__c();
        try {
            payment = [select Id, OpportunityAppointmentDate__c,Paid_Payment__c,Paid_Payment__r.InvoiceNumberAuto__c, Name,TransactionStatus__c, ClinicNameAuto__c, Opportunity__c, PaymentAmount__c, PaymentDate__c, PaymentDueDate__c, LegacyPaymentLink__c, 
                        Customer_Bank_Transfer_ID__c, PaymentLink__c, InvoiceNumberAuto__c, InvoiceDate__c, PaymentVATAmount__c, PaymentNetAmount__c,Invoice_on_behalf_of__c from Payment__c where id = :PayId];
        } catch (Exception e) {}
        return payment;
    }
    
    public Opportunity getOpportunity() {
        Opportunity opportunity = new Opportunity();
        try {
            opportunity = [select Id, Name, AppointmentDate__c, AppointmentBookingDate__c, AppointmentBookingAgentName__c, EmailBrochure__c, Pre_Ex_location_address__c, Pre_Ex_Location__c,
                            ContactLensType__c, DateNoContact__c, PaymentType__c, RecordType.DeveloperName, EmailGoogleMapsAuto__c,
                            Clinic__c, Clinic__r.Name, Clinic__r.BillingStreet, Clinic__r.BillingCity, Clinic__r.BillingCountry, Clinic__r.BillingPostalCode,
                            Clinic__r.ShippingStreet, Clinic__r.ShippingCity, Clinic__r.ShippingCountry, Clinic__r.ShippingPostalCode, 
                            AccountId, Account.LastName, Account.FirstName, Account.Salutation, Account.PersonEmail, Account.BillingStreet, Account.BillingPostalCode, Account.BillingCity,
                            Account.EmailGreeting__c, 
                            Owner.Name, owner.CallAgentImageURL__c, 
                            ClinicProduct__r.ClinicOperationsAppointmentType__c, 
                            AppointmentDateCET__c, AppointmentWeekDay__c, EmailAppointmentTime__c,EmailClinicOperationName__c,EmailClinicOperationMedidatePrice__c,ClinicProduct__r.ClinicOperationSurgeonName__c,
                            (Select Product2.Name, TotalPrice from OpportunityLineItems)
                            from Opportunity 
                            where id in (select Opportunity__c from Payment__c where id = :PayId)];
        } catch (Exception e) {}
        return opportunity;
    }
    
    public void initInvoices() {
        Map<Id, Payment__c> paymentsMap = new Map<Id, Payment__c>((List<Payment__c>)stController.getSelected());
        system.debug(paymentsMap.size());
        this.listOfPayments = [select Id, OpportunityAppointmentDate__c,TransactionStatus__c, Paid_Payment__c,Paid_Payment__r.InvoiceNumberAuto__c,Name, ClinicNameAuto__c, Opportunity__c, PaymentAmount__c, PaymentDate__c, PaymentDueDate__c, LegacyPaymentLink__c,
                                 Customer_Bank_Transfer_ID__c, PaymentLink__c, InvoiceNumberAuto__c, InvoiceDate__c, PaymentVATAmount__c, PaymentNetAmount__c,Invoice_on_behalf_of__c from Payment__c where id IN :paymentsMap.keySet() AND InvoiceNumberAuto__c != null];
        
        listOfOpportunities = new Map<Id, Opportunity>();
        Map<Id, List<Id>> oppPayments = new Map<Id, List<Id>>();
        for(Payment__c payment : listOfPayments) {
            if(!oppPayments.containsKey(payment.Opportunity__c)) {
                oppPayments.put(payment.Opportunity__c, new List<Id>());
            }
            oppPayments.get(payment.Opportunity__c).add(payment.Id);
        }
        for(Opportunity opp: [select Id, Name, AppointmentDate__c, AppointmentBookingDate__c, AppointmentBookingAgentName__c, EmailBrochure__c, Pre_Ex_location_address__c, Pre_Ex_Location__c,
                            ContactLensType__c, DateNoContact__c, PaymentType__c, RecordType.DeveloperName, EmailGoogleMapsAuto__c,
                            Clinic__c, Clinic__r.Name, Clinic__r.BillingStreet, Clinic__r.BillingCity, Clinic__r.BillingCountry, Clinic__r.BillingPostalCode,
                            Clinic__r.ShippingStreet, Clinic__r.ShippingCity, Clinic__r.ShippingCountry, Clinic__r.ShippingPostalCode, 
                            AccountId, Account.LastName, Account.FirstName,Account.Name, Account.Salutation, Account.PersonEmail, Account.BillingStreet, Account.BillingPostalCode, Account.BillingCity,
                            Account.EmailGreeting__c, 
                            Owner.Name, owner.CallAgentImageURL__c, 
                            ClinicProduct__r.ClinicOperationsAppointmentType__c, 
                            AppointmentDateCET__c, AppointmentWeekDay__c,EmailAppointmentTime__c,EmailClinicOperationName__c,EmailClinicOperationMedidatePrice__c,ClinicProduct__r.ClinicOperationSurgeonName__c,
                            (Select Product2.Name, TotalPrice from OpportunityLineItems)
                            from Opportunity 
                            where id in :oppPayments.keySet()]) {
            if(oppPayments.containsKey(opp.Id)) {
                for(Id paymentId :oppPayments.get(opp.Id)) {
                    listOfOpportunities.put(paymentId, opp);
                }
            }
        }
    }
}