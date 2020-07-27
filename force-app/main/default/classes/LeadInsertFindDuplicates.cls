public class LeadInsertFindDuplicates {
    private static final String leadDuplicateStatus = 'Duplikat';
    @InvocableMethod(label = 'Find Lead Duplicates'
            description = 'Checks if a lead record with pair RecordType-Email is already exist. Id yes, then fills out field Overwriting Lead with new Lead reference')
    public static void updateDuplicates(List<Lead> leads) {
        System.debug('*** updateDuplicates ***');
        Set<String> emails = new Set<String>();

        List<Lead> leadsToUpdate = new List<Lead>();

        
        Set<Id> leadIds = new Set<Id>();
        Map<String, Lead> newLeadsKeys = new Map<String, Lead>();

        Map<String, Account> emailPersonAccountMap = new Map<String, Account>();

        for (Lead newLead : leads) {
            emails.add(newLead.Email);
            leadIds.add(newLead.Id);
            newLeadsKeys.put(setKey(newLead.Email), newLead);
        }

        for (Account acc: [SELECT Id, PersonEmail FROM Account WHERE PersonEmail IN :emails]) {
            emailPersonAccountMap.put(acc.PersonEmail, acc);
        }

        System.debug('emailPersonAccountMap ' + emailPersonAccountMap);

        for (Lead newLead : leads) {
            Account account = emailPersonAccountMap.get(newLead.Email);
            if (account != null) {
                leadsToUpdate.add(new Lead(
                        Id = newLead.Id,
                        Status = LeadInsertFindDuplicates.leadDuplicateStatus,
                        Overwriting_Account__c = account.Id));
            }
        }

        System.debug('newLeadsKeys.size()=' + newLeadsKeys.size());

        if (newLeadsKeys.isEmpty()) {
            System.debug('Leads were not updated');
            return;
        }


        for (Lead oldLead : [
                SELECT Id, Overwriting_Lead__c, Email
                FROM Lead
                WHERE Email in :emails
                AND Id not in:leadIds
        ]) {
            String oldLeadKey = setKey(oldLead.Email);
            Lead newLead = newLeadsKeys.get(oldLeadKey);
            if (newLead != null) {
                Lead leadToUpdate = oldLead;
                leadToUpdate.Overwriting_Lead__c = newLead.Id;
                leadToUpdate.Status = LeadInsertFindDuplicates.leadDuplicateStatus;
                System.debug(' leadToUpdate:Id=' + leadToUpdate.Id + '; Overwriting_Lead__c=' + leadToUpdate.Overwriting_Lead__c);
                leadsToUpdate.add(leadToUpdate);
            }
        }

        System.debug('leadsToUpdate.size()=' + leadsToUpdate.size());
        System.debug('leadsToUpdate=' + leadsToUpdate);

        update leadsToUpdate;
    }

    private static String setKey(String email) {
        return email.toLowerCase();
    }
}