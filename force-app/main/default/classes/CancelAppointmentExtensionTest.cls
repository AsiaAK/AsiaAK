@isTest (seeAllData=true)
private class CancelAppointmentExtensionTest {
    static testmethod void ChooseClinicTest() {
        Account customer = TestObjectFactory.getPersonAccount(); insert customer;
        Opportunity opportunity = TestObjectFactory.getOpportunity(customer.Id); insert opportunity;
        System.Test.setMock(HttpCalloutMock.class, new GoogleServiceV3HttpMockup(true));
        ApexPages.StandardController stdController = new ApexPages.StandardController(opportunity);
        System.Test.startTest();
            CancelAppointmentExtension controller = new CancelAppointmentExtension(stdController);
        System.Test.stopTest();
    }
}