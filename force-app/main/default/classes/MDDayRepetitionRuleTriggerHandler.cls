/**
 * TriggerHandler class 1.0.0
 *
 * @description This class represents a TriggerHandler.
 *
 * @author Nadezhda Podobed
 * @date 19.03.2019
 */
public with sharing class MDDayRepetitionRuleTriggerHandler implements TriggerHandler {

	public void execute(TriggerOperation operationType,
                        List<sObject> oldSObjectsList, List<sObject> newSObjectsList,
                        Map<Id, sObject> oldSObjectsMap, Map<Id, sObject> newSObjectsMap) {
        switch on operationType {
            when AFTER_INSERT {
                onAfterInsert(newSObjectsList, newSObjectsMap);
            }
        }
	}

	private static void onAfterInsert(List<sObject> newSObjectsList,  Map<Id, sObject> newSObjectsMap) {
		List<MDDayRepetitionRule__c> newMDDayRepetitionRules = (List<MDDayRepetitionRule__c>) newSObjectsList;
		Map<Id, MDDayRepetitionRule__c> newMDDayRepetitionRulesMap = (Map<Id, MDDayRepetitionRule__c>) newSObjectsMap;

		MDDayRepetitionRuleTriggerService.createMdDaysOnInsert(newMDDayRepetitionRules, newMDDayRepetitionRulesMap);
	}
}