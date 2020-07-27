trigger OpportunityTrigger on Opportunity(before insert, after insert, before update, after update) {
    
    if(Trigger.isInsert && Trigger.isAfter) {
        OpportunityHandler.afterInsert(Trigger.new);
    }
    if(Trigger.isUpdate && Trigger.isAfter) {
        OpportunityHandler.afterUpdate(Trigger.new,Trigger.oldmap);
    }
    
    
   
}