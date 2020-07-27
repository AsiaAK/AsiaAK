@isTest (seeAllData=true)
private class ChooseClinicExtensionTest {
    static testmethod void ChooseClinicTest() {
        Account customer = TestObjectFactory.getPersonAccount(); insert customer;
        Opportunity opportunity = TestObjectFactory.getOpportunity(customer.Id); insert opportunity;
        Opportunity opportunity1 = TestObjectFactory.getOpportunity(customer.Id); insert opportunity1;
        opportunity1.Test_Opportunity__c =false;
        update opportunity1;
        Account clinic = TestObjectFactory.getBusinessAccount(); insert clinic;
        Product2 product = TestObjectFactory.getProduct(); insert product;
        PriceBookEntry priceBookEntry = TestObjectFactory.getPriceBookEntry(product.Id); insert priceBookEntry;
        ClinicProduct__c cliniProduct = TestObjectFactory.getClinicProduct(product.Id, clinic.Id); insert cliniProduct;
        System.Test.setMock(HttpCalloutMock.class, new GoogleServiceV3HttpMockup(true));
        ApexPages.StandardController stdController = new ApexPages.StandardController(opportunity);
        ApexPages.StandardController stdController1 = new ApexPages.StandardController(opportunity1);
        System.Test.startTest();
            ChooseClinicExtension cce = new ChooseClinicExtension(stdController);
            cce.getClinics();
            ChooseClinicExtension cce1 = new ChooseClinicExtension(stdController1);
            cce1.getClinics();
            
            Apexpages.currentPage().getParameters().put('clinicProductId', cliniProduct.Id);
            Apexpages.currentPage().getParameters().put('EventId', '1234');
            Apexpages.currentPage().getParameters().put('appointmentDate', '2016/01/01/00/00');
            cce.confirmAppointment();
        System.Test.stopTest();
    }
}