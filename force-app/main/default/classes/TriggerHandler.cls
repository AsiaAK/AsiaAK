/**
 * TriggerHandler class 1.0.0
 *
 * @description This class represents a TriggerHandler.
 *
 * @author Nadezhda Podobed
 * @date 19.03.2019
 */
public interface TriggerHandler {

    void execute(TriggerOperation operationType,
                List<sObject> oldSObjectsList, List<sObject> newSObjectsList,
				Map<Id, sObject> oldSObjectsMap, Map<Id, sObject> newSObjectsMap);

}