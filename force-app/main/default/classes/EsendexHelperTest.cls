@isTest
private class EsendexHelperTest {
    static testmethod void executeSuccessTest() {
        Account accountRecord = TestObjectFactory.getPersonAccount();
        insert accountRecord;
        Opportunity opportunityRecord = TestObjectFactory.getOpportunity(accountRecord.Id);
        insert opportunityRecord;
        System.Test.setMock(HttpCalloutMock.class, new EsendexHttpCalloutMockup(false));
        System.Test.startTest();
            EsendexHelper.sObjects = new List<Opportunity>{[SELECT Id, Account.Id,Account.Phone, Account.PersonMobilePhone, Account.LastSmsSentAt__c, Account.LastSMSStatus__c, 
                ReminderSMSTextAuto__c FROM Opportunity WHERE Id = :opportunityRecord.Id]};
            EsendexHelper.execute('message dispatcher');
        System.Test.stopTest();
    }
    
    static testmethod void executeFailMessageDispatcherTest() {
        Account accountRecord = TestObjectFactory.getPersonAccount();
        insert accountRecord;
        Opportunity opportunityRecord = TestObjectFactory.getOpportunity(accountRecord.Id);
        insert opportunityRecord;
        System.Test.setMock(HttpCalloutMock.class, new EsendexHttpCalloutMockup(true));
        System.Test.startTest();
            EsendexHelper.sObjects = new List<Opportunity>{[SELECT Id, Account.Id,Account.Phone, Account.PersonMobilePhone, Account.LastSmsSentAt__c, Account.LastSMSStatus__c, 
                ReminderSMSTextAuto__c FROM Opportunity WHERE Id = :opportunityRecord.Id]};
            EsendexHelper.execute('message dispatcher');
        System.Test.stopTest();
    }
    
    static testmethod void executeFailMessageHeaderTest() {
        Account accountRecord = TestObjectFactory.getPersonAccount();
        insert accountRecord;
        Opportunity opportunityRecord = TestObjectFactory.getOpportunity(accountRecord.Id);
        insert opportunityRecord;
        System.Test.setMock(HttpCalloutMock.class, new EsendexHttpCalloutMockup(true));
        System.Test.startTest();
            EsendexHelper.sObjects = new List<Opportunity>{[SELECT Id, Account.Id,Account.Phone, Account.PersonMobilePhone, Account.LastSmsSentAt__c, Account.LastSMSStatus__c, 
                ReminderSMSTextAuto__c FROM Opportunity WHERE Id = :opportunityRecord.Id]};
            EsendexHelper.headers = new Map<String, EsendexMessageHeader__c>{'test'=>new EsendexMessageHeader__c()};
            EsendexHelper.execute('message header');
        System.Test.stopTest();
    }
}