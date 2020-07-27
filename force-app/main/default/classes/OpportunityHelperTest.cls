@isTest
private class OpportunityHelperTest {
    static testMethod void updateRecordTypeTest() {
        Account accountRecord = TestObjectFactory.getPersonAccount();
        insert accountRecord;
        Opportunity opportunityRecord = TestObjectFactory.getOpportunity(accountRecord.Id);
        opportunityRecord.LeadRecordTypeDeveloperNameAuto__c = 'Teeth';
        opportunityRecord.Category__c = 'Teeth';
        insert opportunityRecord;
        System.Test.startTest();
            OpportunityHelper.updateRecordType(new List<Opportunity>{opportunityRecord});
        System.Test.stopTest();
    }
}