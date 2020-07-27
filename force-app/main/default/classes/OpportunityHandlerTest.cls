@isTest
private class OpportunityHandlerTest {
    static testMethod void handlerTest() {
        
        list<opportunity> opplist = new list<opportunity>();
        Account customer = TestObjectFactory.getPersonAccount(); insert customer;
        Opportunity opportunity1 = TestObjectFactory.getOpportunity(customer.Id); insert opportunity1;
        Opportunity opportunity2 = TestObjectFactory.getOpportunity(customer.Id); insert opportunity2;
        Opportunity opportunity3 = TestObjectFactory.getOpportunity(customer.Id); insert opportunity3;
        Opportunity opportunity4 = TestObjectFactory.getOpportunity(customer.Id); insert opportunity4;
        System.Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GoogleServiceV3CalloutMock());
        OpportunityHandler handlerObj = new OpportunityHandler();
        handlerObj.beforeInsert(new List<Opportunity>());
        OpportunityHandler.trustpilot(new List<Opportunity>());
        // OpportunityHandler.updateGoogleCalenderEventTitle(opportunity.id);
        System.Test.stopTest();
        opportunity1.stagename='Reserved';
        opportunity2.stagename='Reserved';
        opportunity3.stagename='Reserved';
        opportunity4.stagename='Reserved';
        opportunity1.AppointmentDate__c = Datetime.newInstance(2017, 10, 29, 02, 00, 00);
        opportunity2.AppointmentDate__c = Datetime.newInstance(2018, 03, 25, 02, 00, 00);
        opportunity3.AppointmentDate__c = Datetime.newInstance(2019, 03, 31, 02, 00, 00);
        opportunity4.AppointmentDate__c = Datetime.newInstance(2020, 03, 27, 02, 00, 00);
        opplist.add(opportunity1);
        opplist.add(opportunity2);
        opplist.add(opportunity3);
        opplist.add(opportunity4);
        update opplist;
        
        
    }
}