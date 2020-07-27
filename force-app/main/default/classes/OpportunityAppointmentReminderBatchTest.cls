@isTest
private class OpportunityAppointmentReminderBatchTest {

    private static testmethod void testBatch() {
        Account accountRecord = TestObjectFactory.getPersonAccount();
        insert accountRecord;
        Opportunity opportunityRecord = TestObjectFactory.getOpportunity(accountRecord.Id);
        insert opportunityRecord;
        System.Test.setMock(HttpCalloutMock.class, new EsendexHttpCalloutMockup(false));
        System.Test.startTest();
            OpportunityAppointmentReminderBatch batchObject = new OpportunityAppointmentReminderBatch();
            batchObject.start(null);
            batchObject.execute(null, new List<sObject>());
            batchObject.finish(null);
        System.Test.stopTest();
    }
}