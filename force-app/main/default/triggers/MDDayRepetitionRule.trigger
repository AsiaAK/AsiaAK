trigger MDDayRepetitionRule on MDDayRepetitionRule__c (after insert) {
    TriggerFactory.execute(MDDayRepetitionRule__c.sObjectType);
}