@isTest
private class LeadInsertFindDuplicatesTest {
    static final Integer amountOfDuplicates = 4;
    static final String sampleEmail = 'test@test.de';
    static Map<ID, Schema.RecordTypeInfo> recordTypeIds = Lead.getSObjectType().getDescribe().getRecordTypeInfosById();
    static Id recordTypeId = recordTypeIds.values()[0].getRecordTypeId();

    @TestSetup
    static void init() {
        List<Lead> leads = new List<Lead>();
        for (Integer i = 0; i < amountOfDuplicates; i++) {
            Lead newLead = new Lead(LastName = 'Test ' + String.valueOf(i), Email = sampleEmail, RecordTypeId = recordTypeId, Company = 'Test');
            leads.add(newLead);
        }
        insert leads;
    }

    @isTest static void testDuplicates() {
        Lead leadToInsert = new Lead(LastName = 'leadToInsert', Email = sampleEmail, RecordTypeId = recordTypeId, Company = 'Test');
        insert leadToInsert;

		//Test.startTest();
        LeadInsertFindDuplicates.updateDuplicates([
                SELECT id, Name, Email, RecordTypeId, Overwriting_Lead__c
                FROM Lead ORDER BY CreatedDate DESC LIMIT 1
        ]);
        //Test.stopTest();
        List<Lead> lds = [
                SELECT id, Name, Email, RecordTypeId, Overwriting_Lead__c
                FROM Lead
                WHERE Email = :sampleEmail AND RecordTypeId = :recordTypeId AND Overwriting_Lead__c != null
        ];
        
        System.assertEquals(lds.size(), amountOfDuplicates, 'Not all Leads were overwritten');

    }
}