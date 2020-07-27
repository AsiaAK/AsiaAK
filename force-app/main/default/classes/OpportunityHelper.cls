public class OpportunityHelper {
    public static void updateRecordType(List<Opportunity> newList) {
        Map<String, String> rtIdsByDeveloperName = new Map<String, String>();
        for(RecordType rt :[SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Opportunity']) {
            rtIdsByDeveloperName.put(rt.DeveloperName, rt.Id);
        }
        for(Opportunity newRecord :newList) {
            if(String.isNotBlank(newRecord.LeadRecordTypeDeveloperNameAuto__c) && rtIdsByDeveloperName.containsKey(newRecord.LeadRecordTypeDeveloperNameAuto__c)) {
                newRecord.RecordTypeId = rtIdsByDeveloperName.get(newRecord.LeadRecordTypeDeveloperNameAuto__c);
                
            }
        }
    }
}