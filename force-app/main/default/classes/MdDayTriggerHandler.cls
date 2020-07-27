/**
 * MdDayTriggerHandler class 1.0.0
 *
 * @description This class represents a MdDayTriggerHandler.
 *
 * @author Nadezhda Podobed
 * @date 19.03.2019
 */
public with sharing class MdDayTriggerHandler implements TriggerHandler {

	public void execute(TriggerOperation operationType,
                        List<sObject> oldSObjectsList, List<sObject> newSObjectsList,
                        Map<Id, sObject> oldSObjectsMap, Map<Id, sObject> newSObjectsMap) {
        switch on operationType {
            when BEFORE_INSERT {
                onBeforeInsert(newSObjectsList);
            }
            when AFTER_INSERT {
                onAfterInsert(newSObjectsList, newSObjectsMap);
            }
        }
	}

	private static void onBeforeInsert(List<sObject> newSObjectsList) {
		List<MD_Day__c> newMdDays = (List<MD_Day__c>) newSObjectsList;
		MdDayTriggerService.checkPreExDaysLocation(newMdDays);

        MdDayTriggerService.checkDuplicatesOnInsert(newMdDays);
	}

	private static void onAfterInsert(List<sObject> newSObjectsList, Map<Id, sObject> newSObjectsMap) {
		List<MD_Day__c> newMdDays = (List<MD_Day__c>) newSObjectsList;
		Map<Id, MD_Day__c> newMdDaysMap = (Map<Id, MD_Day__c>) newSObjectsMap;
		MdDayTriggerService.createAvailabilitiesOnInsert(newMdDays, newMdDaysMap);
	}

}