trigger MdDay on MD_Day__c (before insert, after insert) {
    TriggerFactory.execute(MD_Day__c.sObjectType);
}